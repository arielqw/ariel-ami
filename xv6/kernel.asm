
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 6f 37 10 80       	mov    $0x8010376f,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 a4 84 10 	movl   $0x801084a4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 08 4e 00 00       	call   80104e56 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 70 05 11 80 64 	movl   $0x80110564,0x80110570
80100055:	05 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 74 05 11 80 64 	movl   $0x80110564,0x80110574
8010005f:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 74 05 11 80       	mov    0x80110574,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 74 05 11 80       	mov    %eax,0x80110574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801000bd:	e8 b5 4d 00 00       	call   80104e77 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 74 05 11 80       	mov    0x80110574,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100104:	e8 d0 4d 00 00       	call   80104ed9 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 74 4a 00 00       	call   80104b98 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 70 05 11 80       	mov    0x80110570,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010017c:	e8 58 4d 00 00       	call   80104ed9 <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 ab 84 10 80 	movl   $0x801084ab,(%esp)
8010019f:	e8 99 03 00 00       	call   8010053d <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 e8 25 00 00       	call   801027c0 <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 bc 84 10 80 	movl   $0x801084bc,(%esp)
801001f6:	e8 42 03 00 00       	call   8010053d <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 ab 25 00 00       	call   801027c0 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 c3 84 10 80 	movl   $0x801084c3,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 36 4c 00 00       	call   80104e77 <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 74 05 11 80       	mov    0x80110574,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 74 05 11 80       	mov    %eax,0x80110574

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 cf 49 00 00       	call   80104c71 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 2b 4c 00 00       	call   80104ed9 <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801002c2:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c6:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801002ca:	ec                   	in     (%dx),%al
801002cb:	89 c3                	mov    %eax,%ebx
801002cd:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002d0:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801002d4:	83 c4 14             	add    $0x14,%esp
801002d7:	5b                   	pop    %ebx
801002d8:	5d                   	pop    %ebp
801002d9:	c3                   	ret    

801002da <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002da:	55                   	push   %ebp
801002db:	89 e5                	mov    %esp,%ebp
801002dd:	83 ec 08             	sub    $0x8,%esp
801002e0:	8b 55 08             	mov    0x8(%ebp),%edx
801002e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801002e6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002ea:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002ed:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002f1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002f5:	ee                   	out    %al,(%dx)
}
801002f6:	c9                   	leave  
801002f7:	c3                   	ret    

801002f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f8:	55                   	push   %ebp
801002f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002fb:	fa                   	cli    
}
801002fc:	5d                   	pop    %ebp
801002fd:	c3                   	ret    

801002fe <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fe:	55                   	push   %ebp
801002ff:	89 e5                	mov    %esp,%ebp
80100301:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100304:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100308:	74 19                	je     80100323 <printint+0x25>
8010030a:	8b 45 08             	mov    0x8(%ebp),%eax
8010030d:	c1 e8 1f             	shr    $0x1f,%eax
80100310:	89 45 10             	mov    %eax,0x10(%ebp)
80100313:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100317:	74 0a                	je     80100323 <printint+0x25>
    x = -xx;
80100319:	8b 45 08             	mov    0x8(%ebp),%eax
8010031c:	f7 d8                	neg    %eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100321:	eb 06                	jmp    80100329 <printint+0x2b>
  else
    x = xx;
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100329:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100336:	ba 00 00 00 00       	mov    $0x0,%edx
8010033b:	f7 f1                	div    %ecx
8010033d:	89 d0                	mov    %edx,%eax
8010033f:	0f b6 90 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%edx
80100346:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100349:	03 45 f4             	add    -0xc(%ebp),%eax
8010034c:	88 10                	mov    %dl,(%eax)
8010034e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }while((x /= base) != 0);
80100352:	8b 55 0c             	mov    0xc(%ebp),%edx
80100355:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 75 d4             	divl   -0x2c(%ebp)
80100363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010036a:	75 c4                	jne    80100330 <printint+0x32>

  if(sign)
8010036c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100370:	74 23                	je     80100395 <printint+0x97>
    buf[i++] = '-';
80100372:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100375:	03 45 f4             	add    -0xc(%ebp),%eax
80100378:	c6 00 2d             	movb   $0x2d,(%eax)
8010037b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 14                	jmp    80100395 <printint+0x97>
    consputc(buf[i]);
80100381:	8d 45 e0             	lea    -0x20(%ebp),%eax
80100384:	03 45 f4             	add    -0xc(%ebp),%eax
80100387:	0f b6 00             	movzbl (%eax),%eax
8010038a:	0f be c0             	movsbl %al,%eax
8010038d:	89 04 24             	mov    %eax,(%esp)
80100390:	e8 bb 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100395:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x83>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801003bc:	e8 b6 4a 00 00       	call   80104e77 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 ca 84 10 80 	movl   $0x801084ca,(%esp)
801003cf:	e8 69 01 00 00       	call   8010053d <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 20 01 00 00       	jmp    80100506 <cprintf+0x165>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 59 03 00 00       	call   80100750 <consputc>
      continue;
801003f7:	e9 06 01 00 00       	jmp    80100502 <cprintf+0x161>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100406:	01 d0                	add    %edx,%eax
80100408:	0f b6 00             	movzbl (%eax),%eax
8010040b:	0f be c0             	movsbl %al,%eax
8010040e:	25 ff 00 00 00       	and    $0xff,%eax
80100413:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100416:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010041a:	0f 84 08 01 00 00    	je     80100528 <cprintf+0x187>
      break;
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4d                	je     80100475 <cprintf+0xd4>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0x9f>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13b>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xae>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x149>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 53                	je     80100498 <cprintf+0xf7>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2b                	je     80100475 <cprintf+0xd4>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x149>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8b 00                	mov    (%eax),%eax
80100454:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100458:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045f:	00 
80100460:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100467:	00 
80100468:	89 04 24             	mov    %eax,(%esp)
8010046b:	e8 8e fe ff ff       	call   801002fe <printint>
      break;
80100470:	e9 8d 00 00 00       	jmp    80100502 <cprintf+0x161>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100478:	8b 00                	mov    (%eax),%eax
8010047a:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100485:	00 
80100486:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048d:	00 
8010048e:	89 04 24             	mov    %eax,(%esp)
80100491:	e8 68 fe ff ff       	call   801002fe <printint>
      break;
80100496:	eb 6a                	jmp    80100502 <cprintf+0x161>
    case 's':
      if((s = (char*)*argp++) == 0)
80100498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049b:	8b 00                	mov    (%eax),%eax
8010049d:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004a0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a4:	0f 94 c0             	sete   %al
801004a7:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004ab:	84 c0                	test   %al,%al
801004ad:	74 20                	je     801004cf <cprintf+0x12e>
        s = "(null)";
801004af:	c7 45 ec d3 84 10 80 	movl   $0x801084d3,-0x14(%ebp)
      for(; *s; s++)
801004b6:	eb 17                	jmp    801004cf <cprintf+0x12e>
        consputc(*s);
801004b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004bb:	0f b6 00             	movzbl (%eax),%eax
801004be:	0f be c0             	movsbl %al,%eax
801004c1:	89 04 24             	mov    %eax,(%esp)
801004c4:	e8 87 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c9:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004cd:	eb 01                	jmp    801004d0 <cprintf+0x12f>
801004cf:	90                   	nop
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 de                	jne    801004b8 <cprintf+0x117>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x161>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x161>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 c0 fe ff ff    	jne    801003e6 <cprintf+0x45>
80100526:	eb 01                	jmp    80100529 <cprintf+0x188>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100528:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100529:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052d:	74 0c                	je     8010053b <cprintf+0x19a>
    release(&cons.lock);
8010052f:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100536:	e8 9e 49 00 00       	call   80104ed9 <release>
}
8010053b:	c9                   	leave  
8010053c:	c3                   	ret    

8010053d <panic>:

void
panic(char *s)
{
8010053d:	55                   	push   %ebp
8010053e:	89 e5                	mov    %esp,%ebp
80100540:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100543:	e8 b0 fd ff ff       	call   801002f8 <cli>
  cons.locking = 0;
80100548:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 da 84 10 80 	movl   $0x801084da,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 e9 84 10 80 	movl   $0x801084e9,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 91 49 00 00       	call   80104f28 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 eb 84 10 80 	movl   $0x801084eb,(%esp)
801005b2:	e8 ea fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005bb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bf:	7e df                	jle    801005a0 <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005c1:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005c8:	00 00 00 
  for(;;)
    ;
801005cb:	eb fe                	jmp    801005cb <panic+0x8e>

801005cd <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005cd:	55                   	push   %ebp
801005ce:	89 e5                	mov    %esp,%ebp
801005d0:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d3:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005da:	00 
801005db:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005e2:	e8 f3 fc ff ff       	call   801002da <outb>
  pos = inb(CRTPORT+1) << 8;
801005e7:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005ee:	e8 bd fc ff ff       	call   801002b0 <inb>
801005f3:	0f b6 c0             	movzbl %al,%eax
801005f6:	c1 e0 08             	shl    $0x8,%eax
801005f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005fc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100603:	00 
80100604:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010060b:	e8 ca fc ff ff       	call   801002da <outb>
  pos |= inb(CRTPORT+1);
80100610:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100617:	e8 94 fc ff ff       	call   801002b0 <inb>
8010061c:	0f b6 c0             	movzbl %al,%eax
8010061f:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100622:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100626:	75 30                	jne    80100658 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010062b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100630:	89 c8                	mov    %ecx,%eax
80100632:	f7 ea                	imul   %edx
80100634:	c1 fa 05             	sar    $0x5,%edx
80100637:	89 c8                	mov    %ecx,%eax
80100639:	c1 f8 1f             	sar    $0x1f,%eax
8010063c:	29 c2                	sub    %eax,%edx
8010063e:	89 d0                	mov    %edx,%eax
80100640:	c1 e0 02             	shl    $0x2,%eax
80100643:	01 d0                	add    %edx,%eax
80100645:	c1 e0 04             	shl    $0x4,%eax
80100648:	89 ca                	mov    %ecx,%edx
8010064a:	29 c2                	sub    %eax,%edx
8010064c:	b8 50 00 00 00       	mov    $0x50,%eax
80100651:	29 d0                	sub    %edx,%eax
80100653:	01 45 f4             	add    %eax,-0xc(%ebp)
80100656:	eb 32                	jmp    8010068a <cgaputc+0xbd>
  else if(c == BACKSPACE){
80100658:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065f:	75 0c                	jne    8010066d <cgaputc+0xa0>
    if(pos > 0) --pos;
80100661:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100665:	7e 23                	jle    8010068a <cgaputc+0xbd>
80100667:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
8010066b:	eb 1d                	jmp    8010068a <cgaputc+0xbd>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100672:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100675:	01 d2                	add    %edx,%edx
80100677:	01 c2                	add    %eax,%edx
80100679:	8b 45 08             	mov    0x8(%ebp),%eax
8010067c:	66 25 ff 00          	and    $0xff,%ax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)
80100686:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x119>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 90 10 80       	mov    0x80109000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 90 10 80       	mov    0x80109000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 e2 4a 00 00       	call   80105199 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	01 c0                	add    %eax,%eax
801006c5:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 ca                	add    %ecx,%edx
801006d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 14 24             	mov    %edx,(%esp)
801006e1:	e8 e0 49 00 00       	call   801050c6 <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 e0 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 c7 fb ff ff       	call   801002da <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 b3 fb ff ff       	call   801002da <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 9d fb ff ff       	call   801002da <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 94 fb ff ff       	call   801002f8 <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 7a 63 00 00       	call   80106af5 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 6e 63 00 00       	call   80106af5 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 62 63 00 00       	call   80106af5 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 55 63 00 00       	call   80106af5 <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 22 fe ff ff       	call   801005cd <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
801007ba:	e8 b8 46 00 00       	call   80104e77 <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 41 01 00 00       	jmp    80100905 <consoleintr+0x158>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 68                	je     8010083e <consoleintr+0x91>
801007d6:	e9 94 00 00 00       	jmp    8010086f <consoleintr+0xc2>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 59                	je     8010083e <consoleintr+0x91>
801007e5:	e9 85 00 00 00       	jmp    8010086f <consoleintr+0xc2>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 25 45 00 00       	call   80104d14 <procdump>
      break;
801007ef:	e9 11 01 00 00       	jmp    80100905 <consoleintr+0x158>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
80100816:	a1 38 08 11 80       	mov    0x80110838,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	0f 84 db 00 00 00    	je     801008fe <consoleintr+0x151>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100823:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100828:	83 e8 01             	sub    $0x1,%eax
8010082b:	83 e0 7f             	and    $0x7f,%eax
8010082e:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100835:	3c 0a                	cmp    $0xa,%al
80100837:	75 bb                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100839:	e9 c0 00 00 00       	jmp    801008fe <consoleintr+0x151>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083e:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
80100844:	a1 38 08 11 80       	mov    0x80110838,%eax
80100849:	39 c2                	cmp    %eax,%edx
8010084b:	0f 84 b0 00 00 00    	je     80100901 <consoleintr+0x154>
        input.e--;
80100851:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100856:	83 e8 01             	sub    $0x1,%eax
80100859:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
8010085e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100865:	e8 e6 fe ff ff       	call   80100750 <consputc>
      }
      break;
8010086a:	e9 92 00 00 00       	jmp    80100901 <consoleintr+0x154>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100873:	0f 84 8b 00 00 00    	je     80100904 <consoleintr+0x157>
80100879:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
8010087f:	a1 34 08 11 80       	mov    0x80110834,%eax
80100884:	89 d1                	mov    %edx,%ecx
80100886:	29 c1                	sub    %eax,%ecx
80100888:	89 c8                	mov    %ecx,%eax
8010088a:	83 f8 7f             	cmp    $0x7f,%eax
8010088d:	77 75                	ja     80100904 <consoleintr+0x157>
        c = (c == '\r') ? '\n' : c;
8010088f:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
80100893:	74 05                	je     8010089a <consoleintr+0xed>
80100895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100898:	eb 05                	jmp    8010089f <consoleintr+0xf2>
8010089a:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008a2:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008a7:	89 c1                	mov    %eax,%ecx
801008a9:	83 e1 7f             	and    $0x7f,%ecx
801008ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008af:	88 91 b4 07 11 80    	mov    %dl,-0x7feef84c(%ecx)
801008b5:	83 c0 01             	add    $0x1,%eax
801008b8:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(c);
801008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008c0:	89 04 24             	mov    %eax,(%esp)
801008c3:	e8 88 fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c8:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008cc:	74 18                	je     801008e6 <consoleintr+0x139>
801008ce:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008d2:	74 12                	je     801008e6 <consoleintr+0x139>
801008d4:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008d9:	8b 15 34 08 11 80    	mov    0x80110834,%edx
801008df:	83 ea 80             	sub    $0xffffff80,%edx
801008e2:	39 d0                	cmp    %edx,%eax
801008e4:	75 1e                	jne    80100904 <consoleintr+0x157>
          input.w = input.e;
801008e6:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008eb:	a3 38 08 11 80       	mov    %eax,0x80110838
          wakeup(&input.r);
801008f0:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
801008f7:	e8 75 43 00 00       	call   80104c71 <wakeup>
        }
      }
      break;
801008fc:	eb 06                	jmp    80100904 <consoleintr+0x157>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008fe:	90                   	nop
801008ff:	eb 04                	jmp    80100905 <consoleintr+0x158>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100901:	90                   	nop
80100902:	eb 01                	jmp    80100905 <consoleintr+0x158>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
80100904:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
80100905:	8b 45 08             	mov    0x8(%ebp),%eax
80100908:	ff d0                	call   *%eax
8010090a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010090d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100911:	0f 89 ad fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
80100917:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
8010091e:	e8 b6 45 00 00       	call   80104ed9 <release>
}
80100923:	c9                   	leave  
80100924:	c3                   	ret    

80100925 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100925:	55                   	push   %ebp
80100926:	89 e5                	mov    %esp,%ebp
80100928:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
8010092b:	8b 45 08             	mov    0x8(%ebp),%eax
8010092e:	89 04 24             	mov    %eax,(%esp)
80100931:	e8 8c 10 00 00       	call   801019c2 <iunlock>
  target = n;
80100936:	8b 45 10             	mov    0x10(%ebp),%eax
80100939:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010093c:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100943:	e8 2f 45 00 00       	call   80104e77 <acquire>
  while(n > 0){
80100948:	e9 a8 00 00 00       	jmp    801009f5 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010094d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100953:	8b 40 24             	mov    0x24(%eax),%eax
80100956:	85 c0                	test   %eax,%eax
80100958:	74 21                	je     8010097b <consoleread+0x56>
        release(&input.lock);
8010095a:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100961:	e8 73 45 00 00       	call   80104ed9 <release>
        ilock(ip);
80100966:	8b 45 08             	mov    0x8(%ebp),%eax
80100969:	89 04 24             	mov    %eax,(%esp)
8010096c:	e8 03 0f 00 00       	call   80101874 <ilock>
        return -1;
80100971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100976:	e9 a9 00 00 00       	jmp    80100a24 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010097b:	c7 44 24 04 80 07 11 	movl   $0x80110780,0x4(%esp)
80100982:	80 
80100983:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
8010098a:	e8 09 42 00 00       	call   80104b98 <sleep>
8010098f:	eb 01                	jmp    80100992 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100991:	90                   	nop
80100992:	8b 15 34 08 11 80    	mov    0x80110834,%edx
80100998:	a1 38 08 11 80       	mov    0x80110838,%eax
8010099d:	39 c2                	cmp    %eax,%edx
8010099f:	74 ac                	je     8010094d <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009a1:	a1 34 08 11 80       	mov    0x80110834,%eax
801009a6:	89 c2                	mov    %eax,%edx
801009a8:	83 e2 7f             	and    $0x7f,%edx
801009ab:	0f b6 92 b4 07 11 80 	movzbl -0x7feef84c(%edx),%edx
801009b2:	0f be d2             	movsbl %dl,%edx
801009b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801009b8:	83 c0 01             	add    $0x1,%eax
801009bb:	a3 34 08 11 80       	mov    %eax,0x80110834
    if(c == C('D')){  // EOF
801009c0:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009c4:	75 17                	jne    801009dd <consoleread+0xb8>
      if(n < target){
801009c6:	8b 45 10             	mov    0x10(%ebp),%eax
801009c9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009cc:	73 2f                	jae    801009fd <consoleread+0xd8>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009ce:	a1 34 08 11 80       	mov    0x80110834,%eax
801009d3:	83 e8 01             	sub    $0x1,%eax
801009d6:	a3 34 08 11 80       	mov    %eax,0x80110834
      }
      break;
801009db:	eb 20                	jmp    801009fd <consoleread+0xd8>
    }
    *dst++ = c;
801009dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009e0:	89 c2                	mov    %eax,%edx
801009e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801009e5:	88 10                	mov    %dl,(%eax)
801009e7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
    --n;
801009eb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009ef:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009f3:	74 0b                	je     80100a00 <consoleread+0xdb>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f9:	7f 96                	jg     80100991 <consoleread+0x6c>
801009fb:	eb 04                	jmp    80100a01 <consoleread+0xdc>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
801009fd:	90                   	nop
801009fe:	eb 01                	jmp    80100a01 <consoleread+0xdc>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a00:	90                   	nop
  }
  release(&input.lock);
80100a01:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100a08:	e8 cc 44 00 00       	call   80104ed9 <release>
  ilock(ip);
80100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a10:	89 04 24             	mov    %eax,(%esp)
80100a13:	e8 5c 0e 00 00       	call   80101874 <ilock>

  return target - n;
80100a18:	8b 45 10             	mov    0x10(%ebp),%eax
80100a1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a1e:	89 d1                	mov    %edx,%ecx
80100a20:	29 c1                	sub    %eax,%ecx
80100a22:	89 c8                	mov    %ecx,%eax
}
80100a24:	c9                   	leave  
80100a25:	c3                   	ret    

80100a26 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a26:	55                   	push   %ebp
80100a27:	89 e5                	mov    %esp,%ebp
80100a29:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80100a2f:	89 04 24             	mov    %eax,(%esp)
80100a32:	e8 8b 0f 00 00       	call   801019c2 <iunlock>
  acquire(&cons.lock);
80100a37:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a3e:	e8 34 44 00 00       	call   80104e77 <acquire>
  for(i = 0; i < n; i++)
80100a43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a4a:	eb 1d                	jmp    80100a69 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a4f:	03 45 0c             	add    0xc(%ebp),%eax
80100a52:	0f b6 00             	movzbl (%eax),%eax
80100a55:	0f be c0             	movsbl %al,%eax
80100a58:	25 ff 00 00 00       	and    $0xff,%eax
80100a5d:	89 04 24             	mov    %eax,(%esp)
80100a60:	e8 eb fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a6c:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a6f:	7c db                	jl     80100a4c <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a71:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a78:	e8 5c 44 00 00       	call   80104ed9 <release>
  ilock(ip);
80100a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 ec 0d 00 00       	call   80101874 <ilock>

  return n;
80100a88:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a8b:	c9                   	leave  
80100a8c:	c3                   	ret    

80100a8d <consoleinit>:

void
consoleinit(void)
{
80100a8d:	55                   	push   %ebp
80100a8e:	89 e5                	mov    %esp,%ebp
80100a90:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a93:	c7 44 24 04 ef 84 10 	movl   $0x801084ef,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100aa2:	e8 af 43 00 00       	call   80104e56 <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 f7 84 10 	movl   $0x801084f7,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100ab6:	e8 9b 43 00 00       	call   80104e56 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100abb:	c7 05 ec 11 11 80 26 	movl   $0x80100a26,0x801111ec
80100ac2:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ac5:	c7 05 e8 11 11 80 25 	movl   $0x80100925,0x801111e8
80100acc:	09 10 80 
  cons.locking = 1;
80100acf:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100ad6:	00 00 00 

  picenable(IRQ_KBD);
80100ad9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae0:	e8 34 33 00 00       	call   80103e19 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100aec:	00 
80100aed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af4:	e8 89 1e 00 00       	call   80102982 <ioapicenable>
}
80100af9:	c9                   	leave  
80100afa:	c3                   	ret    
	...

80100afc <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100afc:	55                   	push   %ebp
80100afd:	89 e5                	mov    %esp,%ebp
80100aff:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b05:	e8 57 29 00 00       	call   80103461 <begin_op>
  if((ip = namei(path)) == 0){
80100b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80100b0d:	89 04 24             	mov    %eax,(%esp)
80100b10:	e8 01 19 00 00       	call   80102416 <namei>
80100b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b18:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b1c:	75 0f                	jne    80100b2d <exec+0x31>
    end_op();
80100b1e:	e8 bf 29 00 00       	call   801034e2 <end_op>
    return -1;
80100b23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b28:	e9 dd 03 00 00       	jmp    80100f0a <exec+0x40e>
  }
  ilock(ip);
80100b2d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b30:	89 04 24             	mov    %eax,(%esp)
80100b33:	e8 3c 0d 00 00       	call   80101874 <ilock>
  pgdir = 0;
80100b38:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b3f:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b46:	00 
80100b47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b4e:	00 
80100b4f:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b55:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b59:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b5c:	89 04 24             	mov    %eax,(%esp)
80100b5f:	e8 06 12 00 00       	call   80101d6a <readi>
80100b64:	83 f8 33             	cmp    $0x33,%eax
80100b67:	0f 86 52 03 00 00    	jbe    80100ebf <exec+0x3c3>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b6d:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b73:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b78:	0f 85 44 03 00 00    	jne    80100ec2 <exec+0x3c6>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100b7e:	e8 b6 70 00 00       	call   80107c39 <setupkvm>
80100b83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b86:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b8a:	0f 84 35 03 00 00    	je     80100ec5 <exec+0x3c9>
    goto bad;

  // Load program into memory.
  sz = 0;
80100b90:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b97:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b9e:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100ba4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ba7:	e9 c5 00 00 00       	jmp    80100c71 <exec+0x175>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100baf:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bb6:	00 
80100bb7:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bbb:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bc5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bc8:	89 04 24             	mov    %eax,(%esp)
80100bcb:	e8 9a 11 00 00       	call   80101d6a <readi>
80100bd0:	83 f8 20             	cmp    $0x20,%eax
80100bd3:	0f 85 ef 02 00 00    	jne    80100ec8 <exec+0x3cc>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100bd9:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bdf:	83 f8 01             	cmp    $0x1,%eax
80100be2:	75 7f                	jne    80100c63 <exec+0x167>
      continue;
    if(ph.memsz < ph.filesz)
80100be4:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100bea:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bf0:	39 c2                	cmp    %eax,%edx
80100bf2:	0f 82 d3 02 00 00    	jb     80100ecb <exec+0x3cf>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf8:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bfe:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c04:	01 d0                	add    %edx,%eax
80100c06:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c14:	89 04 24             	mov    %eax,(%esp)
80100c17:	e8 ef 73 00 00       	call   8010800b <allocuvm>
80100c1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c23:	0f 84 a5 02 00 00    	je     80100ece <exec+0x3d2>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c29:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c2f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c35:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c3b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c43:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c46:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c51:	89 04 24             	mov    %eax,(%esp)
80100c54:	e8 c3 72 00 00       	call   80107f1c <loaduvm>
80100c59:	85 c0                	test   %eax,%eax
80100c5b:	0f 88 70 02 00 00    	js     80100ed1 <exec+0x3d5>
80100c61:	eb 01                	jmp    80100c64 <exec+0x168>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c63:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c64:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c68:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c6b:	83 c0 20             	add    $0x20,%eax
80100c6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c71:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c78:	0f b7 c0             	movzwl %ax,%eax
80100c7b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c7e:	0f 8f 28 ff ff ff    	jg     80100bac <exec+0xb0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c84:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c87:	89 04 24             	mov    %eax,(%esp)
80100c8a:	e8 69 0e 00 00       	call   80101af8 <iunlockput>
  end_op();
80100c8f:	e8 4e 28 00 00       	call   801034e2 <end_op>
  ip = 0;
80100c94:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100ca3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ca8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cab:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cae:	05 00 20 00 00       	add    $0x2000,%eax
80100cb3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cb7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cba:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cbe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cc1:	89 04 24             	mov    %eax,(%esp)
80100cc4:	e8 42 73 00 00       	call   8010800b <allocuvm>
80100cc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ccc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cd0:	0f 84 fe 01 00 00    	je     80100ed4 <exec+0x3d8>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cd6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd9:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cde:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ce2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ce5:	89 04 24             	mov    %eax,(%esp)
80100ce8:	e8 42 75 00 00       	call   8010822f <clearpteu>
  sp = sz;
80100ced:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf0:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100cf3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cfa:	e9 81 00 00 00       	jmp    80100d80 <exec+0x284>
    if(argc >= MAXARG)
80100cff:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d03:	0f 87 ce 01 00 00    	ja     80100ed7 <exec+0x3db>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d0c:	c1 e0 02             	shl    $0x2,%eax
80100d0f:	03 45 0c             	add    0xc(%ebp),%eax
80100d12:	8b 00                	mov    (%eax),%eax
80100d14:	89 04 24             	mov    %eax,(%esp)
80100d17:	e8 28 46 00 00       	call   80105344 <strlen>
80100d1c:	f7 d0                	not    %eax
80100d1e:	03 45 dc             	add    -0x24(%ebp),%eax
80100d21:	83 e0 fc             	and    $0xfffffffc,%eax
80100d24:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d2a:	c1 e0 02             	shl    $0x2,%eax
80100d2d:	03 45 0c             	add    0xc(%ebp),%eax
80100d30:	8b 00                	mov    (%eax),%eax
80100d32:	89 04 24             	mov    %eax,(%esp)
80100d35:	e8 0a 46 00 00       	call   80105344 <strlen>
80100d3a:	83 c0 01             	add    $0x1,%eax
80100d3d:	89 c2                	mov    %eax,%edx
80100d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d42:	c1 e0 02             	shl    $0x2,%eax
80100d45:	03 45 0c             	add    0xc(%ebp),%eax
80100d48:	8b 00                	mov    (%eax),%eax
80100d4a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d4e:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d52:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d55:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d59:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d5c:	89 04 24             	mov    %eax,(%esp)
80100d5f:	e8 90 76 00 00       	call   801083f4 <copyout>
80100d64:	85 c0                	test   %eax,%eax
80100d66:	0f 88 6e 01 00 00    	js     80100eda <exec+0x3de>
      goto bad;
    ustack[3+argc] = sp;
80100d6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6f:	8d 50 03             	lea    0x3(%eax),%edx
80100d72:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d75:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d7c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d83:	c1 e0 02             	shl    $0x2,%eax
80100d86:	03 45 0c             	add    0xc(%ebp),%eax
80100d89:	8b 00                	mov    (%eax),%eax
80100d8b:	85 c0                	test   %eax,%eax
80100d8d:	0f 85 6c ff ff ff    	jne    80100cff <exec+0x203>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100d93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d96:	83 c0 03             	add    $0x3,%eax
80100d99:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100da0:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100da4:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dab:	ff ff ff 
  ustack[1] = argc;
80100dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db1:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dba:	83 c0 01             	add    $0x1,%eax
80100dbd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc7:	29 d0                	sub    %edx,%eax
80100dc9:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100dcf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd2:	83 c0 04             	add    $0x4,%eax
80100dd5:	c1 e0 02             	shl    $0x2,%eax
80100dd8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ddb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dde:	83 c0 04             	add    $0x4,%eax
80100de1:	c1 e0 02             	shl    $0x2,%eax
80100de4:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100de8:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100dee:	89 44 24 08          	mov    %eax,0x8(%esp)
80100df2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100df5:	89 44 24 04          	mov    %eax,0x4(%esp)
80100df9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dfc:	89 04 24             	mov    %eax,(%esp)
80100dff:	e8 f0 75 00 00       	call   801083f4 <copyout>
80100e04:	85 c0                	test   %eax,%eax
80100e06:	0f 88 d1 00 00 00    	js     80100edd <exec+0x3e1>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80100e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e15:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e18:	eb 17                	jmp    80100e31 <exec+0x335>
    if(*s == '/')
80100e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e1d:	0f b6 00             	movzbl (%eax),%eax
80100e20:	3c 2f                	cmp    $0x2f,%al
80100e22:	75 09                	jne    80100e2d <exec+0x331>
      last = s+1;
80100e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e27:	83 c0 01             	add    $0x1,%eax
80100e2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e2d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e34:	0f b6 00             	movzbl (%eax),%eax
80100e37:	84 c0                	test   %al,%al
80100e39:	75 df                	jne    80100e1a <exec+0x31e>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e41:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e44:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e4b:	00 
80100e4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e4f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e53:	89 14 24             	mov    %edx,(%esp)
80100e56:	e8 9b 44 00 00       	call   801052f6 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e5b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e61:	8b 40 04             	mov    0x4(%eax),%eax
80100e64:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e6d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e70:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e79:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e7c:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e84:	8b 40 18             	mov    0x18(%eax),%eax
80100e87:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100e8d:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e96:	8b 40 18             	mov    0x18(%eax),%eax
80100e99:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100e9c:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100e9f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea5:	89 04 24             	mov    %eax,(%esp)
80100ea8:	e8 7d 6e 00 00       	call   80107d2a <switchuvm>
  freevm(oldpgdir);
80100ead:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eb0:	89 04 24             	mov    %eax,(%esp)
80100eb3:	e8 e9 72 00 00       	call   801081a1 <freevm>
  return 0;
80100eb8:	b8 00 00 00 00       	mov    $0x0,%eax
80100ebd:	eb 4b                	jmp    80100f0a <exec+0x40e>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100ebf:	90                   	nop
80100ec0:	eb 1c                	jmp    80100ede <exec+0x3e2>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100ec2:	90                   	nop
80100ec3:	eb 19                	jmp    80100ede <exec+0x3e2>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100ec5:	90                   	nop
80100ec6:	eb 16                	jmp    80100ede <exec+0x3e2>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100ec8:	90                   	nop
80100ec9:	eb 13                	jmp    80100ede <exec+0x3e2>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100ecb:	90                   	nop
80100ecc:	eb 10                	jmp    80100ede <exec+0x3e2>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100ece:	90                   	nop
80100ecf:	eb 0d                	jmp    80100ede <exec+0x3e2>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100ed1:	90                   	nop
80100ed2:	eb 0a                	jmp    80100ede <exec+0x3e2>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100ed4:	90                   	nop
80100ed5:	eb 07                	jmp    80100ede <exec+0x3e2>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100ed7:	90                   	nop
80100ed8:	eb 04                	jmp    80100ede <exec+0x3e2>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100eda:	90                   	nop
80100edb:	eb 01                	jmp    80100ede <exec+0x3e2>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100edd:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100ede:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ee2:	74 0b                	je     80100eef <exec+0x3f3>
    freevm(pgdir);
80100ee4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ee7:	89 04 24             	mov    %eax,(%esp)
80100eea:	e8 b2 72 00 00       	call   801081a1 <freevm>
  if(ip){
80100eef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ef3:	74 10                	je     80100f05 <exec+0x409>
    iunlockput(ip);
80100ef5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ef8:	89 04 24             	mov    %eax,(%esp)
80100efb:	e8 f8 0b 00 00       	call   80101af8 <iunlockput>
    end_op();
80100f00:	e8 dd 25 00 00       	call   801034e2 <end_op>
  }
  return -1;
80100f05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f0a:	c9                   	leave  
80100f0b:	c3                   	ret    

80100f0c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f0c:	55                   	push   %ebp
80100f0d:	89 e5                	mov    %esp,%ebp
80100f0f:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f12:	c7 44 24 04 fd 84 10 	movl   $0x801084fd,0x4(%esp)
80100f19:	80 
80100f1a:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f21:	e8 30 3f 00 00       	call   80104e56 <initlock>
}
80100f26:	c9                   	leave  
80100f27:	c3                   	ret    

80100f28 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f28:	55                   	push   %ebp
80100f29:	89 e5                	mov    %esp,%ebp
80100f2b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f2e:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f35:	e8 3d 3f 00 00       	call   80104e77 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f3a:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100f41:	eb 29                	jmp    80100f6c <filealloc+0x44>
    if(f->ref == 0){
80100f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f46:	8b 40 04             	mov    0x4(%eax),%eax
80100f49:	85 c0                	test   %eax,%eax
80100f4b:	75 1b                	jne    80100f68 <filealloc+0x40>
      f->ref = 1;
80100f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f50:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f57:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f5e:	e8 76 3f 00 00       	call   80104ed9 <release>
      return f;
80100f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f66:	eb 1e                	jmp    80100f86 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f68:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f6c:	81 7d f4 d4 11 11 80 	cmpl   $0x801111d4,-0xc(%ebp)
80100f73:	72 ce                	jb     80100f43 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f75:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f7c:	e8 58 3f 00 00       	call   80104ed9 <release>
  return 0;
80100f81:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f86:	c9                   	leave  
80100f87:	c3                   	ret    

80100f88 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f88:	55                   	push   %ebp
80100f89:	89 e5                	mov    %esp,%ebp
80100f8b:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f8e:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f95:	e8 dd 3e 00 00       	call   80104e77 <acquire>
  if(f->ref < 1)
80100f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9d:	8b 40 04             	mov    0x4(%eax),%eax
80100fa0:	85 c0                	test   %eax,%eax
80100fa2:	7f 0c                	jg     80100fb0 <filedup+0x28>
    panic("filedup");
80100fa4:	c7 04 24 04 85 10 80 	movl   $0x80108504,(%esp)
80100fab:	e8 8d f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb3:	8b 40 04             	mov    0x4(%eax),%eax
80100fb6:	8d 50 01             	lea    0x1(%eax),%edx
80100fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fbc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbf:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fc6:	e8 0e 3f 00 00       	call   80104ed9 <release>
  return f;
80100fcb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fce:	c9                   	leave  
80100fcf:	c3                   	ret    

80100fd0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fd0:	55                   	push   %ebp
80100fd1:	89 e5                	mov    %esp,%ebp
80100fd3:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fd6:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fdd:	e8 95 3e 00 00       	call   80104e77 <acquire>
  if(f->ref < 1)
80100fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe5:	8b 40 04             	mov    0x4(%eax),%eax
80100fe8:	85 c0                	test   %eax,%eax
80100fea:	7f 0c                	jg     80100ff8 <fileclose+0x28>
    panic("fileclose");
80100fec:	c7 04 24 0c 85 10 80 	movl   $0x8010850c,(%esp)
80100ff3:	e8 45 f5 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80100ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffb:	8b 40 04             	mov    0x4(%eax),%eax
80100ffe:	8d 50 ff             	lea    -0x1(%eax),%edx
80101001:	8b 45 08             	mov    0x8(%ebp),%eax
80101004:	89 50 04             	mov    %edx,0x4(%eax)
80101007:	8b 45 08             	mov    0x8(%ebp),%eax
8010100a:	8b 40 04             	mov    0x4(%eax),%eax
8010100d:	85 c0                	test   %eax,%eax
8010100f:	7e 11                	jle    80101022 <fileclose+0x52>
    release(&ftable.lock);
80101011:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101018:	e8 bc 3e 00 00       	call   80104ed9 <release>
    return;
8010101d:	e9 82 00 00 00       	jmp    801010a4 <fileclose+0xd4>
  }
  ff = *f;
80101022:	8b 45 08             	mov    0x8(%ebp),%eax
80101025:	8b 10                	mov    (%eax),%edx
80101027:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010102a:	8b 50 04             	mov    0x4(%eax),%edx
8010102d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101030:	8b 50 08             	mov    0x8(%eax),%edx
80101033:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101036:	8b 50 0c             	mov    0xc(%eax),%edx
80101039:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010103c:	8b 50 10             	mov    0x10(%eax),%edx
8010103f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101042:	8b 40 14             	mov    0x14(%eax),%eax
80101045:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101048:	8b 45 08             	mov    0x8(%ebp),%eax
8010104b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101052:	8b 45 08             	mov    0x8(%ebp),%eax
80101055:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010105b:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101062:	e8 72 3e 00 00       	call   80104ed9 <release>
  
  if(ff.type == FD_PIPE)
80101067:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010106a:	83 f8 01             	cmp    $0x1,%eax
8010106d:	75 18                	jne    80101087 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
8010106f:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101073:	0f be d0             	movsbl %al,%edx
80101076:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101079:	89 54 24 04          	mov    %edx,0x4(%esp)
8010107d:	89 04 24             	mov    %eax,(%esp)
80101080:	e8 4e 30 00 00       	call   801040d3 <pipeclose>
80101085:	eb 1d                	jmp    801010a4 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101087:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010108a:	83 f8 02             	cmp    $0x2,%eax
8010108d:	75 15                	jne    801010a4 <fileclose+0xd4>
    begin_op();
8010108f:	e8 cd 23 00 00       	call   80103461 <begin_op>
    iput(ff.ip);
80101094:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101097:	89 04 24             	mov    %eax,(%esp)
8010109a:	e8 88 09 00 00       	call   80101a27 <iput>
    end_op();
8010109f:	e8 3e 24 00 00       	call   801034e2 <end_op>
  }
}
801010a4:	c9                   	leave  
801010a5:	c3                   	ret    

801010a6 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010a6:	55                   	push   %ebp
801010a7:	89 e5                	mov    %esp,%ebp
801010a9:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010ac:	8b 45 08             	mov    0x8(%ebp),%eax
801010af:	8b 00                	mov    (%eax),%eax
801010b1:	83 f8 02             	cmp    $0x2,%eax
801010b4:	75 38                	jne    801010ee <filestat+0x48>
    ilock(f->ip);
801010b6:	8b 45 08             	mov    0x8(%ebp),%eax
801010b9:	8b 40 10             	mov    0x10(%eax),%eax
801010bc:	89 04 24             	mov    %eax,(%esp)
801010bf:	e8 b0 07 00 00       	call   80101874 <ilock>
    stati(f->ip, st);
801010c4:	8b 45 08             	mov    0x8(%ebp),%eax
801010c7:	8b 40 10             	mov    0x10(%eax),%eax
801010ca:	8b 55 0c             	mov    0xc(%ebp),%edx
801010cd:	89 54 24 04          	mov    %edx,0x4(%esp)
801010d1:	89 04 24             	mov    %eax,(%esp)
801010d4:	e8 4c 0c 00 00       	call   80101d25 <stati>
    iunlock(f->ip);
801010d9:	8b 45 08             	mov    0x8(%ebp),%eax
801010dc:	8b 40 10             	mov    0x10(%eax),%eax
801010df:	89 04 24             	mov    %eax,(%esp)
801010e2:	e8 db 08 00 00       	call   801019c2 <iunlock>
    return 0;
801010e7:	b8 00 00 00 00       	mov    $0x0,%eax
801010ec:	eb 05                	jmp    801010f3 <filestat+0x4d>
  }
  return -1;
801010ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010f3:	c9                   	leave  
801010f4:	c3                   	ret    

801010f5 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010f5:	55                   	push   %ebp
801010f6:	89 e5                	mov    %esp,%ebp
801010f8:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010fb:	8b 45 08             	mov    0x8(%ebp),%eax
801010fe:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101102:	84 c0                	test   %al,%al
80101104:	75 0a                	jne    80101110 <fileread+0x1b>
    return -1;
80101106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010110b:	e9 9f 00 00 00       	jmp    801011af <fileread+0xba>
  if(f->type == FD_PIPE)
80101110:	8b 45 08             	mov    0x8(%ebp),%eax
80101113:	8b 00                	mov    (%eax),%eax
80101115:	83 f8 01             	cmp    $0x1,%eax
80101118:	75 1e                	jne    80101138 <fileread+0x43>
    return piperead(f->pipe, addr, n);
8010111a:	8b 45 08             	mov    0x8(%ebp),%eax
8010111d:	8b 40 0c             	mov    0xc(%eax),%eax
80101120:	8b 55 10             	mov    0x10(%ebp),%edx
80101123:	89 54 24 08          	mov    %edx,0x8(%esp)
80101127:	8b 55 0c             	mov    0xc(%ebp),%edx
8010112a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010112e:	89 04 24             	mov    %eax,(%esp)
80101131:	e8 1f 31 00 00       	call   80104255 <piperead>
80101136:	eb 77                	jmp    801011af <fileread+0xba>
  if(f->type == FD_INODE){
80101138:	8b 45 08             	mov    0x8(%ebp),%eax
8010113b:	8b 00                	mov    (%eax),%eax
8010113d:	83 f8 02             	cmp    $0x2,%eax
80101140:	75 61                	jne    801011a3 <fileread+0xae>
    ilock(f->ip);
80101142:	8b 45 08             	mov    0x8(%ebp),%eax
80101145:	8b 40 10             	mov    0x10(%eax),%eax
80101148:	89 04 24             	mov    %eax,(%esp)
8010114b:	e8 24 07 00 00       	call   80101874 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101150:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101153:	8b 45 08             	mov    0x8(%ebp),%eax
80101156:	8b 50 14             	mov    0x14(%eax),%edx
80101159:	8b 45 08             	mov    0x8(%ebp),%eax
8010115c:	8b 40 10             	mov    0x10(%eax),%eax
8010115f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101163:	89 54 24 08          	mov    %edx,0x8(%esp)
80101167:	8b 55 0c             	mov    0xc(%ebp),%edx
8010116a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010116e:	89 04 24             	mov    %eax,(%esp)
80101171:	e8 f4 0b 00 00       	call   80101d6a <readi>
80101176:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101179:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010117d:	7e 11                	jle    80101190 <fileread+0x9b>
      f->off += r;
8010117f:	8b 45 08             	mov    0x8(%ebp),%eax
80101182:	8b 50 14             	mov    0x14(%eax),%edx
80101185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101188:	01 c2                	add    %eax,%edx
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101190:	8b 45 08             	mov    0x8(%ebp),%eax
80101193:	8b 40 10             	mov    0x10(%eax),%eax
80101196:	89 04 24             	mov    %eax,(%esp)
80101199:	e8 24 08 00 00       	call   801019c2 <iunlock>
    return r;
8010119e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011a1:	eb 0c                	jmp    801011af <fileread+0xba>
  }
  panic("fileread");
801011a3:	c7 04 24 16 85 10 80 	movl   $0x80108516,(%esp)
801011aa:	e8 8e f3 ff ff       	call   8010053d <panic>
}
801011af:	c9                   	leave  
801011b0:	c3                   	ret    

801011b1 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011b1:	55                   	push   %ebp
801011b2:	89 e5                	mov    %esp,%ebp
801011b4:	53                   	push   %ebx
801011b5:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011b8:	8b 45 08             	mov    0x8(%ebp),%eax
801011bb:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011bf:	84 c0                	test   %al,%al
801011c1:	75 0a                	jne    801011cd <filewrite+0x1c>
    return -1;
801011c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011c8:	e9 23 01 00 00       	jmp    801012f0 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801011cd:	8b 45 08             	mov    0x8(%ebp),%eax
801011d0:	8b 00                	mov    (%eax),%eax
801011d2:	83 f8 01             	cmp    $0x1,%eax
801011d5:	75 21                	jne    801011f8 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011d7:	8b 45 08             	mov    0x8(%ebp),%eax
801011da:	8b 40 0c             	mov    0xc(%eax),%eax
801011dd:	8b 55 10             	mov    0x10(%ebp),%edx
801011e0:	89 54 24 08          	mov    %edx,0x8(%esp)
801011e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801011e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801011eb:	89 04 24             	mov    %eax,(%esp)
801011ee:	e8 72 2f 00 00       	call   80104165 <pipewrite>
801011f3:	e9 f8 00 00 00       	jmp    801012f0 <filewrite+0x13f>
  if(f->type == FD_INODE){
801011f8:	8b 45 08             	mov    0x8(%ebp),%eax
801011fb:	8b 00                	mov    (%eax),%eax
801011fd:	83 f8 02             	cmp    $0x2,%eax
80101200:	0f 85 de 00 00 00    	jne    801012e4 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101206:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010120d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101214:	e9 a8 00 00 00       	jmp    801012c1 <filewrite+0x110>
      int n1 = n - i;
80101219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121c:	8b 55 10             	mov    0x10(%ebp),%edx
8010121f:	89 d1                	mov    %edx,%ecx
80101221:	29 c1                	sub    %eax,%ecx
80101223:	89 c8                	mov    %ecx,%eax
80101225:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101228:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010122b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010122e:	7e 06                	jle    80101236 <filewrite+0x85>
        n1 = max;
80101230:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101233:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101236:	e8 26 22 00 00       	call   80103461 <begin_op>
      ilock(f->ip);
8010123b:	8b 45 08             	mov    0x8(%ebp),%eax
8010123e:	8b 40 10             	mov    0x10(%eax),%eax
80101241:	89 04 24             	mov    %eax,(%esp)
80101244:	e8 2b 06 00 00       	call   80101874 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101249:	8b 5d f0             	mov    -0x10(%ebp),%ebx
8010124c:	8b 45 08             	mov    0x8(%ebp),%eax
8010124f:	8b 48 14             	mov    0x14(%eax),%ecx
80101252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101255:	89 c2                	mov    %eax,%edx
80101257:	03 55 0c             	add    0xc(%ebp),%edx
8010125a:	8b 45 08             	mov    0x8(%ebp),%eax
8010125d:	8b 40 10             	mov    0x10(%eax),%eax
80101260:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80101264:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101268:	89 54 24 04          	mov    %edx,0x4(%esp)
8010126c:	89 04 24             	mov    %eax,(%esp)
8010126f:	e8 61 0c 00 00       	call   80101ed5 <writei>
80101274:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101277:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010127b:	7e 11                	jle    8010128e <filewrite+0xdd>
        f->off += r;
8010127d:	8b 45 08             	mov    0x8(%ebp),%eax
80101280:	8b 50 14             	mov    0x14(%eax),%edx
80101283:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101286:	01 c2                	add    %eax,%edx
80101288:	8b 45 08             	mov    0x8(%ebp),%eax
8010128b:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010128e:	8b 45 08             	mov    0x8(%ebp),%eax
80101291:	8b 40 10             	mov    0x10(%eax),%eax
80101294:	89 04 24             	mov    %eax,(%esp)
80101297:	e8 26 07 00 00       	call   801019c2 <iunlock>
      end_op();
8010129c:	e8 41 22 00 00       	call   801034e2 <end_op>

      if(r < 0)
801012a1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012a5:	78 28                	js     801012cf <filewrite+0x11e>
        break;
      if(r != n1)
801012a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012aa:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012ad:	74 0c                	je     801012bb <filewrite+0x10a>
        panic("short filewrite");
801012af:	c7 04 24 1f 85 10 80 	movl   $0x8010851f,(%esp)
801012b6:	e8 82 f2 ff ff       	call   8010053d <panic>
      i += r;
801012bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012be:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012c4:	3b 45 10             	cmp    0x10(%ebp),%eax
801012c7:	0f 8c 4c ff ff ff    	jl     80101219 <filewrite+0x68>
801012cd:	eb 01                	jmp    801012d0 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801012cf:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d3:	3b 45 10             	cmp    0x10(%ebp),%eax
801012d6:	75 05                	jne    801012dd <filewrite+0x12c>
801012d8:	8b 45 10             	mov    0x10(%ebp),%eax
801012db:	eb 05                	jmp    801012e2 <filewrite+0x131>
801012dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012e2:	eb 0c                	jmp    801012f0 <filewrite+0x13f>
  }
  panic("filewrite");
801012e4:	c7 04 24 2f 85 10 80 	movl   $0x8010852f,(%esp)
801012eb:	e8 4d f2 ff ff       	call   8010053d <panic>
}
801012f0:	83 c4 24             	add    $0x24,%esp
801012f3:	5b                   	pop    %ebx
801012f4:	5d                   	pop    %ebp
801012f5:	c3                   	ret    
	...

801012f8 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012f8:	55                   	push   %ebp
801012f9:	89 e5                	mov    %esp,%ebp
801012fb:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101301:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101308:	00 
80101309:	89 04 24             	mov    %eax,(%esp)
8010130c:	e8 95 ee ff ff       	call   801001a6 <bread>
80101311:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101317:	83 c0 18             	add    $0x18,%eax
8010131a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101321:	00 
80101322:	89 44 24 04          	mov    %eax,0x4(%esp)
80101326:	8b 45 0c             	mov    0xc(%ebp),%eax
80101329:	89 04 24             	mov    %eax,(%esp)
8010132c:	e8 68 3e 00 00       	call   80105199 <memmove>
  brelse(bp);
80101331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101334:	89 04 24             	mov    %eax,(%esp)
80101337:	e8 db ee ff ff       	call   80100217 <brelse>
}
8010133c:	c9                   	leave  
8010133d:	c3                   	ret    

8010133e <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010133e:	55                   	push   %ebp
8010133f:	89 e5                	mov    %esp,%ebp
80101341:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101344:	8b 55 0c             	mov    0xc(%ebp),%edx
80101347:	8b 45 08             	mov    0x8(%ebp),%eax
8010134a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010134e:	89 04 24             	mov    %eax,(%esp)
80101351:	e8 50 ee ff ff       	call   801001a6 <bread>
80101356:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010135c:	83 c0 18             	add    $0x18,%eax
8010135f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101366:	00 
80101367:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010136e:	00 
8010136f:	89 04 24             	mov    %eax,(%esp)
80101372:	e8 4f 3d 00 00       	call   801050c6 <memset>
  log_write(bp);
80101377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137a:	89 04 24             	mov    %eax,(%esp)
8010137d:	e8 e4 22 00 00       	call   80103666 <log_write>
  brelse(bp);
80101382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101385:	89 04 24             	mov    %eax,(%esp)
80101388:	e8 8a ee ff ff       	call   80100217 <brelse>
}
8010138d:	c9                   	leave  
8010138e:	c3                   	ret    

8010138f <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010138f:	55                   	push   %ebp
80101390:	89 e5                	mov    %esp,%ebp
80101392:	53                   	push   %ebx
80101393:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101396:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
8010139d:	8b 45 08             	mov    0x8(%ebp),%eax
801013a0:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013a3:	89 54 24 04          	mov    %edx,0x4(%esp)
801013a7:	89 04 24             	mov    %eax,(%esp)
801013aa:	e8 49 ff ff ff       	call   801012f8 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013b6:	e9 11 01 00 00       	jmp    801014cc <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013be:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013c4:	85 c0                	test   %eax,%eax
801013c6:	0f 48 c2             	cmovs  %edx,%eax
801013c9:	c1 f8 0c             	sar    $0xc,%eax
801013cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013cf:	c1 ea 03             	shr    $0x3,%edx
801013d2:	01 d0                	add    %edx,%eax
801013d4:	83 c0 03             	add    $0x3,%eax
801013d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801013db:	8b 45 08             	mov    0x8(%ebp),%eax
801013de:	89 04 24             	mov    %eax,(%esp)
801013e1:	e8 c0 ed ff ff       	call   801001a6 <bread>
801013e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013e9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013f0:	e9 a7 00 00 00       	jmp    8010149c <balloc+0x10d>
      m = 1 << (bi % 8);
801013f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f8:	89 c2                	mov    %eax,%edx
801013fa:	c1 fa 1f             	sar    $0x1f,%edx
801013fd:	c1 ea 1d             	shr    $0x1d,%edx
80101400:	01 d0                	add    %edx,%eax
80101402:	83 e0 07             	and    $0x7,%eax
80101405:	29 d0                	sub    %edx,%eax
80101407:	ba 01 00 00 00       	mov    $0x1,%edx
8010140c:	89 d3                	mov    %edx,%ebx
8010140e:	89 c1                	mov    %eax,%ecx
80101410:	d3 e3                	shl    %cl,%ebx
80101412:	89 d8                	mov    %ebx,%eax
80101414:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010141a:	8d 50 07             	lea    0x7(%eax),%edx
8010141d:	85 c0                	test   %eax,%eax
8010141f:	0f 48 c2             	cmovs  %edx,%eax
80101422:	c1 f8 03             	sar    $0x3,%eax
80101425:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101428:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010142d:	0f b6 c0             	movzbl %al,%eax
80101430:	23 45 e8             	and    -0x18(%ebp),%eax
80101433:	85 c0                	test   %eax,%eax
80101435:	75 61                	jne    80101498 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101437:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010143a:	8d 50 07             	lea    0x7(%eax),%edx
8010143d:	85 c0                	test   %eax,%eax
8010143f:	0f 48 c2             	cmovs  %edx,%eax
80101442:	c1 f8 03             	sar    $0x3,%eax
80101445:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101448:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010144d:	89 d1                	mov    %edx,%ecx
8010144f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101452:	09 ca                	or     %ecx,%edx
80101454:	89 d1                	mov    %edx,%ecx
80101456:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101459:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010145d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101460:	89 04 24             	mov    %eax,(%esp)
80101463:	e8 fe 21 00 00       	call   80103666 <log_write>
        brelse(bp);
80101468:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010146b:	89 04 24             	mov    %eax,(%esp)
8010146e:	e8 a4 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101473:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101476:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101479:	01 c2                	add    %eax,%edx
8010147b:	8b 45 08             	mov    0x8(%ebp),%eax
8010147e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101482:	89 04 24             	mov    %eax,(%esp)
80101485:	e8 b4 fe ff ff       	call   8010133e <bzero>
        return b + bi;
8010148a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101490:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
80101492:	83 c4 34             	add    $0x34,%esp
80101495:	5b                   	pop    %ebx
80101496:	5d                   	pop    %ebp
80101497:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101498:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010149c:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014a3:	7f 15                	jg     801014ba <balloc+0x12b>
801014a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ab:	01 d0                	add    %edx,%eax
801014ad:	89 c2                	mov    %eax,%edx
801014af:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014b2:	39 c2                	cmp    %eax,%edx
801014b4:	0f 82 3b ff ff ff    	jb     801013f5 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014bd:	89 04 24             	mov    %eax,(%esp)
801014c0:	e8 52 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014c5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014d2:	39 c2                	cmp    %eax,%edx
801014d4:	0f 82 e1 fe ff ff    	jb     801013bb <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014da:	c7 04 24 39 85 10 80 	movl   $0x80108539,(%esp)
801014e1:	e8 57 f0 ff ff       	call   8010053d <panic>

801014e6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014e6:	55                   	push   %ebp
801014e7:	89 e5                	mov    %esp,%ebp
801014e9:	53                   	push   %ebx
801014ea:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014ed:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801014f4:	8b 45 08             	mov    0x8(%ebp),%eax
801014f7:	89 04 24             	mov    %eax,(%esp)
801014fa:	e8 f9 fd ff ff       	call   801012f8 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80101502:	89 c2                	mov    %eax,%edx
80101504:	c1 ea 0c             	shr    $0xc,%edx
80101507:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010150a:	c1 e8 03             	shr    $0x3,%eax
8010150d:	01 d0                	add    %edx,%eax
8010150f:	8d 50 03             	lea    0x3(%eax),%edx
80101512:	8b 45 08             	mov    0x8(%ebp),%eax
80101515:	89 54 24 04          	mov    %edx,0x4(%esp)
80101519:	89 04 24             	mov    %eax,(%esp)
8010151c:	e8 85 ec ff ff       	call   801001a6 <bread>
80101521:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101524:	8b 45 0c             	mov    0xc(%ebp),%eax
80101527:	25 ff 0f 00 00       	and    $0xfff,%eax
8010152c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101532:	89 c2                	mov    %eax,%edx
80101534:	c1 fa 1f             	sar    $0x1f,%edx
80101537:	c1 ea 1d             	shr    $0x1d,%edx
8010153a:	01 d0                	add    %edx,%eax
8010153c:	83 e0 07             	and    $0x7,%eax
8010153f:	29 d0                	sub    %edx,%eax
80101541:	ba 01 00 00 00       	mov    $0x1,%edx
80101546:	89 d3                	mov    %edx,%ebx
80101548:	89 c1                	mov    %eax,%ecx
8010154a:	d3 e3                	shl    %cl,%ebx
8010154c:	89 d8                	mov    %ebx,%eax
8010154e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101551:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101554:	8d 50 07             	lea    0x7(%eax),%edx
80101557:	85 c0                	test   %eax,%eax
80101559:	0f 48 c2             	cmovs  %edx,%eax
8010155c:	c1 f8 03             	sar    $0x3,%eax
8010155f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101562:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101567:	0f b6 c0             	movzbl %al,%eax
8010156a:	23 45 ec             	and    -0x14(%ebp),%eax
8010156d:	85 c0                	test   %eax,%eax
8010156f:	75 0c                	jne    8010157d <bfree+0x97>
    panic("freeing free block");
80101571:	c7 04 24 4f 85 10 80 	movl   $0x8010854f,(%esp)
80101578:	e8 c0 ef ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
8010157d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101580:	8d 50 07             	lea    0x7(%eax),%edx
80101583:	85 c0                	test   %eax,%eax
80101585:	0f 48 c2             	cmovs  %edx,%eax
80101588:	c1 f8 03             	sar    $0x3,%eax
8010158b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010158e:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101593:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101596:	f7 d1                	not    %ecx
80101598:	21 ca                	and    %ecx,%edx
8010159a:	89 d1                	mov    %edx,%ecx
8010159c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159f:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015a6:	89 04 24             	mov    %eax,(%esp)
801015a9:	e8 b8 20 00 00       	call   80103666 <log_write>
  brelse(bp);
801015ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015b1:	89 04 24             	mov    %eax,(%esp)
801015b4:	e8 5e ec ff ff       	call   80100217 <brelse>
}
801015b9:	83 c4 34             	add    $0x34,%esp
801015bc:	5b                   	pop    %ebx
801015bd:	5d                   	pop    %ebp
801015be:	c3                   	ret    

801015bf <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015bf:	55                   	push   %ebp
801015c0:	89 e5                	mov    %esp,%ebp
801015c2:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015c5:	c7 44 24 04 62 85 10 	movl   $0x80108562,0x4(%esp)
801015cc:	80 
801015cd:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801015d4:	e8 7d 38 00 00       	call   80104e56 <initlock>
}
801015d9:	c9                   	leave  
801015da:	c3                   	ret    

801015db <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015db:	55                   	push   %ebp
801015dc:	89 e5                	mov    %esp,%ebp
801015de:	83 ec 48             	sub    $0x48,%esp
801015e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015e4:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015e8:	8b 45 08             	mov    0x8(%ebp),%eax
801015eb:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015ee:	89 54 24 04          	mov    %edx,0x4(%esp)
801015f2:	89 04 24             	mov    %eax,(%esp)
801015f5:	e8 fe fc ff ff       	call   801012f8 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015fa:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101601:	e9 98 00 00 00       	jmp    8010169e <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101606:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101609:	c1 e8 03             	shr    $0x3,%eax
8010160c:	83 c0 02             	add    $0x2,%eax
8010160f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101613:	8b 45 08             	mov    0x8(%ebp),%eax
80101616:	89 04 24             	mov    %eax,(%esp)
80101619:	e8 88 eb ff ff       	call   801001a6 <bread>
8010161e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101621:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101624:	8d 50 18             	lea    0x18(%eax),%edx
80101627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010162a:	83 e0 07             	and    $0x7,%eax
8010162d:	c1 e0 06             	shl    $0x6,%eax
80101630:	01 d0                	add    %edx,%eax
80101632:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101635:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101638:	0f b7 00             	movzwl (%eax),%eax
8010163b:	66 85 c0             	test   %ax,%ax
8010163e:	75 4f                	jne    8010168f <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101640:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101647:	00 
80101648:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010164f:	00 
80101650:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101653:	89 04 24             	mov    %eax,(%esp)
80101656:	e8 6b 3a 00 00       	call   801050c6 <memset>
      dip->type = type;
8010165b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010165e:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101662:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101668:	89 04 24             	mov    %eax,(%esp)
8010166b:	e8 f6 1f 00 00       	call   80103666 <log_write>
      brelse(bp);
80101670:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101673:	89 04 24             	mov    %eax,(%esp)
80101676:	e8 9c eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010167b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010167e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101682:	8b 45 08             	mov    0x8(%ebp),%eax
80101685:	89 04 24             	mov    %eax,(%esp)
80101688:	e8 e3 00 00 00       	call   80101770 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
8010168d:	c9                   	leave  
8010168e:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
8010168f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101692:	89 04 24             	mov    %eax,(%esp)
80101695:	e8 7d eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010169a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010169e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016a4:	39 c2                	cmp    %eax,%edx
801016a6:	0f 82 5a ff ff ff    	jb     80101606 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016ac:	c7 04 24 69 85 10 80 	movl   $0x80108569,(%esp)
801016b3:	e8 85 ee ff ff       	call   8010053d <panic>

801016b8 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016b8:	55                   	push   %ebp
801016b9:	89 e5                	mov    %esp,%ebp
801016bb:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016be:	8b 45 08             	mov    0x8(%ebp),%eax
801016c1:	8b 40 04             	mov    0x4(%eax),%eax
801016c4:	c1 e8 03             	shr    $0x3,%eax
801016c7:	8d 50 02             	lea    0x2(%eax),%edx
801016ca:	8b 45 08             	mov    0x8(%ebp),%eax
801016cd:	8b 00                	mov    (%eax),%eax
801016cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801016d3:	89 04 24             	mov    %eax,(%esp)
801016d6:	e8 cb ea ff ff       	call   801001a6 <bread>
801016db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e1:	8d 50 18             	lea    0x18(%eax),%edx
801016e4:	8b 45 08             	mov    0x8(%ebp),%eax
801016e7:	8b 40 04             	mov    0x4(%eax),%eax
801016ea:	83 e0 07             	and    $0x7,%eax
801016ed:	c1 e0 06             	shl    $0x6,%eax
801016f0:	01 d0                	add    %edx,%eax
801016f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016f5:	8b 45 08             	mov    0x8(%ebp),%eax
801016f8:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ff:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101702:	8b 45 08             	mov    0x8(%ebp),%eax
80101705:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101709:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010170c:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101710:	8b 45 08             	mov    0x8(%ebp),%eax
80101713:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010171a:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010171e:	8b 45 08             	mov    0x8(%ebp),%eax
80101721:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101725:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101728:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010172c:	8b 45 08             	mov    0x8(%ebp),%eax
8010172f:	8b 50 18             	mov    0x18(%eax),%edx
80101732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101735:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101738:	8b 45 08             	mov    0x8(%ebp),%eax
8010173b:	8d 50 1c             	lea    0x1c(%eax),%edx
8010173e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101741:	83 c0 0c             	add    $0xc,%eax
80101744:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010174b:	00 
8010174c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101750:	89 04 24             	mov    %eax,(%esp)
80101753:	e8 41 3a 00 00       	call   80105199 <memmove>
  log_write(bp);
80101758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175b:	89 04 24             	mov    %eax,(%esp)
8010175e:	e8 03 1f 00 00       	call   80103666 <log_write>
  brelse(bp);
80101763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101766:	89 04 24             	mov    %eax,(%esp)
80101769:	e8 a9 ea ff ff       	call   80100217 <brelse>
}
8010176e:	c9                   	leave  
8010176f:	c3                   	ret    

80101770 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101770:	55                   	push   %ebp
80101771:	89 e5                	mov    %esp,%ebp
80101773:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101776:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010177d:	e8 f5 36 00 00       	call   80104e77 <acquire>

  // Is the inode already cached?
  empty = 0;
80101782:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101789:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
80101790:	eb 59                	jmp    801017eb <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101795:	8b 40 08             	mov    0x8(%eax),%eax
80101798:	85 c0                	test   %eax,%eax
8010179a:	7e 35                	jle    801017d1 <iget+0x61>
8010179c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010179f:	8b 00                	mov    (%eax),%eax
801017a1:	3b 45 08             	cmp    0x8(%ebp),%eax
801017a4:	75 2b                	jne    801017d1 <iget+0x61>
801017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a9:	8b 40 04             	mov    0x4(%eax),%eax
801017ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017af:	75 20                	jne    801017d1 <iget+0x61>
      ip->ref++;
801017b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b4:	8b 40 08             	mov    0x8(%eax),%eax
801017b7:	8d 50 01             	lea    0x1(%eax),%edx
801017ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017bd:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017c0:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801017c7:	e8 0d 37 00 00       	call   80104ed9 <release>
      return ip;
801017cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cf:	eb 6f                	jmp    80101840 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017d5:	75 10                	jne    801017e7 <iget+0x77>
801017d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017da:	8b 40 08             	mov    0x8(%eax),%eax
801017dd:	85 c0                	test   %eax,%eax
801017df:	75 06                	jne    801017e7 <iget+0x77>
      empty = ip;
801017e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017e7:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017eb:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
801017f2:	72 9e                	jb     80101792 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017f8:	75 0c                	jne    80101806 <iget+0x96>
    panic("iget: no inodes");
801017fa:	c7 04 24 7b 85 10 80 	movl   $0x8010857b,(%esp)
80101801:	e8 37 ed ff ff       	call   8010053d <panic>

  ip = empty;
80101806:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101809:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010180c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010180f:	8b 55 08             	mov    0x8(%ebp),%edx
80101812:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101817:	8b 55 0c             	mov    0xc(%ebp),%edx
8010181a:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010181d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101820:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182a:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101831:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101838:	e8 9c 36 00 00       	call   80104ed9 <release>

  return ip;
8010183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101840:	c9                   	leave  
80101841:	c3                   	ret    

80101842 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101842:	55                   	push   %ebp
80101843:	89 e5                	mov    %esp,%ebp
80101845:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101848:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010184f:	e8 23 36 00 00       	call   80104e77 <acquire>
  ip->ref++;
80101854:	8b 45 08             	mov    0x8(%ebp),%eax
80101857:	8b 40 08             	mov    0x8(%eax),%eax
8010185a:	8d 50 01             	lea    0x1(%eax),%edx
8010185d:	8b 45 08             	mov    0x8(%ebp),%eax
80101860:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101863:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010186a:	e8 6a 36 00 00       	call   80104ed9 <release>
  return ip;
8010186f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101872:	c9                   	leave  
80101873:	c3                   	ret    

80101874 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101874:	55                   	push   %ebp
80101875:	89 e5                	mov    %esp,%ebp
80101877:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010187a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010187e:	74 0a                	je     8010188a <ilock+0x16>
80101880:	8b 45 08             	mov    0x8(%ebp),%eax
80101883:	8b 40 08             	mov    0x8(%eax),%eax
80101886:	85 c0                	test   %eax,%eax
80101888:	7f 0c                	jg     80101896 <ilock+0x22>
    panic("ilock");
8010188a:	c7 04 24 8b 85 10 80 	movl   $0x8010858b,(%esp)
80101891:	e8 a7 ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101896:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010189d:	e8 d5 35 00 00       	call   80104e77 <acquire>
  while(ip->flags & I_BUSY)
801018a2:	eb 13                	jmp    801018b7 <ilock+0x43>
    sleep(ip, &icache.lock);
801018a4:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801018ab:	80 
801018ac:	8b 45 08             	mov    0x8(%ebp),%eax
801018af:	89 04 24             	mov    %eax,(%esp)
801018b2:	e8 e1 32 00 00       	call   80104b98 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018b7:	8b 45 08             	mov    0x8(%ebp),%eax
801018ba:	8b 40 0c             	mov    0xc(%eax),%eax
801018bd:	83 e0 01             	and    $0x1,%eax
801018c0:	84 c0                	test   %al,%al
801018c2:	75 e0                	jne    801018a4 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018c4:	8b 45 08             	mov    0x8(%ebp),%eax
801018c7:	8b 40 0c             	mov    0xc(%eax),%eax
801018ca:	89 c2                	mov    %eax,%edx
801018cc:	83 ca 01             	or     $0x1,%edx
801018cf:	8b 45 08             	mov    0x8(%ebp),%eax
801018d2:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018d5:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801018dc:	e8 f8 35 00 00       	call   80104ed9 <release>

  if(!(ip->flags & I_VALID)){
801018e1:	8b 45 08             	mov    0x8(%ebp),%eax
801018e4:	8b 40 0c             	mov    0xc(%eax),%eax
801018e7:	83 e0 02             	and    $0x2,%eax
801018ea:	85 c0                	test   %eax,%eax
801018ec:	0f 85 ce 00 00 00    	jne    801019c0 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018f2:	8b 45 08             	mov    0x8(%ebp),%eax
801018f5:	8b 40 04             	mov    0x4(%eax),%eax
801018f8:	c1 e8 03             	shr    $0x3,%eax
801018fb:	8d 50 02             	lea    0x2(%eax),%edx
801018fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101901:	8b 00                	mov    (%eax),%eax
80101903:	89 54 24 04          	mov    %edx,0x4(%esp)
80101907:	89 04 24             	mov    %eax,(%esp)
8010190a:	e8 97 e8 ff ff       	call   801001a6 <bread>
8010190f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101915:	8d 50 18             	lea    0x18(%eax),%edx
80101918:	8b 45 08             	mov    0x8(%ebp),%eax
8010191b:	8b 40 04             	mov    0x4(%eax),%eax
8010191e:	83 e0 07             	and    $0x7,%eax
80101921:	c1 e0 06             	shl    $0x6,%eax
80101924:	01 d0                	add    %edx,%eax
80101926:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101929:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010192c:	0f b7 10             	movzwl (%eax),%edx
8010192f:	8b 45 08             	mov    0x8(%ebp),%eax
80101932:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101936:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101939:	0f b7 50 02          	movzwl 0x2(%eax),%edx
8010193d:	8b 45 08             	mov    0x8(%ebp),%eax
80101940:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101944:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101947:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010194b:	8b 45 08             	mov    0x8(%ebp),%eax
8010194e:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101952:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101955:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101959:	8b 45 08             	mov    0x8(%ebp),%eax
8010195c:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101963:	8b 50 08             	mov    0x8(%eax),%edx
80101966:	8b 45 08             	mov    0x8(%ebp),%eax
80101969:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010196c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196f:	8d 50 0c             	lea    0xc(%eax),%edx
80101972:	8b 45 08             	mov    0x8(%ebp),%eax
80101975:	83 c0 1c             	add    $0x1c,%eax
80101978:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010197f:	00 
80101980:	89 54 24 04          	mov    %edx,0x4(%esp)
80101984:	89 04 24             	mov    %eax,(%esp)
80101987:	e8 0d 38 00 00       	call   80105199 <memmove>
    brelse(bp);
8010198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198f:	89 04 24             	mov    %eax,(%esp)
80101992:	e8 80 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101997:	8b 45 08             	mov    0x8(%ebp),%eax
8010199a:	8b 40 0c             	mov    0xc(%eax),%eax
8010199d:	89 c2                	mov    %eax,%edx
8010199f:	83 ca 02             	or     $0x2,%edx
801019a2:	8b 45 08             	mov    0x8(%ebp),%eax
801019a5:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
801019a8:	8b 45 08             	mov    0x8(%ebp),%eax
801019ab:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019af:	66 85 c0             	test   %ax,%ax
801019b2:	75 0c                	jne    801019c0 <ilock+0x14c>
      panic("ilock: no type");
801019b4:	c7 04 24 91 85 10 80 	movl   $0x80108591,(%esp)
801019bb:	e8 7d eb ff ff       	call   8010053d <panic>
  }
}
801019c0:	c9                   	leave  
801019c1:	c3                   	ret    

801019c2 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019c2:	55                   	push   %ebp
801019c3:	89 e5                	mov    %esp,%ebp
801019c5:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019c8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019cc:	74 17                	je     801019e5 <iunlock+0x23>
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 40 0c             	mov    0xc(%eax),%eax
801019d4:	83 e0 01             	and    $0x1,%eax
801019d7:	85 c0                	test   %eax,%eax
801019d9:	74 0a                	je     801019e5 <iunlock+0x23>
801019db:	8b 45 08             	mov    0x8(%ebp),%eax
801019de:	8b 40 08             	mov    0x8(%eax),%eax
801019e1:	85 c0                	test   %eax,%eax
801019e3:	7f 0c                	jg     801019f1 <iunlock+0x2f>
    panic("iunlock");
801019e5:	c7 04 24 a0 85 10 80 	movl   $0x801085a0,(%esp)
801019ec:	e8 4c eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801019f1:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801019f8:	e8 7a 34 00 00       	call   80104e77 <acquire>
  ip->flags &= ~I_BUSY;
801019fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101a00:	8b 40 0c             	mov    0xc(%eax),%eax
80101a03:	89 c2                	mov    %eax,%edx
80101a05:	83 e2 fe             	and    $0xfffffffe,%edx
80101a08:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0b:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	89 04 24             	mov    %eax,(%esp)
80101a14:	e8 58 32 00 00       	call   80104c71 <wakeup>
  release(&icache.lock);
80101a19:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a20:	e8 b4 34 00 00       	call   80104ed9 <release>
}
80101a25:	c9                   	leave  
80101a26:	c3                   	ret    

80101a27 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a27:	55                   	push   %ebp
80101a28:	89 e5                	mov    %esp,%ebp
80101a2a:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a2d:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a34:	e8 3e 34 00 00       	call   80104e77 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a39:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3c:	8b 40 08             	mov    0x8(%eax),%eax
80101a3f:	83 f8 01             	cmp    $0x1,%eax
80101a42:	0f 85 93 00 00 00    	jne    80101adb <iput+0xb4>
80101a48:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4b:	8b 40 0c             	mov    0xc(%eax),%eax
80101a4e:	83 e0 02             	and    $0x2,%eax
80101a51:	85 c0                	test   %eax,%eax
80101a53:	0f 84 82 00 00 00    	je     80101adb <iput+0xb4>
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a60:	66 85 c0             	test   %ax,%ax
80101a63:	75 76                	jne    80101adb <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101a65:	8b 45 08             	mov    0x8(%ebp),%eax
80101a68:	8b 40 0c             	mov    0xc(%eax),%eax
80101a6b:	83 e0 01             	and    $0x1,%eax
80101a6e:	84 c0                	test   %al,%al
80101a70:	74 0c                	je     80101a7e <iput+0x57>
      panic("iput busy");
80101a72:	c7 04 24 a8 85 10 80 	movl   $0x801085a8,(%esp)
80101a79:	e8 bf ea ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	8b 40 0c             	mov    0xc(%eax),%eax
80101a84:	89 c2                	mov    %eax,%edx
80101a86:	83 ca 01             	or     $0x1,%edx
80101a89:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8c:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a8f:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a96:	e8 3e 34 00 00       	call   80104ed9 <release>
    itrunc(ip);
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	89 04 24             	mov    %eax,(%esp)
80101aa1:	e8 72 01 00 00       	call   80101c18 <itrunc>
    ip->type = 0;
80101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa9:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101aaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab2:	89 04 24             	mov    %eax,(%esp)
80101ab5:	e8 fe fb ff ff       	call   801016b8 <iupdate>
    acquire(&icache.lock);
80101aba:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101ac1:	e8 b1 33 00 00       	call   80104e77 <acquire>
    ip->flags = 0;
80101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	89 04 24             	mov    %eax,(%esp)
80101ad6:	e8 96 31 00 00       	call   80104c71 <wakeup>
  }
  ip->ref--;
80101adb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ade:	8b 40 08             	mov    0x8(%eax),%eax
80101ae1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101aea:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101af1:	e8 e3 33 00 00       	call   80104ed9 <release>
}
80101af6:	c9                   	leave  
80101af7:	c3                   	ret    

80101af8 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101af8:	55                   	push   %ebp
80101af9:	89 e5                	mov    %esp,%ebp
80101afb:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101afe:	8b 45 08             	mov    0x8(%ebp),%eax
80101b01:	89 04 24             	mov    %eax,(%esp)
80101b04:	e8 b9 fe ff ff       	call   801019c2 <iunlock>
  iput(ip);
80101b09:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0c:	89 04 24             	mov    %eax,(%esp)
80101b0f:	e8 13 ff ff ff       	call   80101a27 <iput>
}
80101b14:	c9                   	leave  
80101b15:	c3                   	ret    

80101b16 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b16:	55                   	push   %ebp
80101b17:	89 e5                	mov    %esp,%ebp
80101b19:	53                   	push   %ebx
80101b1a:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b1d:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b21:	77 3e                	ja     80101b61 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b29:	83 c2 04             	add    $0x4,%edx
80101b2c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b30:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b37:	75 20                	jne    80101b59 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	8b 00                	mov    (%eax),%eax
80101b3e:	89 04 24             	mov    %eax,(%esp)
80101b41:	e8 49 f8 ff ff       	call   8010138f <balloc>
80101b46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b49:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b4f:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b55:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b5c:	e9 b1 00 00 00       	jmp    80101c12 <bmap+0xfc>
  }
  bn -= NDIRECT;
80101b61:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b65:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b69:	0f 87 97 00 00 00    	ja     80101c06 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b72:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b75:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b7c:	75 19                	jne    80101b97 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 00                	mov    (%eax),%eax
80101b83:	89 04 24             	mov    %eax,(%esp)
80101b86:	e8 04 f8 ff ff       	call   8010138f <balloc>
80101b8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b94:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b97:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9a:	8b 00                	mov    (%eax),%eax
80101b9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b9f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ba3:	89 04 24             	mov    %eax,(%esp)
80101ba6:	e8 fb e5 ff ff       	call   801001a6 <bread>
80101bab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb1:	83 c0 18             	add    $0x18,%eax
80101bb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bba:	c1 e0 02             	shl    $0x2,%eax
80101bbd:	03 45 ec             	add    -0x14(%ebp),%eax
80101bc0:	8b 00                	mov    (%eax),%eax
80101bc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bc5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bc9:	75 2b                	jne    80101bf6 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bce:	c1 e0 02             	shl    $0x2,%eax
80101bd1:	89 c3                	mov    %eax,%ebx
80101bd3:	03 5d ec             	add    -0x14(%ebp),%ebx
80101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd9:	8b 00                	mov    (%eax),%eax
80101bdb:	89 04 24             	mov    %eax,(%esp)
80101bde:	e8 ac f7 ff ff       	call   8010138f <balloc>
80101be3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101be9:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bee:	89 04 24             	mov    %eax,(%esp)
80101bf1:	e8 70 1a 00 00       	call   80103666 <log_write>
    }
    brelse(bp);
80101bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bf9:	89 04 24             	mov    %eax,(%esp)
80101bfc:	e8 16 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c04:	eb 0c                	jmp    80101c12 <bmap+0xfc>
  }

  panic("bmap: out of range");
80101c06:	c7 04 24 b2 85 10 80 	movl   $0x801085b2,(%esp)
80101c0d:	e8 2b e9 ff ff       	call   8010053d <panic>
}
80101c12:	83 c4 24             	add    $0x24,%esp
80101c15:	5b                   	pop    %ebx
80101c16:	5d                   	pop    %ebp
80101c17:	c3                   	ret    

80101c18 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c18:	55                   	push   %ebp
80101c19:	89 e5                	mov    %esp,%ebp
80101c1b:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c25:	eb 44                	jmp    80101c6b <itrunc+0x53>
    if(ip->addrs[i]){
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c2d:	83 c2 04             	add    $0x4,%edx
80101c30:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c34:	85 c0                	test   %eax,%eax
80101c36:	74 2f                	je     80101c67 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c38:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c3e:	83 c2 04             	add    $0x4,%edx
80101c41:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c45:	8b 45 08             	mov    0x8(%ebp),%eax
80101c48:	8b 00                	mov    (%eax),%eax
80101c4a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c4e:	89 04 24             	mov    %eax,(%esp)
80101c51:	e8 90 f8 ff ff       	call   801014e6 <bfree>
      ip->addrs[i] = 0;
80101c56:	8b 45 08             	mov    0x8(%ebp),%eax
80101c59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c5c:	83 c2 04             	add    $0x4,%edx
80101c5f:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c66:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c67:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c6b:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c6f:	7e b6                	jle    80101c27 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c71:	8b 45 08             	mov    0x8(%ebp),%eax
80101c74:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c77:	85 c0                	test   %eax,%eax
80101c79:	0f 84 8f 00 00 00    	je     80101d0e <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c82:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c85:	8b 45 08             	mov    0x8(%ebp),%eax
80101c88:	8b 00                	mov    (%eax),%eax
80101c8a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c8e:	89 04 24             	mov    %eax,(%esp)
80101c91:	e8 10 e5 ff ff       	call   801001a6 <bread>
80101c96:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c9c:	83 c0 18             	add    $0x18,%eax
80101c9f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ca2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ca9:	eb 2f                	jmp    80101cda <itrunc+0xc2>
      if(a[j])
80101cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cae:	c1 e0 02             	shl    $0x2,%eax
80101cb1:	03 45 e8             	add    -0x18(%ebp),%eax
80101cb4:	8b 00                	mov    (%eax),%eax
80101cb6:	85 c0                	test   %eax,%eax
80101cb8:	74 1c                	je     80101cd6 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cbd:	c1 e0 02             	shl    $0x2,%eax
80101cc0:	03 45 e8             	add    -0x18(%ebp),%eax
80101cc3:	8b 10                	mov    (%eax),%edx
80101cc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc8:	8b 00                	mov    (%eax),%eax
80101cca:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cce:	89 04 24             	mov    %eax,(%esp)
80101cd1:	e8 10 f8 ff ff       	call   801014e6 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cd6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cdd:	83 f8 7f             	cmp    $0x7f,%eax
80101ce0:	76 c9                	jbe    80101cab <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ce2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ce5:	89 04 24             	mov    %eax,(%esp)
80101ce8:	e8 2a e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ced:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf0:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf6:	8b 00                	mov    (%eax),%eax
80101cf8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cfc:	89 04 24             	mov    %eax,(%esp)
80101cff:	e8 e2 f7 ff ff       	call   801014e6 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d04:	8b 45 08             	mov    0x8(%ebp),%eax
80101d07:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d11:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d18:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1b:	89 04 24             	mov    %eax,(%esp)
80101d1e:	e8 95 f9 ff ff       	call   801016b8 <iupdate>
}
80101d23:	c9                   	leave  
80101d24:	c3                   	ret    

80101d25 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d25:	55                   	push   %ebp
80101d26:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d28:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2b:	8b 00                	mov    (%eax),%eax
80101d2d:	89 c2                	mov    %eax,%edx
80101d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d32:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d35:	8b 45 08             	mov    0x8(%ebp),%eax
80101d38:	8b 50 04             	mov    0x4(%eax),%edx
80101d3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d3e:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d41:	8b 45 08             	mov    0x8(%ebp),%eax
80101d44:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d48:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4b:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d51:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d58:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5f:	8b 50 18             	mov    0x18(%eax),%edx
80101d62:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d65:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d68:	5d                   	pop    %ebp
80101d69:	c3                   	ret    

80101d6a <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d6a:	55                   	push   %ebp
80101d6b:	89 e5                	mov    %esp,%ebp
80101d6d:	53                   	push   %ebx
80101d6e:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d71:	8b 45 08             	mov    0x8(%ebp),%eax
80101d74:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d78:	66 83 f8 03          	cmp    $0x3,%ax
80101d7c:	75 60                	jne    80101dde <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d81:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d85:	66 85 c0             	test   %ax,%ax
80101d88:	78 20                	js     80101daa <readi+0x40>
80101d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d91:	66 83 f8 09          	cmp    $0x9,%ax
80101d95:	7f 13                	jg     80101daa <readi+0x40>
80101d97:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d9e:	98                   	cwtl   
80101d9f:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101da6:	85 c0                	test   %eax,%eax
80101da8:	75 0a                	jne    80101db4 <readi+0x4a>
      return -1;
80101daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101daf:	e9 1b 01 00 00       	jmp    80101ecf <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80101db4:	8b 45 08             	mov    0x8(%ebp),%eax
80101db7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dbb:	98                   	cwtl   
80101dbc:	8b 14 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%edx
80101dc3:	8b 45 14             	mov    0x14(%ebp),%eax
80101dc6:	89 44 24 08          	mov    %eax,0x8(%esp)
80101dca:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
80101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd4:	89 04 24             	mov    %eax,(%esp)
80101dd7:	ff d2                	call   *%edx
80101dd9:	e9 f1 00 00 00       	jmp    80101ecf <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80101dde:	8b 45 08             	mov    0x8(%ebp),%eax
80101de1:	8b 40 18             	mov    0x18(%eax),%eax
80101de4:	3b 45 10             	cmp    0x10(%ebp),%eax
80101de7:	72 0d                	jb     80101df6 <readi+0x8c>
80101de9:	8b 45 14             	mov    0x14(%ebp),%eax
80101dec:	8b 55 10             	mov    0x10(%ebp),%edx
80101def:	01 d0                	add    %edx,%eax
80101df1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101df4:	73 0a                	jae    80101e00 <readi+0x96>
    return -1;
80101df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dfb:	e9 cf 00 00 00       	jmp    80101ecf <readi+0x165>
  if(off + n > ip->size)
80101e00:	8b 45 14             	mov    0x14(%ebp),%eax
80101e03:	8b 55 10             	mov    0x10(%ebp),%edx
80101e06:	01 c2                	add    %eax,%edx
80101e08:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0b:	8b 40 18             	mov    0x18(%eax),%eax
80101e0e:	39 c2                	cmp    %eax,%edx
80101e10:	76 0c                	jbe    80101e1e <readi+0xb4>
    n = ip->size - off;
80101e12:	8b 45 08             	mov    0x8(%ebp),%eax
80101e15:	8b 40 18             	mov    0x18(%eax),%eax
80101e18:	2b 45 10             	sub    0x10(%ebp),%eax
80101e1b:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e25:	e9 96 00 00 00       	jmp    80101ec0 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e2a:	8b 45 10             	mov    0x10(%ebp),%eax
80101e2d:	c1 e8 09             	shr    $0x9,%eax
80101e30:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e34:	8b 45 08             	mov    0x8(%ebp),%eax
80101e37:	89 04 24             	mov    %eax,(%esp)
80101e3a:	e8 d7 fc ff ff       	call   80101b16 <bmap>
80101e3f:	8b 55 08             	mov    0x8(%ebp),%edx
80101e42:	8b 12                	mov    (%edx),%edx
80101e44:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e48:	89 14 24             	mov    %edx,(%esp)
80101e4b:	e8 56 e3 ff ff       	call   801001a6 <bread>
80101e50:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e53:	8b 45 10             	mov    0x10(%ebp),%eax
80101e56:	89 c2                	mov    %eax,%edx
80101e58:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101e5e:	b8 00 02 00 00       	mov    $0x200,%eax
80101e63:	89 c1                	mov    %eax,%ecx
80101e65:	29 d1                	sub    %edx,%ecx
80101e67:	89 ca                	mov    %ecx,%edx
80101e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e6c:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e6f:	89 cb                	mov    %ecx,%ebx
80101e71:	29 c3                	sub    %eax,%ebx
80101e73:	89 d8                	mov    %ebx,%eax
80101e75:	39 c2                	cmp    %eax,%edx
80101e77:	0f 46 c2             	cmovbe %edx,%eax
80101e7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e80:	8d 50 18             	lea    0x18(%eax),%edx
80101e83:	8b 45 10             	mov    0x10(%ebp),%eax
80101e86:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e8b:	01 c2                	add    %eax,%edx
80101e8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e90:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e94:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e98:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9b:	89 04 24             	mov    %eax,(%esp)
80101e9e:	e8 f6 32 00 00       	call   80105199 <memmove>
    brelse(bp);
80101ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea6:	89 04 24             	mov    %eax,(%esp)
80101ea9:	e8 69 e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101eae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb1:	01 45 f4             	add    %eax,-0xc(%ebp)
80101eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eb7:	01 45 10             	add    %eax,0x10(%ebp)
80101eba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ebd:	01 45 0c             	add    %eax,0xc(%ebp)
80101ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ec3:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ec6:	0f 82 5e ff ff ff    	jb     80101e2a <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ecc:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101ecf:	83 c4 24             	add    $0x24,%esp
80101ed2:	5b                   	pop    %ebx
80101ed3:	5d                   	pop    %ebp
80101ed4:	c3                   	ret    

80101ed5 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ed5:	55                   	push   %ebp
80101ed6:	89 e5                	mov    %esp,%ebp
80101ed8:	53                   	push   %ebx
80101ed9:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee3:	66 83 f8 03          	cmp    $0x3,%ax
80101ee7:	75 60                	jne    80101f49 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef0:	66 85 c0             	test   %ax,%ax
80101ef3:	78 20                	js     80101f15 <writei+0x40>
80101ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef8:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101efc:	66 83 f8 09          	cmp    $0x9,%ax
80101f00:	7f 13                	jg     80101f15 <writei+0x40>
80101f02:	8b 45 08             	mov    0x8(%ebp),%eax
80101f05:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f09:	98                   	cwtl   
80101f0a:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <writei+0x4a>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 46 01 00 00       	jmp    80102065 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 14 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%edx
80101f2e:	8b 45 14             	mov    0x14(%ebp),%eax
80101f31:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f35:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f38:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3f:	89 04 24             	mov    %eax,(%esp)
80101f42:	ff d2                	call   *%edx
80101f44:	e9 1c 01 00 00       	jmp    80102065 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80101f49:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4c:	8b 40 18             	mov    0x18(%eax),%eax
80101f4f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f52:	72 0d                	jb     80101f61 <writei+0x8c>
80101f54:	8b 45 14             	mov    0x14(%ebp),%eax
80101f57:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5a:	01 d0                	add    %edx,%eax
80101f5c:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f5f:	73 0a                	jae    80101f6b <writei+0x96>
    return -1;
80101f61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f66:	e9 fa 00 00 00       	jmp    80102065 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80101f6b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6e:	8b 55 10             	mov    0x10(%ebp),%edx
80101f71:	01 d0                	add    %edx,%eax
80101f73:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f78:	76 0a                	jbe    80101f84 <writei+0xaf>
    return -1;
80101f7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7f:	e9 e1 00 00 00       	jmp    80102065 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8b:	e9 a1 00 00 00       	jmp    80102031 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f90:	8b 45 10             	mov    0x10(%ebp),%eax
80101f93:	c1 e8 09             	shr    $0x9,%eax
80101f96:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9d:	89 04 24             	mov    %eax,(%esp)
80101fa0:	e8 71 fb ff ff       	call   80101b16 <bmap>
80101fa5:	8b 55 08             	mov    0x8(%ebp),%edx
80101fa8:	8b 12                	mov    (%edx),%edx
80101faa:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fae:	89 14 24             	mov    %edx,(%esp)
80101fb1:	e8 f0 e1 ff ff       	call   801001a6 <bread>
80101fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fb9:	8b 45 10             	mov    0x10(%ebp),%eax
80101fbc:	89 c2                	mov    %eax,%edx
80101fbe:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101fc4:	b8 00 02 00 00       	mov    $0x200,%eax
80101fc9:	89 c1                	mov    %eax,%ecx
80101fcb:	29 d1                	sub    %edx,%ecx
80101fcd:	89 ca                	mov    %ecx,%edx
80101fcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fd2:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fd5:	89 cb                	mov    %ecx,%ebx
80101fd7:	29 c3                	sub    %eax,%ebx
80101fd9:	89 d8                	mov    %ebx,%eax
80101fdb:	39 c2                	cmp    %eax,%edx
80101fdd:	0f 46 c2             	cmovbe %edx,%eax
80101fe0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101fe3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe6:	8d 50 18             	lea    0x18(%eax),%edx
80101fe9:	8b 45 10             	mov    0x10(%ebp),%eax
80101fec:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ff1:	01 c2                	add    %eax,%edx
80101ff3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff6:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ffd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102001:	89 14 24             	mov    %edx,(%esp)
80102004:	e8 90 31 00 00       	call   80105199 <memmove>
    log_write(bp);
80102009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010200c:	89 04 24             	mov    %eax,(%esp)
8010200f:	e8 52 16 00 00       	call   80103666 <log_write>
    brelse(bp);
80102014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102017:	89 04 24             	mov    %eax,(%esp)
8010201a:	e8 f8 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010201f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102022:	01 45 f4             	add    %eax,-0xc(%ebp)
80102025:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102028:	01 45 10             	add    %eax,0x10(%ebp)
8010202b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202e:	01 45 0c             	add    %eax,0xc(%ebp)
80102031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102034:	3b 45 14             	cmp    0x14(%ebp),%eax
80102037:	0f 82 53 ff ff ff    	jb     80101f90 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010203d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102041:	74 1f                	je     80102062 <writei+0x18d>
80102043:	8b 45 08             	mov    0x8(%ebp),%eax
80102046:	8b 40 18             	mov    0x18(%eax),%eax
80102049:	3b 45 10             	cmp    0x10(%ebp),%eax
8010204c:	73 14                	jae    80102062 <writei+0x18d>
    ip->size = off;
8010204e:	8b 45 08             	mov    0x8(%ebp),%eax
80102051:	8b 55 10             	mov    0x10(%ebp),%edx
80102054:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102057:	8b 45 08             	mov    0x8(%ebp),%eax
8010205a:	89 04 24             	mov    %eax,(%esp)
8010205d:	e8 56 f6 ff ff       	call   801016b8 <iupdate>
  }
  return n;
80102062:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102065:	83 c4 24             	add    $0x24,%esp
80102068:	5b                   	pop    %ebx
80102069:	5d                   	pop    %ebp
8010206a:	c3                   	ret    

8010206b <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010206b:	55                   	push   %ebp
8010206c:	89 e5                	mov    %esp,%ebp
8010206e:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102071:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102078:	00 
80102079:	8b 45 0c             	mov    0xc(%ebp),%eax
8010207c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102080:	8b 45 08             	mov    0x8(%ebp),%eax
80102083:	89 04 24             	mov    %eax,(%esp)
80102086:	e8 b2 31 00 00       	call   8010523d <strncmp>
}
8010208b:	c9                   	leave  
8010208c:	c3                   	ret    

8010208d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010208d:	55                   	push   %ebp
8010208e:	89 e5                	mov    %esp,%ebp
80102090:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102093:	8b 45 08             	mov    0x8(%ebp),%eax
80102096:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010209a:	66 83 f8 01          	cmp    $0x1,%ax
8010209e:	74 0c                	je     801020ac <dirlookup+0x1f>
    panic("dirlookup not DIR");
801020a0:	c7 04 24 c5 85 10 80 	movl   $0x801085c5,(%esp)
801020a7:	e8 91 e4 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020b3:	e9 87 00 00 00       	jmp    8010213f <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020b8:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020bf:	00 
801020c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020c3:	89 44 24 08          	mov    %eax,0x8(%esp)
801020c7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ce:	8b 45 08             	mov    0x8(%ebp),%eax
801020d1:	89 04 24             	mov    %eax,(%esp)
801020d4:	e8 91 fc ff ff       	call   80101d6a <readi>
801020d9:	83 f8 10             	cmp    $0x10,%eax
801020dc:	74 0c                	je     801020ea <dirlookup+0x5d>
      panic("dirlink read");
801020de:	c7 04 24 d7 85 10 80 	movl   $0x801085d7,(%esp)
801020e5:	e8 53 e4 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801020ea:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801020ee:	66 85 c0             	test   %ax,%ax
801020f1:	74 47                	je     8010213a <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
801020f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020f6:	83 c0 02             	add    $0x2,%eax
801020f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801020fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102100:	89 04 24             	mov    %eax,(%esp)
80102103:	e8 63 ff ff ff       	call   8010206b <namecmp>
80102108:	85 c0                	test   %eax,%eax
8010210a:	75 2f                	jne    8010213b <dirlookup+0xae>
      // entry matches path element
      if(poff)
8010210c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102110:	74 08                	je     8010211a <dirlookup+0x8d>
        *poff = off;
80102112:	8b 45 10             	mov    0x10(%ebp),%eax
80102115:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102118:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010211a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010211e:	0f b7 c0             	movzwl %ax,%eax
80102121:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102124:	8b 45 08             	mov    0x8(%ebp),%eax
80102127:	8b 00                	mov    (%eax),%eax
80102129:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010212c:	89 54 24 04          	mov    %edx,0x4(%esp)
80102130:	89 04 24             	mov    %eax,(%esp)
80102133:	e8 38 f6 ff ff       	call   80101770 <iget>
80102138:	eb 19                	jmp    80102153 <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010213a:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010213b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010213f:	8b 45 08             	mov    0x8(%ebp),%eax
80102142:	8b 40 18             	mov    0x18(%eax),%eax
80102145:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102148:	0f 87 6a ff ff ff    	ja     801020b8 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010214e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102153:	c9                   	leave  
80102154:	c3                   	ret    

80102155 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102155:	55                   	push   %ebp
80102156:	89 e5                	mov    %esp,%ebp
80102158:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010215b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102162:	00 
80102163:	8b 45 0c             	mov    0xc(%ebp),%eax
80102166:	89 44 24 04          	mov    %eax,0x4(%esp)
8010216a:	8b 45 08             	mov    0x8(%ebp),%eax
8010216d:	89 04 24             	mov    %eax,(%esp)
80102170:	e8 18 ff ff ff       	call   8010208d <dirlookup>
80102175:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102178:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010217c:	74 15                	je     80102193 <dirlink+0x3e>
    iput(ip);
8010217e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102181:	89 04 24             	mov    %eax,(%esp)
80102184:	e8 9e f8 ff ff       	call   80101a27 <iput>
    return -1;
80102189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010218e:	e9 b8 00 00 00       	jmp    8010224b <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102193:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010219a:	eb 44                	jmp    801021e0 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010219c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010219f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021a6:	00 
801021a7:	89 44 24 08          	mov    %eax,0x8(%esp)
801021ab:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801021b2:	8b 45 08             	mov    0x8(%ebp),%eax
801021b5:	89 04 24             	mov    %eax,(%esp)
801021b8:	e8 ad fb ff ff       	call   80101d6a <readi>
801021bd:	83 f8 10             	cmp    $0x10,%eax
801021c0:	74 0c                	je     801021ce <dirlink+0x79>
      panic("dirlink read");
801021c2:	c7 04 24 d7 85 10 80 	movl   $0x801085d7,(%esp)
801021c9:	e8 6f e3 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801021ce:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021d2:	66 85 c0             	test   %ax,%ax
801021d5:	74 18                	je     801021ef <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021da:	83 c0 10             	add    $0x10,%eax
801021dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021e3:	8b 45 08             	mov    0x8(%ebp),%eax
801021e6:	8b 40 18             	mov    0x18(%eax),%eax
801021e9:	39 c2                	cmp    %eax,%edx
801021eb:	72 af                	jb     8010219c <dirlink+0x47>
801021ed:	eb 01                	jmp    801021f0 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801021ef:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801021f0:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021f7:	00 
801021f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801021fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102202:	83 c0 02             	add    $0x2,%eax
80102205:	89 04 24             	mov    %eax,(%esp)
80102208:	e8 88 30 00 00       	call   80105295 <strncpy>
  de.inum = inum;
8010220d:	8b 45 10             	mov    0x10(%ebp),%eax
80102210:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102214:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102217:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010221e:	00 
8010221f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102223:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102226:	89 44 24 04          	mov    %eax,0x4(%esp)
8010222a:	8b 45 08             	mov    0x8(%ebp),%eax
8010222d:	89 04 24             	mov    %eax,(%esp)
80102230:	e8 a0 fc ff ff       	call   80101ed5 <writei>
80102235:	83 f8 10             	cmp    $0x10,%eax
80102238:	74 0c                	je     80102246 <dirlink+0xf1>
    panic("dirlink");
8010223a:	c7 04 24 e4 85 10 80 	movl   $0x801085e4,(%esp)
80102241:	e8 f7 e2 ff ff       	call   8010053d <panic>
  
  return 0;
80102246:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010224b:	c9                   	leave  
8010224c:	c3                   	ret    

8010224d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010224d:	55                   	push   %ebp
8010224e:	89 e5                	mov    %esp,%ebp
80102250:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102253:	eb 04                	jmp    80102259 <skipelem+0xc>
    path++;
80102255:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102259:	8b 45 08             	mov    0x8(%ebp),%eax
8010225c:	0f b6 00             	movzbl (%eax),%eax
8010225f:	3c 2f                	cmp    $0x2f,%al
80102261:	74 f2                	je     80102255 <skipelem+0x8>
    path++;
  if(*path == 0)
80102263:	8b 45 08             	mov    0x8(%ebp),%eax
80102266:	0f b6 00             	movzbl (%eax),%eax
80102269:	84 c0                	test   %al,%al
8010226b:	75 0a                	jne    80102277 <skipelem+0x2a>
    return 0;
8010226d:	b8 00 00 00 00       	mov    $0x0,%eax
80102272:	e9 86 00 00 00       	jmp    801022fd <skipelem+0xb0>
  s = path;
80102277:	8b 45 08             	mov    0x8(%ebp),%eax
8010227a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010227d:	eb 04                	jmp    80102283 <skipelem+0x36>
    path++;
8010227f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102283:	8b 45 08             	mov    0x8(%ebp),%eax
80102286:	0f b6 00             	movzbl (%eax),%eax
80102289:	3c 2f                	cmp    $0x2f,%al
8010228b:	74 0a                	je     80102297 <skipelem+0x4a>
8010228d:	8b 45 08             	mov    0x8(%ebp),%eax
80102290:	0f b6 00             	movzbl (%eax),%eax
80102293:	84 c0                	test   %al,%al
80102295:	75 e8                	jne    8010227f <skipelem+0x32>
    path++;
  len = path - s;
80102297:	8b 55 08             	mov    0x8(%ebp),%edx
8010229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010229d:	89 d1                	mov    %edx,%ecx
8010229f:	29 c1                	sub    %eax,%ecx
801022a1:	89 c8                	mov    %ecx,%eax
801022a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022a6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022aa:	7e 1c                	jle    801022c8 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801022ac:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022b3:	00 
801022b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801022bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801022be:	89 04 24             	mov    %eax,(%esp)
801022c1:	e8 d3 2e 00 00       	call   80105199 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022c6:	eb 28                	jmp    801022f0 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022cb:	89 44 24 08          	mov    %eax,0x8(%esp)
801022cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d9:	89 04 24             	mov    %eax,(%esp)
801022dc:	e8 b8 2e 00 00       	call   80105199 <memmove>
    name[len] = 0;
801022e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e4:	03 45 0c             	add    0xc(%ebp),%eax
801022e7:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801022ea:	eb 04                	jmp    801022f0 <skipelem+0xa3>
    path++;
801022ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022f0:	8b 45 08             	mov    0x8(%ebp),%eax
801022f3:	0f b6 00             	movzbl (%eax),%eax
801022f6:	3c 2f                	cmp    $0x2f,%al
801022f8:	74 f2                	je     801022ec <skipelem+0x9f>
    path++;
  return path;
801022fa:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022fd:	c9                   	leave  
801022fe:	c3                   	ret    

801022ff <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022ff:	55                   	push   %ebp
80102300:	89 e5                	mov    %esp,%ebp
80102302:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102305:	8b 45 08             	mov    0x8(%ebp),%eax
80102308:	0f b6 00             	movzbl (%eax),%eax
8010230b:	3c 2f                	cmp    $0x2f,%al
8010230d:	75 1c                	jne    8010232b <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010230f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102316:	00 
80102317:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010231e:	e8 4d f4 ff ff       	call   80101770 <iget>
80102323:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102326:	e9 af 00 00 00       	jmp    801023da <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010232b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102331:	8b 40 68             	mov    0x68(%eax),%eax
80102334:	89 04 24             	mov    %eax,(%esp)
80102337:	e8 06 f5 ff ff       	call   80101842 <idup>
8010233c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010233f:	e9 96 00 00 00       	jmp    801023da <namex+0xdb>
    ilock(ip);
80102344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102347:	89 04 24             	mov    %eax,(%esp)
8010234a:	e8 25 f5 ff ff       	call   80101874 <ilock>
    if(ip->type != T_DIR){
8010234f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102352:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102356:	66 83 f8 01          	cmp    $0x1,%ax
8010235a:	74 15                	je     80102371 <namex+0x72>
      iunlockput(ip);
8010235c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235f:	89 04 24             	mov    %eax,(%esp)
80102362:	e8 91 f7 ff ff       	call   80101af8 <iunlockput>
      return 0;
80102367:	b8 00 00 00 00       	mov    $0x0,%eax
8010236c:	e9 a3 00 00 00       	jmp    80102414 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102371:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102375:	74 1d                	je     80102394 <namex+0x95>
80102377:	8b 45 08             	mov    0x8(%ebp),%eax
8010237a:	0f b6 00             	movzbl (%eax),%eax
8010237d:	84 c0                	test   %al,%al
8010237f:	75 13                	jne    80102394 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102384:	89 04 24             	mov    %eax,(%esp)
80102387:	e8 36 f6 ff ff       	call   801019c2 <iunlock>
      return ip;
8010238c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010238f:	e9 80 00 00 00       	jmp    80102414 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102394:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010239b:	00 
8010239c:	8b 45 10             	mov    0x10(%ebp),%eax
8010239f:	89 44 24 04          	mov    %eax,0x4(%esp)
801023a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a6:	89 04 24             	mov    %eax,(%esp)
801023a9:	e8 df fc ff ff       	call   8010208d <dirlookup>
801023ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023b5:	75 12                	jne    801023c9 <namex+0xca>
      iunlockput(ip);
801023b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ba:	89 04 24             	mov    %eax,(%esp)
801023bd:	e8 36 f7 ff ff       	call   80101af8 <iunlockput>
      return 0;
801023c2:	b8 00 00 00 00       	mov    $0x0,%eax
801023c7:	eb 4b                	jmp    80102414 <namex+0x115>
    }
    iunlockput(ip);
801023c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023cc:	89 04 24             	mov    %eax,(%esp)
801023cf:	e8 24 f7 ff ff       	call   80101af8 <iunlockput>
    ip = next;
801023d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023da:	8b 45 10             	mov    0x10(%ebp),%eax
801023dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801023e1:	8b 45 08             	mov    0x8(%ebp),%eax
801023e4:	89 04 24             	mov    %eax,(%esp)
801023e7:	e8 61 fe ff ff       	call   8010224d <skipelem>
801023ec:	89 45 08             	mov    %eax,0x8(%ebp)
801023ef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801023f3:	0f 85 4b ff ff ff    	jne    80102344 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801023f9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023fd:	74 12                	je     80102411 <namex+0x112>
    iput(ip);
801023ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102402:	89 04 24             	mov    %eax,(%esp)
80102405:	e8 1d f6 ff ff       	call   80101a27 <iput>
    return 0;
8010240a:	b8 00 00 00 00       	mov    $0x0,%eax
8010240f:	eb 03                	jmp    80102414 <namex+0x115>
  }
  return ip;
80102411:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102414:	c9                   	leave  
80102415:	c3                   	ret    

80102416 <namei>:

struct inode*
namei(char *path)
{
80102416:	55                   	push   %ebp
80102417:	89 e5                	mov    %esp,%ebp
80102419:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010241c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010241f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102423:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010242a:	00 
8010242b:	8b 45 08             	mov    0x8(%ebp),%eax
8010242e:	89 04 24             	mov    %eax,(%esp)
80102431:	e8 c9 fe ff ff       	call   801022ff <namex>
}
80102436:	c9                   	leave  
80102437:	c3                   	ret    

80102438 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102438:	55                   	push   %ebp
80102439:	89 e5                	mov    %esp,%ebp
8010243b:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010243e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102441:	89 44 24 08          	mov    %eax,0x8(%esp)
80102445:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010244c:	00 
8010244d:	8b 45 08             	mov    0x8(%ebp),%eax
80102450:	89 04 24             	mov    %eax,(%esp)
80102453:	e8 a7 fe ff ff       	call   801022ff <namex>
}
80102458:	c9                   	leave  
80102459:	c3                   	ret    
	...

8010245c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010245c:	55                   	push   %ebp
8010245d:	89 e5                	mov    %esp,%ebp
8010245f:	53                   	push   %ebx
80102460:	83 ec 14             	sub    $0x14,%esp
80102463:	8b 45 08             	mov    0x8(%ebp),%eax
80102466:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010246a:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010246e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102472:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102476:	ec                   	in     (%dx),%al
80102477:	89 c3                	mov    %eax,%ebx
80102479:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010247c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102480:	83 c4 14             	add    $0x14,%esp
80102483:	5b                   	pop    %ebx
80102484:	5d                   	pop    %ebp
80102485:	c3                   	ret    

80102486 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102486:	55                   	push   %ebp
80102487:	89 e5                	mov    %esp,%ebp
80102489:	57                   	push   %edi
8010248a:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010248b:	8b 55 08             	mov    0x8(%ebp),%edx
8010248e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102491:	8b 45 10             	mov    0x10(%ebp),%eax
80102494:	89 cb                	mov    %ecx,%ebx
80102496:	89 df                	mov    %ebx,%edi
80102498:	89 c1                	mov    %eax,%ecx
8010249a:	fc                   	cld    
8010249b:	f3 6d                	rep insl (%dx),%es:(%edi)
8010249d:	89 c8                	mov    %ecx,%eax
8010249f:	89 fb                	mov    %edi,%ebx
801024a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024a4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801024a7:	5b                   	pop    %ebx
801024a8:	5f                   	pop    %edi
801024a9:	5d                   	pop    %ebp
801024aa:	c3                   	ret    

801024ab <outb>:

static inline void
outb(ushort port, uchar data)
{
801024ab:	55                   	push   %ebp
801024ac:	89 e5                	mov    %esp,%ebp
801024ae:	83 ec 08             	sub    $0x8,%esp
801024b1:	8b 55 08             	mov    0x8(%ebp),%edx
801024b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024bb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024be:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024c2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024c6:	ee                   	out    %al,(%dx)
}
801024c7:	c9                   	leave  
801024c8:	c3                   	ret    

801024c9 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024c9:	55                   	push   %ebp
801024ca:	89 e5                	mov    %esp,%ebp
801024cc:	56                   	push   %esi
801024cd:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024ce:	8b 55 08             	mov    0x8(%ebp),%edx
801024d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024d4:	8b 45 10             	mov    0x10(%ebp),%eax
801024d7:	89 cb                	mov    %ecx,%ebx
801024d9:	89 de                	mov    %ebx,%esi
801024db:	89 c1                	mov    %eax,%ecx
801024dd:	fc                   	cld    
801024de:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024e0:	89 c8                	mov    %ecx,%eax
801024e2:	89 f3                	mov    %esi,%ebx
801024e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024e7:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801024ea:	5b                   	pop    %ebx
801024eb:	5e                   	pop    %esi
801024ec:	5d                   	pop    %ebp
801024ed:	c3                   	ret    

801024ee <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801024ee:	55                   	push   %ebp
801024ef:	89 e5                	mov    %esp,%ebp
801024f1:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801024f4:	90                   	nop
801024f5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801024fc:	e8 5b ff ff ff       	call   8010245c <inb>
80102501:	0f b6 c0             	movzbl %al,%eax
80102504:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102507:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010250a:	25 c0 00 00 00       	and    $0xc0,%eax
8010250f:	83 f8 40             	cmp    $0x40,%eax
80102512:	75 e1                	jne    801024f5 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102514:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102518:	74 11                	je     8010252b <idewait+0x3d>
8010251a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010251d:	83 e0 21             	and    $0x21,%eax
80102520:	85 c0                	test   %eax,%eax
80102522:	74 07                	je     8010252b <idewait+0x3d>
    return -1;
80102524:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102529:	eb 05                	jmp    80102530 <idewait+0x42>
  return 0;
8010252b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102530:	c9                   	leave  
80102531:	c3                   	ret    

80102532 <ideinit>:

void
ideinit(void)
{
80102532:	55                   	push   %ebp
80102533:	89 e5                	mov    %esp,%ebp
80102535:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102538:	c7 44 24 04 ec 85 10 	movl   $0x801085ec,0x4(%esp)
8010253f:	80 
80102540:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102547:	e8 0a 29 00 00       	call   80104e56 <initlock>
  picenable(IRQ_IDE);
8010254c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102553:	e8 c1 18 00 00       	call   80103e19 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102558:	a1 40 29 11 80       	mov    0x80112940,%eax
8010255d:	83 e8 01             	sub    $0x1,%eax
80102560:	89 44 24 04          	mov    %eax,0x4(%esp)
80102564:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010256b:	e8 12 04 00 00       	call   80102982 <ioapicenable>
  idewait(0);
80102570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102577:	e8 72 ff ff ff       	call   801024ee <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010257c:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102583:	00 
80102584:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010258b:	e8 1b ff ff ff       	call   801024ab <outb>
  for(i=0; i<1000; i++){
80102590:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102597:	eb 20                	jmp    801025b9 <ideinit+0x87>
    if(inb(0x1f7) != 0){
80102599:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025a0:	e8 b7 fe ff ff       	call   8010245c <inb>
801025a5:	84 c0                	test   %al,%al
801025a7:	74 0c                	je     801025b5 <ideinit+0x83>
      havedisk1 = 1;
801025a9:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801025b0:	00 00 00 
      break;
801025b3:	eb 0d                	jmp    801025c2 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025b9:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025c0:	7e d7                	jle    80102599 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025c2:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025c9:	00 
801025ca:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025d1:	e8 d5 fe ff ff       	call   801024ab <outb>
}
801025d6:	c9                   	leave  
801025d7:	c3                   	ret    

801025d8 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025d8:	55                   	push   %ebp
801025d9:	89 e5                	mov    %esp,%ebp
801025db:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025de:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025e2:	75 0c                	jne    801025f0 <idestart+0x18>
    panic("idestart");
801025e4:	c7 04 24 f0 85 10 80 	movl   $0x801085f0,(%esp)
801025eb:	e8 4d df ff ff       	call   8010053d <panic>

  idewait(0);
801025f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025f7:	e8 f2 fe ff ff       	call   801024ee <idewait>
  outb(0x3f6, 0);  // generate interrupt
801025fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102603:	00 
80102604:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010260b:	e8 9b fe ff ff       	call   801024ab <outb>
  outb(0x1f2, 1);  // number of sectors
80102610:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102617:	00 
80102618:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010261f:	e8 87 fe ff ff       	call   801024ab <outb>
  outb(0x1f3, b->sector & 0xff);
80102624:	8b 45 08             	mov    0x8(%ebp),%eax
80102627:	8b 40 08             	mov    0x8(%eax),%eax
8010262a:	0f b6 c0             	movzbl %al,%eax
8010262d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102631:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102638:	e8 6e fe ff ff       	call   801024ab <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010263d:	8b 45 08             	mov    0x8(%ebp),%eax
80102640:	8b 40 08             	mov    0x8(%eax),%eax
80102643:	c1 e8 08             	shr    $0x8,%eax
80102646:	0f b6 c0             	movzbl %al,%eax
80102649:	89 44 24 04          	mov    %eax,0x4(%esp)
8010264d:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102654:	e8 52 fe ff ff       	call   801024ab <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102659:	8b 45 08             	mov    0x8(%ebp),%eax
8010265c:	8b 40 08             	mov    0x8(%eax),%eax
8010265f:	c1 e8 10             	shr    $0x10,%eax
80102662:	0f b6 c0             	movzbl %al,%eax
80102665:	89 44 24 04          	mov    %eax,0x4(%esp)
80102669:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102670:	e8 36 fe ff ff       	call   801024ab <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102675:	8b 45 08             	mov    0x8(%ebp),%eax
80102678:	8b 40 04             	mov    0x4(%eax),%eax
8010267b:	83 e0 01             	and    $0x1,%eax
8010267e:	89 c2                	mov    %eax,%edx
80102680:	c1 e2 04             	shl    $0x4,%edx
80102683:	8b 45 08             	mov    0x8(%ebp),%eax
80102686:	8b 40 08             	mov    0x8(%eax),%eax
80102689:	c1 e8 18             	shr    $0x18,%eax
8010268c:	83 e0 0f             	and    $0xf,%eax
8010268f:	09 d0                	or     %edx,%eax
80102691:	83 c8 e0             	or     $0xffffffe0,%eax
80102694:	0f b6 c0             	movzbl %al,%eax
80102697:	89 44 24 04          	mov    %eax,0x4(%esp)
8010269b:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026a2:	e8 04 fe ff ff       	call   801024ab <outb>
  if(b->flags & B_DIRTY){
801026a7:	8b 45 08             	mov    0x8(%ebp),%eax
801026aa:	8b 00                	mov    (%eax),%eax
801026ac:	83 e0 04             	and    $0x4,%eax
801026af:	85 c0                	test   %eax,%eax
801026b1:	74 34                	je     801026e7 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026b3:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026ba:	00 
801026bb:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026c2:	e8 e4 fd ff ff       	call   801024ab <outb>
    outsl(0x1f0, b->data, 512/4);
801026c7:	8b 45 08             	mov    0x8(%ebp),%eax
801026ca:	83 c0 18             	add    $0x18,%eax
801026cd:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026d4:	00 
801026d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801026d9:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026e0:	e8 e4 fd ff ff       	call   801024c9 <outsl>
801026e5:	eb 14                	jmp    801026fb <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026e7:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
801026ee:	00 
801026ef:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026f6:	e8 b0 fd ff ff       	call   801024ab <outb>
  }
}
801026fb:	c9                   	leave  
801026fc:	c3                   	ret    

801026fd <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801026fd:	55                   	push   %ebp
801026fe:	89 e5                	mov    %esp,%ebp
80102700:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102703:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010270a:	e8 68 27 00 00       	call   80104e77 <acquire>
  if((b = idequeue) == 0){
8010270f:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102714:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010271b:	75 11                	jne    8010272e <ideintr+0x31>
    release(&idelock);
8010271d:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102724:	e8 b0 27 00 00       	call   80104ed9 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102729:	e9 90 00 00 00       	jmp    801027be <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102731:	8b 40 14             	mov    0x14(%eax),%eax
80102734:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273c:	8b 00                	mov    (%eax),%eax
8010273e:	83 e0 04             	and    $0x4,%eax
80102741:	85 c0                	test   %eax,%eax
80102743:	75 2e                	jne    80102773 <ideintr+0x76>
80102745:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010274c:	e8 9d fd ff ff       	call   801024ee <idewait>
80102751:	85 c0                	test   %eax,%eax
80102753:	78 1e                	js     80102773 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102758:	83 c0 18             	add    $0x18,%eax
8010275b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102762:	00 
80102763:	89 44 24 04          	mov    %eax,0x4(%esp)
80102767:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010276e:	e8 13 fd ff ff       	call   80102486 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102776:	8b 00                	mov    (%eax),%eax
80102778:	89 c2                	mov    %eax,%edx
8010277a:	83 ca 02             	or     $0x2,%edx
8010277d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102780:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102785:	8b 00                	mov    (%eax),%eax
80102787:	89 c2                	mov    %eax,%edx
80102789:	83 e2 fb             	and    $0xfffffffb,%edx
8010278c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278f:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102794:	89 04 24             	mov    %eax,(%esp)
80102797:	e8 d5 24 00 00       	call   80104c71 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010279c:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801027a1:	85 c0                	test   %eax,%eax
801027a3:	74 0d                	je     801027b2 <ideintr+0xb5>
    idestart(idequeue);
801027a5:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801027aa:	89 04 24             	mov    %eax,(%esp)
801027ad:	e8 26 fe ff ff       	call   801025d8 <idestart>

  release(&idelock);
801027b2:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027b9:	e8 1b 27 00 00       	call   80104ed9 <release>
}
801027be:	c9                   	leave  
801027bf:	c3                   	ret    

801027c0 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027c0:	55                   	push   %ebp
801027c1:	89 e5                	mov    %esp,%ebp
801027c3:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027c6:	8b 45 08             	mov    0x8(%ebp),%eax
801027c9:	8b 00                	mov    (%eax),%eax
801027cb:	83 e0 01             	and    $0x1,%eax
801027ce:	85 c0                	test   %eax,%eax
801027d0:	75 0c                	jne    801027de <iderw+0x1e>
    panic("iderw: buf not busy");
801027d2:	c7 04 24 f9 85 10 80 	movl   $0x801085f9,(%esp)
801027d9:	e8 5f dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027de:	8b 45 08             	mov    0x8(%ebp),%eax
801027e1:	8b 00                	mov    (%eax),%eax
801027e3:	83 e0 06             	and    $0x6,%eax
801027e6:	83 f8 02             	cmp    $0x2,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x37>
    panic("iderw: nothing to do");
801027eb:	c7 04 24 0d 86 10 80 	movl   $0x8010860d,(%esp)
801027f2:	e8 46 dd ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
801027f7:	8b 45 08             	mov    0x8(%ebp),%eax
801027fa:	8b 40 04             	mov    0x4(%eax),%eax
801027fd:	85 c0                	test   %eax,%eax
801027ff:	74 15                	je     80102816 <iderw+0x56>
80102801:	a1 38 b6 10 80       	mov    0x8010b638,%eax
80102806:	85 c0                	test   %eax,%eax
80102808:	75 0c                	jne    80102816 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
8010280a:	c7 04 24 22 86 10 80 	movl   $0x80108622,(%esp)
80102811:	e8 27 dd ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102816:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010281d:	e8 55 26 00 00       	call   80104e77 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102822:	8b 45 08             	mov    0x8(%ebp),%eax
80102825:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010282c:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
80102833:	eb 0b                	jmp    80102840 <iderw+0x80>
80102835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102838:	8b 00                	mov    (%eax),%eax
8010283a:	83 c0 14             	add    $0x14,%eax
8010283d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102843:	8b 00                	mov    (%eax),%eax
80102845:	85 c0                	test   %eax,%eax
80102847:	75 ec                	jne    80102835 <iderw+0x75>
    ;
  *pp = b;
80102849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010284c:	8b 55 08             	mov    0x8(%ebp),%edx
8010284f:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102851:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102856:	3b 45 08             	cmp    0x8(%ebp),%eax
80102859:	75 22                	jne    8010287d <iderw+0xbd>
    idestart(b);
8010285b:	8b 45 08             	mov    0x8(%ebp),%eax
8010285e:	89 04 24             	mov    %eax,(%esp)
80102861:	e8 72 fd ff ff       	call   801025d8 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102866:	eb 15                	jmp    8010287d <iderw+0xbd>
    sleep(b, &idelock);
80102868:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
8010286f:	80 
80102870:	8b 45 08             	mov    0x8(%ebp),%eax
80102873:	89 04 24             	mov    %eax,(%esp)
80102876:	e8 1d 23 00 00       	call   80104b98 <sleep>
8010287b:	eb 01                	jmp    8010287e <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010287d:	90                   	nop
8010287e:	8b 45 08             	mov    0x8(%ebp),%eax
80102881:	8b 00                	mov    (%eax),%eax
80102883:	83 e0 06             	and    $0x6,%eax
80102886:	83 f8 02             	cmp    $0x2,%eax
80102889:	75 dd                	jne    80102868 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
8010288b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102892:	e8 42 26 00 00       	call   80104ed9 <release>
}
80102897:	c9                   	leave  
80102898:	c3                   	ret    
80102899:	00 00                	add    %al,(%eax)
	...

8010289c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010289c:	55                   	push   %ebp
8010289d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010289f:	a1 14 22 11 80       	mov    0x80112214,%eax
801028a4:	8b 55 08             	mov    0x8(%ebp),%edx
801028a7:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801028a9:	a1 14 22 11 80       	mov    0x80112214,%eax
801028ae:	8b 40 10             	mov    0x10(%eax),%eax
}
801028b1:	5d                   	pop    %ebp
801028b2:	c3                   	ret    

801028b3 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801028b3:	55                   	push   %ebp
801028b4:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028b6:	a1 14 22 11 80       	mov    0x80112214,%eax
801028bb:	8b 55 08             	mov    0x8(%ebp),%edx
801028be:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028c0:	a1 14 22 11 80       	mov    0x80112214,%eax
801028c5:	8b 55 0c             	mov    0xc(%ebp),%edx
801028c8:	89 50 10             	mov    %edx,0x10(%eax)
}
801028cb:	5d                   	pop    %ebp
801028cc:	c3                   	ret    

801028cd <ioapicinit>:

void
ioapicinit(void)
{
801028cd:	55                   	push   %ebp
801028ce:	89 e5                	mov    %esp,%ebp
801028d0:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028d3:	a1 44 23 11 80       	mov    0x80112344,%eax
801028d8:	85 c0                	test   %eax,%eax
801028da:	0f 84 9f 00 00 00    	je     8010297f <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801028e0:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
801028e7:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801028ea:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028f1:	e8 a6 ff ff ff       	call   8010289c <ioapicread>
801028f6:	c1 e8 10             	shr    $0x10,%eax
801028f9:	25 ff 00 00 00       	and    $0xff,%eax
801028fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102901:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102908:	e8 8f ff ff ff       	call   8010289c <ioapicread>
8010290d:	c1 e8 18             	shr    $0x18,%eax
80102910:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102913:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
8010291a:	0f b6 c0             	movzbl %al,%eax
8010291d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102920:	74 0c                	je     8010292e <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102922:	c7 04 24 40 86 10 80 	movl   $0x80108640,(%esp)
80102929:	e8 73 da ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010292e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102935:	eb 3e                	jmp    80102975 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293a:	83 c0 20             	add    $0x20,%eax
8010293d:	0d 00 00 01 00       	or     $0x10000,%eax
80102942:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102945:	83 c2 08             	add    $0x8,%edx
80102948:	01 d2                	add    %edx,%edx
8010294a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010294e:	89 14 24             	mov    %edx,(%esp)
80102951:	e8 5d ff ff ff       	call   801028b3 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102959:	83 c0 08             	add    $0x8,%eax
8010295c:	01 c0                	add    %eax,%eax
8010295e:	83 c0 01             	add    $0x1,%eax
80102961:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102968:	00 
80102969:	89 04 24             	mov    %eax,(%esp)
8010296c:	e8 42 ff ff ff       	call   801028b3 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102971:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102978:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010297b:	7e ba                	jle    80102937 <ioapicinit+0x6a>
8010297d:	eb 01                	jmp    80102980 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
8010297f:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102980:	c9                   	leave  
80102981:	c3                   	ret    

80102982 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102982:	55                   	push   %ebp
80102983:	89 e5                	mov    %esp,%ebp
80102985:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102988:	a1 44 23 11 80       	mov    0x80112344,%eax
8010298d:	85 c0                	test   %eax,%eax
8010298f:	74 39                	je     801029ca <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102991:	8b 45 08             	mov    0x8(%ebp),%eax
80102994:	83 c0 20             	add    $0x20,%eax
80102997:	8b 55 08             	mov    0x8(%ebp),%edx
8010299a:	83 c2 08             	add    $0x8,%edx
8010299d:	01 d2                	add    %edx,%edx
8010299f:	89 44 24 04          	mov    %eax,0x4(%esp)
801029a3:	89 14 24             	mov    %edx,(%esp)
801029a6:	e8 08 ff ff ff       	call   801028b3 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801029ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801029ae:	c1 e0 18             	shl    $0x18,%eax
801029b1:	8b 55 08             	mov    0x8(%ebp),%edx
801029b4:	83 c2 08             	add    $0x8,%edx
801029b7:	01 d2                	add    %edx,%edx
801029b9:	83 c2 01             	add    $0x1,%edx
801029bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801029c0:	89 14 24             	mov    %edx,(%esp)
801029c3:	e8 eb fe ff ff       	call   801028b3 <ioapicwrite>
801029c8:	eb 01                	jmp    801029cb <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
801029ca:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801029cb:	c9                   	leave  
801029cc:	c3                   	ret    
801029cd:	00 00                	add    %al,(%eax)
	...

801029d0 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029d0:	55                   	push   %ebp
801029d1:	89 e5                	mov    %esp,%ebp
801029d3:	8b 45 08             	mov    0x8(%ebp),%eax
801029d6:	05 00 00 00 80       	add    $0x80000000,%eax
801029db:	5d                   	pop    %ebp
801029dc:	c3                   	ret    

801029dd <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029dd:	55                   	push   %ebp
801029de:	89 e5                	mov    %esp,%ebp
801029e0:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029e3:	c7 44 24 04 72 86 10 	movl   $0x80108672,0x4(%esp)
801029ea:	80 
801029eb:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
801029f2:	e8 5f 24 00 00       	call   80104e56 <initlock>
  kmem.use_lock = 0;
801029f7:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
801029fe:	00 00 00 
  freerange(vstart, vend);
80102a01:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a04:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a08:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0b:	89 04 24             	mov    %eax,(%esp)
80102a0e:	e8 26 00 00 00       	call   80102a39 <freerange>
}
80102a13:	c9                   	leave  
80102a14:	c3                   	ret    

80102a15 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a15:	55                   	push   %ebp
80102a16:	89 e5                	mov    %esp,%ebp
80102a18:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a22:	8b 45 08             	mov    0x8(%ebp),%eax
80102a25:	89 04 24             	mov    %eax,(%esp)
80102a28:	e8 0c 00 00 00       	call   80102a39 <freerange>
  kmem.use_lock = 1;
80102a2d:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102a34:	00 00 00 
}
80102a37:	c9                   	leave  
80102a38:	c3                   	ret    

80102a39 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a39:	55                   	push   %ebp
80102a3a:	89 e5                	mov    %esp,%ebp
80102a3c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a3f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a42:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a4f:	eb 12                	jmp    80102a63 <freerange+0x2a>
    kfree(p);
80102a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a54:	89 04 24             	mov    %eax,(%esp)
80102a57:	e8 16 00 00 00       	call   80102a72 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a5c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a66:	05 00 10 00 00       	add    $0x1000,%eax
80102a6b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a6e:	76 e1                	jbe    80102a51 <freerange+0x18>
    kfree(p);
}
80102a70:	c9                   	leave  
80102a71:	c3                   	ret    

80102a72 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a72:	55                   	push   %ebp
80102a73:	89 e5                	mov    %esp,%ebp
80102a75:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a78:	8b 45 08             	mov    0x8(%ebp),%eax
80102a7b:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a80:	85 c0                	test   %eax,%eax
80102a82:	75 1b                	jne    80102a9f <kfree+0x2d>
80102a84:	81 7d 08 3c 52 11 80 	cmpl   $0x8011523c,0x8(%ebp)
80102a8b:	72 12                	jb     80102a9f <kfree+0x2d>
80102a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a90:	89 04 24             	mov    %eax,(%esp)
80102a93:	e8 38 ff ff ff       	call   801029d0 <v2p>
80102a98:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a9d:	76 0c                	jbe    80102aab <kfree+0x39>
    panic("kfree");
80102a9f:	c7 04 24 77 86 10 80 	movl   $0x80108677,(%esp)
80102aa6:	e8 92 da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102aab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102ab2:	00 
80102ab3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102aba:	00 
80102abb:	8b 45 08             	mov    0x8(%ebp),%eax
80102abe:	89 04 24             	mov    %eax,(%esp)
80102ac1:	e8 00 26 00 00       	call   801050c6 <memset>

  if(kmem.use_lock)
80102ac6:	a1 54 22 11 80       	mov    0x80112254,%eax
80102acb:	85 c0                	test   %eax,%eax
80102acd:	74 0c                	je     80102adb <kfree+0x69>
    acquire(&kmem.lock);
80102acf:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102ad6:	e8 9c 23 00 00       	call   80104e77 <acquire>
  r = (struct run*)v;
80102adb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ade:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ae1:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aea:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aef:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102af4:	a1 54 22 11 80       	mov    0x80112254,%eax
80102af9:	85 c0                	test   %eax,%eax
80102afb:	74 0c                	je     80102b09 <kfree+0x97>
    release(&kmem.lock);
80102afd:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b04:	e8 d0 23 00 00       	call   80104ed9 <release>
}
80102b09:	c9                   	leave  
80102b0a:	c3                   	ret    

80102b0b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b0b:	55                   	push   %ebp
80102b0c:	89 e5                	mov    %esp,%ebp
80102b0e:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b11:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b16:	85 c0                	test   %eax,%eax
80102b18:	74 0c                	je     80102b26 <kalloc+0x1b>
    acquire(&kmem.lock);
80102b1a:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b21:	e8 51 23 00 00       	call   80104e77 <acquire>
  r = kmem.freelist;
80102b26:	a1 58 22 11 80       	mov    0x80112258,%eax
80102b2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b32:	74 0a                	je     80102b3e <kalloc+0x33>
    kmem.freelist = r->next;
80102b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b37:	8b 00                	mov    (%eax),%eax
80102b39:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102b3e:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b43:	85 c0                	test   %eax,%eax
80102b45:	74 0c                	je     80102b53 <kalloc+0x48>
    release(&kmem.lock);
80102b47:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b4e:	e8 86 23 00 00       	call   80104ed9 <release>
  return (char*)r;
80102b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b56:	c9                   	leave  
80102b57:	c3                   	ret    

80102b58 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b58:	55                   	push   %ebp
80102b59:	89 e5                	mov    %esp,%ebp
80102b5b:	53                   	push   %ebx
80102b5c:	83 ec 14             	sub    $0x14,%esp
80102b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b62:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b66:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102b6a:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102b6e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102b72:	ec                   	in     (%dx),%al
80102b73:	89 c3                	mov    %eax,%ebx
80102b75:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102b78:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102b7c:	83 c4 14             	add    $0x14,%esp
80102b7f:	5b                   	pop    %ebx
80102b80:	5d                   	pop    %ebp
80102b81:	c3                   	ret    

80102b82 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b82:	55                   	push   %ebp
80102b83:	89 e5                	mov    %esp,%ebp
80102b85:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b88:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b8f:	e8 c4 ff ff ff       	call   80102b58 <inb>
80102b94:	0f b6 c0             	movzbl %al,%eax
80102b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9d:	83 e0 01             	and    $0x1,%eax
80102ba0:	85 c0                	test   %eax,%eax
80102ba2:	75 0a                	jne    80102bae <kbdgetc+0x2c>
    return -1;
80102ba4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ba9:	e9 23 01 00 00       	jmp    80102cd1 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102bae:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102bb5:	e8 9e ff ff ff       	call   80102b58 <inb>
80102bba:	0f b6 c0             	movzbl %al,%eax
80102bbd:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102bc0:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102bc7:	75 17                	jne    80102be0 <kbdgetc+0x5e>
    shift |= E0ESC;
80102bc9:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bce:	83 c8 40             	or     $0x40,%eax
80102bd1:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102bd6:	b8 00 00 00 00       	mov    $0x0,%eax
80102bdb:	e9 f1 00 00 00       	jmp    80102cd1 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102be0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102be3:	25 80 00 00 00       	and    $0x80,%eax
80102be8:	85 c0                	test   %eax,%eax
80102bea:	74 45                	je     80102c31 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102bec:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102bf1:	83 e0 40             	and    $0x40,%eax
80102bf4:	85 c0                	test   %eax,%eax
80102bf6:	75 08                	jne    80102c00 <kbdgetc+0x7e>
80102bf8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bfb:	83 e0 7f             	and    $0x7f,%eax
80102bfe:	eb 03                	jmp    80102c03 <kbdgetc+0x81>
80102c00:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c03:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c09:	05 20 90 10 80       	add    $0x80109020,%eax
80102c0e:	0f b6 00             	movzbl (%eax),%eax
80102c11:	83 c8 40             	or     $0x40,%eax
80102c14:	0f b6 c0             	movzbl %al,%eax
80102c17:	f7 d0                	not    %eax
80102c19:	89 c2                	mov    %eax,%edx
80102c1b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c20:	21 d0                	and    %edx,%eax
80102c22:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102c27:	b8 00 00 00 00       	mov    $0x0,%eax
80102c2c:	e9 a0 00 00 00       	jmp    80102cd1 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102c31:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c36:	83 e0 40             	and    $0x40,%eax
80102c39:	85 c0                	test   %eax,%eax
80102c3b:	74 14                	je     80102c51 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c3d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c44:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c49:	83 e0 bf             	and    $0xffffffbf,%eax
80102c4c:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102c51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c54:	05 20 90 10 80       	add    $0x80109020,%eax
80102c59:	0f b6 00             	movzbl (%eax),%eax
80102c5c:	0f b6 d0             	movzbl %al,%edx
80102c5f:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c64:	09 d0                	or     %edx,%eax
80102c66:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102c6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6e:	05 20 91 10 80       	add    $0x80109120,%eax
80102c73:	0f b6 00             	movzbl (%eax),%eax
80102c76:	0f b6 d0             	movzbl %al,%edx
80102c79:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c7e:	31 d0                	xor    %edx,%eax
80102c80:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c85:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c8a:	83 e0 03             	and    $0x3,%eax
80102c8d:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102c94:	03 45 fc             	add    -0x4(%ebp),%eax
80102c97:	0f b6 00             	movzbl (%eax),%eax
80102c9a:	0f b6 c0             	movzbl %al,%eax
80102c9d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ca0:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ca5:	83 e0 08             	and    $0x8,%eax
80102ca8:	85 c0                	test   %eax,%eax
80102caa:	74 22                	je     80102cce <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102cac:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102cb0:	76 0c                	jbe    80102cbe <kbdgetc+0x13c>
80102cb2:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102cb6:	77 06                	ja     80102cbe <kbdgetc+0x13c>
      c += 'A' - 'a';
80102cb8:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102cbc:	eb 10                	jmp    80102cce <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102cbe:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102cc2:	76 0a                	jbe    80102cce <kbdgetc+0x14c>
80102cc4:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102cc8:	77 04                	ja     80102cce <kbdgetc+0x14c>
      c += 'a' - 'A';
80102cca:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102cce:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102cd1:	c9                   	leave  
80102cd2:	c3                   	ret    

80102cd3 <kbdintr>:

void
kbdintr(void)
{
80102cd3:	55                   	push   %ebp
80102cd4:	89 e5                	mov    %esp,%ebp
80102cd6:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102cd9:	c7 04 24 82 2b 10 80 	movl   $0x80102b82,(%esp)
80102ce0:	e8 c8 da ff ff       	call   801007ad <consoleintr>
}
80102ce5:	c9                   	leave  
80102ce6:	c3                   	ret    
	...

80102ce8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ce8:	55                   	push   %ebp
80102ce9:	89 e5                	mov    %esp,%ebp
80102ceb:	53                   	push   %ebx
80102cec:	83 ec 14             	sub    $0x14,%esp
80102cef:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102cfa:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102cfe:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102d02:	ec                   	in     (%dx),%al
80102d03:	89 c3                	mov    %eax,%ebx
80102d05:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102d08:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102d0c:	83 c4 14             	add    $0x14,%esp
80102d0f:	5b                   	pop    %ebx
80102d10:	5d                   	pop    %ebp
80102d11:	c3                   	ret    

80102d12 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d12:	55                   	push   %ebp
80102d13:	89 e5                	mov    %esp,%ebp
80102d15:	83 ec 08             	sub    $0x8,%esp
80102d18:	8b 55 08             	mov    0x8(%ebp),%edx
80102d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d1e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d22:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d25:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d29:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d2d:	ee                   	out    %al,(%dx)
}
80102d2e:	c9                   	leave  
80102d2f:	c3                   	ret    

80102d30 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102d30:	55                   	push   %ebp
80102d31:	89 e5                	mov    %esp,%ebp
80102d33:	53                   	push   %ebx
80102d34:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d37:	9c                   	pushf  
80102d38:	5b                   	pop    %ebx
80102d39:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102d3c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d3f:	83 c4 10             	add    $0x10,%esp
80102d42:	5b                   	pop    %ebx
80102d43:	5d                   	pop    %ebp
80102d44:	c3                   	ret    

80102d45 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d45:	55                   	push   %ebp
80102d46:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d48:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d4d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d50:	c1 e2 02             	shl    $0x2,%edx
80102d53:	01 c2                	add    %eax,%edx
80102d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d58:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d5a:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d5f:	83 c0 20             	add    $0x20,%eax
80102d62:	8b 00                	mov    (%eax),%eax
}
80102d64:	5d                   	pop    %ebp
80102d65:	c3                   	ret    

80102d66 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d66:	55                   	push   %ebp
80102d67:	89 e5                	mov    %esp,%ebp
80102d69:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d6c:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d71:	85 c0                	test   %eax,%eax
80102d73:	0f 84 47 01 00 00    	je     80102ec0 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d79:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d80:	00 
80102d81:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102d88:	e8 b8 ff ff ff       	call   80102d45 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102d8d:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102d94:	00 
80102d95:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d9c:	e8 a4 ff ff ff       	call   80102d45 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102da1:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102da8:	00 
80102da9:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102db0:	e8 90 ff ff ff       	call   80102d45 <lapicw>
  lapicw(TICR, 10000000); 
80102db5:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102dbc:	00 
80102dbd:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102dc4:	e8 7c ff ff ff       	call   80102d45 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102dc9:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dd0:	00 
80102dd1:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102dd8:	e8 68 ff ff ff       	call   80102d45 <lapicw>
  lapicw(LINT1, MASKED);
80102ddd:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102de4:	00 
80102de5:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102dec:	e8 54 ff ff ff       	call   80102d45 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102df1:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102df6:	83 c0 30             	add    $0x30,%eax
80102df9:	8b 00                	mov    (%eax),%eax
80102dfb:	c1 e8 10             	shr    $0x10,%eax
80102dfe:	25 ff 00 00 00       	and    $0xff,%eax
80102e03:	83 f8 03             	cmp    $0x3,%eax
80102e06:	76 14                	jbe    80102e1c <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80102e08:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e0f:	00 
80102e10:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e17:	e8 29 ff ff ff       	call   80102d45 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e1c:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e23:	00 
80102e24:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e2b:	e8 15 ff ff ff       	call   80102d45 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e30:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e37:	00 
80102e38:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e3f:	e8 01 ff ff ff       	call   80102d45 <lapicw>
  lapicw(ESR, 0);
80102e44:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e4b:	00 
80102e4c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e53:	e8 ed fe ff ff       	call   80102d45 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e5f:	00 
80102e60:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e67:	e8 d9 fe ff ff       	call   80102d45 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e73:	00 
80102e74:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e7b:	e8 c5 fe ff ff       	call   80102d45 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e80:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e87:	00 
80102e88:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102e8f:	e8 b1 fe ff ff       	call   80102d45 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102e94:	90                   	nop
80102e95:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e9a:	05 00 03 00 00       	add    $0x300,%eax
80102e9f:	8b 00                	mov    (%eax),%eax
80102ea1:	25 00 10 00 00       	and    $0x1000,%eax
80102ea6:	85 c0                	test   %eax,%eax
80102ea8:	75 eb                	jne    80102e95 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102eaa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102eb1:	00 
80102eb2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102eb9:	e8 87 fe ff ff       	call   80102d45 <lapicw>
80102ebe:	eb 01                	jmp    80102ec1 <lapicinit+0x15b>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102ec0:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102ec1:	c9                   	leave  
80102ec2:	c3                   	ret    

80102ec3 <cpunum>:

int
cpunum(void)
{
80102ec3:	55                   	push   %ebp
80102ec4:	89 e5                	mov    %esp,%ebp
80102ec6:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102ec9:	e8 62 fe ff ff       	call   80102d30 <readeflags>
80102ece:	25 00 02 00 00       	and    $0x200,%eax
80102ed3:	85 c0                	test   %eax,%eax
80102ed5:	74 29                	je     80102f00 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80102ed7:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102edc:	85 c0                	test   %eax,%eax
80102ede:	0f 94 c2             	sete   %dl
80102ee1:	83 c0 01             	add    $0x1,%eax
80102ee4:	a3 40 b6 10 80       	mov    %eax,0x8010b640
80102ee9:	84 d2                	test   %dl,%dl
80102eeb:	74 13                	je     80102f00 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80102eed:	8b 45 04             	mov    0x4(%ebp),%eax
80102ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ef4:	c7 04 24 80 86 10 80 	movl   $0x80108680,(%esp)
80102efb:	e8 a1 d4 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f00:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f05:	85 c0                	test   %eax,%eax
80102f07:	74 0f                	je     80102f18 <cpunum+0x55>
    return lapic[ID]>>24;
80102f09:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f0e:	83 c0 20             	add    $0x20,%eax
80102f11:	8b 00                	mov    (%eax),%eax
80102f13:	c1 e8 18             	shr    $0x18,%eax
80102f16:	eb 05                	jmp    80102f1d <cpunum+0x5a>
  return 0;
80102f18:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f1d:	c9                   	leave  
80102f1e:	c3                   	ret    

80102f1f <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f1f:	55                   	push   %ebp
80102f20:	89 e5                	mov    %esp,%ebp
80102f22:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f25:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f2a:	85 c0                	test   %eax,%eax
80102f2c:	74 14                	je     80102f42 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f2e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f35:	00 
80102f36:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f3d:	e8 03 fe ff ff       	call   80102d45 <lapicw>
}
80102f42:	c9                   	leave  
80102f43:	c3                   	ret    

80102f44 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f44:	55                   	push   %ebp
80102f45:	89 e5                	mov    %esp,%ebp
}
80102f47:	5d                   	pop    %ebp
80102f48:	c3                   	ret    

80102f49 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f49:	55                   	push   %ebp
80102f4a:	89 e5                	mov    %esp,%ebp
80102f4c:	83 ec 1c             	sub    $0x1c,%esp
80102f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102f52:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f55:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f5c:	00 
80102f5d:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f64:	e8 a9 fd ff ff       	call   80102d12 <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f69:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f70:	00 
80102f71:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f78:	e8 95 fd ff ff       	call   80102d12 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f7d:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f84:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f87:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102f8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f8f:	8d 50 02             	lea    0x2(%eax),%edx
80102f92:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f95:	c1 e8 04             	shr    $0x4,%eax
80102f98:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102f9b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f9f:	c1 e0 18             	shl    $0x18,%eax
80102fa2:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fa6:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fad:	e8 93 fd ff ff       	call   80102d45 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fb2:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102fb9:	00 
80102fba:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fc1:	e8 7f fd ff ff       	call   80102d45 <lapicw>
  microdelay(200);
80102fc6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fcd:	e8 72 ff ff ff       	call   80102f44 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102fd2:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102fd9:	00 
80102fda:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fe1:	e8 5f fd ff ff       	call   80102d45 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102fe6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fed:	e8 52 ff ff ff       	call   80102f44 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102ff2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102ff9:	eb 40                	jmp    8010303b <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80102ffb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fff:	c1 e0 18             	shl    $0x18,%eax
80103002:	89 44 24 04          	mov    %eax,0x4(%esp)
80103006:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010300d:	e8 33 fd ff ff       	call   80102d45 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103012:	8b 45 0c             	mov    0xc(%ebp),%eax
80103015:	c1 e8 0c             	shr    $0xc,%eax
80103018:	80 cc 06             	or     $0x6,%ah
8010301b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010301f:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103026:	e8 1a fd ff ff       	call   80102d45 <lapicw>
    microdelay(200);
8010302b:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103032:	e8 0d ff ff ff       	call   80102f44 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103037:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010303b:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010303f:	7e ba                	jle    80102ffb <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103041:	c9                   	leave  
80103042:	c3                   	ret    

80103043 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103043:	55                   	push   %ebp
80103044:	89 e5                	mov    %esp,%ebp
80103046:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103049:	8b 45 08             	mov    0x8(%ebp),%eax
8010304c:	0f b6 c0             	movzbl %al,%eax
8010304f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103053:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010305a:	e8 b3 fc ff ff       	call   80102d12 <outb>
  microdelay(200);
8010305f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103066:	e8 d9 fe ff ff       	call   80102f44 <microdelay>

  return inb(CMOS_RETURN);
8010306b:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103072:	e8 71 fc ff ff       	call   80102ce8 <inb>
80103077:	0f b6 c0             	movzbl %al,%eax
}
8010307a:	c9                   	leave  
8010307b:	c3                   	ret    

8010307c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010307c:	55                   	push   %ebp
8010307d:	89 e5                	mov    %esp,%ebp
8010307f:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103082:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103089:	e8 b5 ff ff ff       	call   80103043 <cmos_read>
8010308e:	8b 55 08             	mov    0x8(%ebp),%edx
80103091:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103093:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010309a:	e8 a4 ff ff ff       	call   80103043 <cmos_read>
8010309f:	8b 55 08             	mov    0x8(%ebp),%edx
801030a2:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801030a5:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801030ac:	e8 92 ff ff ff       	call   80103043 <cmos_read>
801030b1:	8b 55 08             	mov    0x8(%ebp),%edx
801030b4:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801030b7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801030be:	e8 80 ff ff ff       	call   80103043 <cmos_read>
801030c3:	8b 55 08             	mov    0x8(%ebp),%edx
801030c6:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801030c9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801030d0:	e8 6e ff ff ff       	call   80103043 <cmos_read>
801030d5:	8b 55 08             	mov    0x8(%ebp),%edx
801030d8:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801030db:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801030e2:	e8 5c ff ff ff       	call   80103043 <cmos_read>
801030e7:	8b 55 08             	mov    0x8(%ebp),%edx
801030ea:	89 42 14             	mov    %eax,0x14(%edx)
}
801030ed:	c9                   	leave  
801030ee:	c3                   	ret    

801030ef <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801030ef:	55                   	push   %ebp
801030f0:	89 e5                	mov    %esp,%ebp
801030f2:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801030f5:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801030fc:	e8 42 ff ff ff       	call   80103043 <cmos_read>
80103101:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103107:	83 e0 04             	and    $0x4,%eax
8010310a:	85 c0                	test   %eax,%eax
8010310c:	0f 94 c0             	sete   %al
8010310f:	0f b6 c0             	movzbl %al,%eax
80103112:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103115:	eb 01                	jmp    80103118 <cmostime+0x29>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103117:	90                   	nop

  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103118:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010311b:	89 04 24             	mov    %eax,(%esp)
8010311e:	e8 59 ff ff ff       	call   8010307c <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103123:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010312a:	e8 14 ff ff ff       	call   80103043 <cmos_read>
8010312f:	25 80 00 00 00       	and    $0x80,%eax
80103134:	85 c0                	test   %eax,%eax
80103136:	75 2b                	jne    80103163 <cmostime+0x74>
        continue;
    fill_rtcdate(&t2);
80103138:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010313b:	89 04 24             	mov    %eax,(%esp)
8010313e:	e8 39 ff ff ff       	call   8010307c <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103143:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
8010314a:	00 
8010314b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010314e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103152:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103155:	89 04 24             	mov    %eax,(%esp)
80103158:	e8 e0 1f 00 00       	call   8010513d <memcmp>
8010315d:	85 c0                	test   %eax,%eax
8010315f:	75 b6                	jne    80103117 <cmostime+0x28>
      break;
80103161:	eb 03                	jmp    80103166 <cmostime+0x77>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103163:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103164:	eb b1                	jmp    80103117 <cmostime+0x28>

  // convert
  if (bcd) {
80103166:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010316a:	0f 84 a8 00 00 00    	je     80103218 <cmostime+0x129>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103170:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103173:	89 c2                	mov    %eax,%edx
80103175:	c1 ea 04             	shr    $0x4,%edx
80103178:	89 d0                	mov    %edx,%eax
8010317a:	c1 e0 02             	shl    $0x2,%eax
8010317d:	01 d0                	add    %edx,%eax
8010317f:	01 c0                	add    %eax,%eax
80103181:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103184:	83 e2 0f             	and    $0xf,%edx
80103187:	01 d0                	add    %edx,%eax
80103189:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010318c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010318f:	89 c2                	mov    %eax,%edx
80103191:	c1 ea 04             	shr    $0x4,%edx
80103194:	89 d0                	mov    %edx,%eax
80103196:	c1 e0 02             	shl    $0x2,%eax
80103199:	01 d0                	add    %edx,%eax
8010319b:	01 c0                	add    %eax,%eax
8010319d:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031a0:	83 e2 0f             	and    $0xf,%edx
801031a3:	01 d0                	add    %edx,%eax
801031a5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031ab:	89 c2                	mov    %eax,%edx
801031ad:	c1 ea 04             	shr    $0x4,%edx
801031b0:	89 d0                	mov    %edx,%eax
801031b2:	c1 e0 02             	shl    $0x2,%eax
801031b5:	01 d0                	add    %edx,%eax
801031b7:	01 c0                	add    %eax,%eax
801031b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031bc:	83 e2 0f             	and    $0xf,%edx
801031bf:	01 d0                	add    %edx,%eax
801031c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801031c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801031c7:	89 c2                	mov    %eax,%edx
801031c9:	c1 ea 04             	shr    $0x4,%edx
801031cc:	89 d0                	mov    %edx,%eax
801031ce:	c1 e0 02             	shl    $0x2,%eax
801031d1:	01 d0                	add    %edx,%eax
801031d3:	01 c0                	add    %eax,%eax
801031d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031d8:	83 e2 0f             	and    $0xf,%edx
801031db:	01 d0                	add    %edx,%eax
801031dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801031e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801031e3:	89 c2                	mov    %eax,%edx
801031e5:	c1 ea 04             	shr    $0x4,%edx
801031e8:	89 d0                	mov    %edx,%eax
801031ea:	c1 e0 02             	shl    $0x2,%eax
801031ed:	01 d0                	add    %edx,%eax
801031ef:	01 c0                	add    %eax,%eax
801031f1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801031f4:	83 e2 0f             	and    $0xf,%edx
801031f7:	01 d0                	add    %edx,%eax
801031f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801031fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ff:	89 c2                	mov    %eax,%edx
80103201:	c1 ea 04             	shr    $0x4,%edx
80103204:	89 d0                	mov    %edx,%eax
80103206:	c1 e0 02             	shl    $0x2,%eax
80103209:	01 d0                	add    %edx,%eax
8010320b:	01 c0                	add    %eax,%eax
8010320d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103210:	83 e2 0f             	and    $0xf,%edx
80103213:	01 d0                	add    %edx,%eax
80103215:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103218:	8b 45 08             	mov    0x8(%ebp),%eax
8010321b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010321e:	89 10                	mov    %edx,(%eax)
80103220:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103223:	89 50 04             	mov    %edx,0x4(%eax)
80103226:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103229:	89 50 08             	mov    %edx,0x8(%eax)
8010322c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010322f:	89 50 0c             	mov    %edx,0xc(%eax)
80103232:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103235:	89 50 10             	mov    %edx,0x10(%eax)
80103238:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010323b:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010323e:	8b 45 08             	mov    0x8(%ebp),%eax
80103241:	8b 40 14             	mov    0x14(%eax),%eax
80103244:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010324a:	8b 45 08             	mov    0x8(%ebp),%eax
8010324d:	89 50 14             	mov    %edx,0x14(%eax)
}
80103250:	c9                   	leave  
80103251:	c3                   	ret    
	...

80103254 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
80103254:	55                   	push   %ebp
80103255:	89 e5                	mov    %esp,%ebp
80103257:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010325a:	c7 44 24 04 ac 86 10 	movl   $0x801086ac,0x4(%esp)
80103261:	80 
80103262:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103269:	e8 e8 1b 00 00       	call   80104e56 <initlock>
  readsb(ROOTDEV, &sb);
8010326e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103271:	89 44 24 04          	mov    %eax,0x4(%esp)
80103275:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010327c:	e8 77 e0 ff ff       	call   801012f8 <readsb>
  log.start = sb.size - sb.nlog;
80103281:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103284:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103287:	89 d1                	mov    %edx,%ecx
80103289:	29 c1                	sub    %eax,%ecx
8010328b:	89 c8                	mov    %ecx,%eax
8010328d:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
80103292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103295:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = ROOTDEV;
8010329a:	c7 05 a4 22 11 80 01 	movl   $0x1,0x801122a4
801032a1:	00 00 00 
  recover_from_log();
801032a4:	e8 97 01 00 00       	call   80103440 <recover_from_log>
}
801032a9:	c9                   	leave  
801032aa:	c3                   	ret    

801032ab <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801032ab:	55                   	push   %ebp
801032ac:	89 e5                	mov    %esp,%ebp
801032ae:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032b8:	e9 89 00 00 00       	jmp    80103346 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032bd:	a1 94 22 11 80       	mov    0x80112294,%eax
801032c2:	03 45 f4             	add    -0xc(%ebp),%eax
801032c5:	83 c0 01             	add    $0x1,%eax
801032c8:	89 c2                	mov    %eax,%edx
801032ca:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801032cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801032d3:	89 04 24             	mov    %eax,(%esp)
801032d6:	e8 cb ce ff ff       	call   801001a6 <bread>
801032db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801032de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e1:	83 c0 10             	add    $0x10,%eax
801032e4:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801032eb:	89 c2                	mov    %eax,%edx
801032ed:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801032f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801032f6:	89 04 24             	mov    %eax,(%esp)
801032f9:	e8 a8 ce ff ff       	call   801001a6 <bread>
801032fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103301:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103304:	8d 50 18             	lea    0x18(%eax),%edx
80103307:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010330a:	83 c0 18             	add    $0x18,%eax
8010330d:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103314:	00 
80103315:	89 54 24 04          	mov    %edx,0x4(%esp)
80103319:	89 04 24             	mov    %eax,(%esp)
8010331c:	e8 78 1e 00 00       	call   80105199 <memmove>
    bwrite(dbuf);  // write dst to disk
80103321:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103324:	89 04 24             	mov    %eax,(%esp)
80103327:	e8 b1 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
8010332c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010332f:	89 04 24             	mov    %eax,(%esp)
80103332:	e8 e0 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103337:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010333a:	89 04 24             	mov    %eax,(%esp)
8010333d:	e8 d5 ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103342:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103346:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010334b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010334e:	0f 8f 69 ff ff ff    	jg     801032bd <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103354:	c9                   	leave  
80103355:	c3                   	ret    

80103356 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103356:	55                   	push   %ebp
80103357:	89 e5                	mov    %esp,%ebp
80103359:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010335c:	a1 94 22 11 80       	mov    0x80112294,%eax
80103361:	89 c2                	mov    %eax,%edx
80103363:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103368:	89 54 24 04          	mov    %edx,0x4(%esp)
8010336c:	89 04 24             	mov    %eax,(%esp)
8010336f:	e8 32 ce ff ff       	call   801001a6 <bread>
80103374:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103377:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010337a:	83 c0 18             	add    $0x18,%eax
8010337d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103380:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103383:	8b 00                	mov    (%eax),%eax
80103385:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
8010338a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103391:	eb 1b                	jmp    801033ae <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103393:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103396:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103399:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010339d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033a0:	83 c2 10             	add    $0x10,%edx
801033a3:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033ae:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801033b3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033b6:	7f db                	jg     80103393 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801033b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033bb:	89 04 24             	mov    %eax,(%esp)
801033be:	e8 54 ce ff ff       	call   80100217 <brelse>
}
801033c3:	c9                   	leave  
801033c4:	c3                   	ret    

801033c5 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801033c5:	55                   	push   %ebp
801033c6:	89 e5                	mov    %esp,%ebp
801033c8:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033cb:	a1 94 22 11 80       	mov    0x80112294,%eax
801033d0:	89 c2                	mov    %eax,%edx
801033d2:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801033d7:	89 54 24 04          	mov    %edx,0x4(%esp)
801033db:	89 04 24             	mov    %eax,(%esp)
801033de:	e8 c3 cd ff ff       	call   801001a6 <bread>
801033e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801033e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e9:	83 c0 18             	add    $0x18,%eax
801033ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801033ef:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
801033f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f8:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103401:	eb 1b                	jmp    8010341e <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
80103403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103406:	83 c0 10             	add    $0x10,%eax
80103409:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
80103410:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103413:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103416:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010341a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010341e:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103423:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103426:	7f db                	jg     80103403 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010342b:	89 04 24             	mov    %eax,(%esp)
8010342e:	e8 aa cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103433:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103436:	89 04 24             	mov    %eax,(%esp)
80103439:	e8 d9 cd ff ff       	call   80100217 <brelse>
}
8010343e:	c9                   	leave  
8010343f:	c3                   	ret    

80103440 <recover_from_log>:

static void
recover_from_log(void)
{
80103440:	55                   	push   %ebp
80103441:	89 e5                	mov    %esp,%ebp
80103443:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103446:	e8 0b ff ff ff       	call   80103356 <read_head>
  install_trans(); // if committed, copy from log to disk
8010344b:	e8 5b fe ff ff       	call   801032ab <install_trans>
  log.lh.n = 0;
80103450:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103457:	00 00 00 
  write_head(); // clear the log
8010345a:	e8 66 ff ff ff       	call   801033c5 <write_head>
}
8010345f:	c9                   	leave  
80103460:	c3                   	ret    

80103461 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103461:	55                   	push   %ebp
80103462:	89 e5                	mov    %esp,%ebp
80103464:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103467:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010346e:	e8 04 1a 00 00       	call   80104e77 <acquire>
  while(1){
    if(log.committing){
80103473:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103478:	85 c0                	test   %eax,%eax
8010347a:	74 16                	je     80103492 <begin_op+0x31>
      sleep(&log, &log.lock);
8010347c:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103483:	80 
80103484:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010348b:	e8 08 17 00 00       	call   80104b98 <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
80103490:	eb e1                	jmp    80103473 <begin_op+0x12>
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103492:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
80103498:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010349d:	8d 50 01             	lea    0x1(%eax),%edx
801034a0:	89 d0                	mov    %edx,%eax
801034a2:	c1 e0 02             	shl    $0x2,%eax
801034a5:	01 d0                	add    %edx,%eax
801034a7:	01 c0                	add    %eax,%eax
801034a9:	01 c8                	add    %ecx,%eax
801034ab:	83 f8 1e             	cmp    $0x1e,%eax
801034ae:	7e 16                	jle    801034c6 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801034b0:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
801034b7:	80 
801034b8:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034bf:	e8 d4 16 00 00       	call   80104b98 <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
801034c4:	eb ad                	jmp    80103473 <begin_op+0x12>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
801034c6:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034cb:	83 c0 01             	add    $0x1,%eax
801034ce:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
801034d3:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034da:	e8 fa 19 00 00       	call   80104ed9 <release>
      break;
801034df:	90                   	nop
    }
  }
}
801034e0:	c9                   	leave  
801034e1:	c3                   	ret    

801034e2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801034e2:	55                   	push   %ebp
801034e3:	89 e5                	mov    %esp,%ebp
801034e5:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801034e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801034ef:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034f6:	e8 7c 19 00 00       	call   80104e77 <acquire>
  log.outstanding -= 1;
801034fb:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103500:	83 e8 01             	sub    $0x1,%eax
80103503:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
80103508:	a1 a0 22 11 80       	mov    0x801122a0,%eax
8010350d:	85 c0                	test   %eax,%eax
8010350f:	74 0c                	je     8010351d <end_op+0x3b>
    panic("log.committing");
80103511:	c7 04 24 b0 86 10 80 	movl   $0x801086b0,(%esp)
80103518:	e8 20 d0 ff ff       	call   8010053d <panic>
  if(log.outstanding == 0){
8010351d:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103522:	85 c0                	test   %eax,%eax
80103524:	75 13                	jne    80103539 <end_op+0x57>
    do_commit = 1;
80103526:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010352d:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
80103534:	00 00 00 
80103537:	eb 0c                	jmp    80103545 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103539:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103540:	e8 2c 17 00 00       	call   80104c71 <wakeup>
  }
  release(&log.lock);
80103545:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010354c:	e8 88 19 00 00       	call   80104ed9 <release>

  if(do_commit){
80103551:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103555:	74 33                	je     8010358a <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103557:	e8 db 00 00 00       	call   80103637 <commit>
    acquire(&log.lock);
8010355c:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103563:	e8 0f 19 00 00       	call   80104e77 <acquire>
    log.committing = 0;
80103568:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
8010356f:	00 00 00 
    wakeup(&log);
80103572:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103579:	e8 f3 16 00 00       	call   80104c71 <wakeup>
    release(&log.lock);
8010357e:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103585:	e8 4f 19 00 00       	call   80104ed9 <release>
  }
}
8010358a:	c9                   	leave  
8010358b:	c3                   	ret    

8010358c <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010358c:	55                   	push   %ebp
8010358d:	89 e5                	mov    %esp,%ebp
8010358f:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103592:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103599:	e9 89 00 00 00       	jmp    80103627 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010359e:	a1 94 22 11 80       	mov    0x80112294,%eax
801035a3:	03 45 f4             	add    -0xc(%ebp),%eax
801035a6:	83 c0 01             	add    $0x1,%eax
801035a9:	89 c2                	mov    %eax,%edx
801035ab:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801035b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801035b4:	89 04 24             	mov    %eax,(%esp)
801035b7:	e8 ea cb ff ff       	call   801001a6 <bread>
801035bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
801035bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035c2:	83 c0 10             	add    $0x10,%eax
801035c5:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801035cc:	89 c2                	mov    %eax,%edx
801035ce:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801035d3:	89 54 24 04          	mov    %edx,0x4(%esp)
801035d7:	89 04 24             	mov    %eax,(%esp)
801035da:	e8 c7 cb ff ff       	call   801001a6 <bread>
801035df:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801035e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035e5:	8d 50 18             	lea    0x18(%eax),%edx
801035e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035eb:	83 c0 18             	add    $0x18,%eax
801035ee:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801035f5:	00 
801035f6:	89 54 24 04          	mov    %edx,0x4(%esp)
801035fa:	89 04 24             	mov    %eax,(%esp)
801035fd:	e8 97 1b 00 00       	call   80105199 <memmove>
    bwrite(to);  // write the log
80103602:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103605:	89 04 24             	mov    %eax,(%esp)
80103608:	e8 d0 cb ff ff       	call   801001dd <bwrite>
    brelse(from); 
8010360d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103610:	89 04 24             	mov    %eax,(%esp)
80103613:	e8 ff cb ff ff       	call   80100217 <brelse>
    brelse(to);
80103618:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010361b:	89 04 24             	mov    %eax,(%esp)
8010361e:	e8 f4 cb ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103623:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103627:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010362c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010362f:	0f 8f 69 ff ff ff    	jg     8010359e <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103635:	c9                   	leave  
80103636:	c3                   	ret    

80103637 <commit>:

static void
commit()
{
80103637:	55                   	push   %ebp
80103638:	89 e5                	mov    %esp,%ebp
8010363a:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010363d:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103642:	85 c0                	test   %eax,%eax
80103644:	7e 1e                	jle    80103664 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103646:	e8 41 ff ff ff       	call   8010358c <write_log>
    write_head();    // Write header to disk -- the real commit
8010364b:	e8 75 fd ff ff       	call   801033c5 <write_head>
    install_trans(); // Now install writes to home locations
80103650:	e8 56 fc ff ff       	call   801032ab <install_trans>
    log.lh.n = 0; 
80103655:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
8010365c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010365f:	e8 61 fd ff ff       	call   801033c5 <write_head>
  }
}
80103664:	c9                   	leave  
80103665:	c3                   	ret    

80103666 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103666:	55                   	push   %ebp
80103667:	89 e5                	mov    %esp,%ebp
80103669:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010366c:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103671:	83 f8 1d             	cmp    $0x1d,%eax
80103674:	7f 12                	jg     80103688 <log_write+0x22>
80103676:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010367b:	8b 15 98 22 11 80    	mov    0x80112298,%edx
80103681:	83 ea 01             	sub    $0x1,%edx
80103684:	39 d0                	cmp    %edx,%eax
80103686:	7c 0c                	jl     80103694 <log_write+0x2e>
    panic("too big a transaction");
80103688:	c7 04 24 bf 86 10 80 	movl   $0x801086bf,(%esp)
8010368f:	e8 a9 ce ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
80103694:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103699:	85 c0                	test   %eax,%eax
8010369b:	7f 0c                	jg     801036a9 <log_write+0x43>
    panic("log_write outside of trans");
8010369d:	c7 04 24 d5 86 10 80 	movl   $0x801086d5,(%esp)
801036a4:	e8 94 ce ff ff       	call   8010053d <panic>

  acquire(&log.lock);
801036a9:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036b0:	e8 c2 17 00 00       	call   80104e77 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801036b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036bc:	eb 1d                	jmp    801036db <log_write+0x75>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
801036be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036c1:	83 c0 10             	add    $0x10,%eax
801036c4:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801036cb:	89 c2                	mov    %eax,%edx
801036cd:	8b 45 08             	mov    0x8(%ebp),%eax
801036d0:	8b 40 08             	mov    0x8(%eax),%eax
801036d3:	39 c2                	cmp    %eax,%edx
801036d5:	74 10                	je     801036e7 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801036d7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036db:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036e0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036e3:	7f d9                	jg     801036be <log_write+0x58>
801036e5:	eb 01                	jmp    801036e8 <log_write+0x82>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
801036e7:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
801036e8:	8b 45 08             	mov    0x8(%ebp),%eax
801036eb:	8b 40 08             	mov    0x8(%eax),%eax
801036ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036f1:	83 c2 10             	add    $0x10,%edx
801036f4:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
  if (i == log.lh.n)
801036fb:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103700:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103703:	75 0d                	jne    80103712 <log_write+0xac>
    log.lh.n++;
80103705:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010370a:	83 c0 01             	add    $0x1,%eax
8010370d:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
80103712:	8b 45 08             	mov    0x8(%ebp),%eax
80103715:	8b 00                	mov    (%eax),%eax
80103717:	89 c2                	mov    %eax,%edx
80103719:	83 ca 04             	or     $0x4,%edx
8010371c:	8b 45 08             	mov    0x8(%ebp),%eax
8010371f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103721:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103728:	e8 ac 17 00 00       	call   80104ed9 <release>
}
8010372d:	c9                   	leave  
8010372e:	c3                   	ret    
	...

80103730 <v2p>:
80103730:	55                   	push   %ebp
80103731:	89 e5                	mov    %esp,%ebp
80103733:	8b 45 08             	mov    0x8(%ebp),%eax
80103736:	05 00 00 00 80       	add    $0x80000000,%eax
8010373b:	5d                   	pop    %ebp
8010373c:	c3                   	ret    

8010373d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010373d:	55                   	push   %ebp
8010373e:	89 e5                	mov    %esp,%ebp
80103740:	8b 45 08             	mov    0x8(%ebp),%eax
80103743:	05 00 00 00 80       	add    $0x80000000,%eax
80103748:	5d                   	pop    %ebp
80103749:	c3                   	ret    

8010374a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010374a:	55                   	push   %ebp
8010374b:	89 e5                	mov    %esp,%ebp
8010374d:	53                   	push   %ebx
8010374e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103751:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103754:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80103757:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010375a:	89 c3                	mov    %eax,%ebx
8010375c:	89 d8                	mov    %ebx,%eax
8010375e:	f0 87 02             	lock xchg %eax,(%edx)
80103761:	89 c3                	mov    %eax,%ebx
80103763:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103766:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103769:	83 c4 10             	add    $0x10,%esp
8010376c:	5b                   	pop    %ebx
8010376d:	5d                   	pop    %ebp
8010376e:	c3                   	ret    

8010376f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010376f:	55                   	push   %ebp
80103770:	89 e5                	mov    %esp,%ebp
80103772:	83 e4 f0             	and    $0xfffffff0,%esp
80103775:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103778:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010377f:	80 
80103780:	c7 04 24 3c 52 11 80 	movl   $0x8011523c,(%esp)
80103787:	e8 51 f2 ff ff       	call   801029dd <kinit1>
  kvmalloc();      // kernel page table
8010378c:	e8 65 45 00 00       	call   80107cf6 <kvmalloc>
  mpinit();        // collect info about this machine
80103791:	e8 53 04 00 00       	call   80103be9 <mpinit>
  lapicinit();
80103796:	e8 cb f5 ff ff       	call   80102d66 <lapicinit>
  seginit();       // set up segments
8010379b:	e8 f9 3e 00 00       	call   80107699 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037a0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037a6:	0f b6 00             	movzbl (%eax),%eax
801037a9:	0f b6 c0             	movzbl %al,%eax
801037ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801037b0:	c7 04 24 f0 86 10 80 	movl   $0x801086f0,(%esp)
801037b7:	e8 e5 cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037bc:	e8 8d 06 00 00       	call   80103e4e <picinit>
  ioapicinit();    // another interrupt controller
801037c1:	e8 07 f1 ff ff       	call   801028cd <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037c6:	e8 c2 d2 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
801037cb:	e8 14 32 00 00       	call   801069e4 <uartinit>
  pinit();         // process table
801037d0:	e8 8e 0b 00 00       	call   80104363 <pinit>
  tvinit();        // trap vectors
801037d5:	e8 91 2d 00 00       	call   8010656b <tvinit>
  binit();         // buffer cache
801037da:	e8 55 c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037df:	e8 28 d7 ff ff       	call   80100f0c <fileinit>
  iinit();         // inode cache
801037e4:	e8 d6 dd ff ff       	call   801015bf <iinit>
  ideinit();       // disk
801037e9:	e8 44 ed ff ff       	call   80102532 <ideinit>
  if(!ismp)
801037ee:	a1 44 23 11 80       	mov    0x80112344,%eax
801037f3:	85 c0                	test   %eax,%eax
801037f5:	75 05                	jne    801037fc <main+0x8d>
    timerinit();   // uniprocessor timer
801037f7:	e8 b2 2c 00 00       	call   801064ae <timerinit>
  startothers();   // start other processors
801037fc:	e8 7f 00 00 00       	call   80103880 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103801:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103808:	8e 
80103809:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103810:	e8 00 f2 ff ff       	call   80102a15 <kinit2>
  userinit();      // first user process
80103815:	e8 64 0c 00 00       	call   8010447e <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010381a:	e8 1a 00 00 00       	call   80103839 <mpmain>

8010381f <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010381f:	55                   	push   %ebp
80103820:	89 e5                	mov    %esp,%ebp
80103822:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103825:	e8 e3 44 00 00       	call   80107d0d <switchkvm>
  seginit();
8010382a:	e8 6a 3e 00 00       	call   80107699 <seginit>
  lapicinit();
8010382f:	e8 32 f5 ff ff       	call   80102d66 <lapicinit>
  mpmain();
80103834:	e8 00 00 00 00       	call   80103839 <mpmain>

80103839 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103839:	55                   	push   %ebp
8010383a:	89 e5                	mov    %esp,%ebp
8010383c:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010383f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103845:	0f b6 00             	movzbl (%eax),%eax
80103848:	0f b6 c0             	movzbl %al,%eax
8010384b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010384f:	c7 04 24 07 87 10 80 	movl   $0x80108707,(%esp)
80103856:	e8 46 cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
8010385b:	e8 7f 2e 00 00       	call   801066df <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103860:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103866:	05 a8 00 00 00       	add    $0xa8,%eax
8010386b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103872:	00 
80103873:	89 04 24             	mov    %eax,(%esp)
80103876:	e8 cf fe ff ff       	call   8010374a <xchg>
  scheduler();     // start running processes
8010387b:	e8 6f 11 00 00       	call   801049ef <scheduler>

80103880 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103880:	55                   	push   %ebp
80103881:	89 e5                	mov    %esp,%ebp
80103883:	53                   	push   %ebx
80103884:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103887:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
8010388e:	e8 aa fe ff ff       	call   8010373d <p2v>
80103893:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103896:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010389b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010389f:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
801038a6:	80 
801038a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038aa:	89 04 24             	mov    %eax,(%esp)
801038ad:	e8 e7 18 00 00       	call   80105199 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038b2:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
801038b9:	e9 86 00 00 00       	jmp    80103944 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038be:	e8 00 f6 ff ff       	call   80102ec3 <cpunum>
801038c3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038c9:	05 60 23 11 80       	add    $0x80112360,%eax
801038ce:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038d1:	74 69                	je     8010393c <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038d3:	e8 33 f2 ff ff       	call   80102b0b <kalloc>
801038d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038de:	83 e8 04             	sub    $0x4,%eax
801038e1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038e4:	81 c2 00 10 00 00    	add    $0x1000,%edx
801038ea:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801038ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ef:	83 e8 08             	sub    $0x8,%eax
801038f2:	c7 00 1f 38 10 80    	movl   $0x8010381f,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801038f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038fb:	8d 58 f4             	lea    -0xc(%eax),%ebx
801038fe:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103905:	e8 26 fe ff ff       	call   80103730 <v2p>
8010390a:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010390c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390f:	89 04 24             	mov    %eax,(%esp)
80103912:	e8 19 fe ff ff       	call   80103730 <v2p>
80103917:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010391a:	0f b6 12             	movzbl (%edx),%edx
8010391d:	0f b6 d2             	movzbl %dl,%edx
80103920:	89 44 24 04          	mov    %eax,0x4(%esp)
80103924:	89 14 24             	mov    %edx,(%esp)
80103927:	e8 1d f6 ff ff       	call   80102f49 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010392c:	90                   	nop
8010392d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103930:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103936:	85 c0                	test   %eax,%eax
80103938:	74 f3                	je     8010392d <startothers+0xad>
8010393a:	eb 01                	jmp    8010393d <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010393c:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010393d:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103944:	a1 40 29 11 80       	mov    0x80112940,%eax
80103949:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010394f:	05 60 23 11 80       	add    $0x80112360,%eax
80103954:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103957:	0f 87 61 ff ff ff    	ja     801038be <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010395d:	83 c4 24             	add    $0x24,%esp
80103960:	5b                   	pop    %ebx
80103961:	5d                   	pop    %ebp
80103962:	c3                   	ret    
	...

80103964 <p2v>:
80103964:	55                   	push   %ebp
80103965:	89 e5                	mov    %esp,%ebp
80103967:	8b 45 08             	mov    0x8(%ebp),%eax
8010396a:	05 00 00 00 80       	add    $0x80000000,%eax
8010396f:	5d                   	pop    %ebp
80103970:	c3                   	ret    

80103971 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103971:	55                   	push   %ebp
80103972:	89 e5                	mov    %esp,%ebp
80103974:	53                   	push   %ebx
80103975:	83 ec 14             	sub    $0x14,%esp
80103978:	8b 45 08             	mov    0x8(%ebp),%eax
8010397b:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010397f:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80103983:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80103987:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010398b:	ec                   	in     (%dx),%al
8010398c:	89 c3                	mov    %eax,%ebx
8010398e:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80103991:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80103995:	83 c4 14             	add    $0x14,%esp
80103998:	5b                   	pop    %ebx
80103999:	5d                   	pop    %ebp
8010399a:	c3                   	ret    

8010399b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010399b:	55                   	push   %ebp
8010399c:	89 e5                	mov    %esp,%ebp
8010399e:	83 ec 08             	sub    $0x8,%esp
801039a1:	8b 55 08             	mov    0x8(%ebp),%edx
801039a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801039a7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039ab:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039ae:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039b2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039b6:	ee                   	out    %al,(%dx)
}
801039b7:	c9                   	leave  
801039b8:	c3                   	ret    

801039b9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039b9:	55                   	push   %ebp
801039ba:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039bc:	a1 44 b6 10 80       	mov    0x8010b644,%eax
801039c1:	89 c2                	mov    %eax,%edx
801039c3:	b8 60 23 11 80       	mov    $0x80112360,%eax
801039c8:	89 d1                	mov    %edx,%ecx
801039ca:	29 c1                	sub    %eax,%ecx
801039cc:	89 c8                	mov    %ecx,%eax
801039ce:	c1 f8 02             	sar    $0x2,%eax
801039d1:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039d7:	5d                   	pop    %ebp
801039d8:	c3                   	ret    

801039d9 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
801039dc:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039df:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039ed:	eb 13                	jmp    80103a02 <sum+0x29>
    sum += addr[i];
801039ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801039f2:	03 45 08             	add    0x8(%ebp),%eax
801039f5:	0f b6 00             	movzbl (%eax),%eax
801039f8:	0f b6 c0             	movzbl %al,%eax
801039fb:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801039fe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a02:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a05:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a08:	7c e5                	jl     801039ef <sum+0x16>
    sum += addr[i];
  return sum;
80103a0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a0d:	c9                   	leave  
80103a0e:	c3                   	ret    

80103a0f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a0f:	55                   	push   %ebp
80103a10:	89 e5                	mov    %esp,%ebp
80103a12:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a15:	8b 45 08             	mov    0x8(%ebp),%eax
80103a18:	89 04 24             	mov    %eax,(%esp)
80103a1b:	e8 44 ff ff ff       	call   80103964 <p2v>
80103a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a23:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a26:	03 45 f0             	add    -0x10(%ebp),%eax
80103a29:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a32:	eb 3f                	jmp    80103a73 <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a34:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a3b:	00 
80103a3c:	c7 44 24 04 18 87 10 	movl   $0x80108718,0x4(%esp)
80103a43:	80 
80103a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a47:	89 04 24             	mov    %eax,(%esp)
80103a4a:	e8 ee 16 00 00       	call   8010513d <memcmp>
80103a4f:	85 c0                	test   %eax,%eax
80103a51:	75 1c                	jne    80103a6f <mpsearch1+0x60>
80103a53:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a5a:	00 
80103a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5e:	89 04 24             	mov    %eax,(%esp)
80103a61:	e8 73 ff ff ff       	call   801039d9 <sum>
80103a66:	84 c0                	test   %al,%al
80103a68:	75 05                	jne    80103a6f <mpsearch1+0x60>
      return (struct mp*)p;
80103a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a6d:	eb 11                	jmp    80103a80 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a6f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a76:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a79:	72 b9                	jb     80103a34 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a80:	c9                   	leave  
80103a81:	c3                   	ret    

80103a82 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a82:	55                   	push   %ebp
80103a83:	89 e5                	mov    %esp,%ebp
80103a85:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a88:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a92:	83 c0 0f             	add    $0xf,%eax
80103a95:	0f b6 00             	movzbl (%eax),%eax
80103a98:	0f b6 c0             	movzbl %al,%eax
80103a9b:	89 c2                	mov    %eax,%edx
80103a9d:	c1 e2 08             	shl    $0x8,%edx
80103aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa3:	83 c0 0e             	add    $0xe,%eax
80103aa6:	0f b6 00             	movzbl (%eax),%eax
80103aa9:	0f b6 c0             	movzbl %al,%eax
80103aac:	09 d0                	or     %edx,%eax
80103aae:	c1 e0 04             	shl    $0x4,%eax
80103ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ab4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ab8:	74 21                	je     80103adb <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103aba:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ac1:	00 
80103ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac5:	89 04 24             	mov    %eax,(%esp)
80103ac8:	e8 42 ff ff ff       	call   80103a0f <mpsearch1>
80103acd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ad0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ad4:	74 50                	je     80103b26 <mpsearch+0xa4>
      return mp;
80103ad6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ad9:	eb 5f                	jmp    80103b3a <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ade:	83 c0 14             	add    $0x14,%eax
80103ae1:	0f b6 00             	movzbl (%eax),%eax
80103ae4:	0f b6 c0             	movzbl %al,%eax
80103ae7:	89 c2                	mov    %eax,%edx
80103ae9:	c1 e2 08             	shl    $0x8,%edx
80103aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aef:	83 c0 13             	add    $0x13,%eax
80103af2:	0f b6 00             	movzbl (%eax),%eax
80103af5:	0f b6 c0             	movzbl %al,%eax
80103af8:	09 d0                	or     %edx,%eax
80103afa:	c1 e0 0a             	shl    $0xa,%eax
80103afd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b03:	2d 00 04 00 00       	sub    $0x400,%eax
80103b08:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b0f:	00 
80103b10:	89 04 24             	mov    %eax,(%esp)
80103b13:	e8 f7 fe ff ff       	call   80103a0f <mpsearch1>
80103b18:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b1b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b1f:	74 05                	je     80103b26 <mpsearch+0xa4>
      return mp;
80103b21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b24:	eb 14                	jmp    80103b3a <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b26:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b2d:	00 
80103b2e:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b35:	e8 d5 fe ff ff       	call   80103a0f <mpsearch1>
}
80103b3a:	c9                   	leave  
80103b3b:	c3                   	ret    

80103b3c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b3c:	55                   	push   %ebp
80103b3d:	89 e5                	mov    %esp,%ebp
80103b3f:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b42:	e8 3b ff ff ff       	call   80103a82 <mpsearch>
80103b47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b4e:	74 0a                	je     80103b5a <mpconfig+0x1e>
80103b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b53:	8b 40 04             	mov    0x4(%eax),%eax
80103b56:	85 c0                	test   %eax,%eax
80103b58:	75 0a                	jne    80103b64 <mpconfig+0x28>
    return 0;
80103b5a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b5f:	e9 83 00 00 00       	jmp    80103be7 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b67:	8b 40 04             	mov    0x4(%eax),%eax
80103b6a:	89 04 24             	mov    %eax,(%esp)
80103b6d:	e8 f2 fd ff ff       	call   80103964 <p2v>
80103b72:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b75:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b7c:	00 
80103b7d:	c7 44 24 04 1d 87 10 	movl   $0x8010871d,0x4(%esp)
80103b84:	80 
80103b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b88:	89 04 24             	mov    %eax,(%esp)
80103b8b:	e8 ad 15 00 00       	call   8010513d <memcmp>
80103b90:	85 c0                	test   %eax,%eax
80103b92:	74 07                	je     80103b9b <mpconfig+0x5f>
    return 0;
80103b94:	b8 00 00 00 00       	mov    $0x0,%eax
80103b99:	eb 4c                	jmp    80103be7 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b9e:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ba2:	3c 01                	cmp    $0x1,%al
80103ba4:	74 12                	je     80103bb8 <mpconfig+0x7c>
80103ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba9:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bad:	3c 04                	cmp    $0x4,%al
80103baf:	74 07                	je     80103bb8 <mpconfig+0x7c>
    return 0;
80103bb1:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb6:	eb 2f                	jmp    80103be7 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bbb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bbf:	0f b7 c0             	movzwl %ax,%eax
80103bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc9:	89 04 24             	mov    %eax,(%esp)
80103bcc:	e8 08 fe ff ff       	call   801039d9 <sum>
80103bd1:	84 c0                	test   %al,%al
80103bd3:	74 07                	je     80103bdc <mpconfig+0xa0>
    return 0;
80103bd5:	b8 00 00 00 00       	mov    $0x0,%eax
80103bda:	eb 0b                	jmp    80103be7 <mpconfig+0xab>
  *pmp = mp;
80103bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bdf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103be2:	89 10                	mov    %edx,(%eax)
  return conf;
80103be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103be7:	c9                   	leave  
80103be8:	c3                   	ret    

80103be9 <mpinit>:

void
mpinit(void)
{
80103be9:	55                   	push   %ebp
80103bea:	89 e5                	mov    %esp,%ebp
80103bec:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103bef:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103bf6:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103bf9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103bfc:	89 04 24             	mov    %eax,(%esp)
80103bff:	e8 38 ff ff ff       	call   80103b3c <mpconfig>
80103c04:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c0b:	0f 84 9c 01 00 00    	je     80103dad <mpinit+0x1c4>
    return;
  ismp = 1;
80103c11:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103c18:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1e:	8b 40 24             	mov    0x24(%eax),%eax
80103c21:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c29:	83 c0 2c             	add    $0x2c,%eax
80103c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c32:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c36:	0f b7 c0             	movzwl %ax,%eax
80103c39:	03 45 f0             	add    -0x10(%ebp),%eax
80103c3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c3f:	e9 f4 00 00 00       	jmp    80103d38 <mpinit+0x14f>
    switch(*p){
80103c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c47:	0f b6 00             	movzbl (%eax),%eax
80103c4a:	0f b6 c0             	movzbl %al,%eax
80103c4d:	83 f8 04             	cmp    $0x4,%eax
80103c50:	0f 87 bf 00 00 00    	ja     80103d15 <mpinit+0x12c>
80103c56:	8b 04 85 60 87 10 80 	mov    -0x7fef78a0(,%eax,4),%eax
80103c5d:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c62:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c65:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c68:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c6c:	0f b6 d0             	movzbl %al,%edx
80103c6f:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c74:	39 c2                	cmp    %eax,%edx
80103c76:	74 2d                	je     80103ca5 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c78:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c7b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c7f:	0f b6 d0             	movzbl %al,%edx
80103c82:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c87:	89 54 24 08          	mov    %edx,0x8(%esp)
80103c8b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c8f:	c7 04 24 22 87 10 80 	movl   $0x80108722,(%esp)
80103c96:	e8 06 c7 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103c9b:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103ca2:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103ca5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ca8:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103cac:	0f b6 c0             	movzbl %al,%eax
80103caf:	83 e0 02             	and    $0x2,%eax
80103cb2:	85 c0                	test   %eax,%eax
80103cb4:	74 15                	je     80103ccb <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103cb6:	a1 40 29 11 80       	mov    0x80112940,%eax
80103cbb:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cc1:	05 60 23 11 80       	add    $0x80112360,%eax
80103cc6:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103ccb:	8b 15 40 29 11 80    	mov    0x80112940,%edx
80103cd1:	a1 40 29 11 80       	mov    0x80112940,%eax
80103cd6:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cdc:	81 c2 60 23 11 80    	add    $0x80112360,%edx
80103ce2:	88 02                	mov    %al,(%edx)
      ncpu++;
80103ce4:	a1 40 29 11 80       	mov    0x80112940,%eax
80103ce9:	83 c0 01             	add    $0x1,%eax
80103cec:	a3 40 29 11 80       	mov    %eax,0x80112940
      p += sizeof(struct mpproc);
80103cf1:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cf5:	eb 41                	jmp    80103d38 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d00:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d04:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103d09:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d0d:	eb 29                	jmp    80103d38 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d0f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d13:	eb 23                	jmp    80103d38 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d18:	0f b6 00             	movzbl (%eax),%eax
80103d1b:	0f b6 c0             	movzbl %al,%eax
80103d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d22:	c7 04 24 40 87 10 80 	movl   $0x80108740,(%esp)
80103d29:	e8 73 c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d2e:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103d35:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d3b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d3e:	0f 82 00 ff ff ff    	jb     80103c44 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d44:	a1 44 23 11 80       	mov    0x80112344,%eax
80103d49:	85 c0                	test   %eax,%eax
80103d4b:	75 1d                	jne    80103d6a <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d4d:	c7 05 40 29 11 80 01 	movl   $0x1,0x80112940
80103d54:	00 00 00 
    lapic = 0;
80103d57:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103d5e:	00 00 00 
    ioapicid = 0;
80103d61:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103d68:	eb 44                	jmp    80103dae <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d6d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d71:	84 c0                	test   %al,%al
80103d73:	74 39                	je     80103dae <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d75:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d7c:	00 
80103d7d:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d84:	e8 12 fc ff ff       	call   8010399b <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d89:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d90:	e8 dc fb ff ff       	call   80103971 <inb>
80103d95:	83 c8 01             	or     $0x1,%eax
80103d98:	0f b6 c0             	movzbl %al,%eax
80103d9b:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d9f:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103da6:	e8 f0 fb ff ff       	call   8010399b <outb>
80103dab:	eb 01                	jmp    80103dae <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103dad:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103dae:	c9                   	leave  
80103daf:	c3                   	ret    

80103db0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103db0:	55                   	push   %ebp
80103db1:	89 e5                	mov    %esp,%ebp
80103db3:	83 ec 08             	sub    $0x8,%esp
80103db6:	8b 55 08             	mov    0x8(%ebp),%edx
80103db9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dbc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dc0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103dc3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103dc7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103dcb:	ee                   	out    %al,(%dx)
}
80103dcc:	c9                   	leave  
80103dcd:	c3                   	ret    

80103dce <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103dce:	55                   	push   %ebp
80103dcf:	89 e5                	mov    %esp,%ebp
80103dd1:	83 ec 0c             	sub    $0xc,%esp
80103dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103ddb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ddf:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103de5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103de9:	0f b6 c0             	movzbl %al,%eax
80103dec:	89 44 24 04          	mov    %eax,0x4(%esp)
80103df0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103df7:	e8 b4 ff ff ff       	call   80103db0 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103dfc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e00:	66 c1 e8 08          	shr    $0x8,%ax
80103e04:	0f b6 c0             	movzbl %al,%eax
80103e07:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e0b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e12:	e8 99 ff ff ff       	call   80103db0 <outb>
}
80103e17:	c9                   	leave  
80103e18:	c3                   	ret    

80103e19 <picenable>:

void
picenable(int irq)
{
80103e19:	55                   	push   %ebp
80103e1a:	89 e5                	mov    %esp,%ebp
80103e1c:	53                   	push   %ebx
80103e1d:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e20:	8b 45 08             	mov    0x8(%ebp),%eax
80103e23:	ba 01 00 00 00       	mov    $0x1,%edx
80103e28:	89 d3                	mov    %edx,%ebx
80103e2a:	89 c1                	mov    %eax,%ecx
80103e2c:	d3 e3                	shl    %cl,%ebx
80103e2e:	89 d8                	mov    %ebx,%eax
80103e30:	89 c2                	mov    %eax,%edx
80103e32:	f7 d2                	not    %edx
80103e34:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e3b:	21 d0                	and    %edx,%eax
80103e3d:	0f b7 c0             	movzwl %ax,%eax
80103e40:	89 04 24             	mov    %eax,(%esp)
80103e43:	e8 86 ff ff ff       	call   80103dce <picsetmask>
}
80103e48:	83 c4 04             	add    $0x4,%esp
80103e4b:	5b                   	pop    %ebx
80103e4c:	5d                   	pop    %ebp
80103e4d:	c3                   	ret    

80103e4e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e4e:	55                   	push   %ebp
80103e4f:	89 e5                	mov    %esp,%ebp
80103e51:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e54:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e5b:	00 
80103e5c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e63:	e8 48 ff ff ff       	call   80103db0 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e68:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e6f:	00 
80103e70:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e77:	e8 34 ff ff ff       	call   80103db0 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e7c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e83:	00 
80103e84:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103e8b:	e8 20 ff ff ff       	call   80103db0 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103e90:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103e97:	00 
80103e98:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e9f:	e8 0c ff ff ff       	call   80103db0 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103ea4:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103eab:	00 
80103eac:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eb3:	e8 f8 fe ff ff       	call   80103db0 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103eb8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ebf:	00 
80103ec0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ec7:	e8 e4 fe ff ff       	call   80103db0 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103ecc:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ed3:	00 
80103ed4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103edb:	e8 d0 fe ff ff       	call   80103db0 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ee0:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103ee7:	00 
80103ee8:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103eef:	e8 bc fe ff ff       	call   80103db0 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103ef4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103efb:	00 
80103efc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f03:	e8 a8 fe ff ff       	call   80103db0 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f08:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f0f:	00 
80103f10:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f17:	e8 94 fe ff ff       	call   80103db0 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f1c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f23:	00 
80103f24:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f2b:	e8 80 fe ff ff       	call   80103db0 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f30:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f37:	00 
80103f38:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f3f:	e8 6c fe ff ff       	call   80103db0 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f44:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f4b:	00 
80103f4c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f53:	e8 58 fe ff ff       	call   80103db0 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f58:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f5f:	00 
80103f60:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f67:	e8 44 fe ff ff       	call   80103db0 <outb>

  if(irqmask != 0xFFFF)
80103f6c:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f73:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f77:	74 12                	je     80103f8b <picinit+0x13d>
    picsetmask(irqmask);
80103f79:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f80:	0f b7 c0             	movzwl %ax,%eax
80103f83:	89 04 24             	mov    %eax,(%esp)
80103f86:	e8 43 fe ff ff       	call   80103dce <picsetmask>
}
80103f8b:	c9                   	leave  
80103f8c:	c3                   	ret    
80103f8d:	00 00                	add    %al,(%eax)
	...

80103f90 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f90:	55                   	push   %ebp
80103f91:	89 e5                	mov    %esp,%ebp
80103f93:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fa6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fa9:	8b 10                	mov    (%eax),%edx
80103fab:	8b 45 08             	mov    0x8(%ebp),%eax
80103fae:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fb0:	e8 73 cf ff ff       	call   80100f28 <filealloc>
80103fb5:	8b 55 08             	mov    0x8(%ebp),%edx
80103fb8:	89 02                	mov    %eax,(%edx)
80103fba:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbd:	8b 00                	mov    (%eax),%eax
80103fbf:	85 c0                	test   %eax,%eax
80103fc1:	0f 84 c8 00 00 00    	je     8010408f <pipealloc+0xff>
80103fc7:	e8 5c cf ff ff       	call   80100f28 <filealloc>
80103fcc:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fcf:	89 02                	mov    %eax,(%edx)
80103fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd4:	8b 00                	mov    (%eax),%eax
80103fd6:	85 c0                	test   %eax,%eax
80103fd8:	0f 84 b1 00 00 00    	je     8010408f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103fde:	e8 28 eb ff ff       	call   80102b0b <kalloc>
80103fe3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fe6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103fea:	0f 84 9e 00 00 00    	je     8010408e <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff3:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ffa:	00 00 00 
  p->writeopen = 1;
80103ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104000:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104007:	00 00 00 
  p->nwrite = 0;
8010400a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400d:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104014:	00 00 00 
  p->nread = 0;
80104017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401a:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104021:	00 00 00 
  initlock(&p->lock, "pipe");
80104024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104027:	c7 44 24 04 74 87 10 	movl   $0x80108774,0x4(%esp)
8010402e:	80 
8010402f:	89 04 24             	mov    %eax,(%esp)
80104032:	e8 1f 0e 00 00       	call   80104e56 <initlock>
  (*f0)->type = FD_PIPE;
80104037:	8b 45 08             	mov    0x8(%ebp),%eax
8010403a:	8b 00                	mov    (%eax),%eax
8010403c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104042:	8b 45 08             	mov    0x8(%ebp),%eax
80104045:	8b 00                	mov    (%eax),%eax
80104047:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010404b:	8b 45 08             	mov    0x8(%ebp),%eax
8010404e:	8b 00                	mov    (%eax),%eax
80104050:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104054:	8b 45 08             	mov    0x8(%ebp),%eax
80104057:	8b 00                	mov    (%eax),%eax
80104059:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010405c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010405f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104062:	8b 00                	mov    (%eax),%eax
80104064:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010406a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010406d:	8b 00                	mov    (%eax),%eax
8010406f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104073:	8b 45 0c             	mov    0xc(%ebp),%eax
80104076:	8b 00                	mov    (%eax),%eax
80104078:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010407c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407f:	8b 00                	mov    (%eax),%eax
80104081:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104084:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104087:	b8 00 00 00 00       	mov    $0x0,%eax
8010408c:	eb 43                	jmp    801040d1 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
8010408e:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010408f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104093:	74 0b                	je     801040a0 <pipealloc+0x110>
    kfree((char*)p);
80104095:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104098:	89 04 24             	mov    %eax,(%esp)
8010409b:	e8 d2 e9 ff ff       	call   80102a72 <kfree>
  if(*f0)
801040a0:	8b 45 08             	mov    0x8(%ebp),%eax
801040a3:	8b 00                	mov    (%eax),%eax
801040a5:	85 c0                	test   %eax,%eax
801040a7:	74 0d                	je     801040b6 <pipealloc+0x126>
    fileclose(*f0);
801040a9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ac:	8b 00                	mov    (%eax),%eax
801040ae:	89 04 24             	mov    %eax,(%esp)
801040b1:	e8 1a cf ff ff       	call   80100fd0 <fileclose>
  if(*f1)
801040b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b9:	8b 00                	mov    (%eax),%eax
801040bb:	85 c0                	test   %eax,%eax
801040bd:	74 0d                	je     801040cc <pipealloc+0x13c>
    fileclose(*f1);
801040bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c2:	8b 00                	mov    (%eax),%eax
801040c4:	89 04 24             	mov    %eax,(%esp)
801040c7:	e8 04 cf ff ff       	call   80100fd0 <fileclose>
  return -1;
801040cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040d1:	c9                   	leave  
801040d2:	c3                   	ret    

801040d3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040d3:	55                   	push   %ebp
801040d4:	89 e5                	mov    %esp,%ebp
801040d6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040d9:	8b 45 08             	mov    0x8(%ebp),%eax
801040dc:	89 04 24             	mov    %eax,(%esp)
801040df:	e8 93 0d 00 00       	call   80104e77 <acquire>
  if(writable){
801040e4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040e8:	74 1f                	je     80104109 <pipeclose+0x36>
    p->writeopen = 0;
801040ea:	8b 45 08             	mov    0x8(%ebp),%eax
801040ed:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040f4:	00 00 00 
    wakeup(&p->nread);
801040f7:	8b 45 08             	mov    0x8(%ebp),%eax
801040fa:	05 34 02 00 00       	add    $0x234,%eax
801040ff:	89 04 24             	mov    %eax,(%esp)
80104102:	e8 6a 0b 00 00       	call   80104c71 <wakeup>
80104107:	eb 1d                	jmp    80104126 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104109:	8b 45 08             	mov    0x8(%ebp),%eax
8010410c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104113:	00 00 00 
    wakeup(&p->nwrite);
80104116:	8b 45 08             	mov    0x8(%ebp),%eax
80104119:	05 38 02 00 00       	add    $0x238,%eax
8010411e:	89 04 24             	mov    %eax,(%esp)
80104121:	e8 4b 0b 00 00       	call   80104c71 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104126:	8b 45 08             	mov    0x8(%ebp),%eax
80104129:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010412f:	85 c0                	test   %eax,%eax
80104131:	75 25                	jne    80104158 <pipeclose+0x85>
80104133:	8b 45 08             	mov    0x8(%ebp),%eax
80104136:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010413c:	85 c0                	test   %eax,%eax
8010413e:	75 18                	jne    80104158 <pipeclose+0x85>
    release(&p->lock);
80104140:	8b 45 08             	mov    0x8(%ebp),%eax
80104143:	89 04 24             	mov    %eax,(%esp)
80104146:	e8 8e 0d 00 00       	call   80104ed9 <release>
    kfree((char*)p);
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	89 04 24             	mov    %eax,(%esp)
80104151:	e8 1c e9 ff ff       	call   80102a72 <kfree>
80104156:	eb 0b                	jmp    80104163 <pipeclose+0x90>
  } else
    release(&p->lock);
80104158:	8b 45 08             	mov    0x8(%ebp),%eax
8010415b:	89 04 24             	mov    %eax,(%esp)
8010415e:	e8 76 0d 00 00       	call   80104ed9 <release>
}
80104163:	c9                   	leave  
80104164:	c3                   	ret    

80104165 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104165:	55                   	push   %ebp
80104166:	89 e5                	mov    %esp,%ebp
80104168:	53                   	push   %ebx
80104169:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010416c:	8b 45 08             	mov    0x8(%ebp),%eax
8010416f:	89 04 24             	mov    %eax,(%esp)
80104172:	e8 00 0d 00 00       	call   80104e77 <acquire>
  for(i = 0; i < n; i++){
80104177:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010417e:	e9 a6 00 00 00       	jmp    80104229 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104183:	8b 45 08             	mov    0x8(%ebp),%eax
80104186:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010418c:	85 c0                	test   %eax,%eax
8010418e:	74 0d                	je     8010419d <pipewrite+0x38>
80104190:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104196:	8b 40 24             	mov    0x24(%eax),%eax
80104199:	85 c0                	test   %eax,%eax
8010419b:	74 15                	je     801041b2 <pipewrite+0x4d>
        release(&p->lock);
8010419d:	8b 45 08             	mov    0x8(%ebp),%eax
801041a0:	89 04 24             	mov    %eax,(%esp)
801041a3:	e8 31 0d 00 00       	call   80104ed9 <release>
        return -1;
801041a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ad:	e9 9d 00 00 00       	jmp    8010424f <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041b2:	8b 45 08             	mov    0x8(%ebp),%eax
801041b5:	05 34 02 00 00       	add    $0x234,%eax
801041ba:	89 04 24             	mov    %eax,(%esp)
801041bd:	e8 af 0a 00 00       	call   80104c71 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041c2:	8b 45 08             	mov    0x8(%ebp),%eax
801041c5:	8b 55 08             	mov    0x8(%ebp),%edx
801041c8:	81 c2 38 02 00 00    	add    $0x238,%edx
801041ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801041d2:	89 14 24             	mov    %edx,(%esp)
801041d5:	e8 be 09 00 00       	call   80104b98 <sleep>
801041da:	eb 01                	jmp    801041dd <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041dc:	90                   	nop
801041dd:	8b 45 08             	mov    0x8(%ebp),%eax
801041e0:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041e6:	8b 45 08             	mov    0x8(%ebp),%eax
801041e9:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041ef:	05 00 02 00 00       	add    $0x200,%eax
801041f4:	39 c2                	cmp    %eax,%edx
801041f6:	74 8b                	je     80104183 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041f8:	8b 45 08             	mov    0x8(%ebp),%eax
801041fb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104201:	89 c3                	mov    %eax,%ebx
80104203:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104209:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010420c:	03 55 0c             	add    0xc(%ebp),%edx
8010420f:	0f b6 0a             	movzbl (%edx),%ecx
80104212:	8b 55 08             	mov    0x8(%ebp),%edx
80104215:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104219:	8d 50 01             	lea    0x1(%eax),%edx
8010421c:	8b 45 08             	mov    0x8(%ebp),%eax
8010421f:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104225:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010422c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010422f:	7c ab                	jl     801041dc <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104231:	8b 45 08             	mov    0x8(%ebp),%eax
80104234:	05 34 02 00 00       	add    $0x234,%eax
80104239:	89 04 24             	mov    %eax,(%esp)
8010423c:	e8 30 0a 00 00       	call   80104c71 <wakeup>
  release(&p->lock);
80104241:	8b 45 08             	mov    0x8(%ebp),%eax
80104244:	89 04 24             	mov    %eax,(%esp)
80104247:	e8 8d 0c 00 00       	call   80104ed9 <release>
  return n;
8010424c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010424f:	83 c4 24             	add    $0x24,%esp
80104252:	5b                   	pop    %ebx
80104253:	5d                   	pop    %ebp
80104254:	c3                   	ret    

80104255 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104255:	55                   	push   %ebp
80104256:	89 e5                	mov    %esp,%ebp
80104258:	53                   	push   %ebx
80104259:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010425c:	8b 45 08             	mov    0x8(%ebp),%eax
8010425f:	89 04 24             	mov    %eax,(%esp)
80104262:	e8 10 0c 00 00       	call   80104e77 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104267:	eb 3a                	jmp    801042a3 <piperead+0x4e>
    if(proc->killed){
80104269:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010426f:	8b 40 24             	mov    0x24(%eax),%eax
80104272:	85 c0                	test   %eax,%eax
80104274:	74 15                	je     8010428b <piperead+0x36>
      release(&p->lock);
80104276:	8b 45 08             	mov    0x8(%ebp),%eax
80104279:	89 04 24             	mov    %eax,(%esp)
8010427c:	e8 58 0c 00 00       	call   80104ed9 <release>
      return -1;
80104281:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104286:	e9 b6 00 00 00       	jmp    80104341 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010428b:	8b 45 08             	mov    0x8(%ebp),%eax
8010428e:	8b 55 08             	mov    0x8(%ebp),%edx
80104291:	81 c2 34 02 00 00    	add    $0x234,%edx
80104297:	89 44 24 04          	mov    %eax,0x4(%esp)
8010429b:	89 14 24             	mov    %edx,(%esp)
8010429e:	e8 f5 08 00 00       	call   80104b98 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042a3:	8b 45 08             	mov    0x8(%ebp),%eax
801042a6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042ac:	8b 45 08             	mov    0x8(%ebp),%eax
801042af:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042b5:	39 c2                	cmp    %eax,%edx
801042b7:	75 0d                	jne    801042c6 <piperead+0x71>
801042b9:	8b 45 08             	mov    0x8(%ebp),%eax
801042bc:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042c2:	85 c0                	test   %eax,%eax
801042c4:	75 a3                	jne    80104269 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042cd:	eb 49                	jmp    80104318 <piperead+0xc3>
    if(p->nread == p->nwrite)
801042cf:	8b 45 08             	mov    0x8(%ebp),%eax
801042d2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042d8:	8b 45 08             	mov    0x8(%ebp),%eax
801042db:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042e1:	39 c2                	cmp    %eax,%edx
801042e3:	74 3d                	je     80104322 <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e8:	89 c2                	mov    %eax,%edx
801042ea:	03 55 0c             	add    0xc(%ebp),%edx
801042ed:	8b 45 08             	mov    0x8(%ebp),%eax
801042f0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042f6:	89 c3                	mov    %eax,%ebx
801042f8:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801042fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104301:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104306:	88 0a                	mov    %cl,(%edx)
80104308:	8d 50 01             	lea    0x1(%eax),%edx
8010430b:	8b 45 08             	mov    0x8(%ebp),%eax
8010430e:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104314:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010431e:	7c af                	jl     801042cf <piperead+0x7a>
80104320:	eb 01                	jmp    80104323 <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80104322:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104323:	8b 45 08             	mov    0x8(%ebp),%eax
80104326:	05 38 02 00 00       	add    $0x238,%eax
8010432b:	89 04 24             	mov    %eax,(%esp)
8010432e:	e8 3e 09 00 00       	call   80104c71 <wakeup>
  release(&p->lock);
80104333:	8b 45 08             	mov    0x8(%ebp),%eax
80104336:	89 04 24             	mov    %eax,(%esp)
80104339:	e8 9b 0b 00 00       	call   80104ed9 <release>
  return i;
8010433e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104341:	83 c4 24             	add    $0x24,%esp
80104344:	5b                   	pop    %ebx
80104345:	5d                   	pop    %ebp
80104346:	c3                   	ret    
	...

80104348 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104348:	55                   	push   %ebp
80104349:	89 e5                	mov    %esp,%ebp
8010434b:	53                   	push   %ebx
8010434c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010434f:	9c                   	pushf  
80104350:	5b                   	pop    %ebx
80104351:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104354:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104357:	83 c4 10             	add    $0x10,%esp
8010435a:	5b                   	pop    %ebx
8010435b:	5d                   	pop    %ebp
8010435c:	c3                   	ret    

8010435d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010435d:	55                   	push   %ebp
8010435e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104360:	fb                   	sti    
}
80104361:	5d                   	pop    %ebp
80104362:	c3                   	ret    

80104363 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104363:	55                   	push   %ebp
80104364:	89 e5                	mov    %esp,%ebp
80104366:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104369:	c7 44 24 04 79 87 10 	movl   $0x80108779,0x4(%esp)
80104370:	80 
80104371:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104378:	e8 d9 0a 00 00       	call   80104e56 <initlock>
}
8010437d:	c9                   	leave  
8010437e:	c3                   	ret    

8010437f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010437f:	55                   	push   %ebp
80104380:	89 e5                	mov    %esp,%ebp
80104382:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104385:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
8010438c:	e8 e6 0a 00 00       	call   80104e77 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104391:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104398:	eb 0e                	jmp    801043a8 <allocproc+0x29>
    if(p->state == UNUSED)
8010439a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439d:	8b 40 0c             	mov    0xc(%eax),%eax
801043a0:	85 c0                	test   %eax,%eax
801043a2:	74 23                	je     801043c7 <allocproc+0x48>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a4:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801043a8:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
801043af:	72 e9                	jb     8010439a <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043b1:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801043b8:	e8 1c 0b 00 00       	call   80104ed9 <release>
  return 0;
801043bd:	b8 00 00 00 00       	mov    $0x0,%eax
801043c2:	e9 b5 00 00 00       	jmp    8010447c <allocproc+0xfd>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043c7:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cb:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043d2:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043da:	89 42 10             	mov    %eax,0x10(%edx)
801043dd:	83 c0 01             	add    $0x1,%eax
801043e0:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801043e5:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801043ec:	e8 e8 0a 00 00       	call   80104ed9 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801043f1:	e8 15 e7 ff ff       	call   80102b0b <kalloc>
801043f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f9:	89 42 08             	mov    %eax,0x8(%edx)
801043fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ff:	8b 40 08             	mov    0x8(%eax),%eax
80104402:	85 c0                	test   %eax,%eax
80104404:	75 11                	jne    80104417 <allocproc+0x98>
    p->state = UNUSED;
80104406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104409:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104410:	b8 00 00 00 00       	mov    $0x0,%eax
80104415:	eb 65                	jmp    8010447c <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
80104417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441a:	8b 40 08             	mov    0x8(%eax),%eax
8010441d:	05 00 10 00 00       	add    $0x1000,%eax
80104422:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104425:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104429:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010442f:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104432:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104436:	ba 20 65 10 80       	mov    $0x80106520,%edx
8010443b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010443e:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104440:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104447:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010444a:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010444d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104450:	8b 40 1c             	mov    0x1c(%eax),%eax
80104453:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010445a:	00 
8010445b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104462:	00 
80104463:	89 04 24             	mov    %eax,(%esp)
80104466:	e8 5b 0c 00 00       	call   801050c6 <memset>
  p->context->eip = (uint)forkret;
8010446b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104471:	ba 6c 4b 10 80       	mov    $0x80104b6c,%edx
80104476:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104479:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010447c:	c9                   	leave  
8010447d:	c3                   	ret    

8010447e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010447e:	55                   	push   %ebp
8010447f:	89 e5                	mov    %esp,%ebp
80104481:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104484:	e8 f6 fe ff ff       	call   8010437f <allocproc>
80104489:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
8010448c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448f:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
80104494:	e8 a0 37 00 00       	call   80107c39 <setupkvm>
80104499:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010449c:	89 42 04             	mov    %eax,0x4(%edx)
8010449f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a2:	8b 40 04             	mov    0x4(%eax),%eax
801044a5:	85 c0                	test   %eax,%eax
801044a7:	75 0c                	jne    801044b5 <userinit+0x37>
    panic("userinit: out of memory?");
801044a9:	c7 04 24 80 87 10 80 	movl   $0x80108780,(%esp)
801044b0:	e8 88 c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044b5:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bd:	8b 40 04             	mov    0x4(%eax),%eax
801044c0:	89 54 24 08          	mov    %edx,0x8(%esp)
801044c4:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044cb:	80 
801044cc:	89 04 24             	mov    %eax,(%esp)
801044cf:	e8 bd 39 00 00       	call   80107e91 <inituvm>
  p->sz = PGSIZE;
801044d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d7:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e0:	8b 40 18             	mov    0x18(%eax),%eax
801044e3:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044ea:	00 
801044eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044f2:	00 
801044f3:	89 04 24             	mov    %eax,(%esp)
801044f6:	e8 cb 0b 00 00       	call   801050c6 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fe:	8b 40 18             	mov    0x18(%eax),%eax
80104501:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450a:	8b 40 18             	mov    0x18(%eax),%eax
8010450d:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104516:	8b 40 18             	mov    0x18(%eax),%eax
80104519:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010451c:	8b 52 18             	mov    0x18(%edx),%edx
8010451f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104523:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452a:	8b 40 18             	mov    0x18(%eax),%eax
8010452d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104530:	8b 52 18             	mov    0x18(%edx),%edx
80104533:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104537:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453e:	8b 40 18             	mov    0x18(%eax),%eax
80104541:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454b:	8b 40 18             	mov    0x18(%eax),%eax
8010454e:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104558:	8b 40 18             	mov    0x18(%eax),%eax
8010455b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104565:	83 c0 6c             	add    $0x6c,%eax
80104568:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010456f:	00 
80104570:	c7 44 24 04 99 87 10 	movl   $0x80108799,0x4(%esp)
80104577:	80 
80104578:	89 04 24             	mov    %eax,(%esp)
8010457b:	e8 76 0d 00 00       	call   801052f6 <safestrcpy>
  p->cwd = namei("/");
80104580:	c7 04 24 a2 87 10 80 	movl   $0x801087a2,(%esp)
80104587:	e8 8a de ff ff       	call   80102416 <namei>
8010458c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010458f:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104592:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104595:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010459c:	c9                   	leave  
8010459d:	c3                   	ret    

8010459e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010459e:	55                   	push   %ebp
8010459f:	89 e5                	mov    %esp,%ebp
801045a1:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045aa:	8b 00                	mov    (%eax),%eax
801045ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045b3:	7e 34                	jle    801045e9 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045b5:	8b 45 08             	mov    0x8(%ebp),%eax
801045b8:	89 c2                	mov    %eax,%edx
801045ba:	03 55 f4             	add    -0xc(%ebp),%edx
801045bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c3:	8b 40 04             	mov    0x4(%eax),%eax
801045c6:	89 54 24 08          	mov    %edx,0x8(%esp)
801045ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045cd:	89 54 24 04          	mov    %edx,0x4(%esp)
801045d1:	89 04 24             	mov    %eax,(%esp)
801045d4:	e8 32 3a 00 00       	call   8010800b <allocuvm>
801045d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045e0:	75 41                	jne    80104623 <growproc+0x85>
      return -1;
801045e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045e7:	eb 58                	jmp    80104641 <growproc+0xa3>
  } else if(n < 0){
801045e9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045ed:	79 34                	jns    80104623 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801045ef:	8b 45 08             	mov    0x8(%ebp),%eax
801045f2:	89 c2                	mov    %eax,%edx
801045f4:	03 55 f4             	add    -0xc(%ebp),%edx
801045f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045fd:	8b 40 04             	mov    0x4(%eax),%eax
80104600:	89 54 24 08          	mov    %edx,0x8(%esp)
80104604:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104607:	89 54 24 04          	mov    %edx,0x4(%esp)
8010460b:	89 04 24             	mov    %eax,(%esp)
8010460e:	e8 d2 3a 00 00       	call   801080e5 <deallocuvm>
80104613:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104616:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010461a:	75 07                	jne    80104623 <growproc+0x85>
      return -1;
8010461c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104621:	eb 1e                	jmp    80104641 <growproc+0xa3>
  }
  proc->sz = sz;
80104623:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104629:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010462c:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010462e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104634:	89 04 24             	mov    %eax,(%esp)
80104637:	e8 ee 36 00 00       	call   80107d2a <switchuvm>
  return 0;
8010463c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104641:	c9                   	leave  
80104642:	c3                   	ret    

80104643 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104643:	55                   	push   %ebp
80104644:	89 e5                	mov    %esp,%ebp
80104646:	57                   	push   %edi
80104647:	56                   	push   %esi
80104648:	53                   	push   %ebx
80104649:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010464c:	e8 2e fd ff ff       	call   8010437f <allocproc>
80104651:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104654:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104658:	75 0a                	jne    80104664 <fork+0x21>
    return -1;
8010465a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010465f:	e9 52 01 00 00       	jmp    801047b6 <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104664:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010466a:	8b 10                	mov    (%eax),%edx
8010466c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104672:	8b 40 04             	mov    0x4(%eax),%eax
80104675:	89 54 24 04          	mov    %edx,0x4(%esp)
80104679:	89 04 24             	mov    %eax,(%esp)
8010467c:	e8 f4 3b 00 00       	call   80108275 <copyuvm>
80104681:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104684:	89 42 04             	mov    %eax,0x4(%edx)
80104687:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468a:	8b 40 04             	mov    0x4(%eax),%eax
8010468d:	85 c0                	test   %eax,%eax
8010468f:	75 2c                	jne    801046bd <fork+0x7a>
    kfree(np->kstack);
80104691:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104694:	8b 40 08             	mov    0x8(%eax),%eax
80104697:	89 04 24             	mov    %eax,(%esp)
8010469a:	e8 d3 e3 ff ff       	call   80102a72 <kfree>
    np->kstack = 0;
8010469f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ac:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046b8:	e9 f9 00 00 00       	jmp    801047b6 <fork+0x173>
  }
  np->sz = proc->sz;
801046bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c3:	8b 10                	mov    (%eax),%edx
801046c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c8:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046ca:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046da:	8b 50 18             	mov    0x18(%eax),%edx
801046dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e3:	8b 40 18             	mov    0x18(%eax),%eax
801046e6:	89 c3                	mov    %eax,%ebx
801046e8:	b8 13 00 00 00       	mov    $0x13,%eax
801046ed:	89 d7                	mov    %edx,%edi
801046ef:	89 de                	mov    %ebx,%esi
801046f1:	89 c1                	mov    %eax,%ecx
801046f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f8:	8b 40 18             	mov    0x18(%eax),%eax
801046fb:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104702:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104709:	eb 3d                	jmp    80104748 <fork+0x105>
    if(proc->ofile[i])
8010470b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104711:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104714:	83 c2 08             	add    $0x8,%edx
80104717:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010471b:	85 c0                	test   %eax,%eax
8010471d:	74 25                	je     80104744 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010471f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104725:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104728:	83 c2 08             	add    $0x8,%edx
8010472b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010472f:	89 04 24             	mov    %eax,(%esp)
80104732:	e8 51 c8 ff ff       	call   80100f88 <filedup>
80104737:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010473a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010473d:	83 c1 08             	add    $0x8,%ecx
80104740:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104744:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104748:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010474c:	7e bd                	jle    8010470b <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010474e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104754:	8b 40 68             	mov    0x68(%eax),%eax
80104757:	89 04 24             	mov    %eax,(%esp)
8010475a:	e8 e3 d0 ff ff       	call   80101842 <idup>
8010475f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104762:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104765:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010476e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104771:	83 c0 6c             	add    $0x6c,%eax
80104774:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010477b:	00 
8010477c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104780:	89 04 24             	mov    %eax,(%esp)
80104783:	e8 6e 0b 00 00       	call   801052f6 <safestrcpy>
 
  pid = np->pid;
80104788:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478b:	8b 40 10             	mov    0x10(%eax),%eax
8010478e:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104791:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104798:	e8 da 06 00 00       	call   80104e77 <acquire>
  np->state = RUNNABLE;
8010479d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801047a7:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047ae:	e8 26 07 00 00       	call   80104ed9 <release>
  
  return pid;
801047b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047b6:	83 c4 2c             	add    $0x2c,%esp
801047b9:	5b                   	pop    %ebx
801047ba:	5e                   	pop    %esi
801047bb:	5f                   	pop    %edi
801047bc:	5d                   	pop    %ebp
801047bd:	c3                   	ret    

801047be <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(int status)
{
801047be:	55                   	push   %ebp
801047bf:	89 e5                	mov    %esp,%ebp
801047c1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047c4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047cb:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801047d0:	39 c2                	cmp    %eax,%edx
801047d2:	75 0c                	jne    801047e0 <exit+0x22>
    panic("init exiting");
801047d4:	c7 04 24 a4 87 10 80 	movl   $0x801087a4,(%esp)
801047db:	e8 5d bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047e0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047e7:	eb 44                	jmp    8010482d <exit+0x6f>
    if(proc->ofile[fd]){
801047e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
801047f2:	83 c2 08             	add    $0x8,%edx
801047f5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801047f9:	85 c0                	test   %eax,%eax
801047fb:	74 2c                	je     80104829 <exit+0x6b>
      fileclose(proc->ofile[fd]);
801047fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104803:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104806:	83 c2 08             	add    $0x8,%edx
80104809:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010480d:	89 04 24             	mov    %eax,(%esp)
80104810:	e8 bb c7 ff ff       	call   80100fd0 <fileclose>
      proc->ofile[fd] = 0;
80104815:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010481e:	83 c2 08             	add    $0x8,%edx
80104821:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104828:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104829:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010482d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104831:	7e b6                	jle    801047e9 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104833:	e8 29 ec ff ff       	call   80103461 <begin_op>
  iput(proc->cwd);
80104838:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483e:	8b 40 68             	mov    0x68(%eax),%eax
80104841:	89 04 24             	mov    %eax,(%esp)
80104844:	e8 de d1 ff ff       	call   80101a27 <iput>
  end_op();
80104849:	e8 94 ec ff ff       	call   801034e2 <end_op>
  proc->cwd = 0;
8010484e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104854:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010485b:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104862:	e8 10 06 00 00       	call   80104e77 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104867:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486d:	8b 40 14             	mov    0x14(%eax),%eax
80104870:	89 04 24             	mov    %eax,(%esp)
80104873:	e8 bb 03 00 00       	call   80104c33 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104878:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
8010487f:	eb 38                	jmp    801048b9 <exit+0xfb>
    if(p->parent == proc){
80104881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104884:	8b 50 14             	mov    0x14(%eax),%edx
80104887:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488d:	39 c2                	cmp    %eax,%edx
8010488f:	75 24                	jne    801048b5 <exit+0xf7>
      p->parent = initproc;
80104891:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
80104897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489a:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010489d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a0:	8b 40 0c             	mov    0xc(%eax),%eax
801048a3:	83 f8 05             	cmp    $0x5,%eax
801048a6:	75 0d                	jne    801048b5 <exit+0xf7>
        wakeup1(initproc);
801048a8:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048ad:	89 04 24             	mov    %eax,(%esp)
801048b0:	e8 7e 03 00 00       	call   80104c33 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048b5:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801048b9:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
801048c0:	72 bf                	jb     80104881 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801048c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048c8:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048cf:	e8 b4 01 00 00       	call   80104a88 <sched>
  panic("zombie exit");
801048d4:	c7 04 24 b1 87 10 80 	movl   $0x801087b1,(%esp)
801048db:	e8 5d bc ff ff       	call   8010053d <panic>

801048e0 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801048e0:	55                   	push   %ebp
801048e1:	89 e5                	mov    %esp,%ebp
801048e3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801048e6:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801048ed:	e8 85 05 00 00       	call   80104e77 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801048f2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048f9:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104900:	e9 9a 00 00 00       	jmp    8010499f <wait+0xbf>
      if(p->parent != proc)
80104905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104908:	8b 50 14             	mov    0x14(%eax),%edx
8010490b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104911:	39 c2                	cmp    %eax,%edx
80104913:	0f 85 81 00 00 00    	jne    8010499a <wait+0xba>
        continue;
      havekids = 1;
80104919:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104923:	8b 40 0c             	mov    0xc(%eax),%eax
80104926:	83 f8 05             	cmp    $0x5,%eax
80104929:	75 70                	jne    8010499b <wait+0xbb>
        // Found one.
        pid = p->pid;
8010492b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492e:	8b 40 10             	mov    0x10(%eax),%eax
80104931:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104934:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104937:	8b 40 08             	mov    0x8(%eax),%eax
8010493a:	89 04 24             	mov    %eax,(%esp)
8010493d:	e8 30 e1 ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
80104942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104945:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010494c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494f:	8b 40 04             	mov    0x4(%eax),%eax
80104952:	89 04 24             	mov    %eax,(%esp)
80104955:	e8 47 38 00 00       	call   801081a1 <freevm>
        p->state = UNUSED;
8010495a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104967:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010496e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104971:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010497f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104982:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104989:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104990:	e8 44 05 00 00       	call   80104ed9 <release>
        return pid;
80104995:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104998:	eb 53                	jmp    801049ed <wait+0x10d>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
8010499a:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010499b:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010499f:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
801049a6:	0f 82 59 ff ff ff    	jb     80104905 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049b0:	74 0d                	je     801049bf <wait+0xdf>
801049b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b8:	8b 40 24             	mov    0x24(%eax),%eax
801049bb:	85 c0                	test   %eax,%eax
801049bd:	74 13                	je     801049d2 <wait+0xf2>
      release(&ptable.lock);
801049bf:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801049c6:	e8 0e 05 00 00       	call   80104ed9 <release>
      return -1;
801049cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049d0:	eb 1b                	jmp    801049ed <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801049d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d8:	c7 44 24 04 60 29 11 	movl   $0x80112960,0x4(%esp)
801049df:	80 
801049e0:	89 04 24             	mov    %eax,(%esp)
801049e3:	e8 b0 01 00 00       	call   80104b98 <sleep>
  }
801049e8:	e9 05 ff ff ff       	jmp    801048f2 <wait+0x12>
}
801049ed:	c9                   	leave  
801049ee:	c3                   	ret    

801049ef <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801049ef:	55                   	push   %ebp
801049f0:	89 e5                	mov    %esp,%ebp
801049f2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801049f5:	e8 63 f9 ff ff       	call   8010435d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801049fa:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a01:	e8 71 04 00 00       	call   80104e77 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a06:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104a0d:	eb 5f                	jmp    80104a6e <scheduler+0x7f>
      if(p->state != RUNNABLE)
80104a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a12:	8b 40 0c             	mov    0xc(%eax),%eax
80104a15:	83 f8 03             	cmp    $0x3,%eax
80104a18:	75 4f                	jne    80104a69 <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1d:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a26:	89 04 24             	mov    %eax,(%esp)
80104a29:	e8 fc 32 00 00       	call   80107d2a <switchuvm>
      p->state = RUNNING;
80104a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a31:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104a38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a3e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a41:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104a48:	83 c2 04             	add    $0x4,%edx
80104a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a4f:	89 14 24             	mov    %edx,(%esp)
80104a52:	e8 15 09 00 00       	call   8010536c <swtch>
      switchkvm();
80104a57:	e8 b1 32 00 00       	call   80107d0d <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104a5c:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104a63:	00 00 00 00 
80104a67:	eb 01                	jmp    80104a6a <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104a69:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a6a:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104a6e:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
80104a75:	72 98                	jb     80104a0f <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104a77:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a7e:	e8 56 04 00 00       	call   80104ed9 <release>

  }
80104a83:	e9 6d ff ff ff       	jmp    801049f5 <scheduler+0x6>

80104a88 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104a88:	55                   	push   %ebp
80104a89:	89 e5                	mov    %esp,%ebp
80104a8b:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104a8e:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a95:	e8 fb 04 00 00       	call   80104f95 <holding>
80104a9a:	85 c0                	test   %eax,%eax
80104a9c:	75 0c                	jne    80104aaa <sched+0x22>
    panic("sched ptable.lock");
80104a9e:	c7 04 24 bd 87 10 80 	movl   $0x801087bd,(%esp)
80104aa5:	e8 93 ba ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104aaa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ab0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104ab6:	83 f8 01             	cmp    $0x1,%eax
80104ab9:	74 0c                	je     80104ac7 <sched+0x3f>
    panic("sched locks");
80104abb:	c7 04 24 cf 87 10 80 	movl   $0x801087cf,(%esp)
80104ac2:	e8 76 ba ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104ac7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104acd:	8b 40 0c             	mov    0xc(%eax),%eax
80104ad0:	83 f8 04             	cmp    $0x4,%eax
80104ad3:	75 0c                	jne    80104ae1 <sched+0x59>
    panic("sched running");
80104ad5:	c7 04 24 db 87 10 80 	movl   $0x801087db,(%esp)
80104adc:	e8 5c ba ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104ae1:	e8 62 f8 ff ff       	call   80104348 <readeflags>
80104ae6:	25 00 02 00 00       	and    $0x200,%eax
80104aeb:	85 c0                	test   %eax,%eax
80104aed:	74 0c                	je     80104afb <sched+0x73>
    panic("sched interruptible");
80104aef:	c7 04 24 e9 87 10 80 	movl   $0x801087e9,(%esp)
80104af6:	e8 42 ba ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104afb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b01:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104b07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104b0a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b10:	8b 40 04             	mov    0x4(%eax),%eax
80104b13:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b1a:	83 c2 1c             	add    $0x1c,%edx
80104b1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b21:	89 14 24             	mov    %edx,(%esp)
80104b24:	e8 43 08 00 00       	call   8010536c <swtch>
  cpu->intena = intena;
80104b29:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b32:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104b38:	c9                   	leave  
80104b39:	c3                   	ret    

80104b3a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b3a:	55                   	push   %ebp
80104b3b:	89 e5                	mov    %esp,%ebp
80104b3d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b40:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b47:	e8 2b 03 00 00       	call   80104e77 <acquire>
  proc->state = RUNNABLE;
80104b4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b52:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b59:	e8 2a ff ff ff       	call   80104a88 <sched>
  release(&ptable.lock);
80104b5e:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b65:	e8 6f 03 00 00       	call   80104ed9 <release>
}
80104b6a:	c9                   	leave  
80104b6b:	c3                   	ret    

80104b6c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b6c:	55                   	push   %ebp
80104b6d:	89 e5                	mov    %esp,%ebp
80104b6f:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b72:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b79:	e8 5b 03 00 00       	call   80104ed9 <release>

  if (first) {
80104b7e:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104b83:	85 c0                	test   %eax,%eax
80104b85:	74 0f                	je     80104b96 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104b87:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104b8e:	00 00 00 
    initlog();
80104b91:	e8 be e6 ff ff       	call   80103254 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104b96:	c9                   	leave  
80104b97:	c3                   	ret    

80104b98 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104b98:	55                   	push   %ebp
80104b99:	89 e5                	mov    %esp,%ebp
80104b9b:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104b9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ba4:	85 c0                	test   %eax,%eax
80104ba6:	75 0c                	jne    80104bb4 <sleep+0x1c>
    panic("sleep");
80104ba8:	c7 04 24 fd 87 10 80 	movl   $0x801087fd,(%esp)
80104baf:	e8 89 b9 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104bb4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104bb8:	75 0c                	jne    80104bc6 <sleep+0x2e>
    panic("sleep without lk");
80104bba:	c7 04 24 03 88 10 80 	movl   $0x80108803,(%esp)
80104bc1:	e8 77 b9 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104bc6:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104bcd:	74 17                	je     80104be6 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104bcf:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104bd6:	e8 9c 02 00 00       	call   80104e77 <acquire>
    release(lk);
80104bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bde:	89 04 24             	mov    %eax,(%esp)
80104be1:	e8 f3 02 00 00       	call   80104ed9 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104be6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bec:	8b 55 08             	mov    0x8(%ebp),%edx
80104bef:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104bf2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104bff:	e8 84 fe ff ff       	call   80104a88 <sched>

  // Tidy up.
  proc->chan = 0;
80104c04:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c0a:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c11:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104c18:	74 17                	je     80104c31 <sleep+0x99>
    release(&ptable.lock);
80104c1a:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c21:	e8 b3 02 00 00       	call   80104ed9 <release>
    acquire(lk);
80104c26:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c29:	89 04 24             	mov    %eax,(%esp)
80104c2c:	e8 46 02 00 00       	call   80104e77 <acquire>
  }
}
80104c31:	c9                   	leave  
80104c32:	c3                   	ret    

80104c33 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c33:	55                   	push   %ebp
80104c34:	89 e5                	mov    %esp,%ebp
80104c36:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c39:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104c40:	eb 24                	jmp    80104c66 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c45:	8b 40 0c             	mov    0xc(%eax),%eax
80104c48:	83 f8 02             	cmp    $0x2,%eax
80104c4b:	75 15                	jne    80104c62 <wakeup1+0x2f>
80104c4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c50:	8b 40 20             	mov    0x20(%eax),%eax
80104c53:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c56:	75 0a                	jne    80104c62 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c5b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c62:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104c66:	81 7d fc 94 49 11 80 	cmpl   $0x80114994,-0x4(%ebp)
80104c6d:	72 d3                	jb     80104c42 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c6f:	c9                   	leave  
80104c70:	c3                   	ret    

80104c71 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c71:	55                   	push   %ebp
80104c72:	89 e5                	mov    %esp,%ebp
80104c74:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104c77:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c7e:	e8 f4 01 00 00       	call   80104e77 <acquire>
  wakeup1(chan);
80104c83:	8b 45 08             	mov    0x8(%ebp),%eax
80104c86:	89 04 24             	mov    %eax,(%esp)
80104c89:	e8 a5 ff ff ff       	call   80104c33 <wakeup1>
  release(&ptable.lock);
80104c8e:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c95:	e8 3f 02 00 00       	call   80104ed9 <release>
}
80104c9a:	c9                   	leave  
80104c9b:	c3                   	ret    

80104c9c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104c9c:	55                   	push   %ebp
80104c9d:	89 e5                	mov    %esp,%ebp
80104c9f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ca2:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ca9:	e8 c9 01 00 00       	call   80104e77 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cae:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104cb5:	eb 41                	jmp    80104cf8 <kill+0x5c>
    if(p->pid == pid){
80104cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cba:	8b 40 10             	mov    0x10(%eax),%eax
80104cbd:	3b 45 08             	cmp    0x8(%ebp),%eax
80104cc0:	75 32                	jne    80104cf4 <kill+0x58>
      p->killed = 1;
80104cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ccc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ccf:	8b 40 0c             	mov    0xc(%eax),%eax
80104cd2:	83 f8 02             	cmp    $0x2,%eax
80104cd5:	75 0a                	jne    80104ce1 <kill+0x45>
        p->state = RUNNABLE;
80104cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cda:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104ce1:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ce8:	e8 ec 01 00 00       	call   80104ed9 <release>
      return 0;
80104ced:	b8 00 00 00 00       	mov    $0x0,%eax
80104cf2:	eb 1e                	jmp    80104d12 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cf4:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104cf8:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
80104cff:	72 b6                	jb     80104cb7 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d01:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d08:	e8 cc 01 00 00       	call   80104ed9 <release>
  return -1;
80104d0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d12:	c9                   	leave  
80104d13:	c3                   	ret    

80104d14 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d14:	55                   	push   %ebp
80104d15:	89 e5                	mov    %esp,%ebp
80104d17:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d1a:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104d21:	e9 d8 00 00 00       	jmp    80104dfe <procdump+0xea>
    if(p->state == UNUSED)
80104d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d29:	8b 40 0c             	mov    0xc(%eax),%eax
80104d2c:	85 c0                	test   %eax,%eax
80104d2e:	0f 84 c5 00 00 00    	je     80104df9 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d37:	8b 40 0c             	mov    0xc(%eax),%eax
80104d3a:	83 f8 05             	cmp    $0x5,%eax
80104d3d:	77 23                	ja     80104d62 <procdump+0x4e>
80104d3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d42:	8b 40 0c             	mov    0xc(%eax),%eax
80104d45:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104d4c:	85 c0                	test   %eax,%eax
80104d4e:	74 12                	je     80104d62 <procdump+0x4e>
      state = states[p->state];
80104d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d53:	8b 40 0c             	mov    0xc(%eax),%eax
80104d56:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104d5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d60:	eb 07                	jmp    80104d69 <procdump+0x55>
    else
      state = "???";
80104d62:	c7 45 ec 14 88 10 80 	movl   $0x80108814,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d6c:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d72:	8b 40 10             	mov    0x10(%eax),%eax
80104d75:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104d79:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d7c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d80:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d84:	c7 04 24 18 88 10 80 	movl   $0x80108818,(%esp)
80104d8b:	e8 11 b6 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d93:	8b 40 0c             	mov    0xc(%eax),%eax
80104d96:	83 f8 02             	cmp    $0x2,%eax
80104d99:	75 50                	jne    80104deb <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d9e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104da1:	8b 40 0c             	mov    0xc(%eax),%eax
80104da4:	83 c0 08             	add    $0x8,%eax
80104da7:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104daa:	89 54 24 04          	mov    %edx,0x4(%esp)
80104dae:	89 04 24             	mov    %eax,(%esp)
80104db1:	e8 72 01 00 00       	call   80104f28 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104db6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104dbd:	eb 1b                	jmp    80104dda <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104dbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc2:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dca:	c7 04 24 21 88 10 80 	movl   $0x80108821,(%esp)
80104dd1:	e8 cb b5 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104dd6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104dda:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104dde:	7f 0b                	jg     80104deb <procdump+0xd7>
80104de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104de7:	85 c0                	test   %eax,%eax
80104de9:	75 d4                	jne    80104dbf <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104deb:	c7 04 24 25 88 10 80 	movl   $0x80108825,(%esp)
80104df2:	e8 aa b5 ff ff       	call   801003a1 <cprintf>
80104df7:	eb 01                	jmp    80104dfa <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104df9:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dfa:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104dfe:	81 7d f0 94 49 11 80 	cmpl   $0x80114994,-0x10(%ebp)
80104e05:	0f 82 1b ff ff ff    	jb     80104d26 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104e0b:	c9                   	leave  
80104e0c:	c3                   	ret    
80104e0d:	00 00                	add    %al,(%eax)
	...

80104e10 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104e10:	55                   	push   %ebp
80104e11:	89 e5                	mov    %esp,%ebp
80104e13:	53                   	push   %ebx
80104e14:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104e17:	9c                   	pushf  
80104e18:	5b                   	pop    %ebx
80104e19:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104e1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104e1f:	83 c4 10             	add    $0x10,%esp
80104e22:	5b                   	pop    %ebx
80104e23:	5d                   	pop    %ebp
80104e24:	c3                   	ret    

80104e25 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104e25:	55                   	push   %ebp
80104e26:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104e28:	fa                   	cli    
}
80104e29:	5d                   	pop    %ebp
80104e2a:	c3                   	ret    

80104e2b <sti>:

static inline void
sti(void)
{
80104e2b:	55                   	push   %ebp
80104e2c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104e2e:	fb                   	sti    
}
80104e2f:	5d                   	pop    %ebp
80104e30:	c3                   	ret    

80104e31 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104e31:	55                   	push   %ebp
80104e32:	89 e5                	mov    %esp,%ebp
80104e34:	53                   	push   %ebx
80104e35:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104e38:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104e3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104e41:	89 c3                	mov    %eax,%ebx
80104e43:	89 d8                	mov    %ebx,%eax
80104e45:	f0 87 02             	lock xchg %eax,(%edx)
80104e48:	89 c3                	mov    %eax,%ebx
80104e4a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104e4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104e50:	83 c4 10             	add    $0x10,%esp
80104e53:	5b                   	pop    %ebx
80104e54:	5d                   	pop    %ebp
80104e55:	c3                   	ret    

80104e56 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104e56:	55                   	push   %ebp
80104e57:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104e59:	8b 45 08             	mov    0x8(%ebp),%eax
80104e5c:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e5f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104e62:	8b 45 08             	mov    0x8(%ebp),%eax
80104e65:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104e75:	5d                   	pop    %ebp
80104e76:	c3                   	ret    

80104e77 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104e77:	55                   	push   %ebp
80104e78:	89 e5                	mov    %esp,%ebp
80104e7a:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104e7d:	e8 3d 01 00 00       	call   80104fbf <pushcli>
  if(holding(lk))
80104e82:	8b 45 08             	mov    0x8(%ebp),%eax
80104e85:	89 04 24             	mov    %eax,(%esp)
80104e88:	e8 08 01 00 00       	call   80104f95 <holding>
80104e8d:	85 c0                	test   %eax,%eax
80104e8f:	74 0c                	je     80104e9d <acquire+0x26>
    panic("acquire");
80104e91:	c7 04 24 51 88 10 80 	movl   $0x80108851,(%esp)
80104e98:	e8 a0 b6 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104e9d:	90                   	nop
80104e9e:	8b 45 08             	mov    0x8(%ebp),%eax
80104ea1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104ea8:	00 
80104ea9:	89 04 24             	mov    %eax,(%esp)
80104eac:	e8 80 ff ff ff       	call   80104e31 <xchg>
80104eb1:	85 c0                	test   %eax,%eax
80104eb3:	75 e9                	jne    80104e9e <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104eb8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ebf:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec5:	83 c0 0c             	add    $0xc,%eax
80104ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ecc:	8d 45 08             	lea    0x8(%ebp),%eax
80104ecf:	89 04 24             	mov    %eax,(%esp)
80104ed2:	e8 51 00 00 00       	call   80104f28 <getcallerpcs>
}
80104ed7:	c9                   	leave  
80104ed8:	c3                   	ret    

80104ed9 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104ed9:	55                   	push   %ebp
80104eda:	89 e5                	mov    %esp,%ebp
80104edc:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104edf:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee2:	89 04 24             	mov    %eax,(%esp)
80104ee5:	e8 ab 00 00 00       	call   80104f95 <holding>
80104eea:	85 c0                	test   %eax,%eax
80104eec:	75 0c                	jne    80104efa <release+0x21>
    panic("release");
80104eee:	c7 04 24 59 88 10 80 	movl   $0x80108859,(%esp)
80104ef5:	e8 43 b6 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80104efa:	8b 45 08             	mov    0x8(%ebp),%eax
80104efd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104f04:	8b 45 08             	mov    0x8(%ebp),%eax
80104f07:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104f0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f11:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104f18:	00 
80104f19:	89 04 24             	mov    %eax,(%esp)
80104f1c:	e8 10 ff ff ff       	call   80104e31 <xchg>

  popcli();
80104f21:	e8 e1 00 00 00       	call   80105007 <popcli>
}
80104f26:	c9                   	leave  
80104f27:	c3                   	ret    

80104f28 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104f28:	55                   	push   %ebp
80104f29:	89 e5                	mov    %esp,%ebp
80104f2b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f31:	83 e8 08             	sub    $0x8,%eax
80104f34:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104f37:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104f3e:	eb 32                	jmp    80104f72 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104f40:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104f44:	74 47                	je     80104f8d <getcallerpcs+0x65>
80104f46:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104f4d:	76 3e                	jbe    80104f8d <getcallerpcs+0x65>
80104f4f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104f53:	74 38                	je     80104f8d <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104f55:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f58:	c1 e0 02             	shl    $0x2,%eax
80104f5b:	03 45 0c             	add    0xc(%ebp),%eax
80104f5e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f61:	8b 52 04             	mov    0x4(%edx),%edx
80104f64:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80104f66:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f69:	8b 00                	mov    (%eax),%eax
80104f6b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104f6e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104f72:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f76:	7e c8                	jle    80104f40 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104f78:	eb 13                	jmp    80104f8d <getcallerpcs+0x65>
    pcs[i] = 0;
80104f7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f7d:	c1 e0 02             	shl    $0x2,%eax
80104f80:	03 45 0c             	add    0xc(%ebp),%eax
80104f83:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104f89:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104f8d:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f91:	7e e7                	jle    80104f7a <getcallerpcs+0x52>
    pcs[i] = 0;
}
80104f93:	c9                   	leave  
80104f94:	c3                   	ret    

80104f95 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104f95:	55                   	push   %ebp
80104f96:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104f98:	8b 45 08             	mov    0x8(%ebp),%eax
80104f9b:	8b 00                	mov    (%eax),%eax
80104f9d:	85 c0                	test   %eax,%eax
80104f9f:	74 17                	je     80104fb8 <holding+0x23>
80104fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa4:	8b 50 08             	mov    0x8(%eax),%edx
80104fa7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fad:	39 c2                	cmp    %eax,%edx
80104faf:	75 07                	jne    80104fb8 <holding+0x23>
80104fb1:	b8 01 00 00 00       	mov    $0x1,%eax
80104fb6:	eb 05                	jmp    80104fbd <holding+0x28>
80104fb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fbd:	5d                   	pop    %ebp
80104fbe:	c3                   	ret    

80104fbf <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104fbf:	55                   	push   %ebp
80104fc0:	89 e5                	mov    %esp,%ebp
80104fc2:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104fc5:	e8 46 fe ff ff       	call   80104e10 <readeflags>
80104fca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104fcd:	e8 53 fe ff ff       	call   80104e25 <cli>
  if(cpu->ncli++ == 0)
80104fd2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fd8:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104fde:	85 d2                	test   %edx,%edx
80104fe0:	0f 94 c1             	sete   %cl
80104fe3:	83 c2 01             	add    $0x1,%edx
80104fe6:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104fec:	84 c9                	test   %cl,%cl
80104fee:	74 15                	je     80105005 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80104ff0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ff6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ff9:	81 e2 00 02 00 00    	and    $0x200,%edx
80104fff:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105005:	c9                   	leave  
80105006:	c3                   	ret    

80105007 <popcli>:

void
popcli(void)
{
80105007:	55                   	push   %ebp
80105008:	89 e5                	mov    %esp,%ebp
8010500a:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010500d:	e8 fe fd ff ff       	call   80104e10 <readeflags>
80105012:	25 00 02 00 00       	and    $0x200,%eax
80105017:	85 c0                	test   %eax,%eax
80105019:	74 0c                	je     80105027 <popcli+0x20>
    panic("popcli - interruptible");
8010501b:	c7 04 24 61 88 10 80 	movl   $0x80108861,(%esp)
80105022:	e8 16 b5 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80105027:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010502d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105033:	83 ea 01             	sub    $0x1,%edx
80105036:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010503c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105042:	85 c0                	test   %eax,%eax
80105044:	79 0c                	jns    80105052 <popcli+0x4b>
    panic("popcli");
80105046:	c7 04 24 78 88 10 80 	movl   $0x80108878,(%esp)
8010504d:	e8 eb b4 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105052:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105058:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010505e:	85 c0                	test   %eax,%eax
80105060:	75 15                	jne    80105077 <popcli+0x70>
80105062:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105068:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010506e:	85 c0                	test   %eax,%eax
80105070:	74 05                	je     80105077 <popcli+0x70>
    sti();
80105072:	e8 b4 fd ff ff       	call   80104e2b <sti>
}
80105077:	c9                   	leave  
80105078:	c3                   	ret    
80105079:	00 00                	add    %al,(%eax)
	...

8010507c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010507c:	55                   	push   %ebp
8010507d:	89 e5                	mov    %esp,%ebp
8010507f:	57                   	push   %edi
80105080:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105081:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105084:	8b 55 10             	mov    0x10(%ebp),%edx
80105087:	8b 45 0c             	mov    0xc(%ebp),%eax
8010508a:	89 cb                	mov    %ecx,%ebx
8010508c:	89 df                	mov    %ebx,%edi
8010508e:	89 d1                	mov    %edx,%ecx
80105090:	fc                   	cld    
80105091:	f3 aa                	rep stos %al,%es:(%edi)
80105093:	89 ca                	mov    %ecx,%edx
80105095:	89 fb                	mov    %edi,%ebx
80105097:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010509a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010509d:	5b                   	pop    %ebx
8010509e:	5f                   	pop    %edi
8010509f:	5d                   	pop    %ebp
801050a0:	c3                   	ret    

801050a1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801050a1:	55                   	push   %ebp
801050a2:	89 e5                	mov    %esp,%ebp
801050a4:	57                   	push   %edi
801050a5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801050a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050a9:	8b 55 10             	mov    0x10(%ebp),%edx
801050ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801050af:	89 cb                	mov    %ecx,%ebx
801050b1:	89 df                	mov    %ebx,%edi
801050b3:	89 d1                	mov    %edx,%ecx
801050b5:	fc                   	cld    
801050b6:	f3 ab                	rep stos %eax,%es:(%edi)
801050b8:	89 ca                	mov    %ecx,%edx
801050ba:	89 fb                	mov    %edi,%ebx
801050bc:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050bf:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801050c2:	5b                   	pop    %ebx
801050c3:	5f                   	pop    %edi
801050c4:	5d                   	pop    %ebp
801050c5:	c3                   	ret    

801050c6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801050c6:	55                   	push   %ebp
801050c7:	89 e5                	mov    %esp,%ebp
801050c9:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801050cc:	8b 45 08             	mov    0x8(%ebp),%eax
801050cf:	83 e0 03             	and    $0x3,%eax
801050d2:	85 c0                	test   %eax,%eax
801050d4:	75 49                	jne    8010511f <memset+0x59>
801050d6:	8b 45 10             	mov    0x10(%ebp),%eax
801050d9:	83 e0 03             	and    $0x3,%eax
801050dc:	85 c0                	test   %eax,%eax
801050de:	75 3f                	jne    8010511f <memset+0x59>
    c &= 0xFF;
801050e0:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801050e7:	8b 45 10             	mov    0x10(%ebp),%eax
801050ea:	c1 e8 02             	shr    $0x2,%eax
801050ed:	89 c2                	mov    %eax,%edx
801050ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801050f2:	89 c1                	mov    %eax,%ecx
801050f4:	c1 e1 18             	shl    $0x18,%ecx
801050f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fa:	c1 e0 10             	shl    $0x10,%eax
801050fd:	09 c1                	or     %eax,%ecx
801050ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105102:	c1 e0 08             	shl    $0x8,%eax
80105105:	09 c8                	or     %ecx,%eax
80105107:	0b 45 0c             	or     0xc(%ebp),%eax
8010510a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010510e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105112:	8b 45 08             	mov    0x8(%ebp),%eax
80105115:	89 04 24             	mov    %eax,(%esp)
80105118:	e8 84 ff ff ff       	call   801050a1 <stosl>
8010511d:	eb 19                	jmp    80105138 <memset+0x72>
  } else
    stosb(dst, c, n);
8010511f:	8b 45 10             	mov    0x10(%ebp),%eax
80105122:	89 44 24 08          	mov    %eax,0x8(%esp)
80105126:	8b 45 0c             	mov    0xc(%ebp),%eax
80105129:	89 44 24 04          	mov    %eax,0x4(%esp)
8010512d:	8b 45 08             	mov    0x8(%ebp),%eax
80105130:	89 04 24             	mov    %eax,(%esp)
80105133:	e8 44 ff ff ff       	call   8010507c <stosb>
  return dst;
80105138:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010513b:	c9                   	leave  
8010513c:	c3                   	ret    

8010513d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010513d:	55                   	push   %ebp
8010513e:	89 e5                	mov    %esp,%ebp
80105140:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105143:	8b 45 08             	mov    0x8(%ebp),%eax
80105146:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105149:	8b 45 0c             	mov    0xc(%ebp),%eax
8010514c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010514f:	eb 32                	jmp    80105183 <memcmp+0x46>
    if(*s1 != *s2)
80105151:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105154:	0f b6 10             	movzbl (%eax),%edx
80105157:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010515a:	0f b6 00             	movzbl (%eax),%eax
8010515d:	38 c2                	cmp    %al,%dl
8010515f:	74 1a                	je     8010517b <memcmp+0x3e>
      return *s1 - *s2;
80105161:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105164:	0f b6 00             	movzbl (%eax),%eax
80105167:	0f b6 d0             	movzbl %al,%edx
8010516a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010516d:	0f b6 00             	movzbl (%eax),%eax
80105170:	0f b6 c0             	movzbl %al,%eax
80105173:	89 d1                	mov    %edx,%ecx
80105175:	29 c1                	sub    %eax,%ecx
80105177:	89 c8                	mov    %ecx,%eax
80105179:	eb 1c                	jmp    80105197 <memcmp+0x5a>
    s1++, s2++;
8010517b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010517f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105183:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105187:	0f 95 c0             	setne  %al
8010518a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010518e:	84 c0                	test   %al,%al
80105190:	75 bf                	jne    80105151 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105192:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105197:	c9                   	leave  
80105198:	c3                   	ret    

80105199 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105199:	55                   	push   %ebp
8010519a:	89 e5                	mov    %esp,%ebp
8010519c:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010519f:	8b 45 0c             	mov    0xc(%ebp),%eax
801051a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801051a5:	8b 45 08             	mov    0x8(%ebp),%eax
801051a8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801051ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051b1:	73 54                	jae    80105207 <memmove+0x6e>
801051b3:	8b 45 10             	mov    0x10(%ebp),%eax
801051b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051b9:	01 d0                	add    %edx,%eax
801051bb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051be:	76 47                	jbe    80105207 <memmove+0x6e>
    s += n;
801051c0:	8b 45 10             	mov    0x10(%ebp),%eax
801051c3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801051c6:	8b 45 10             	mov    0x10(%ebp),%eax
801051c9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801051cc:	eb 13                	jmp    801051e1 <memmove+0x48>
      *--d = *--s;
801051ce:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801051d2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801051d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051d9:	0f b6 10             	movzbl (%eax),%edx
801051dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051df:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801051e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051e5:	0f 95 c0             	setne  %al
801051e8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051ec:	84 c0                	test   %al,%al
801051ee:	75 de                	jne    801051ce <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801051f0:	eb 25                	jmp    80105217 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801051f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051f5:	0f b6 10             	movzbl (%eax),%edx
801051f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051fb:	88 10                	mov    %dl,(%eax)
801051fd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105201:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105205:	eb 01                	jmp    80105208 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105207:	90                   	nop
80105208:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010520c:	0f 95 c0             	setne  %al
8010520f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105213:	84 c0                	test   %al,%al
80105215:	75 db                	jne    801051f2 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105217:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010521a:	c9                   	leave  
8010521b:	c3                   	ret    

8010521c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010521c:	55                   	push   %ebp
8010521d:	89 e5                	mov    %esp,%ebp
8010521f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105222:	8b 45 10             	mov    0x10(%ebp),%eax
80105225:	89 44 24 08          	mov    %eax,0x8(%esp)
80105229:	8b 45 0c             	mov    0xc(%ebp),%eax
8010522c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105230:	8b 45 08             	mov    0x8(%ebp),%eax
80105233:	89 04 24             	mov    %eax,(%esp)
80105236:	e8 5e ff ff ff       	call   80105199 <memmove>
}
8010523b:	c9                   	leave  
8010523c:	c3                   	ret    

8010523d <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010523d:	55                   	push   %ebp
8010523e:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105240:	eb 0c                	jmp    8010524e <strncmp+0x11>
    n--, p++, q++;
80105242:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105246:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010524a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010524e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105252:	74 1a                	je     8010526e <strncmp+0x31>
80105254:	8b 45 08             	mov    0x8(%ebp),%eax
80105257:	0f b6 00             	movzbl (%eax),%eax
8010525a:	84 c0                	test   %al,%al
8010525c:	74 10                	je     8010526e <strncmp+0x31>
8010525e:	8b 45 08             	mov    0x8(%ebp),%eax
80105261:	0f b6 10             	movzbl (%eax),%edx
80105264:	8b 45 0c             	mov    0xc(%ebp),%eax
80105267:	0f b6 00             	movzbl (%eax),%eax
8010526a:	38 c2                	cmp    %al,%dl
8010526c:	74 d4                	je     80105242 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010526e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105272:	75 07                	jne    8010527b <strncmp+0x3e>
    return 0;
80105274:	b8 00 00 00 00       	mov    $0x0,%eax
80105279:	eb 18                	jmp    80105293 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
8010527b:	8b 45 08             	mov    0x8(%ebp),%eax
8010527e:	0f b6 00             	movzbl (%eax),%eax
80105281:	0f b6 d0             	movzbl %al,%edx
80105284:	8b 45 0c             	mov    0xc(%ebp),%eax
80105287:	0f b6 00             	movzbl (%eax),%eax
8010528a:	0f b6 c0             	movzbl %al,%eax
8010528d:	89 d1                	mov    %edx,%ecx
8010528f:	29 c1                	sub    %eax,%ecx
80105291:	89 c8                	mov    %ecx,%eax
}
80105293:	5d                   	pop    %ebp
80105294:	c3                   	ret    

80105295 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105295:	55                   	push   %ebp
80105296:	89 e5                	mov    %esp,%ebp
80105298:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010529b:	8b 45 08             	mov    0x8(%ebp),%eax
8010529e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801052a1:	90                   	nop
801052a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052a6:	0f 9f c0             	setg   %al
801052a9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801052ad:	84 c0                	test   %al,%al
801052af:	74 30                	je     801052e1 <strncpy+0x4c>
801052b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801052b4:	0f b6 10             	movzbl (%eax),%edx
801052b7:	8b 45 08             	mov    0x8(%ebp),%eax
801052ba:	88 10                	mov    %dl,(%eax)
801052bc:	8b 45 08             	mov    0x8(%ebp),%eax
801052bf:	0f b6 00             	movzbl (%eax),%eax
801052c2:	84 c0                	test   %al,%al
801052c4:	0f 95 c0             	setne  %al
801052c7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801052cb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801052cf:	84 c0                	test   %al,%al
801052d1:	75 cf                	jne    801052a2 <strncpy+0xd>
    ;
  while(n-- > 0)
801052d3:	eb 0c                	jmp    801052e1 <strncpy+0x4c>
    *s++ = 0;
801052d5:	8b 45 08             	mov    0x8(%ebp),%eax
801052d8:	c6 00 00             	movb   $0x0,(%eax)
801052db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801052df:	eb 01                	jmp    801052e2 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801052e1:	90                   	nop
801052e2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052e6:	0f 9f c0             	setg   %al
801052e9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801052ed:	84 c0                	test   %al,%al
801052ef:	75 e4                	jne    801052d5 <strncpy+0x40>
    *s++ = 0;
  return os;
801052f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801052f4:	c9                   	leave  
801052f5:	c3                   	ret    

801052f6 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801052f6:	55                   	push   %ebp
801052f7:	89 e5                	mov    %esp,%ebp
801052f9:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801052fc:	8b 45 08             	mov    0x8(%ebp),%eax
801052ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105302:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105306:	7f 05                	jg     8010530d <safestrcpy+0x17>
    return os;
80105308:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010530b:	eb 35                	jmp    80105342 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
8010530d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105311:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105315:	7e 22                	jle    80105339 <safestrcpy+0x43>
80105317:	8b 45 0c             	mov    0xc(%ebp),%eax
8010531a:	0f b6 10             	movzbl (%eax),%edx
8010531d:	8b 45 08             	mov    0x8(%ebp),%eax
80105320:	88 10                	mov    %dl,(%eax)
80105322:	8b 45 08             	mov    0x8(%ebp),%eax
80105325:	0f b6 00             	movzbl (%eax),%eax
80105328:	84 c0                	test   %al,%al
8010532a:	0f 95 c0             	setne  %al
8010532d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105331:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105335:	84 c0                	test   %al,%al
80105337:	75 d4                	jne    8010530d <safestrcpy+0x17>
    ;
  *s = 0;
80105339:	8b 45 08             	mov    0x8(%ebp),%eax
8010533c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010533f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105342:	c9                   	leave  
80105343:	c3                   	ret    

80105344 <strlen>:

int
strlen(const char *s)
{
80105344:	55                   	push   %ebp
80105345:	89 e5                	mov    %esp,%ebp
80105347:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010534a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105351:	eb 04                	jmp    80105357 <strlen+0x13>
80105353:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105357:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010535a:	03 45 08             	add    0x8(%ebp),%eax
8010535d:	0f b6 00             	movzbl (%eax),%eax
80105360:	84 c0                	test   %al,%al
80105362:	75 ef                	jne    80105353 <strlen+0xf>
    ;
  return n;
80105364:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105367:	c9                   	leave  
80105368:	c3                   	ret    
80105369:	00 00                	add    %al,(%eax)
	...

8010536c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010536c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105370:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105374:	55                   	push   %ebp
  pushl %ebx
80105375:	53                   	push   %ebx
  pushl %esi
80105376:	56                   	push   %esi
  pushl %edi
80105377:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105378:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010537a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010537c:	5f                   	pop    %edi
  popl %esi
8010537d:	5e                   	pop    %esi
  popl %ebx
8010537e:	5b                   	pop    %ebx
  popl %ebp
8010537f:	5d                   	pop    %ebp
  ret
80105380:	c3                   	ret    
80105381:	00 00                	add    %al,(%eax)
	...

80105384 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105384:	55                   	push   %ebp
80105385:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105387:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010538d:	8b 00                	mov    (%eax),%eax
8010538f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105392:	76 12                	jbe    801053a6 <fetchint+0x22>
80105394:	8b 45 08             	mov    0x8(%ebp),%eax
80105397:	8d 50 04             	lea    0x4(%eax),%edx
8010539a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053a0:	8b 00                	mov    (%eax),%eax
801053a2:	39 c2                	cmp    %eax,%edx
801053a4:	76 07                	jbe    801053ad <fetchint+0x29>
    return -1;
801053a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ab:	eb 0f                	jmp    801053bc <fetchint+0x38>
  *ip = *(int*)(addr);
801053ad:	8b 45 08             	mov    0x8(%ebp),%eax
801053b0:	8b 10                	mov    (%eax),%edx
801053b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b5:	89 10                	mov    %edx,(%eax)
  return 0;
801053b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053bc:	5d                   	pop    %ebp
801053bd:	c3                   	ret    

801053be <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801053be:	55                   	push   %ebp
801053bf:	89 e5                	mov    %esp,%ebp
801053c1:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801053c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ca:	8b 00                	mov    (%eax),%eax
801053cc:	3b 45 08             	cmp    0x8(%ebp),%eax
801053cf:	77 07                	ja     801053d8 <fetchstr+0x1a>
    return -1;
801053d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d6:	eb 48                	jmp    80105420 <fetchstr+0x62>
  *pp = (char*)addr;
801053d8:	8b 55 08             	mov    0x8(%ebp),%edx
801053db:	8b 45 0c             	mov    0xc(%ebp),%eax
801053de:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801053e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053e6:	8b 00                	mov    (%eax),%eax
801053e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801053eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ee:	8b 00                	mov    (%eax),%eax
801053f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
801053f3:	eb 1e                	jmp    80105413 <fetchstr+0x55>
    if(*s == 0)
801053f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053f8:	0f b6 00             	movzbl (%eax),%eax
801053fb:	84 c0                	test   %al,%al
801053fd:	75 10                	jne    8010540f <fetchstr+0x51>
      return s - *pp;
801053ff:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105402:	8b 45 0c             	mov    0xc(%ebp),%eax
80105405:	8b 00                	mov    (%eax),%eax
80105407:	89 d1                	mov    %edx,%ecx
80105409:	29 c1                	sub    %eax,%ecx
8010540b:	89 c8                	mov    %ecx,%eax
8010540d:	eb 11                	jmp    80105420 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010540f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105413:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105416:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105419:	72 da                	jb     801053f5 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010541b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105420:	c9                   	leave  
80105421:	c3                   	ret    

80105422 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105422:	55                   	push   %ebp
80105423:	89 e5                	mov    %esp,%ebp
80105425:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105428:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010542e:	8b 40 18             	mov    0x18(%eax),%eax
80105431:	8b 50 44             	mov    0x44(%eax),%edx
80105434:	8b 45 08             	mov    0x8(%ebp),%eax
80105437:	c1 e0 02             	shl    $0x2,%eax
8010543a:	01 d0                	add    %edx,%eax
8010543c:	8d 50 04             	lea    0x4(%eax),%edx
8010543f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105442:	89 44 24 04          	mov    %eax,0x4(%esp)
80105446:	89 14 24             	mov    %edx,(%esp)
80105449:	e8 36 ff ff ff       	call   80105384 <fetchint>
}
8010544e:	c9                   	leave  
8010544f:	c3                   	ret    

80105450 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105450:	55                   	push   %ebp
80105451:	89 e5                	mov    %esp,%ebp
80105453:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105456:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105459:	89 44 24 04          	mov    %eax,0x4(%esp)
8010545d:	8b 45 08             	mov    0x8(%ebp),%eax
80105460:	89 04 24             	mov    %eax,(%esp)
80105463:	e8 ba ff ff ff       	call   80105422 <argint>
80105468:	85 c0                	test   %eax,%eax
8010546a:	79 07                	jns    80105473 <argptr+0x23>
    return -1;
8010546c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105471:	eb 3d                	jmp    801054b0 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105473:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105476:	89 c2                	mov    %eax,%edx
80105478:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010547e:	8b 00                	mov    (%eax),%eax
80105480:	39 c2                	cmp    %eax,%edx
80105482:	73 16                	jae    8010549a <argptr+0x4a>
80105484:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105487:	89 c2                	mov    %eax,%edx
80105489:	8b 45 10             	mov    0x10(%ebp),%eax
8010548c:	01 c2                	add    %eax,%edx
8010548e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105494:	8b 00                	mov    (%eax),%eax
80105496:	39 c2                	cmp    %eax,%edx
80105498:	76 07                	jbe    801054a1 <argptr+0x51>
    return -1;
8010549a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010549f:	eb 0f                	jmp    801054b0 <argptr+0x60>
  *pp = (char*)i;
801054a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054a4:	89 c2                	mov    %eax,%edx
801054a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a9:	89 10                	mov    %edx,(%eax)
  return 0;
801054ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054b0:	c9                   	leave  
801054b1:	c3                   	ret    

801054b2 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801054b2:	55                   	push   %ebp
801054b3:	89 e5                	mov    %esp,%ebp
801054b5:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801054b8:	8d 45 fc             	lea    -0x4(%ebp),%eax
801054bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801054bf:	8b 45 08             	mov    0x8(%ebp),%eax
801054c2:	89 04 24             	mov    %eax,(%esp)
801054c5:	e8 58 ff ff ff       	call   80105422 <argint>
801054ca:	85 c0                	test   %eax,%eax
801054cc:	79 07                	jns    801054d5 <argstr+0x23>
    return -1;
801054ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054d3:	eb 12                	jmp    801054e7 <argstr+0x35>
  return fetchstr(addr, pp);
801054d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d8:	8b 55 0c             	mov    0xc(%ebp),%edx
801054db:	89 54 24 04          	mov    %edx,0x4(%esp)
801054df:	89 04 24             	mov    %eax,(%esp)
801054e2:	e8 d7 fe ff ff       	call   801053be <fetchstr>
}
801054e7:	c9                   	leave  
801054e8:	c3                   	ret    

801054e9 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801054e9:	55                   	push   %ebp
801054ea:	89 e5                	mov    %esp,%ebp
801054ec:	53                   	push   %ebx
801054ed:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801054f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054f6:	8b 40 18             	mov    0x18(%eax),%eax
801054f9:	8b 40 1c             	mov    0x1c(%eax),%eax
801054fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801054ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105503:	7e 30                	jle    80105535 <syscall+0x4c>
80105505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105508:	83 f8 15             	cmp    $0x15,%eax
8010550b:	77 28                	ja     80105535 <syscall+0x4c>
8010550d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105510:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105517:	85 c0                	test   %eax,%eax
80105519:	74 1a                	je     80105535 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010551b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105521:	8b 58 18             	mov    0x18(%eax),%ebx
80105524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105527:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010552e:	ff d0                	call   *%eax
80105530:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105533:	eb 3d                	jmp    80105572 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105535:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010553b:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010553e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105544:	8b 40 10             	mov    0x10(%eax),%eax
80105547:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010554a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010554e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105552:	89 44 24 04          	mov    %eax,0x4(%esp)
80105556:	c7 04 24 7f 88 10 80 	movl   $0x8010887f,(%esp)
8010555d:	e8 3f ae ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105562:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105568:	8b 40 18             	mov    0x18(%eax),%eax
8010556b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105572:	83 c4 24             	add    $0x24,%esp
80105575:	5b                   	pop    %ebx
80105576:	5d                   	pop    %ebp
80105577:	c3                   	ret    

80105578 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105578:	55                   	push   %ebp
80105579:	89 e5                	mov    %esp,%ebp
8010557b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010557e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105581:	89 44 24 04          	mov    %eax,0x4(%esp)
80105585:	8b 45 08             	mov    0x8(%ebp),%eax
80105588:	89 04 24             	mov    %eax,(%esp)
8010558b:	e8 92 fe ff ff       	call   80105422 <argint>
80105590:	85 c0                	test   %eax,%eax
80105592:	79 07                	jns    8010559b <argfd+0x23>
    return -1;
80105594:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105599:	eb 50                	jmp    801055eb <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010559b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010559e:	85 c0                	test   %eax,%eax
801055a0:	78 21                	js     801055c3 <argfd+0x4b>
801055a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055a5:	83 f8 0f             	cmp    $0xf,%eax
801055a8:	7f 19                	jg     801055c3 <argfd+0x4b>
801055aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055b3:	83 c2 08             	add    $0x8,%edx
801055b6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801055ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055c1:	75 07                	jne    801055ca <argfd+0x52>
    return -1;
801055c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c8:	eb 21                	jmp    801055eb <argfd+0x73>
  if(pfd)
801055ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801055ce:	74 08                	je     801055d8 <argfd+0x60>
    *pfd = fd;
801055d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d6:	89 10                	mov    %edx,(%eax)
  if(pf)
801055d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055dc:	74 08                	je     801055e6 <argfd+0x6e>
    *pf = f;
801055de:	8b 45 10             	mov    0x10(%ebp),%eax
801055e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055e4:	89 10                	mov    %edx,(%eax)
  return 0;
801055e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055eb:	c9                   	leave  
801055ec:	c3                   	ret    

801055ed <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801055ed:	55                   	push   %ebp
801055ee:	89 e5                	mov    %esp,%ebp
801055f0:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801055f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801055fa:	eb 30                	jmp    8010562c <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801055fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105602:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105605:	83 c2 08             	add    $0x8,%edx
80105608:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010560c:	85 c0                	test   %eax,%eax
8010560e:	75 18                	jne    80105628 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105610:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105616:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105619:	8d 4a 08             	lea    0x8(%edx),%ecx
8010561c:	8b 55 08             	mov    0x8(%ebp),%edx
8010561f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105623:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105626:	eb 0f                	jmp    80105637 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105628:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010562c:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105630:	7e ca                	jle    801055fc <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105632:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105637:	c9                   	leave  
80105638:	c3                   	ret    

80105639 <sys_dup>:

int
sys_dup(void)
{
80105639:	55                   	push   %ebp
8010563a:	89 e5                	mov    %esp,%ebp
8010563c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010563f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105642:	89 44 24 08          	mov    %eax,0x8(%esp)
80105646:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010564d:	00 
8010564e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105655:	e8 1e ff ff ff       	call   80105578 <argfd>
8010565a:	85 c0                	test   %eax,%eax
8010565c:	79 07                	jns    80105665 <sys_dup+0x2c>
    return -1;
8010565e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105663:	eb 29                	jmp    8010568e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105668:	89 04 24             	mov    %eax,(%esp)
8010566b:	e8 7d ff ff ff       	call   801055ed <fdalloc>
80105670:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105673:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105677:	79 07                	jns    80105680 <sys_dup+0x47>
    return -1;
80105679:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010567e:	eb 0e                	jmp    8010568e <sys_dup+0x55>
  filedup(f);
80105680:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105683:	89 04 24             	mov    %eax,(%esp)
80105686:	e8 fd b8 ff ff       	call   80100f88 <filedup>
  return fd;
8010568b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010568e:	c9                   	leave  
8010568f:	c3                   	ret    

80105690 <sys_read>:

int
sys_read(void)
{
80105690:	55                   	push   %ebp
80105691:	89 e5                	mov    %esp,%ebp
80105693:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105696:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105699:	89 44 24 08          	mov    %eax,0x8(%esp)
8010569d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056a4:	00 
801056a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056ac:	e8 c7 fe ff ff       	call   80105578 <argfd>
801056b1:	85 c0                	test   %eax,%eax
801056b3:	78 35                	js     801056ea <sys_read+0x5a>
801056b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801056bc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801056c3:	e8 5a fd ff ff       	call   80105422 <argint>
801056c8:	85 c0                	test   %eax,%eax
801056ca:	78 1e                	js     801056ea <sys_read+0x5a>
801056cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801056d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801056d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801056da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801056e1:	e8 6a fd ff ff       	call   80105450 <argptr>
801056e6:	85 c0                	test   %eax,%eax
801056e8:	79 07                	jns    801056f1 <sys_read+0x61>
    return -1;
801056ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ef:	eb 19                	jmp    8010570a <sys_read+0x7a>
  return fileread(f, p, n);
801056f1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801056f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801056f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801056fe:	89 54 24 04          	mov    %edx,0x4(%esp)
80105702:	89 04 24             	mov    %eax,(%esp)
80105705:	e8 eb b9 ff ff       	call   801010f5 <fileread>
}
8010570a:	c9                   	leave  
8010570b:	c3                   	ret    

8010570c <sys_write>:

int
sys_write(void)
{
8010570c:	55                   	push   %ebp
8010570d:	89 e5                	mov    %esp,%ebp
8010570f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105712:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105715:	89 44 24 08          	mov    %eax,0x8(%esp)
80105719:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105720:	00 
80105721:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105728:	e8 4b fe ff ff       	call   80105578 <argfd>
8010572d:	85 c0                	test   %eax,%eax
8010572f:	78 35                	js     80105766 <sys_write+0x5a>
80105731:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105734:	89 44 24 04          	mov    %eax,0x4(%esp)
80105738:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010573f:	e8 de fc ff ff       	call   80105422 <argint>
80105744:	85 c0                	test   %eax,%eax
80105746:	78 1e                	js     80105766 <sys_write+0x5a>
80105748:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010574b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010574f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105752:	89 44 24 04          	mov    %eax,0x4(%esp)
80105756:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010575d:	e8 ee fc ff ff       	call   80105450 <argptr>
80105762:	85 c0                	test   %eax,%eax
80105764:	79 07                	jns    8010576d <sys_write+0x61>
    return -1;
80105766:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010576b:	eb 19                	jmp    80105786 <sys_write+0x7a>
  return filewrite(f, p, n);
8010576d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105770:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105776:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010577a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010577e:	89 04 24             	mov    %eax,(%esp)
80105781:	e8 2b ba ff ff       	call   801011b1 <filewrite>
}
80105786:	c9                   	leave  
80105787:	c3                   	ret    

80105788 <sys_close>:

int
sys_close(void)
{
80105788:	55                   	push   %ebp
80105789:	89 e5                	mov    %esp,%ebp
8010578b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010578e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105791:	89 44 24 08          	mov    %eax,0x8(%esp)
80105795:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105798:	89 44 24 04          	mov    %eax,0x4(%esp)
8010579c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057a3:	e8 d0 fd ff ff       	call   80105578 <argfd>
801057a8:	85 c0                	test   %eax,%eax
801057aa:	79 07                	jns    801057b3 <sys_close+0x2b>
    return -1;
801057ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b1:	eb 24                	jmp    801057d7 <sys_close+0x4f>
  proc->ofile[fd] = 0;
801057b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057bc:	83 c2 08             	add    $0x8,%edx
801057bf:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801057c6:	00 
  fileclose(f);
801057c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ca:	89 04 24             	mov    %eax,(%esp)
801057cd:	e8 fe b7 ff ff       	call   80100fd0 <fileclose>
  return 0;
801057d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057d7:	c9                   	leave  
801057d8:	c3                   	ret    

801057d9 <sys_fstat>:

int
sys_fstat(void)
{
801057d9:	55                   	push   %ebp
801057da:	89 e5                	mov    %esp,%ebp
801057dc:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801057df:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057e2:	89 44 24 08          	mov    %eax,0x8(%esp)
801057e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801057ed:	00 
801057ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057f5:	e8 7e fd ff ff       	call   80105578 <argfd>
801057fa:	85 c0                	test   %eax,%eax
801057fc:	78 1f                	js     8010581d <sys_fstat+0x44>
801057fe:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105805:	00 
80105806:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105809:	89 44 24 04          	mov    %eax,0x4(%esp)
8010580d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105814:	e8 37 fc ff ff       	call   80105450 <argptr>
80105819:	85 c0                	test   %eax,%eax
8010581b:	79 07                	jns    80105824 <sys_fstat+0x4b>
    return -1;
8010581d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105822:	eb 12                	jmp    80105836 <sys_fstat+0x5d>
  return filestat(f, st);
80105824:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010582a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010582e:	89 04 24             	mov    %eax,(%esp)
80105831:	e8 70 b8 ff ff       	call   801010a6 <filestat>
}
80105836:	c9                   	leave  
80105837:	c3                   	ret    

80105838 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105838:	55                   	push   %ebp
80105839:	89 e5                	mov    %esp,%ebp
8010583b:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010583e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105841:	89 44 24 04          	mov    %eax,0x4(%esp)
80105845:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010584c:	e8 61 fc ff ff       	call   801054b2 <argstr>
80105851:	85 c0                	test   %eax,%eax
80105853:	78 17                	js     8010586c <sys_link+0x34>
80105855:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105858:	89 44 24 04          	mov    %eax,0x4(%esp)
8010585c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105863:	e8 4a fc ff ff       	call   801054b2 <argstr>
80105868:	85 c0                	test   %eax,%eax
8010586a:	79 0a                	jns    80105876 <sys_link+0x3e>
    return -1;
8010586c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105871:	e9 41 01 00 00       	jmp    801059b7 <sys_link+0x17f>

  begin_op();
80105876:	e8 e6 db ff ff       	call   80103461 <begin_op>
  if((ip = namei(old)) == 0){
8010587b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010587e:	89 04 24             	mov    %eax,(%esp)
80105881:	e8 90 cb ff ff       	call   80102416 <namei>
80105886:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105889:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010588d:	75 0f                	jne    8010589e <sys_link+0x66>
    end_op();
8010588f:	e8 4e dc ff ff       	call   801034e2 <end_op>
    return -1;
80105894:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105899:	e9 19 01 00 00       	jmp    801059b7 <sys_link+0x17f>
  }

  ilock(ip);
8010589e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058a1:	89 04 24             	mov    %eax,(%esp)
801058a4:	e8 cb bf ff ff       	call   80101874 <ilock>
  if(ip->type == T_DIR){
801058a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ac:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801058b0:	66 83 f8 01          	cmp    $0x1,%ax
801058b4:	75 1a                	jne    801058d0 <sys_link+0x98>
    iunlockput(ip);
801058b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b9:	89 04 24             	mov    %eax,(%esp)
801058bc:	e8 37 c2 ff ff       	call   80101af8 <iunlockput>
    end_op();
801058c1:	e8 1c dc ff ff       	call   801034e2 <end_op>
    return -1;
801058c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058cb:	e9 e7 00 00 00       	jmp    801059b7 <sys_link+0x17f>
  }

  ip->nlink++;
801058d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801058d7:	8d 50 01             	lea    0x1(%eax),%edx
801058da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058dd:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801058e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e4:	89 04 24             	mov    %eax,(%esp)
801058e7:	e8 cc bd ff ff       	call   801016b8 <iupdate>
  iunlock(ip);
801058ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ef:	89 04 24             	mov    %eax,(%esp)
801058f2:	e8 cb c0 ff ff       	call   801019c2 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801058f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801058fa:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801058fd:	89 54 24 04          	mov    %edx,0x4(%esp)
80105901:	89 04 24             	mov    %eax,(%esp)
80105904:	e8 2f cb ff ff       	call   80102438 <nameiparent>
80105909:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010590c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105910:	74 68                	je     8010597a <sys_link+0x142>
    goto bad;
  ilock(dp);
80105912:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105915:	89 04 24             	mov    %eax,(%esp)
80105918:	e8 57 bf ff ff       	call   80101874 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
8010591d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105920:	8b 10                	mov    (%eax),%edx
80105922:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105925:	8b 00                	mov    (%eax),%eax
80105927:	39 c2                	cmp    %eax,%edx
80105929:	75 20                	jne    8010594b <sys_link+0x113>
8010592b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010592e:	8b 40 04             	mov    0x4(%eax),%eax
80105931:	89 44 24 08          	mov    %eax,0x8(%esp)
80105935:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105938:	89 44 24 04          	mov    %eax,0x4(%esp)
8010593c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593f:	89 04 24             	mov    %eax,(%esp)
80105942:	e8 0e c8 ff ff       	call   80102155 <dirlink>
80105947:	85 c0                	test   %eax,%eax
80105949:	79 0d                	jns    80105958 <sys_link+0x120>
    iunlockput(dp);
8010594b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594e:	89 04 24             	mov    %eax,(%esp)
80105951:	e8 a2 c1 ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105956:	eb 23                	jmp    8010597b <sys_link+0x143>
  }
  iunlockput(dp);
80105958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595b:	89 04 24             	mov    %eax,(%esp)
8010595e:	e8 95 c1 ff ff       	call   80101af8 <iunlockput>
  iput(ip);
80105963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105966:	89 04 24             	mov    %eax,(%esp)
80105969:	e8 b9 c0 ff ff       	call   80101a27 <iput>

  end_op();
8010596e:	e8 6f db ff ff       	call   801034e2 <end_op>

  return 0;
80105973:	b8 00 00 00 00       	mov    $0x0,%eax
80105978:	eb 3d                	jmp    801059b7 <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
8010597a:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
8010597b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010597e:	89 04 24             	mov    %eax,(%esp)
80105981:	e8 ee be ff ff       	call   80101874 <ilock>
  ip->nlink--;
80105986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105989:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010598d:	8d 50 ff             	lea    -0x1(%eax),%edx
80105990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105993:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105997:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599a:	89 04 24             	mov    %eax,(%esp)
8010599d:	e8 16 bd ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
801059a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a5:	89 04 24             	mov    %eax,(%esp)
801059a8:	e8 4b c1 ff ff       	call   80101af8 <iunlockput>
  end_op();
801059ad:	e8 30 db ff ff       	call   801034e2 <end_op>
  return -1;
801059b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059b7:	c9                   	leave  
801059b8:	c3                   	ret    

801059b9 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801059b9:	55                   	push   %ebp
801059ba:	89 e5                	mov    %esp,%ebp
801059bc:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801059bf:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801059c6:	eb 4b                	jmp    80105a13 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801059c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cb:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801059d2:	00 
801059d3:	89 44 24 08          	mov    %eax,0x8(%esp)
801059d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801059da:	89 44 24 04          	mov    %eax,0x4(%esp)
801059de:	8b 45 08             	mov    0x8(%ebp),%eax
801059e1:	89 04 24             	mov    %eax,(%esp)
801059e4:	e8 81 c3 ff ff       	call   80101d6a <readi>
801059e9:	83 f8 10             	cmp    $0x10,%eax
801059ec:	74 0c                	je     801059fa <isdirempty+0x41>
      panic("isdirempty: readi");
801059ee:	c7 04 24 9b 88 10 80 	movl   $0x8010889b,(%esp)
801059f5:	e8 43 ab ff ff       	call   8010053d <panic>
    if(de.inum != 0)
801059fa:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801059fe:	66 85 c0             	test   %ax,%ax
80105a01:	74 07                	je     80105a0a <isdirempty+0x51>
      return 0;
80105a03:	b8 00 00 00 00       	mov    $0x0,%eax
80105a08:	eb 1b                	jmp    80105a25 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0d:	83 c0 10             	add    $0x10,%eax
80105a10:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a13:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a16:	8b 45 08             	mov    0x8(%ebp),%eax
80105a19:	8b 40 18             	mov    0x18(%eax),%eax
80105a1c:	39 c2                	cmp    %eax,%edx
80105a1e:	72 a8                	jb     801059c8 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105a20:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105a25:	c9                   	leave  
80105a26:	c3                   	ret    

80105a27 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105a27:	55                   	push   %ebp
80105a28:	89 e5                	mov    %esp,%ebp
80105a2a:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105a2d:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105a30:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a3b:	e8 72 fa ff ff       	call   801054b2 <argstr>
80105a40:	85 c0                	test   %eax,%eax
80105a42:	79 0a                	jns    80105a4e <sys_unlink+0x27>
    return -1;
80105a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a49:	e9 af 01 00 00       	jmp    80105bfd <sys_unlink+0x1d6>

  begin_op();
80105a4e:	e8 0e da ff ff       	call   80103461 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105a53:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105a56:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105a59:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a5d:	89 04 24             	mov    %eax,(%esp)
80105a60:	e8 d3 c9 ff ff       	call   80102438 <nameiparent>
80105a65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a6c:	75 0f                	jne    80105a7d <sys_unlink+0x56>
    end_op();
80105a6e:	e8 6f da ff ff       	call   801034e2 <end_op>
    return -1;
80105a73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a78:	e9 80 01 00 00       	jmp    80105bfd <sys_unlink+0x1d6>
  }

  ilock(dp);
80105a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a80:	89 04 24             	mov    %eax,(%esp)
80105a83:	e8 ec bd ff ff       	call   80101874 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105a88:	c7 44 24 04 ad 88 10 	movl   $0x801088ad,0x4(%esp)
80105a8f:	80 
80105a90:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a93:	89 04 24             	mov    %eax,(%esp)
80105a96:	e8 d0 c5 ff ff       	call   8010206b <namecmp>
80105a9b:	85 c0                	test   %eax,%eax
80105a9d:	0f 84 45 01 00 00    	je     80105be8 <sys_unlink+0x1c1>
80105aa3:	c7 44 24 04 af 88 10 	movl   $0x801088af,0x4(%esp)
80105aaa:	80 
80105aab:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105aae:	89 04 24             	mov    %eax,(%esp)
80105ab1:	e8 b5 c5 ff ff       	call   8010206b <namecmp>
80105ab6:	85 c0                	test   %eax,%eax
80105ab8:	0f 84 2a 01 00 00    	je     80105be8 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105abe:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ac1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ac5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105acf:	89 04 24             	mov    %eax,(%esp)
80105ad2:	e8 b6 c5 ff ff       	call   8010208d <dirlookup>
80105ad7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ada:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ade:	0f 84 03 01 00 00    	je     80105be7 <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
80105ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae7:	89 04 24             	mov    %eax,(%esp)
80105aea:	e8 85 bd ff ff       	call   80101874 <ilock>

  if(ip->nlink < 1)
80105aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af2:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105af6:	66 85 c0             	test   %ax,%ax
80105af9:	7f 0c                	jg     80105b07 <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
80105afb:	c7 04 24 b2 88 10 80 	movl   $0x801088b2,(%esp)
80105b02:	e8 36 aa ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105b07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b0e:	66 83 f8 01          	cmp    $0x1,%ax
80105b12:	75 1f                	jne    80105b33 <sys_unlink+0x10c>
80105b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b17:	89 04 24             	mov    %eax,(%esp)
80105b1a:	e8 9a fe ff ff       	call   801059b9 <isdirempty>
80105b1f:	85 c0                	test   %eax,%eax
80105b21:	75 10                	jne    80105b33 <sys_unlink+0x10c>
    iunlockput(ip);
80105b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b26:	89 04 24             	mov    %eax,(%esp)
80105b29:	e8 ca bf ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105b2e:	e9 b5 00 00 00       	jmp    80105be8 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105b33:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105b3a:	00 
80105b3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b42:	00 
80105b43:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b46:	89 04 24             	mov    %eax,(%esp)
80105b49:	e8 78 f5 ff ff       	call   801050c6 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b4e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105b51:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b58:	00 
80105b59:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b5d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b60:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b67:	89 04 24             	mov    %eax,(%esp)
80105b6a:	e8 66 c3 ff ff       	call   80101ed5 <writei>
80105b6f:	83 f8 10             	cmp    $0x10,%eax
80105b72:	74 0c                	je     80105b80 <sys_unlink+0x159>
    panic("unlink: writei");
80105b74:	c7 04 24 c4 88 10 80 	movl   $0x801088c4,(%esp)
80105b7b:	e8 bd a9 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b83:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b87:	66 83 f8 01          	cmp    $0x1,%ax
80105b8b:	75 1c                	jne    80105ba9 <sys_unlink+0x182>
    dp->nlink--;
80105b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b90:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b94:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba1:	89 04 24             	mov    %eax,(%esp)
80105ba4:	e8 0f bb ff ff       	call   801016b8 <iupdate>
  }
  iunlockput(dp);
80105ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bac:	89 04 24             	mov    %eax,(%esp)
80105baf:	e8 44 bf ff ff       	call   80101af8 <iunlockput>

  ip->nlink--;
80105bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bbb:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc1:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc8:	89 04 24             	mov    %eax,(%esp)
80105bcb:	e8 e8 ba ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
80105bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd3:	89 04 24             	mov    %eax,(%esp)
80105bd6:	e8 1d bf ff ff       	call   80101af8 <iunlockput>

  end_op();
80105bdb:	e8 02 d9 ff ff       	call   801034e2 <end_op>

  return 0;
80105be0:	b8 00 00 00 00       	mov    $0x0,%eax
80105be5:	eb 16                	jmp    80105bfd <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105be7:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105beb:	89 04 24             	mov    %eax,(%esp)
80105bee:	e8 05 bf ff ff       	call   80101af8 <iunlockput>
  end_op();
80105bf3:	e8 ea d8 ff ff       	call   801034e2 <end_op>
  return -1;
80105bf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105bfd:	c9                   	leave  
80105bfe:	c3                   	ret    

80105bff <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105bff:	55                   	push   %ebp
80105c00:	89 e5                	mov    %esp,%ebp
80105c02:	83 ec 48             	sub    $0x48,%esp
80105c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105c08:	8b 55 10             	mov    0x10(%ebp),%edx
80105c0b:	8b 45 14             	mov    0x14(%ebp),%eax
80105c0e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105c12:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105c16:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105c1a:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c21:	8b 45 08             	mov    0x8(%ebp),%eax
80105c24:	89 04 24             	mov    %eax,(%esp)
80105c27:	e8 0c c8 ff ff       	call   80102438 <nameiparent>
80105c2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c33:	75 0a                	jne    80105c3f <create+0x40>
    return 0;
80105c35:	b8 00 00 00 00       	mov    $0x0,%eax
80105c3a:	e9 7e 01 00 00       	jmp    80105dbd <create+0x1be>
  ilock(dp);
80105c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c42:	89 04 24             	mov    %eax,(%esp)
80105c45:	e8 2a bc ff ff       	call   80101874 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105c4a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c4d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c51:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c54:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5b:	89 04 24             	mov    %eax,(%esp)
80105c5e:	e8 2a c4 ff ff       	call   8010208d <dirlookup>
80105c63:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c6a:	74 47                	je     80105cb3 <create+0xb4>
    iunlockput(dp);
80105c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6f:	89 04 24             	mov    %eax,(%esp)
80105c72:	e8 81 be ff ff       	call   80101af8 <iunlockput>
    ilock(ip);
80105c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7a:	89 04 24             	mov    %eax,(%esp)
80105c7d:	e8 f2 bb ff ff       	call   80101874 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105c82:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105c87:	75 15                	jne    80105c9e <create+0x9f>
80105c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c90:	66 83 f8 02          	cmp    $0x2,%ax
80105c94:	75 08                	jne    80105c9e <create+0x9f>
      return ip;
80105c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c99:	e9 1f 01 00 00       	jmp    80105dbd <create+0x1be>
    iunlockput(ip);
80105c9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca1:	89 04 24             	mov    %eax,(%esp)
80105ca4:	e8 4f be ff ff       	call   80101af8 <iunlockput>
    return 0;
80105ca9:	b8 00 00 00 00       	mov    $0x0,%eax
80105cae:	e9 0a 01 00 00       	jmp    80105dbd <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105cb3:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cba:	8b 00                	mov    (%eax),%eax
80105cbc:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cc0:	89 04 24             	mov    %eax,(%esp)
80105cc3:	e8 13 b9 ff ff       	call   801015db <ialloc>
80105cc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ccb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ccf:	75 0c                	jne    80105cdd <create+0xde>
    panic("create: ialloc");
80105cd1:	c7 04 24 d3 88 10 80 	movl   $0x801088d3,(%esp)
80105cd8:	e8 60 a8 ff ff       	call   8010053d <panic>

  ilock(ip);
80105cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce0:	89 04 24             	mov    %eax,(%esp)
80105ce3:	e8 8c bb ff ff       	call   80101874 <ilock>
  ip->major = major;
80105ce8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ceb:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105cef:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf6:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105cfa:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d01:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0a:	89 04 24             	mov    %eax,(%esp)
80105d0d:	e8 a6 b9 ff ff       	call   801016b8 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105d12:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105d17:	75 6a                	jne    80105d83 <create+0x184>
    dp->nlink++;  // for ".."
80105d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d20:	8d 50 01             	lea    0x1(%eax),%edx
80105d23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d26:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2d:	89 04 24             	mov    %eax,(%esp)
80105d30:	e8 83 b9 ff ff       	call   801016b8 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105d35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d38:	8b 40 04             	mov    0x4(%eax),%eax
80105d3b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d3f:	c7 44 24 04 ad 88 10 	movl   $0x801088ad,0x4(%esp)
80105d46:	80 
80105d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4a:	89 04 24             	mov    %eax,(%esp)
80105d4d:	e8 03 c4 ff ff       	call   80102155 <dirlink>
80105d52:	85 c0                	test   %eax,%eax
80105d54:	78 21                	js     80105d77 <create+0x178>
80105d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d59:	8b 40 04             	mov    0x4(%eax),%eax
80105d5c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d60:	c7 44 24 04 af 88 10 	movl   $0x801088af,0x4(%esp)
80105d67:	80 
80105d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6b:	89 04 24             	mov    %eax,(%esp)
80105d6e:	e8 e2 c3 ff ff       	call   80102155 <dirlink>
80105d73:	85 c0                	test   %eax,%eax
80105d75:	79 0c                	jns    80105d83 <create+0x184>
      panic("create dots");
80105d77:	c7 04 24 e2 88 10 80 	movl   $0x801088e2,(%esp)
80105d7e:	e8 ba a7 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d86:	8b 40 04             	mov    0x4(%eax),%eax
80105d89:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d8d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d90:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d97:	89 04 24             	mov    %eax,(%esp)
80105d9a:	e8 b6 c3 ff ff       	call   80102155 <dirlink>
80105d9f:	85 c0                	test   %eax,%eax
80105da1:	79 0c                	jns    80105daf <create+0x1b0>
    panic("create: dirlink");
80105da3:	c7 04 24 ee 88 10 80 	movl   $0x801088ee,(%esp)
80105daa:	e8 8e a7 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80105daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db2:	89 04 24             	mov    %eax,(%esp)
80105db5:	e8 3e bd ff ff       	call   80101af8 <iunlockput>

  return ip;
80105dba:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105dbd:	c9                   	leave  
80105dbe:	c3                   	ret    

80105dbf <sys_open>:

int
sys_open(void)
{
80105dbf:	55                   	push   %ebp
80105dc0:	89 e5                	mov    %esp,%ebp
80105dc2:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105dc5:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dd3:	e8 da f6 ff ff       	call   801054b2 <argstr>
80105dd8:	85 c0                	test   %eax,%eax
80105dda:	78 17                	js     80105df3 <sys_open+0x34>
80105ddc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105dea:	e8 33 f6 ff ff       	call   80105422 <argint>
80105def:	85 c0                	test   %eax,%eax
80105df1:	79 0a                	jns    80105dfd <sys_open+0x3e>
    return -1;
80105df3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df8:	e9 5a 01 00 00       	jmp    80105f57 <sys_open+0x198>

  begin_op();
80105dfd:	e8 5f d6 ff ff       	call   80103461 <begin_op>

  if(omode & O_CREATE){
80105e02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e05:	25 00 02 00 00       	and    $0x200,%eax
80105e0a:	85 c0                	test   %eax,%eax
80105e0c:	74 3b                	je     80105e49 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105e0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e11:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105e18:	00 
80105e19:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e20:	00 
80105e21:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105e28:	00 
80105e29:	89 04 24             	mov    %eax,(%esp)
80105e2c:	e8 ce fd ff ff       	call   80105bff <create>
80105e31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105e34:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e38:	75 6b                	jne    80105ea5 <sys_open+0xe6>
      end_op();
80105e3a:	e8 a3 d6 ff ff       	call   801034e2 <end_op>
      return -1;
80105e3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e44:	e9 0e 01 00 00       	jmp    80105f57 <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
80105e49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e4c:	89 04 24             	mov    %eax,(%esp)
80105e4f:	e8 c2 c5 ff ff       	call   80102416 <namei>
80105e54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e5b:	75 0f                	jne    80105e6c <sys_open+0xad>
      end_op();
80105e5d:	e8 80 d6 ff ff       	call   801034e2 <end_op>
      return -1;
80105e62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e67:	e9 eb 00 00 00       	jmp    80105f57 <sys_open+0x198>
    }
    ilock(ip);
80105e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6f:	89 04 24             	mov    %eax,(%esp)
80105e72:	e8 fd b9 ff ff       	call   80101874 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e7e:	66 83 f8 01          	cmp    $0x1,%ax
80105e82:	75 21                	jne    80105ea5 <sys_open+0xe6>
80105e84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e87:	85 c0                	test   %eax,%eax
80105e89:	74 1a                	je     80105ea5 <sys_open+0xe6>
      iunlockput(ip);
80105e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8e:	89 04 24             	mov    %eax,(%esp)
80105e91:	e8 62 bc ff ff       	call   80101af8 <iunlockput>
      end_op();
80105e96:	e8 47 d6 ff ff       	call   801034e2 <end_op>
      return -1;
80105e9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ea0:	e9 b2 00 00 00       	jmp    80105f57 <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105ea5:	e8 7e b0 ff ff       	call   80100f28 <filealloc>
80105eaa:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ead:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105eb1:	74 14                	je     80105ec7 <sys_open+0x108>
80105eb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb6:	89 04 24             	mov    %eax,(%esp)
80105eb9:	e8 2f f7 ff ff       	call   801055ed <fdalloc>
80105ebe:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105ec1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105ec5:	79 28                	jns    80105eef <sys_open+0x130>
    if(f)
80105ec7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ecb:	74 0b                	je     80105ed8 <sys_open+0x119>
      fileclose(f);
80105ecd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed0:	89 04 24             	mov    %eax,(%esp)
80105ed3:	e8 f8 b0 ff ff       	call   80100fd0 <fileclose>
    iunlockput(ip);
80105ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edb:	89 04 24             	mov    %eax,(%esp)
80105ede:	e8 15 bc ff ff       	call   80101af8 <iunlockput>
    end_op();
80105ee3:	e8 fa d5 ff ff       	call   801034e2 <end_op>
    return -1;
80105ee8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eed:	eb 68                	jmp    80105f57 <sys_open+0x198>
  }
  iunlock(ip);
80105eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef2:	89 04 24             	mov    %eax,(%esp)
80105ef5:	e8 c8 ba ff ff       	call   801019c2 <iunlock>
  end_op();
80105efa:	e8 e3 d5 ff ff       	call   801034e2 <end_op>

  f->type = FD_INODE;
80105eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f02:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105f08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f0e:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f14:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105f1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f1e:	83 e0 01             	and    $0x1,%eax
80105f21:	85 c0                	test   %eax,%eax
80105f23:	0f 94 c2             	sete   %dl
80105f26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f29:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105f2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f2f:	83 e0 01             	and    $0x1,%eax
80105f32:	84 c0                	test   %al,%al
80105f34:	75 0a                	jne    80105f40 <sys_open+0x181>
80105f36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f39:	83 e0 02             	and    $0x2,%eax
80105f3c:	85 c0                	test   %eax,%eax
80105f3e:	74 07                	je     80105f47 <sys_open+0x188>
80105f40:	b8 01 00 00 00       	mov    $0x1,%eax
80105f45:	eb 05                	jmp    80105f4c <sys_open+0x18d>
80105f47:	b8 00 00 00 00       	mov    $0x0,%eax
80105f4c:	89 c2                	mov    %eax,%edx
80105f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f51:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105f54:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105f57:	c9                   	leave  
80105f58:	c3                   	ret    

80105f59 <sys_mkdir>:

int
sys_mkdir(void)
{
80105f59:	55                   	push   %ebp
80105f5a:	89 e5                	mov    %esp,%ebp
80105f5c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105f5f:	e8 fd d4 ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105f64:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f67:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f72:	e8 3b f5 ff ff       	call   801054b2 <argstr>
80105f77:	85 c0                	test   %eax,%eax
80105f79:	78 2c                	js     80105fa7 <sys_mkdir+0x4e>
80105f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f7e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105f85:	00 
80105f86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105f8d:	00 
80105f8e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105f95:	00 
80105f96:	89 04 24             	mov    %eax,(%esp)
80105f99:	e8 61 fc ff ff       	call   80105bff <create>
80105f9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fa1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fa5:	75 0c                	jne    80105fb3 <sys_mkdir+0x5a>
    end_op();
80105fa7:	e8 36 d5 ff ff       	call   801034e2 <end_op>
    return -1;
80105fac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fb1:	eb 15                	jmp    80105fc8 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb6:	89 04 24             	mov    %eax,(%esp)
80105fb9:	e8 3a bb ff ff       	call   80101af8 <iunlockput>
  end_op();
80105fbe:	e8 1f d5 ff ff       	call   801034e2 <end_op>
  return 0;
80105fc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fc8:	c9                   	leave  
80105fc9:	c3                   	ret    

80105fca <sys_mknod>:

int
sys_mknod(void)
{
80105fca:	55                   	push   %ebp
80105fcb:	89 e5                	mov    %esp,%ebp
80105fcd:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80105fd0:	e8 8c d4 ff ff       	call   80103461 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80105fd5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fdc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fe3:	e8 ca f4 ff ff       	call   801054b2 <argstr>
80105fe8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105feb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fef:	78 5e                	js     8010604f <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80105ff1:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ff8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105fff:	e8 1e f4 ff ff       	call   80105422 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106004:	85 c0                	test   %eax,%eax
80106006:	78 47                	js     8010604f <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106008:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010600b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010600f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106016:	e8 07 f4 ff ff       	call   80105422 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010601b:	85 c0                	test   %eax,%eax
8010601d:	78 30                	js     8010604f <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010601f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106022:	0f bf c8             	movswl %ax,%ecx
80106025:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106028:	0f bf d0             	movswl %ax,%edx
8010602b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010602e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106032:	89 54 24 08          	mov    %edx,0x8(%esp)
80106036:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010603d:	00 
8010603e:	89 04 24             	mov    %eax,(%esp)
80106041:	e8 b9 fb ff ff       	call   80105bff <create>
80106046:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106049:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010604d:	75 0c                	jne    8010605b <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010604f:	e8 8e d4 ff ff       	call   801034e2 <end_op>
    return -1;
80106054:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106059:	eb 15                	jmp    80106070 <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010605b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010605e:	89 04 24             	mov    %eax,(%esp)
80106061:	e8 92 ba ff ff       	call   80101af8 <iunlockput>
  end_op();
80106066:	e8 77 d4 ff ff       	call   801034e2 <end_op>
  return 0;
8010606b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106070:	c9                   	leave  
80106071:	c3                   	ret    

80106072 <sys_chdir>:

int
sys_chdir(void)
{
80106072:	55                   	push   %ebp
80106073:	89 e5                	mov    %esp,%ebp
80106075:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106078:	e8 e4 d3 ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010607d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106080:	89 44 24 04          	mov    %eax,0x4(%esp)
80106084:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010608b:	e8 22 f4 ff ff       	call   801054b2 <argstr>
80106090:	85 c0                	test   %eax,%eax
80106092:	78 14                	js     801060a8 <sys_chdir+0x36>
80106094:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106097:	89 04 24             	mov    %eax,(%esp)
8010609a:	e8 77 c3 ff ff       	call   80102416 <namei>
8010609f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060a6:	75 0c                	jne    801060b4 <sys_chdir+0x42>
    end_op();
801060a8:	e8 35 d4 ff ff       	call   801034e2 <end_op>
    return -1;
801060ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b2:	eb 61                	jmp    80106115 <sys_chdir+0xa3>
  }
  ilock(ip);
801060b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b7:	89 04 24             	mov    %eax,(%esp)
801060ba:	e8 b5 b7 ff ff       	call   80101874 <ilock>
  if(ip->type != T_DIR){
801060bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060c6:	66 83 f8 01          	cmp    $0x1,%ax
801060ca:	74 17                	je     801060e3 <sys_chdir+0x71>
    iunlockput(ip);
801060cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060cf:	89 04 24             	mov    %eax,(%esp)
801060d2:	e8 21 ba ff ff       	call   80101af8 <iunlockput>
    end_op();
801060d7:	e8 06 d4 ff ff       	call   801034e2 <end_op>
    return -1;
801060dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060e1:	eb 32                	jmp    80106115 <sys_chdir+0xa3>
  }
  iunlock(ip);
801060e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060e6:	89 04 24             	mov    %eax,(%esp)
801060e9:	e8 d4 b8 ff ff       	call   801019c2 <iunlock>
  iput(proc->cwd);
801060ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801060f4:	8b 40 68             	mov    0x68(%eax),%eax
801060f7:	89 04 24             	mov    %eax,(%esp)
801060fa:	e8 28 b9 ff ff       	call   80101a27 <iput>
  end_op();
801060ff:	e8 de d3 ff ff       	call   801034e2 <end_op>
  proc->cwd = ip;
80106104:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010610a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010610d:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106110:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106115:	c9                   	leave  
80106116:	c3                   	ret    

80106117 <sys_exec>:

int
sys_exec(void)
{
80106117:	55                   	push   %ebp
80106118:	89 e5                	mov    %esp,%ebp
8010611a:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106120:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106123:	89 44 24 04          	mov    %eax,0x4(%esp)
80106127:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010612e:	e8 7f f3 ff ff       	call   801054b2 <argstr>
80106133:	85 c0                	test   %eax,%eax
80106135:	78 1a                	js     80106151 <sys_exec+0x3a>
80106137:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010613d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106141:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106148:	e8 d5 f2 ff ff       	call   80105422 <argint>
8010614d:	85 c0                	test   %eax,%eax
8010614f:	79 0a                	jns    8010615b <sys_exec+0x44>
    return -1;
80106151:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106156:	e9 cc 00 00 00       	jmp    80106227 <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
8010615b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106162:	00 
80106163:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010616a:	00 
8010616b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106171:	89 04 24             	mov    %eax,(%esp)
80106174:	e8 4d ef ff ff       	call   801050c6 <memset>
  for(i=0;; i++){
80106179:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106183:	83 f8 1f             	cmp    $0x1f,%eax
80106186:	76 0a                	jbe    80106192 <sys_exec+0x7b>
      return -1;
80106188:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010618d:	e9 95 00 00 00       	jmp    80106227 <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106195:	c1 e0 02             	shl    $0x2,%eax
80106198:	89 c2                	mov    %eax,%edx
8010619a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801061a0:	01 c2                	add    %eax,%edx
801061a2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801061a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ac:	89 14 24             	mov    %edx,(%esp)
801061af:	e8 d0 f1 ff ff       	call   80105384 <fetchint>
801061b4:	85 c0                	test   %eax,%eax
801061b6:	79 07                	jns    801061bf <sys_exec+0xa8>
      return -1;
801061b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061bd:	eb 68                	jmp    80106227 <sys_exec+0x110>
    if(uarg == 0){
801061bf:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801061c5:	85 c0                	test   %eax,%eax
801061c7:	75 26                	jne    801061ef <sys_exec+0xd8>
      argv[i] = 0;
801061c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061cc:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801061d3:	00 00 00 00 
      break;
801061d7:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801061d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061db:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801061e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801061e5:	89 04 24             	mov    %eax,(%esp)
801061e8:	e8 0f a9 ff ff       	call   80100afc <exec>
801061ed:	eb 38                	jmp    80106227 <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801061ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801061f9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801061ff:	01 c2                	add    %eax,%edx
80106201:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106207:	89 54 24 04          	mov    %edx,0x4(%esp)
8010620b:	89 04 24             	mov    %eax,(%esp)
8010620e:	e8 ab f1 ff ff       	call   801053be <fetchstr>
80106213:	85 c0                	test   %eax,%eax
80106215:	79 07                	jns    8010621e <sys_exec+0x107>
      return -1;
80106217:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621c:	eb 09                	jmp    80106227 <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010621e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106222:	e9 59 ff ff ff       	jmp    80106180 <sys_exec+0x69>
  return exec(path, argv);
}
80106227:	c9                   	leave  
80106228:	c3                   	ret    

80106229 <sys_pipe>:

int
sys_pipe(void)
{
80106229:	55                   	push   %ebp
8010622a:	89 e5                	mov    %esp,%ebp
8010622c:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010622f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106236:	00 
80106237:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010623a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010623e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106245:	e8 06 f2 ff ff       	call   80105450 <argptr>
8010624a:	85 c0                	test   %eax,%eax
8010624c:	79 0a                	jns    80106258 <sys_pipe+0x2f>
    return -1;
8010624e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106253:	e9 9b 00 00 00       	jmp    801062f3 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106258:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010625b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010625f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106262:	89 04 24             	mov    %eax,(%esp)
80106265:	e8 26 dd ff ff       	call   80103f90 <pipealloc>
8010626a:	85 c0                	test   %eax,%eax
8010626c:	79 07                	jns    80106275 <sys_pipe+0x4c>
    return -1;
8010626e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106273:	eb 7e                	jmp    801062f3 <sys_pipe+0xca>
  fd0 = -1;
80106275:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010627c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010627f:	89 04 24             	mov    %eax,(%esp)
80106282:	e8 66 f3 ff ff       	call   801055ed <fdalloc>
80106287:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010628a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010628e:	78 14                	js     801062a4 <sys_pipe+0x7b>
80106290:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106293:	89 04 24             	mov    %eax,(%esp)
80106296:	e8 52 f3 ff ff       	call   801055ed <fdalloc>
8010629b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010629e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062a2:	79 37                	jns    801062db <sys_pipe+0xb2>
    if(fd0 >= 0)
801062a4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062a8:	78 14                	js     801062be <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801062aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062b3:	83 c2 08             	add    $0x8,%edx
801062b6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801062bd:	00 
    fileclose(rf);
801062be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062c1:	89 04 24             	mov    %eax,(%esp)
801062c4:	e8 07 ad ff ff       	call   80100fd0 <fileclose>
    fileclose(wf);
801062c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062cc:	89 04 24             	mov    %eax,(%esp)
801062cf:	e8 fc ac ff ff       	call   80100fd0 <fileclose>
    return -1;
801062d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d9:	eb 18                	jmp    801062f3 <sys_pipe+0xca>
  }
  fd[0] = fd0;
801062db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062e1:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801062e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062e6:	8d 50 04             	lea    0x4(%eax),%edx
801062e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ec:	89 02                	mov    %eax,(%edx)
  return 0;
801062ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062f3:	c9                   	leave  
801062f4:	c3                   	ret    
801062f5:	00 00                	add    %al,(%eax)
	...

801062f8 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801062f8:	55                   	push   %ebp
801062f9:	89 e5                	mov    %esp,%ebp
801062fb:	83 ec 08             	sub    $0x8,%esp
  return fork();
801062fe:	e8 40 e3 ff ff       	call   80104643 <fork>
}
80106303:	c9                   	leave  
80106304:	c3                   	ret    

80106305 <sys_exit>:

int
sys_exit(void)
{
80106305:	55                   	push   %ebp
80106306:	89 e5                	mov    %esp,%ebp
80106308:	83 ec 28             	sub    $0x28,%esp
	int status;
	if(argint(0, &status) < 0)
8010630b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010630e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106312:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106319:	e8 04 f1 ff ff       	call   80105422 <argint>
8010631e:	85 c0                	test   %eax,%eax
80106320:	79 07                	jns    80106329 <sys_exit+0x24>
	    return -1;
80106322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106327:	eb 10                	jmp    80106339 <sys_exit+0x34>

	exit(status);
80106329:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632c:	89 04 24             	mov    %eax,(%esp)
8010632f:	e8 8a e4 ff ff       	call   801047be <exit>
	return 0;  // not reached
80106334:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106339:	c9                   	leave  
8010633a:	c3                   	ret    

8010633b <sys_wait>:

int
sys_wait(void)
{
8010633b:	55                   	push   %ebp
8010633c:	89 e5                	mov    %esp,%ebp
8010633e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106341:	e8 9a e5 ff ff       	call   801048e0 <wait>
}
80106346:	c9                   	leave  
80106347:	c3                   	ret    

80106348 <sys_kill>:

int
sys_kill(void)
{
80106348:	55                   	push   %ebp
80106349:	89 e5                	mov    %esp,%ebp
8010634b:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010634e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106351:	89 44 24 04          	mov    %eax,0x4(%esp)
80106355:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010635c:	e8 c1 f0 ff ff       	call   80105422 <argint>
80106361:	85 c0                	test   %eax,%eax
80106363:	79 07                	jns    8010636c <sys_kill+0x24>
    return -1;
80106365:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010636a:	eb 0b                	jmp    80106377 <sys_kill+0x2f>
  return kill(pid);
8010636c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636f:	89 04 24             	mov    %eax,(%esp)
80106372:	e8 25 e9 ff ff       	call   80104c9c <kill>
}
80106377:	c9                   	leave  
80106378:	c3                   	ret    

80106379 <sys_getpid>:

int
sys_getpid(void)
{
80106379:	55                   	push   %ebp
8010637a:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010637c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106382:	8b 40 10             	mov    0x10(%eax),%eax
}
80106385:	5d                   	pop    %ebp
80106386:	c3                   	ret    

80106387 <sys_sbrk>:

int
sys_sbrk(void)
{
80106387:	55                   	push   %ebp
80106388:	89 e5                	mov    %esp,%ebp
8010638a:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010638d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106390:	89 44 24 04          	mov    %eax,0x4(%esp)
80106394:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010639b:	e8 82 f0 ff ff       	call   80105422 <argint>
801063a0:	85 c0                	test   %eax,%eax
801063a2:	79 07                	jns    801063ab <sys_sbrk+0x24>
    return -1;
801063a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a9:	eb 24                	jmp    801063cf <sys_sbrk+0x48>
  addr = proc->sz;
801063ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063b1:	8b 00                	mov    (%eax),%eax
801063b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801063b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b9:	89 04 24             	mov    %eax,(%esp)
801063bc:	e8 dd e1 ff ff       	call   8010459e <growproc>
801063c1:	85 c0                	test   %eax,%eax
801063c3:	79 07                	jns    801063cc <sys_sbrk+0x45>
    return -1;
801063c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ca:	eb 03                	jmp    801063cf <sys_sbrk+0x48>
  return addr;
801063cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063cf:	c9                   	leave  
801063d0:	c3                   	ret    

801063d1 <sys_sleep>:

int
sys_sleep(void)
{
801063d1:	55                   	push   %ebp
801063d2:	89 e5                	mov    %esp,%ebp
801063d4:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801063d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063da:	89 44 24 04          	mov    %eax,0x4(%esp)
801063de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063e5:	e8 38 f0 ff ff       	call   80105422 <argint>
801063ea:	85 c0                	test   %eax,%eax
801063ec:	79 07                	jns    801063f5 <sys_sleep+0x24>
    return -1;
801063ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063f3:	eb 6c                	jmp    80106461 <sys_sleep+0x90>
  acquire(&tickslock);
801063f5:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801063fc:	e8 76 ea ff ff       	call   80104e77 <acquire>
  ticks0 = ticks;
80106401:	a1 e0 51 11 80       	mov    0x801151e0,%eax
80106406:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106409:	eb 34                	jmp    8010643f <sys_sleep+0x6e>
    if(proc->killed){
8010640b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106411:	8b 40 24             	mov    0x24(%eax),%eax
80106414:	85 c0                	test   %eax,%eax
80106416:	74 13                	je     8010642b <sys_sleep+0x5a>
      release(&tickslock);
80106418:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
8010641f:	e8 b5 ea ff ff       	call   80104ed9 <release>
      return -1;
80106424:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106429:	eb 36                	jmp    80106461 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010642b:	c7 44 24 04 a0 49 11 	movl   $0x801149a0,0x4(%esp)
80106432:	80 
80106433:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
8010643a:	e8 59 e7 ff ff       	call   80104b98 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010643f:	a1 e0 51 11 80       	mov    0x801151e0,%eax
80106444:	89 c2                	mov    %eax,%edx
80106446:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106449:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010644c:	39 c2                	cmp    %eax,%edx
8010644e:	72 bb                	jb     8010640b <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106450:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106457:	e8 7d ea ff ff       	call   80104ed9 <release>
  return 0;
8010645c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106461:	c9                   	leave  
80106462:	c3                   	ret    

80106463 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106463:	55                   	push   %ebp
80106464:	89 e5                	mov    %esp,%ebp
80106466:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106469:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106470:	e8 02 ea ff ff       	call   80104e77 <acquire>
  xticks = ticks;
80106475:	a1 e0 51 11 80       	mov    0x801151e0,%eax
8010647a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
8010647d:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106484:	e8 50 ea ff ff       	call   80104ed9 <release>
  return xticks;
80106489:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010648c:	c9                   	leave  
8010648d:	c3                   	ret    
	...

80106490 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106490:	55                   	push   %ebp
80106491:	89 e5                	mov    %esp,%ebp
80106493:	83 ec 08             	sub    $0x8,%esp
80106496:	8b 55 08             	mov    0x8(%ebp),%edx
80106499:	8b 45 0c             	mov    0xc(%ebp),%eax
8010649c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801064a0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801064a3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801064a7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801064ab:	ee                   	out    %al,(%dx)
}
801064ac:	c9                   	leave  
801064ad:	c3                   	ret    

801064ae <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801064ae:	55                   	push   %ebp
801064af:	89 e5                	mov    %esp,%ebp
801064b1:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801064b4:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801064bb:	00 
801064bc:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801064c3:	e8 c8 ff ff ff       	call   80106490 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801064c8:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801064cf:	00 
801064d0:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801064d7:	e8 b4 ff ff ff       	call   80106490 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801064dc:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801064e3:	00 
801064e4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801064eb:	e8 a0 ff ff ff       	call   80106490 <outb>
  picenable(IRQ_TIMER);
801064f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064f7:	e8 1d d9 ff ff       	call   80103e19 <picenable>
}
801064fc:	c9                   	leave  
801064fd:	c3                   	ret    
	...

80106500 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106500:	1e                   	push   %ds
  pushl %es
80106501:	06                   	push   %es
  pushl %fs
80106502:	0f a0                	push   %fs
  pushl %gs
80106504:	0f a8                	push   %gs
  pushal
80106506:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106507:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010650b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010650d:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010650f:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106513:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106515:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106517:	54                   	push   %esp
  call trap
80106518:	e8 de 01 00 00       	call   801066fb <trap>
  addl $4, %esp
8010651d:	83 c4 04             	add    $0x4,%esp

80106520 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106520:	61                   	popa   
  popl %gs
80106521:	0f a9                	pop    %gs
  popl %fs
80106523:	0f a1                	pop    %fs
  popl %es
80106525:	07                   	pop    %es
  popl %ds
80106526:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106527:	83 c4 08             	add    $0x8,%esp
  iret
8010652a:	cf                   	iret   
	...

8010652c <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010652c:	55                   	push   %ebp
8010652d:	89 e5                	mov    %esp,%ebp
8010652f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106532:	8b 45 0c             	mov    0xc(%ebp),%eax
80106535:	83 e8 01             	sub    $0x1,%eax
80106538:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010653c:	8b 45 08             	mov    0x8(%ebp),%eax
8010653f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106543:	8b 45 08             	mov    0x8(%ebp),%eax
80106546:	c1 e8 10             	shr    $0x10,%eax
80106549:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010654d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106550:	0f 01 18             	lidtl  (%eax)
}
80106553:	c9                   	leave  
80106554:	c3                   	ret    

80106555 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106555:	55                   	push   %ebp
80106556:	89 e5                	mov    %esp,%ebp
80106558:	53                   	push   %ebx
80106559:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010655c:	0f 20 d3             	mov    %cr2,%ebx
8010655f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106562:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106565:	83 c4 10             	add    $0x10,%esp
80106568:	5b                   	pop    %ebx
80106569:	5d                   	pop    %ebp
8010656a:	c3                   	ret    

8010656b <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010656b:	55                   	push   %ebp
8010656c:	89 e5                	mov    %esp,%ebp
8010656e:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106571:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106578:	e9 c3 00 00 00       	jmp    80106640 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010657d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106580:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106587:	89 c2                	mov    %eax,%edx
80106589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658c:	66 89 14 c5 e0 49 11 	mov    %dx,-0x7feeb620(,%eax,8)
80106593:	80 
80106594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106597:	66 c7 04 c5 e2 49 11 	movw   $0x8,-0x7feeb61e(,%eax,8)
8010659e:	80 08 00 
801065a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a4:	0f b6 14 c5 e4 49 11 	movzbl -0x7feeb61c(,%eax,8),%edx
801065ab:	80 
801065ac:	83 e2 e0             	and    $0xffffffe0,%edx
801065af:	88 14 c5 e4 49 11 80 	mov    %dl,-0x7feeb61c(,%eax,8)
801065b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b9:	0f b6 14 c5 e4 49 11 	movzbl -0x7feeb61c(,%eax,8),%edx
801065c0:	80 
801065c1:	83 e2 1f             	and    $0x1f,%edx
801065c4:	88 14 c5 e4 49 11 80 	mov    %dl,-0x7feeb61c(,%eax,8)
801065cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ce:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
801065d5:	80 
801065d6:	83 e2 f0             	and    $0xfffffff0,%edx
801065d9:	83 ca 0e             	or     $0xe,%edx
801065dc:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
801065e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e6:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
801065ed:	80 
801065ee:	83 e2 ef             	and    $0xffffffef,%edx
801065f1:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
801065f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065fb:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
80106602:	80 
80106603:	83 e2 9f             	and    $0xffffff9f,%edx
80106606:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
8010660d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106610:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
80106617:	80 
80106618:	83 ca 80             	or     $0xffffff80,%edx
8010661b:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
80106622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106625:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
8010662c:	c1 e8 10             	shr    $0x10,%eax
8010662f:	89 c2                	mov    %eax,%edx
80106631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106634:	66 89 14 c5 e6 49 11 	mov    %dx,-0x7feeb61a(,%eax,8)
8010663b:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010663c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106640:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106647:	0f 8e 30 ff ff ff    	jle    8010657d <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010664d:	a1 98 b1 10 80       	mov    0x8010b198,%eax
80106652:	66 a3 e0 4b 11 80    	mov    %ax,0x80114be0
80106658:	66 c7 05 e2 4b 11 80 	movw   $0x8,0x80114be2
8010665f:	08 00 
80106661:	0f b6 05 e4 4b 11 80 	movzbl 0x80114be4,%eax
80106668:	83 e0 e0             	and    $0xffffffe0,%eax
8010666b:	a2 e4 4b 11 80       	mov    %al,0x80114be4
80106670:	0f b6 05 e4 4b 11 80 	movzbl 0x80114be4,%eax
80106677:	83 e0 1f             	and    $0x1f,%eax
8010667a:	a2 e4 4b 11 80       	mov    %al,0x80114be4
8010667f:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
80106686:	83 c8 0f             	or     $0xf,%eax
80106689:	a2 e5 4b 11 80       	mov    %al,0x80114be5
8010668e:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
80106695:	83 e0 ef             	and    $0xffffffef,%eax
80106698:	a2 e5 4b 11 80       	mov    %al,0x80114be5
8010669d:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801066a4:	83 c8 60             	or     $0x60,%eax
801066a7:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801066ac:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801066b3:	83 c8 80             	or     $0xffffff80,%eax
801066b6:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801066bb:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801066c0:	c1 e8 10             	shr    $0x10,%eax
801066c3:	66 a3 e6 4b 11 80    	mov    %ax,0x80114be6
  
  initlock(&tickslock, "time");
801066c9:	c7 44 24 04 00 89 10 	movl   $0x80108900,0x4(%esp)
801066d0:	80 
801066d1:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801066d8:	e8 79 e7 ff ff       	call   80104e56 <initlock>
}
801066dd:	c9                   	leave  
801066de:	c3                   	ret    

801066df <idtinit>:

void
idtinit(void)
{
801066df:	55                   	push   %ebp
801066e0:	89 e5                	mov    %esp,%ebp
801066e2:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801066e5:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801066ec:	00 
801066ed:	c7 04 24 e0 49 11 80 	movl   $0x801149e0,(%esp)
801066f4:	e8 33 fe ff ff       	call   8010652c <lidt>
}
801066f9:	c9                   	leave  
801066fa:	c3                   	ret    

801066fb <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801066fb:	55                   	push   %ebp
801066fc:	89 e5                	mov    %esp,%ebp
801066fe:	57                   	push   %edi
801066ff:	56                   	push   %esi
80106700:	53                   	push   %ebx
80106701:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106704:	8b 45 08             	mov    0x8(%ebp),%eax
80106707:	8b 40 30             	mov    0x30(%eax),%eax
8010670a:	83 f8 40             	cmp    $0x40,%eax
8010670d:	75 4c                	jne    8010675b <trap+0x60>
    if(proc->killed)
8010670f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106715:	8b 40 24             	mov    0x24(%eax),%eax
80106718:	85 c0                	test   %eax,%eax
8010671a:	74 0c                	je     80106728 <trap+0x2d>
      exit(EXIT_STATUS_DEFAULT);
8010671c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106723:	e8 96 e0 ff ff       	call   801047be <exit>
    proc->tf = tf;
80106728:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010672e:	8b 55 08             	mov    0x8(%ebp),%edx
80106731:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106734:	e8 b0 ed ff ff       	call   801054e9 <syscall>
    if(proc->killed)
80106739:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010673f:	8b 40 24             	mov    0x24(%eax),%eax
80106742:	85 c0                	test   %eax,%eax
80106744:	0f 84 49 02 00 00    	je     80106993 <trap+0x298>
      exit(EXIT_STATUS_DEFAULT);
8010674a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106751:	e8 68 e0 ff ff       	call   801047be <exit>
    return;
80106756:	e9 38 02 00 00       	jmp    80106993 <trap+0x298>
  }

  switch(tf->trapno){
8010675b:	8b 45 08             	mov    0x8(%ebp),%eax
8010675e:	8b 40 30             	mov    0x30(%eax),%eax
80106761:	83 e8 20             	sub    $0x20,%eax
80106764:	83 f8 1f             	cmp    $0x1f,%eax
80106767:	0f 87 bc 00 00 00    	ja     80106829 <trap+0x12e>
8010676d:	8b 04 85 a8 89 10 80 	mov    -0x7fef7658(,%eax,4),%eax
80106774:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106776:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010677c:	0f b6 00             	movzbl (%eax),%eax
8010677f:	84 c0                	test   %al,%al
80106781:	75 31                	jne    801067b4 <trap+0xb9>
      acquire(&tickslock);
80106783:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
8010678a:	e8 e8 e6 ff ff       	call   80104e77 <acquire>
      ticks++;
8010678f:	a1 e0 51 11 80       	mov    0x801151e0,%eax
80106794:	83 c0 01             	add    $0x1,%eax
80106797:	a3 e0 51 11 80       	mov    %eax,0x801151e0
      wakeup(&ticks);
8010679c:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
801067a3:	e8 c9 e4 ff ff       	call   80104c71 <wakeup>
      release(&tickslock);
801067a8:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801067af:	e8 25 e7 ff ff       	call   80104ed9 <release>
    }
    lapiceoi();
801067b4:	e8 66 c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067b9:	e9 41 01 00 00       	jmp    801068ff <trap+0x204>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801067be:	e8 3a bf ff ff       	call   801026fd <ideintr>
    lapiceoi();
801067c3:	e8 57 c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067c8:	e9 32 01 00 00       	jmp    801068ff <trap+0x204>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801067cd:	e8 01 c5 ff ff       	call   80102cd3 <kbdintr>
    lapiceoi();
801067d2:	e8 48 c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067d7:	e9 23 01 00 00       	jmp    801068ff <trap+0x204>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801067dc:	e8 b7 03 00 00       	call   80106b98 <uartintr>
    lapiceoi();
801067e1:	e8 39 c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067e6:	e9 14 01 00 00       	jmp    801068ff <trap+0x204>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
801067eb:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067ee:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801067f1:	8b 45 08             	mov    0x8(%ebp),%eax
801067f4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067f8:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801067fb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106801:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106804:	0f b6 c0             	movzbl %al,%eax
80106807:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010680b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010680f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106813:	c7 04 24 08 89 10 80 	movl   $0x80108908,(%esp)
8010681a:	e8 82 9b ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010681f:	e8 fb c6 ff ff       	call   80102f1f <lapiceoi>
    break;
80106824:	e9 d6 00 00 00       	jmp    801068ff <trap+0x204>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106829:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010682f:	85 c0                	test   %eax,%eax
80106831:	74 11                	je     80106844 <trap+0x149>
80106833:	8b 45 08             	mov    0x8(%ebp),%eax
80106836:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010683a:	0f b7 c0             	movzwl %ax,%eax
8010683d:	83 e0 03             	and    $0x3,%eax
80106840:	85 c0                	test   %eax,%eax
80106842:	75 46                	jne    8010688a <trap+0x18f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106844:	e8 0c fd ff ff       	call   80106555 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106849:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010684c:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010684f:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106856:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106859:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010685c:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010685f:	8b 52 30             	mov    0x30(%edx),%edx
80106862:	89 44 24 10          	mov    %eax,0x10(%esp)
80106866:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
8010686a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010686e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106872:	c7 04 24 2c 89 10 80 	movl   $0x8010892c,(%esp)
80106879:	e8 23 9b ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010687e:	c7 04 24 5e 89 10 80 	movl   $0x8010895e,(%esp)
80106885:	e8 b3 9c ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010688a:	e8 c6 fc ff ff       	call   80106555 <rcr2>
8010688f:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106891:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106894:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106897:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010689d:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068a0:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801068a3:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068a6:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801068a9:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068ac:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801068af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068b5:	83 c0 6c             	add    $0x6c,%eax
801068b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801068bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068c1:	8b 40 10             	mov    0x10(%eax),%eax
801068c4:	89 54 24 1c          	mov    %edx,0x1c(%esp)
801068c8:	89 7c 24 18          	mov    %edi,0x18(%esp)
801068cc:	89 74 24 14          	mov    %esi,0x14(%esp)
801068d0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801068d4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801068d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801068db:	89 54 24 08          	mov    %edx,0x8(%esp)
801068df:	89 44 24 04          	mov    %eax,0x4(%esp)
801068e3:	c7 04 24 64 89 10 80 	movl   $0x80108964,(%esp)
801068ea:	e8 b2 9a ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801068ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068f5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801068fc:	eb 01                	jmp    801068ff <trap+0x204>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801068fe:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801068ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106905:	85 c0                	test   %eax,%eax
80106907:	74 2b                	je     80106934 <trap+0x239>
80106909:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010690f:	8b 40 24             	mov    0x24(%eax),%eax
80106912:	85 c0                	test   %eax,%eax
80106914:	74 1e                	je     80106934 <trap+0x239>
80106916:	8b 45 08             	mov    0x8(%ebp),%eax
80106919:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010691d:	0f b7 c0             	movzwl %ax,%eax
80106920:	83 e0 03             	and    $0x3,%eax
80106923:	83 f8 03             	cmp    $0x3,%eax
80106926:	75 0c                	jne    80106934 <trap+0x239>
    exit(EXIT_STATUS_DEFAULT);
80106928:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010692f:	e8 8a de ff ff       	call   801047be <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106934:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010693a:	85 c0                	test   %eax,%eax
8010693c:	74 1e                	je     8010695c <trap+0x261>
8010693e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106944:	8b 40 0c             	mov    0xc(%eax),%eax
80106947:	83 f8 04             	cmp    $0x4,%eax
8010694a:	75 10                	jne    8010695c <trap+0x261>
8010694c:	8b 45 08             	mov    0x8(%ebp),%eax
8010694f:	8b 40 30             	mov    0x30(%eax),%eax
80106952:	83 f8 20             	cmp    $0x20,%eax
80106955:	75 05                	jne    8010695c <trap+0x261>
    yield();
80106957:	e8 de e1 ff ff       	call   80104b3a <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010695c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106962:	85 c0                	test   %eax,%eax
80106964:	74 2e                	je     80106994 <trap+0x299>
80106966:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010696c:	8b 40 24             	mov    0x24(%eax),%eax
8010696f:	85 c0                	test   %eax,%eax
80106971:	74 21                	je     80106994 <trap+0x299>
80106973:	8b 45 08             	mov    0x8(%ebp),%eax
80106976:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010697a:	0f b7 c0             	movzwl %ax,%eax
8010697d:	83 e0 03             	and    $0x3,%eax
80106980:	83 f8 03             	cmp    $0x3,%eax
80106983:	75 0f                	jne    80106994 <trap+0x299>
    exit(EXIT_STATUS_DEFAULT);
80106985:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010698c:	e8 2d de ff ff       	call   801047be <exit>
80106991:	eb 01                	jmp    80106994 <trap+0x299>
      exit(EXIT_STATUS_DEFAULT);
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit(EXIT_STATUS_DEFAULT);
    return;
80106993:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit(EXIT_STATUS_DEFAULT);
}
80106994:	83 c4 3c             	add    $0x3c,%esp
80106997:	5b                   	pop    %ebx
80106998:	5e                   	pop    %esi
80106999:	5f                   	pop    %edi
8010699a:	5d                   	pop    %ebp
8010699b:	c3                   	ret    

8010699c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010699c:	55                   	push   %ebp
8010699d:	89 e5                	mov    %esp,%ebp
8010699f:	53                   	push   %ebx
801069a0:	83 ec 14             	sub    $0x14,%esp
801069a3:	8b 45 08             	mov    0x8(%ebp),%eax
801069a6:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801069aa:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801069ae:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801069b2:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801069b6:	ec                   	in     (%dx),%al
801069b7:	89 c3                	mov    %eax,%ebx
801069b9:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801069bc:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801069c0:	83 c4 14             	add    $0x14,%esp
801069c3:	5b                   	pop    %ebx
801069c4:	5d                   	pop    %ebp
801069c5:	c3                   	ret    

801069c6 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801069c6:	55                   	push   %ebp
801069c7:	89 e5                	mov    %esp,%ebp
801069c9:	83 ec 08             	sub    $0x8,%esp
801069cc:	8b 55 08             	mov    0x8(%ebp),%edx
801069cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801069d2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801069d6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801069d9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801069dd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801069e1:	ee                   	out    %al,(%dx)
}
801069e2:	c9                   	leave  
801069e3:	c3                   	ret    

801069e4 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801069e4:	55                   	push   %ebp
801069e5:	89 e5                	mov    %esp,%ebp
801069e7:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801069ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801069f1:	00 
801069f2:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801069f9:	e8 c8 ff ff ff       	call   801069c6 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801069fe:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106a05:	00 
80106a06:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106a0d:	e8 b4 ff ff ff       	call   801069c6 <outb>
  outb(COM1+0, 115200/9600);
80106a12:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106a19:	00 
80106a1a:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a21:	e8 a0 ff ff ff       	call   801069c6 <outb>
  outb(COM1+1, 0);
80106a26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a2d:	00 
80106a2e:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106a35:	e8 8c ff ff ff       	call   801069c6 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106a3a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106a41:	00 
80106a42:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106a49:	e8 78 ff ff ff       	call   801069c6 <outb>
  outb(COM1+4, 0);
80106a4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a55:	00 
80106a56:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106a5d:	e8 64 ff ff ff       	call   801069c6 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106a62:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106a69:	00 
80106a6a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106a71:	e8 50 ff ff ff       	call   801069c6 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106a76:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a7d:	e8 1a ff ff ff       	call   8010699c <inb>
80106a82:	3c ff                	cmp    $0xff,%al
80106a84:	74 6c                	je     80106af2 <uartinit+0x10e>
    return;
  uart = 1;
80106a86:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106a8d:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106a90:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106a97:	e8 00 ff ff ff       	call   8010699c <inb>
  inb(COM1+0);
80106a9c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106aa3:	e8 f4 fe ff ff       	call   8010699c <inb>
  picenable(IRQ_COM1);
80106aa8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106aaf:	e8 65 d3 ff ff       	call   80103e19 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106ab4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106abb:	00 
80106abc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106ac3:	e8 ba be ff ff       	call   80102982 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ac8:	c7 45 f4 28 8a 10 80 	movl   $0x80108a28,-0xc(%ebp)
80106acf:	eb 15                	jmp    80106ae6 <uartinit+0x102>
    uartputc(*p);
80106ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ad4:	0f b6 00             	movzbl (%eax),%eax
80106ad7:	0f be c0             	movsbl %al,%eax
80106ada:	89 04 24             	mov    %eax,(%esp)
80106add:	e8 13 00 00 00       	call   80106af5 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ae2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106ae6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae9:	0f b6 00             	movzbl (%eax),%eax
80106aec:	84 c0                	test   %al,%al
80106aee:	75 e1                	jne    80106ad1 <uartinit+0xed>
80106af0:	eb 01                	jmp    80106af3 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106af2:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106af3:	c9                   	leave  
80106af4:	c3                   	ret    

80106af5 <uartputc>:

void
uartputc(int c)
{
80106af5:	55                   	push   %ebp
80106af6:	89 e5                	mov    %esp,%ebp
80106af8:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106afb:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106b00:	85 c0                	test   %eax,%eax
80106b02:	74 4d                	je     80106b51 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b0b:	eb 10                	jmp    80106b1d <uartputc+0x28>
    microdelay(10);
80106b0d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106b14:	e8 2b c4 ff ff       	call   80102f44 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b19:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b1d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106b21:	7f 16                	jg     80106b39 <uartputc+0x44>
80106b23:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106b2a:	e8 6d fe ff ff       	call   8010699c <inb>
80106b2f:	0f b6 c0             	movzbl %al,%eax
80106b32:	83 e0 20             	and    $0x20,%eax
80106b35:	85 c0                	test   %eax,%eax
80106b37:	74 d4                	je     80106b0d <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106b39:	8b 45 08             	mov    0x8(%ebp),%eax
80106b3c:	0f b6 c0             	movzbl %al,%eax
80106b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b43:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b4a:	e8 77 fe ff ff       	call   801069c6 <outb>
80106b4f:	eb 01                	jmp    80106b52 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106b51:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106b52:	c9                   	leave  
80106b53:	c3                   	ret    

80106b54 <uartgetc>:

static int
uartgetc(void)
{
80106b54:	55                   	push   %ebp
80106b55:	89 e5                	mov    %esp,%ebp
80106b57:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106b5a:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106b5f:	85 c0                	test   %eax,%eax
80106b61:	75 07                	jne    80106b6a <uartgetc+0x16>
    return -1;
80106b63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b68:	eb 2c                	jmp    80106b96 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106b6a:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106b71:	e8 26 fe ff ff       	call   8010699c <inb>
80106b76:	0f b6 c0             	movzbl %al,%eax
80106b79:	83 e0 01             	and    $0x1,%eax
80106b7c:	85 c0                	test   %eax,%eax
80106b7e:	75 07                	jne    80106b87 <uartgetc+0x33>
    return -1;
80106b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b85:	eb 0f                	jmp    80106b96 <uartgetc+0x42>
  return inb(COM1+0);
80106b87:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b8e:	e8 09 fe ff ff       	call   8010699c <inb>
80106b93:	0f b6 c0             	movzbl %al,%eax
}
80106b96:	c9                   	leave  
80106b97:	c3                   	ret    

80106b98 <uartintr>:

void
uartintr(void)
{
80106b98:	55                   	push   %ebp
80106b99:	89 e5                	mov    %esp,%ebp
80106b9b:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106b9e:	c7 04 24 54 6b 10 80 	movl   $0x80106b54,(%esp)
80106ba5:	e8 03 9c ff ff       	call   801007ad <consoleintr>
}
80106baa:	c9                   	leave  
80106bab:	c3                   	ret    

80106bac <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $0
80106bae:	6a 00                	push   $0x0
  jmp alltraps
80106bb0:	e9 4b f9 ff ff       	jmp    80106500 <alltraps>

80106bb5 <vector1>:
.globl vector1
vector1:
  pushl $0
80106bb5:	6a 00                	push   $0x0
  pushl $1
80106bb7:	6a 01                	push   $0x1
  jmp alltraps
80106bb9:	e9 42 f9 ff ff       	jmp    80106500 <alltraps>

80106bbe <vector2>:
.globl vector2
vector2:
  pushl $0
80106bbe:	6a 00                	push   $0x0
  pushl $2
80106bc0:	6a 02                	push   $0x2
  jmp alltraps
80106bc2:	e9 39 f9 ff ff       	jmp    80106500 <alltraps>

80106bc7 <vector3>:
.globl vector3
vector3:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $3
80106bc9:	6a 03                	push   $0x3
  jmp alltraps
80106bcb:	e9 30 f9 ff ff       	jmp    80106500 <alltraps>

80106bd0 <vector4>:
.globl vector4
vector4:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $4
80106bd2:	6a 04                	push   $0x4
  jmp alltraps
80106bd4:	e9 27 f9 ff ff       	jmp    80106500 <alltraps>

80106bd9 <vector5>:
.globl vector5
vector5:
  pushl $0
80106bd9:	6a 00                	push   $0x0
  pushl $5
80106bdb:	6a 05                	push   $0x5
  jmp alltraps
80106bdd:	e9 1e f9 ff ff       	jmp    80106500 <alltraps>

80106be2 <vector6>:
.globl vector6
vector6:
  pushl $0
80106be2:	6a 00                	push   $0x0
  pushl $6
80106be4:	6a 06                	push   $0x6
  jmp alltraps
80106be6:	e9 15 f9 ff ff       	jmp    80106500 <alltraps>

80106beb <vector7>:
.globl vector7
vector7:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $7
80106bed:	6a 07                	push   $0x7
  jmp alltraps
80106bef:	e9 0c f9 ff ff       	jmp    80106500 <alltraps>

80106bf4 <vector8>:
.globl vector8
vector8:
  pushl $8
80106bf4:	6a 08                	push   $0x8
  jmp alltraps
80106bf6:	e9 05 f9 ff ff       	jmp    80106500 <alltraps>

80106bfb <vector9>:
.globl vector9
vector9:
  pushl $0
80106bfb:	6a 00                	push   $0x0
  pushl $9
80106bfd:	6a 09                	push   $0x9
  jmp alltraps
80106bff:	e9 fc f8 ff ff       	jmp    80106500 <alltraps>

80106c04 <vector10>:
.globl vector10
vector10:
  pushl $10
80106c04:	6a 0a                	push   $0xa
  jmp alltraps
80106c06:	e9 f5 f8 ff ff       	jmp    80106500 <alltraps>

80106c0b <vector11>:
.globl vector11
vector11:
  pushl $11
80106c0b:	6a 0b                	push   $0xb
  jmp alltraps
80106c0d:	e9 ee f8 ff ff       	jmp    80106500 <alltraps>

80106c12 <vector12>:
.globl vector12
vector12:
  pushl $12
80106c12:	6a 0c                	push   $0xc
  jmp alltraps
80106c14:	e9 e7 f8 ff ff       	jmp    80106500 <alltraps>

80106c19 <vector13>:
.globl vector13
vector13:
  pushl $13
80106c19:	6a 0d                	push   $0xd
  jmp alltraps
80106c1b:	e9 e0 f8 ff ff       	jmp    80106500 <alltraps>

80106c20 <vector14>:
.globl vector14
vector14:
  pushl $14
80106c20:	6a 0e                	push   $0xe
  jmp alltraps
80106c22:	e9 d9 f8 ff ff       	jmp    80106500 <alltraps>

80106c27 <vector15>:
.globl vector15
vector15:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $15
80106c29:	6a 0f                	push   $0xf
  jmp alltraps
80106c2b:	e9 d0 f8 ff ff       	jmp    80106500 <alltraps>

80106c30 <vector16>:
.globl vector16
vector16:
  pushl $0
80106c30:	6a 00                	push   $0x0
  pushl $16
80106c32:	6a 10                	push   $0x10
  jmp alltraps
80106c34:	e9 c7 f8 ff ff       	jmp    80106500 <alltraps>

80106c39 <vector17>:
.globl vector17
vector17:
  pushl $17
80106c39:	6a 11                	push   $0x11
  jmp alltraps
80106c3b:	e9 c0 f8 ff ff       	jmp    80106500 <alltraps>

80106c40 <vector18>:
.globl vector18
vector18:
  pushl $0
80106c40:	6a 00                	push   $0x0
  pushl $18
80106c42:	6a 12                	push   $0x12
  jmp alltraps
80106c44:	e9 b7 f8 ff ff       	jmp    80106500 <alltraps>

80106c49 <vector19>:
.globl vector19
vector19:
  pushl $0
80106c49:	6a 00                	push   $0x0
  pushl $19
80106c4b:	6a 13                	push   $0x13
  jmp alltraps
80106c4d:	e9 ae f8 ff ff       	jmp    80106500 <alltraps>

80106c52 <vector20>:
.globl vector20
vector20:
  pushl $0
80106c52:	6a 00                	push   $0x0
  pushl $20
80106c54:	6a 14                	push   $0x14
  jmp alltraps
80106c56:	e9 a5 f8 ff ff       	jmp    80106500 <alltraps>

80106c5b <vector21>:
.globl vector21
vector21:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $21
80106c5d:	6a 15                	push   $0x15
  jmp alltraps
80106c5f:	e9 9c f8 ff ff       	jmp    80106500 <alltraps>

80106c64 <vector22>:
.globl vector22
vector22:
  pushl $0
80106c64:	6a 00                	push   $0x0
  pushl $22
80106c66:	6a 16                	push   $0x16
  jmp alltraps
80106c68:	e9 93 f8 ff ff       	jmp    80106500 <alltraps>

80106c6d <vector23>:
.globl vector23
vector23:
  pushl $0
80106c6d:	6a 00                	push   $0x0
  pushl $23
80106c6f:	6a 17                	push   $0x17
  jmp alltraps
80106c71:	e9 8a f8 ff ff       	jmp    80106500 <alltraps>

80106c76 <vector24>:
.globl vector24
vector24:
  pushl $0
80106c76:	6a 00                	push   $0x0
  pushl $24
80106c78:	6a 18                	push   $0x18
  jmp alltraps
80106c7a:	e9 81 f8 ff ff       	jmp    80106500 <alltraps>

80106c7f <vector25>:
.globl vector25
vector25:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $25
80106c81:	6a 19                	push   $0x19
  jmp alltraps
80106c83:	e9 78 f8 ff ff       	jmp    80106500 <alltraps>

80106c88 <vector26>:
.globl vector26
vector26:
  pushl $0
80106c88:	6a 00                	push   $0x0
  pushl $26
80106c8a:	6a 1a                	push   $0x1a
  jmp alltraps
80106c8c:	e9 6f f8 ff ff       	jmp    80106500 <alltraps>

80106c91 <vector27>:
.globl vector27
vector27:
  pushl $0
80106c91:	6a 00                	push   $0x0
  pushl $27
80106c93:	6a 1b                	push   $0x1b
  jmp alltraps
80106c95:	e9 66 f8 ff ff       	jmp    80106500 <alltraps>

80106c9a <vector28>:
.globl vector28
vector28:
  pushl $0
80106c9a:	6a 00                	push   $0x0
  pushl $28
80106c9c:	6a 1c                	push   $0x1c
  jmp alltraps
80106c9e:	e9 5d f8 ff ff       	jmp    80106500 <alltraps>

80106ca3 <vector29>:
.globl vector29
vector29:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $29
80106ca5:	6a 1d                	push   $0x1d
  jmp alltraps
80106ca7:	e9 54 f8 ff ff       	jmp    80106500 <alltraps>

80106cac <vector30>:
.globl vector30
vector30:
  pushl $0
80106cac:	6a 00                	push   $0x0
  pushl $30
80106cae:	6a 1e                	push   $0x1e
  jmp alltraps
80106cb0:	e9 4b f8 ff ff       	jmp    80106500 <alltraps>

80106cb5 <vector31>:
.globl vector31
vector31:
  pushl $0
80106cb5:	6a 00                	push   $0x0
  pushl $31
80106cb7:	6a 1f                	push   $0x1f
  jmp alltraps
80106cb9:	e9 42 f8 ff ff       	jmp    80106500 <alltraps>

80106cbe <vector32>:
.globl vector32
vector32:
  pushl $0
80106cbe:	6a 00                	push   $0x0
  pushl $32
80106cc0:	6a 20                	push   $0x20
  jmp alltraps
80106cc2:	e9 39 f8 ff ff       	jmp    80106500 <alltraps>

80106cc7 <vector33>:
.globl vector33
vector33:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $33
80106cc9:	6a 21                	push   $0x21
  jmp alltraps
80106ccb:	e9 30 f8 ff ff       	jmp    80106500 <alltraps>

80106cd0 <vector34>:
.globl vector34
vector34:
  pushl $0
80106cd0:	6a 00                	push   $0x0
  pushl $34
80106cd2:	6a 22                	push   $0x22
  jmp alltraps
80106cd4:	e9 27 f8 ff ff       	jmp    80106500 <alltraps>

80106cd9 <vector35>:
.globl vector35
vector35:
  pushl $0
80106cd9:	6a 00                	push   $0x0
  pushl $35
80106cdb:	6a 23                	push   $0x23
  jmp alltraps
80106cdd:	e9 1e f8 ff ff       	jmp    80106500 <alltraps>

80106ce2 <vector36>:
.globl vector36
vector36:
  pushl $0
80106ce2:	6a 00                	push   $0x0
  pushl $36
80106ce4:	6a 24                	push   $0x24
  jmp alltraps
80106ce6:	e9 15 f8 ff ff       	jmp    80106500 <alltraps>

80106ceb <vector37>:
.globl vector37
vector37:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $37
80106ced:	6a 25                	push   $0x25
  jmp alltraps
80106cef:	e9 0c f8 ff ff       	jmp    80106500 <alltraps>

80106cf4 <vector38>:
.globl vector38
vector38:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $38
80106cf6:	6a 26                	push   $0x26
  jmp alltraps
80106cf8:	e9 03 f8 ff ff       	jmp    80106500 <alltraps>

80106cfd <vector39>:
.globl vector39
vector39:
  pushl $0
80106cfd:	6a 00                	push   $0x0
  pushl $39
80106cff:	6a 27                	push   $0x27
  jmp alltraps
80106d01:	e9 fa f7 ff ff       	jmp    80106500 <alltraps>

80106d06 <vector40>:
.globl vector40
vector40:
  pushl $0
80106d06:	6a 00                	push   $0x0
  pushl $40
80106d08:	6a 28                	push   $0x28
  jmp alltraps
80106d0a:	e9 f1 f7 ff ff       	jmp    80106500 <alltraps>

80106d0f <vector41>:
.globl vector41
vector41:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $41
80106d11:	6a 29                	push   $0x29
  jmp alltraps
80106d13:	e9 e8 f7 ff ff       	jmp    80106500 <alltraps>

80106d18 <vector42>:
.globl vector42
vector42:
  pushl $0
80106d18:	6a 00                	push   $0x0
  pushl $42
80106d1a:	6a 2a                	push   $0x2a
  jmp alltraps
80106d1c:	e9 df f7 ff ff       	jmp    80106500 <alltraps>

80106d21 <vector43>:
.globl vector43
vector43:
  pushl $0
80106d21:	6a 00                	push   $0x0
  pushl $43
80106d23:	6a 2b                	push   $0x2b
  jmp alltraps
80106d25:	e9 d6 f7 ff ff       	jmp    80106500 <alltraps>

80106d2a <vector44>:
.globl vector44
vector44:
  pushl $0
80106d2a:	6a 00                	push   $0x0
  pushl $44
80106d2c:	6a 2c                	push   $0x2c
  jmp alltraps
80106d2e:	e9 cd f7 ff ff       	jmp    80106500 <alltraps>

80106d33 <vector45>:
.globl vector45
vector45:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $45
80106d35:	6a 2d                	push   $0x2d
  jmp alltraps
80106d37:	e9 c4 f7 ff ff       	jmp    80106500 <alltraps>

80106d3c <vector46>:
.globl vector46
vector46:
  pushl $0
80106d3c:	6a 00                	push   $0x0
  pushl $46
80106d3e:	6a 2e                	push   $0x2e
  jmp alltraps
80106d40:	e9 bb f7 ff ff       	jmp    80106500 <alltraps>

80106d45 <vector47>:
.globl vector47
vector47:
  pushl $0
80106d45:	6a 00                	push   $0x0
  pushl $47
80106d47:	6a 2f                	push   $0x2f
  jmp alltraps
80106d49:	e9 b2 f7 ff ff       	jmp    80106500 <alltraps>

80106d4e <vector48>:
.globl vector48
vector48:
  pushl $0
80106d4e:	6a 00                	push   $0x0
  pushl $48
80106d50:	6a 30                	push   $0x30
  jmp alltraps
80106d52:	e9 a9 f7 ff ff       	jmp    80106500 <alltraps>

80106d57 <vector49>:
.globl vector49
vector49:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $49
80106d59:	6a 31                	push   $0x31
  jmp alltraps
80106d5b:	e9 a0 f7 ff ff       	jmp    80106500 <alltraps>

80106d60 <vector50>:
.globl vector50
vector50:
  pushl $0
80106d60:	6a 00                	push   $0x0
  pushl $50
80106d62:	6a 32                	push   $0x32
  jmp alltraps
80106d64:	e9 97 f7 ff ff       	jmp    80106500 <alltraps>

80106d69 <vector51>:
.globl vector51
vector51:
  pushl $0
80106d69:	6a 00                	push   $0x0
  pushl $51
80106d6b:	6a 33                	push   $0x33
  jmp alltraps
80106d6d:	e9 8e f7 ff ff       	jmp    80106500 <alltraps>

80106d72 <vector52>:
.globl vector52
vector52:
  pushl $0
80106d72:	6a 00                	push   $0x0
  pushl $52
80106d74:	6a 34                	push   $0x34
  jmp alltraps
80106d76:	e9 85 f7 ff ff       	jmp    80106500 <alltraps>

80106d7b <vector53>:
.globl vector53
vector53:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $53
80106d7d:	6a 35                	push   $0x35
  jmp alltraps
80106d7f:	e9 7c f7 ff ff       	jmp    80106500 <alltraps>

80106d84 <vector54>:
.globl vector54
vector54:
  pushl $0
80106d84:	6a 00                	push   $0x0
  pushl $54
80106d86:	6a 36                	push   $0x36
  jmp alltraps
80106d88:	e9 73 f7 ff ff       	jmp    80106500 <alltraps>

80106d8d <vector55>:
.globl vector55
vector55:
  pushl $0
80106d8d:	6a 00                	push   $0x0
  pushl $55
80106d8f:	6a 37                	push   $0x37
  jmp alltraps
80106d91:	e9 6a f7 ff ff       	jmp    80106500 <alltraps>

80106d96 <vector56>:
.globl vector56
vector56:
  pushl $0
80106d96:	6a 00                	push   $0x0
  pushl $56
80106d98:	6a 38                	push   $0x38
  jmp alltraps
80106d9a:	e9 61 f7 ff ff       	jmp    80106500 <alltraps>

80106d9f <vector57>:
.globl vector57
vector57:
  pushl $0
80106d9f:	6a 00                	push   $0x0
  pushl $57
80106da1:	6a 39                	push   $0x39
  jmp alltraps
80106da3:	e9 58 f7 ff ff       	jmp    80106500 <alltraps>

80106da8 <vector58>:
.globl vector58
vector58:
  pushl $0
80106da8:	6a 00                	push   $0x0
  pushl $58
80106daa:	6a 3a                	push   $0x3a
  jmp alltraps
80106dac:	e9 4f f7 ff ff       	jmp    80106500 <alltraps>

80106db1 <vector59>:
.globl vector59
vector59:
  pushl $0
80106db1:	6a 00                	push   $0x0
  pushl $59
80106db3:	6a 3b                	push   $0x3b
  jmp alltraps
80106db5:	e9 46 f7 ff ff       	jmp    80106500 <alltraps>

80106dba <vector60>:
.globl vector60
vector60:
  pushl $0
80106dba:	6a 00                	push   $0x0
  pushl $60
80106dbc:	6a 3c                	push   $0x3c
  jmp alltraps
80106dbe:	e9 3d f7 ff ff       	jmp    80106500 <alltraps>

80106dc3 <vector61>:
.globl vector61
vector61:
  pushl $0
80106dc3:	6a 00                	push   $0x0
  pushl $61
80106dc5:	6a 3d                	push   $0x3d
  jmp alltraps
80106dc7:	e9 34 f7 ff ff       	jmp    80106500 <alltraps>

80106dcc <vector62>:
.globl vector62
vector62:
  pushl $0
80106dcc:	6a 00                	push   $0x0
  pushl $62
80106dce:	6a 3e                	push   $0x3e
  jmp alltraps
80106dd0:	e9 2b f7 ff ff       	jmp    80106500 <alltraps>

80106dd5 <vector63>:
.globl vector63
vector63:
  pushl $0
80106dd5:	6a 00                	push   $0x0
  pushl $63
80106dd7:	6a 3f                	push   $0x3f
  jmp alltraps
80106dd9:	e9 22 f7 ff ff       	jmp    80106500 <alltraps>

80106dde <vector64>:
.globl vector64
vector64:
  pushl $0
80106dde:	6a 00                	push   $0x0
  pushl $64
80106de0:	6a 40                	push   $0x40
  jmp alltraps
80106de2:	e9 19 f7 ff ff       	jmp    80106500 <alltraps>

80106de7 <vector65>:
.globl vector65
vector65:
  pushl $0
80106de7:	6a 00                	push   $0x0
  pushl $65
80106de9:	6a 41                	push   $0x41
  jmp alltraps
80106deb:	e9 10 f7 ff ff       	jmp    80106500 <alltraps>

80106df0 <vector66>:
.globl vector66
vector66:
  pushl $0
80106df0:	6a 00                	push   $0x0
  pushl $66
80106df2:	6a 42                	push   $0x42
  jmp alltraps
80106df4:	e9 07 f7 ff ff       	jmp    80106500 <alltraps>

80106df9 <vector67>:
.globl vector67
vector67:
  pushl $0
80106df9:	6a 00                	push   $0x0
  pushl $67
80106dfb:	6a 43                	push   $0x43
  jmp alltraps
80106dfd:	e9 fe f6 ff ff       	jmp    80106500 <alltraps>

80106e02 <vector68>:
.globl vector68
vector68:
  pushl $0
80106e02:	6a 00                	push   $0x0
  pushl $68
80106e04:	6a 44                	push   $0x44
  jmp alltraps
80106e06:	e9 f5 f6 ff ff       	jmp    80106500 <alltraps>

80106e0b <vector69>:
.globl vector69
vector69:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $69
80106e0d:	6a 45                	push   $0x45
  jmp alltraps
80106e0f:	e9 ec f6 ff ff       	jmp    80106500 <alltraps>

80106e14 <vector70>:
.globl vector70
vector70:
  pushl $0
80106e14:	6a 00                	push   $0x0
  pushl $70
80106e16:	6a 46                	push   $0x46
  jmp alltraps
80106e18:	e9 e3 f6 ff ff       	jmp    80106500 <alltraps>

80106e1d <vector71>:
.globl vector71
vector71:
  pushl $0
80106e1d:	6a 00                	push   $0x0
  pushl $71
80106e1f:	6a 47                	push   $0x47
  jmp alltraps
80106e21:	e9 da f6 ff ff       	jmp    80106500 <alltraps>

80106e26 <vector72>:
.globl vector72
vector72:
  pushl $0
80106e26:	6a 00                	push   $0x0
  pushl $72
80106e28:	6a 48                	push   $0x48
  jmp alltraps
80106e2a:	e9 d1 f6 ff ff       	jmp    80106500 <alltraps>

80106e2f <vector73>:
.globl vector73
vector73:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $73
80106e31:	6a 49                	push   $0x49
  jmp alltraps
80106e33:	e9 c8 f6 ff ff       	jmp    80106500 <alltraps>

80106e38 <vector74>:
.globl vector74
vector74:
  pushl $0
80106e38:	6a 00                	push   $0x0
  pushl $74
80106e3a:	6a 4a                	push   $0x4a
  jmp alltraps
80106e3c:	e9 bf f6 ff ff       	jmp    80106500 <alltraps>

80106e41 <vector75>:
.globl vector75
vector75:
  pushl $0
80106e41:	6a 00                	push   $0x0
  pushl $75
80106e43:	6a 4b                	push   $0x4b
  jmp alltraps
80106e45:	e9 b6 f6 ff ff       	jmp    80106500 <alltraps>

80106e4a <vector76>:
.globl vector76
vector76:
  pushl $0
80106e4a:	6a 00                	push   $0x0
  pushl $76
80106e4c:	6a 4c                	push   $0x4c
  jmp alltraps
80106e4e:	e9 ad f6 ff ff       	jmp    80106500 <alltraps>

80106e53 <vector77>:
.globl vector77
vector77:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $77
80106e55:	6a 4d                	push   $0x4d
  jmp alltraps
80106e57:	e9 a4 f6 ff ff       	jmp    80106500 <alltraps>

80106e5c <vector78>:
.globl vector78
vector78:
  pushl $0
80106e5c:	6a 00                	push   $0x0
  pushl $78
80106e5e:	6a 4e                	push   $0x4e
  jmp alltraps
80106e60:	e9 9b f6 ff ff       	jmp    80106500 <alltraps>

80106e65 <vector79>:
.globl vector79
vector79:
  pushl $0
80106e65:	6a 00                	push   $0x0
  pushl $79
80106e67:	6a 4f                	push   $0x4f
  jmp alltraps
80106e69:	e9 92 f6 ff ff       	jmp    80106500 <alltraps>

80106e6e <vector80>:
.globl vector80
vector80:
  pushl $0
80106e6e:	6a 00                	push   $0x0
  pushl $80
80106e70:	6a 50                	push   $0x50
  jmp alltraps
80106e72:	e9 89 f6 ff ff       	jmp    80106500 <alltraps>

80106e77 <vector81>:
.globl vector81
vector81:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $81
80106e79:	6a 51                	push   $0x51
  jmp alltraps
80106e7b:	e9 80 f6 ff ff       	jmp    80106500 <alltraps>

80106e80 <vector82>:
.globl vector82
vector82:
  pushl $0
80106e80:	6a 00                	push   $0x0
  pushl $82
80106e82:	6a 52                	push   $0x52
  jmp alltraps
80106e84:	e9 77 f6 ff ff       	jmp    80106500 <alltraps>

80106e89 <vector83>:
.globl vector83
vector83:
  pushl $0
80106e89:	6a 00                	push   $0x0
  pushl $83
80106e8b:	6a 53                	push   $0x53
  jmp alltraps
80106e8d:	e9 6e f6 ff ff       	jmp    80106500 <alltraps>

80106e92 <vector84>:
.globl vector84
vector84:
  pushl $0
80106e92:	6a 00                	push   $0x0
  pushl $84
80106e94:	6a 54                	push   $0x54
  jmp alltraps
80106e96:	e9 65 f6 ff ff       	jmp    80106500 <alltraps>

80106e9b <vector85>:
.globl vector85
vector85:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $85
80106e9d:	6a 55                	push   $0x55
  jmp alltraps
80106e9f:	e9 5c f6 ff ff       	jmp    80106500 <alltraps>

80106ea4 <vector86>:
.globl vector86
vector86:
  pushl $0
80106ea4:	6a 00                	push   $0x0
  pushl $86
80106ea6:	6a 56                	push   $0x56
  jmp alltraps
80106ea8:	e9 53 f6 ff ff       	jmp    80106500 <alltraps>

80106ead <vector87>:
.globl vector87
vector87:
  pushl $0
80106ead:	6a 00                	push   $0x0
  pushl $87
80106eaf:	6a 57                	push   $0x57
  jmp alltraps
80106eb1:	e9 4a f6 ff ff       	jmp    80106500 <alltraps>

80106eb6 <vector88>:
.globl vector88
vector88:
  pushl $0
80106eb6:	6a 00                	push   $0x0
  pushl $88
80106eb8:	6a 58                	push   $0x58
  jmp alltraps
80106eba:	e9 41 f6 ff ff       	jmp    80106500 <alltraps>

80106ebf <vector89>:
.globl vector89
vector89:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $89
80106ec1:	6a 59                	push   $0x59
  jmp alltraps
80106ec3:	e9 38 f6 ff ff       	jmp    80106500 <alltraps>

80106ec8 <vector90>:
.globl vector90
vector90:
  pushl $0
80106ec8:	6a 00                	push   $0x0
  pushl $90
80106eca:	6a 5a                	push   $0x5a
  jmp alltraps
80106ecc:	e9 2f f6 ff ff       	jmp    80106500 <alltraps>

80106ed1 <vector91>:
.globl vector91
vector91:
  pushl $0
80106ed1:	6a 00                	push   $0x0
  pushl $91
80106ed3:	6a 5b                	push   $0x5b
  jmp alltraps
80106ed5:	e9 26 f6 ff ff       	jmp    80106500 <alltraps>

80106eda <vector92>:
.globl vector92
vector92:
  pushl $0
80106eda:	6a 00                	push   $0x0
  pushl $92
80106edc:	6a 5c                	push   $0x5c
  jmp alltraps
80106ede:	e9 1d f6 ff ff       	jmp    80106500 <alltraps>

80106ee3 <vector93>:
.globl vector93
vector93:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $93
80106ee5:	6a 5d                	push   $0x5d
  jmp alltraps
80106ee7:	e9 14 f6 ff ff       	jmp    80106500 <alltraps>

80106eec <vector94>:
.globl vector94
vector94:
  pushl $0
80106eec:	6a 00                	push   $0x0
  pushl $94
80106eee:	6a 5e                	push   $0x5e
  jmp alltraps
80106ef0:	e9 0b f6 ff ff       	jmp    80106500 <alltraps>

80106ef5 <vector95>:
.globl vector95
vector95:
  pushl $0
80106ef5:	6a 00                	push   $0x0
  pushl $95
80106ef7:	6a 5f                	push   $0x5f
  jmp alltraps
80106ef9:	e9 02 f6 ff ff       	jmp    80106500 <alltraps>

80106efe <vector96>:
.globl vector96
vector96:
  pushl $0
80106efe:	6a 00                	push   $0x0
  pushl $96
80106f00:	6a 60                	push   $0x60
  jmp alltraps
80106f02:	e9 f9 f5 ff ff       	jmp    80106500 <alltraps>

80106f07 <vector97>:
.globl vector97
vector97:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $97
80106f09:	6a 61                	push   $0x61
  jmp alltraps
80106f0b:	e9 f0 f5 ff ff       	jmp    80106500 <alltraps>

80106f10 <vector98>:
.globl vector98
vector98:
  pushl $0
80106f10:	6a 00                	push   $0x0
  pushl $98
80106f12:	6a 62                	push   $0x62
  jmp alltraps
80106f14:	e9 e7 f5 ff ff       	jmp    80106500 <alltraps>

80106f19 <vector99>:
.globl vector99
vector99:
  pushl $0
80106f19:	6a 00                	push   $0x0
  pushl $99
80106f1b:	6a 63                	push   $0x63
  jmp alltraps
80106f1d:	e9 de f5 ff ff       	jmp    80106500 <alltraps>

80106f22 <vector100>:
.globl vector100
vector100:
  pushl $0
80106f22:	6a 00                	push   $0x0
  pushl $100
80106f24:	6a 64                	push   $0x64
  jmp alltraps
80106f26:	e9 d5 f5 ff ff       	jmp    80106500 <alltraps>

80106f2b <vector101>:
.globl vector101
vector101:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $101
80106f2d:	6a 65                	push   $0x65
  jmp alltraps
80106f2f:	e9 cc f5 ff ff       	jmp    80106500 <alltraps>

80106f34 <vector102>:
.globl vector102
vector102:
  pushl $0
80106f34:	6a 00                	push   $0x0
  pushl $102
80106f36:	6a 66                	push   $0x66
  jmp alltraps
80106f38:	e9 c3 f5 ff ff       	jmp    80106500 <alltraps>

80106f3d <vector103>:
.globl vector103
vector103:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $103
80106f3f:	6a 67                	push   $0x67
  jmp alltraps
80106f41:	e9 ba f5 ff ff       	jmp    80106500 <alltraps>

80106f46 <vector104>:
.globl vector104
vector104:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $104
80106f48:	6a 68                	push   $0x68
  jmp alltraps
80106f4a:	e9 b1 f5 ff ff       	jmp    80106500 <alltraps>

80106f4f <vector105>:
.globl vector105
vector105:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $105
80106f51:	6a 69                	push   $0x69
  jmp alltraps
80106f53:	e9 a8 f5 ff ff       	jmp    80106500 <alltraps>

80106f58 <vector106>:
.globl vector106
vector106:
  pushl $0
80106f58:	6a 00                	push   $0x0
  pushl $106
80106f5a:	6a 6a                	push   $0x6a
  jmp alltraps
80106f5c:	e9 9f f5 ff ff       	jmp    80106500 <alltraps>

80106f61 <vector107>:
.globl vector107
vector107:
  pushl $0
80106f61:	6a 00                	push   $0x0
  pushl $107
80106f63:	6a 6b                	push   $0x6b
  jmp alltraps
80106f65:	e9 96 f5 ff ff       	jmp    80106500 <alltraps>

80106f6a <vector108>:
.globl vector108
vector108:
  pushl $0
80106f6a:	6a 00                	push   $0x0
  pushl $108
80106f6c:	6a 6c                	push   $0x6c
  jmp alltraps
80106f6e:	e9 8d f5 ff ff       	jmp    80106500 <alltraps>

80106f73 <vector109>:
.globl vector109
vector109:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $109
80106f75:	6a 6d                	push   $0x6d
  jmp alltraps
80106f77:	e9 84 f5 ff ff       	jmp    80106500 <alltraps>

80106f7c <vector110>:
.globl vector110
vector110:
  pushl $0
80106f7c:	6a 00                	push   $0x0
  pushl $110
80106f7e:	6a 6e                	push   $0x6e
  jmp alltraps
80106f80:	e9 7b f5 ff ff       	jmp    80106500 <alltraps>

80106f85 <vector111>:
.globl vector111
vector111:
  pushl $0
80106f85:	6a 00                	push   $0x0
  pushl $111
80106f87:	6a 6f                	push   $0x6f
  jmp alltraps
80106f89:	e9 72 f5 ff ff       	jmp    80106500 <alltraps>

80106f8e <vector112>:
.globl vector112
vector112:
  pushl $0
80106f8e:	6a 00                	push   $0x0
  pushl $112
80106f90:	6a 70                	push   $0x70
  jmp alltraps
80106f92:	e9 69 f5 ff ff       	jmp    80106500 <alltraps>

80106f97 <vector113>:
.globl vector113
vector113:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $113
80106f99:	6a 71                	push   $0x71
  jmp alltraps
80106f9b:	e9 60 f5 ff ff       	jmp    80106500 <alltraps>

80106fa0 <vector114>:
.globl vector114
vector114:
  pushl $0
80106fa0:	6a 00                	push   $0x0
  pushl $114
80106fa2:	6a 72                	push   $0x72
  jmp alltraps
80106fa4:	e9 57 f5 ff ff       	jmp    80106500 <alltraps>

80106fa9 <vector115>:
.globl vector115
vector115:
  pushl $0
80106fa9:	6a 00                	push   $0x0
  pushl $115
80106fab:	6a 73                	push   $0x73
  jmp alltraps
80106fad:	e9 4e f5 ff ff       	jmp    80106500 <alltraps>

80106fb2 <vector116>:
.globl vector116
vector116:
  pushl $0
80106fb2:	6a 00                	push   $0x0
  pushl $116
80106fb4:	6a 74                	push   $0x74
  jmp alltraps
80106fb6:	e9 45 f5 ff ff       	jmp    80106500 <alltraps>

80106fbb <vector117>:
.globl vector117
vector117:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $117
80106fbd:	6a 75                	push   $0x75
  jmp alltraps
80106fbf:	e9 3c f5 ff ff       	jmp    80106500 <alltraps>

80106fc4 <vector118>:
.globl vector118
vector118:
  pushl $0
80106fc4:	6a 00                	push   $0x0
  pushl $118
80106fc6:	6a 76                	push   $0x76
  jmp alltraps
80106fc8:	e9 33 f5 ff ff       	jmp    80106500 <alltraps>

80106fcd <vector119>:
.globl vector119
vector119:
  pushl $0
80106fcd:	6a 00                	push   $0x0
  pushl $119
80106fcf:	6a 77                	push   $0x77
  jmp alltraps
80106fd1:	e9 2a f5 ff ff       	jmp    80106500 <alltraps>

80106fd6 <vector120>:
.globl vector120
vector120:
  pushl $0
80106fd6:	6a 00                	push   $0x0
  pushl $120
80106fd8:	6a 78                	push   $0x78
  jmp alltraps
80106fda:	e9 21 f5 ff ff       	jmp    80106500 <alltraps>

80106fdf <vector121>:
.globl vector121
vector121:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $121
80106fe1:	6a 79                	push   $0x79
  jmp alltraps
80106fe3:	e9 18 f5 ff ff       	jmp    80106500 <alltraps>

80106fe8 <vector122>:
.globl vector122
vector122:
  pushl $0
80106fe8:	6a 00                	push   $0x0
  pushl $122
80106fea:	6a 7a                	push   $0x7a
  jmp alltraps
80106fec:	e9 0f f5 ff ff       	jmp    80106500 <alltraps>

80106ff1 <vector123>:
.globl vector123
vector123:
  pushl $0
80106ff1:	6a 00                	push   $0x0
  pushl $123
80106ff3:	6a 7b                	push   $0x7b
  jmp alltraps
80106ff5:	e9 06 f5 ff ff       	jmp    80106500 <alltraps>

80106ffa <vector124>:
.globl vector124
vector124:
  pushl $0
80106ffa:	6a 00                	push   $0x0
  pushl $124
80106ffc:	6a 7c                	push   $0x7c
  jmp alltraps
80106ffe:	e9 fd f4 ff ff       	jmp    80106500 <alltraps>

80107003 <vector125>:
.globl vector125
vector125:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $125
80107005:	6a 7d                	push   $0x7d
  jmp alltraps
80107007:	e9 f4 f4 ff ff       	jmp    80106500 <alltraps>

8010700c <vector126>:
.globl vector126
vector126:
  pushl $0
8010700c:	6a 00                	push   $0x0
  pushl $126
8010700e:	6a 7e                	push   $0x7e
  jmp alltraps
80107010:	e9 eb f4 ff ff       	jmp    80106500 <alltraps>

80107015 <vector127>:
.globl vector127
vector127:
  pushl $0
80107015:	6a 00                	push   $0x0
  pushl $127
80107017:	6a 7f                	push   $0x7f
  jmp alltraps
80107019:	e9 e2 f4 ff ff       	jmp    80106500 <alltraps>

8010701e <vector128>:
.globl vector128
vector128:
  pushl $0
8010701e:	6a 00                	push   $0x0
  pushl $128
80107020:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107025:	e9 d6 f4 ff ff       	jmp    80106500 <alltraps>

8010702a <vector129>:
.globl vector129
vector129:
  pushl $0
8010702a:	6a 00                	push   $0x0
  pushl $129
8010702c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107031:	e9 ca f4 ff ff       	jmp    80106500 <alltraps>

80107036 <vector130>:
.globl vector130
vector130:
  pushl $0
80107036:	6a 00                	push   $0x0
  pushl $130
80107038:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010703d:	e9 be f4 ff ff       	jmp    80106500 <alltraps>

80107042 <vector131>:
.globl vector131
vector131:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $131
80107044:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107049:	e9 b2 f4 ff ff       	jmp    80106500 <alltraps>

8010704e <vector132>:
.globl vector132
vector132:
  pushl $0
8010704e:	6a 00                	push   $0x0
  pushl $132
80107050:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107055:	e9 a6 f4 ff ff       	jmp    80106500 <alltraps>

8010705a <vector133>:
.globl vector133
vector133:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $133
8010705c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107061:	e9 9a f4 ff ff       	jmp    80106500 <alltraps>

80107066 <vector134>:
.globl vector134
vector134:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $134
80107068:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010706d:	e9 8e f4 ff ff       	jmp    80106500 <alltraps>

80107072 <vector135>:
.globl vector135
vector135:
  pushl $0
80107072:	6a 00                	push   $0x0
  pushl $135
80107074:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107079:	e9 82 f4 ff ff       	jmp    80106500 <alltraps>

8010707e <vector136>:
.globl vector136
vector136:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $136
80107080:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107085:	e9 76 f4 ff ff       	jmp    80106500 <alltraps>

8010708a <vector137>:
.globl vector137
vector137:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $137
8010708c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107091:	e9 6a f4 ff ff       	jmp    80106500 <alltraps>

80107096 <vector138>:
.globl vector138
vector138:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $138
80107098:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010709d:	e9 5e f4 ff ff       	jmp    80106500 <alltraps>

801070a2 <vector139>:
.globl vector139
vector139:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $139
801070a4:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801070a9:	e9 52 f4 ff ff       	jmp    80106500 <alltraps>

801070ae <vector140>:
.globl vector140
vector140:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $140
801070b0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801070b5:	e9 46 f4 ff ff       	jmp    80106500 <alltraps>

801070ba <vector141>:
.globl vector141
vector141:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $141
801070bc:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801070c1:	e9 3a f4 ff ff       	jmp    80106500 <alltraps>

801070c6 <vector142>:
.globl vector142
vector142:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $142
801070c8:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801070cd:	e9 2e f4 ff ff       	jmp    80106500 <alltraps>

801070d2 <vector143>:
.globl vector143
vector143:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $143
801070d4:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801070d9:	e9 22 f4 ff ff       	jmp    80106500 <alltraps>

801070de <vector144>:
.globl vector144
vector144:
  pushl $0
801070de:	6a 00                	push   $0x0
  pushl $144
801070e0:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801070e5:	e9 16 f4 ff ff       	jmp    80106500 <alltraps>

801070ea <vector145>:
.globl vector145
vector145:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $145
801070ec:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801070f1:	e9 0a f4 ff ff       	jmp    80106500 <alltraps>

801070f6 <vector146>:
.globl vector146
vector146:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $146
801070f8:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801070fd:	e9 fe f3 ff ff       	jmp    80106500 <alltraps>

80107102 <vector147>:
.globl vector147
vector147:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $147
80107104:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107109:	e9 f2 f3 ff ff       	jmp    80106500 <alltraps>

8010710e <vector148>:
.globl vector148
vector148:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $148
80107110:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107115:	e9 e6 f3 ff ff       	jmp    80106500 <alltraps>

8010711a <vector149>:
.globl vector149
vector149:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $149
8010711c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107121:	e9 da f3 ff ff       	jmp    80106500 <alltraps>

80107126 <vector150>:
.globl vector150
vector150:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $150
80107128:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010712d:	e9 ce f3 ff ff       	jmp    80106500 <alltraps>

80107132 <vector151>:
.globl vector151
vector151:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $151
80107134:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107139:	e9 c2 f3 ff ff       	jmp    80106500 <alltraps>

8010713e <vector152>:
.globl vector152
vector152:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $152
80107140:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107145:	e9 b6 f3 ff ff       	jmp    80106500 <alltraps>

8010714a <vector153>:
.globl vector153
vector153:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $153
8010714c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107151:	e9 aa f3 ff ff       	jmp    80106500 <alltraps>

80107156 <vector154>:
.globl vector154
vector154:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $154
80107158:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010715d:	e9 9e f3 ff ff       	jmp    80106500 <alltraps>

80107162 <vector155>:
.globl vector155
vector155:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $155
80107164:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107169:	e9 92 f3 ff ff       	jmp    80106500 <alltraps>

8010716e <vector156>:
.globl vector156
vector156:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $156
80107170:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107175:	e9 86 f3 ff ff       	jmp    80106500 <alltraps>

8010717a <vector157>:
.globl vector157
vector157:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $157
8010717c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107181:	e9 7a f3 ff ff       	jmp    80106500 <alltraps>

80107186 <vector158>:
.globl vector158
vector158:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $158
80107188:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010718d:	e9 6e f3 ff ff       	jmp    80106500 <alltraps>

80107192 <vector159>:
.globl vector159
vector159:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $159
80107194:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107199:	e9 62 f3 ff ff       	jmp    80106500 <alltraps>

8010719e <vector160>:
.globl vector160
vector160:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $160
801071a0:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801071a5:	e9 56 f3 ff ff       	jmp    80106500 <alltraps>

801071aa <vector161>:
.globl vector161
vector161:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $161
801071ac:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801071b1:	e9 4a f3 ff ff       	jmp    80106500 <alltraps>

801071b6 <vector162>:
.globl vector162
vector162:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $162
801071b8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801071bd:	e9 3e f3 ff ff       	jmp    80106500 <alltraps>

801071c2 <vector163>:
.globl vector163
vector163:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $163
801071c4:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801071c9:	e9 32 f3 ff ff       	jmp    80106500 <alltraps>

801071ce <vector164>:
.globl vector164
vector164:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $164
801071d0:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801071d5:	e9 26 f3 ff ff       	jmp    80106500 <alltraps>

801071da <vector165>:
.globl vector165
vector165:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $165
801071dc:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801071e1:	e9 1a f3 ff ff       	jmp    80106500 <alltraps>

801071e6 <vector166>:
.globl vector166
vector166:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $166
801071e8:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801071ed:	e9 0e f3 ff ff       	jmp    80106500 <alltraps>

801071f2 <vector167>:
.globl vector167
vector167:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $167
801071f4:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801071f9:	e9 02 f3 ff ff       	jmp    80106500 <alltraps>

801071fe <vector168>:
.globl vector168
vector168:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $168
80107200:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107205:	e9 f6 f2 ff ff       	jmp    80106500 <alltraps>

8010720a <vector169>:
.globl vector169
vector169:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $169
8010720c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107211:	e9 ea f2 ff ff       	jmp    80106500 <alltraps>

80107216 <vector170>:
.globl vector170
vector170:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $170
80107218:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010721d:	e9 de f2 ff ff       	jmp    80106500 <alltraps>

80107222 <vector171>:
.globl vector171
vector171:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $171
80107224:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107229:	e9 d2 f2 ff ff       	jmp    80106500 <alltraps>

8010722e <vector172>:
.globl vector172
vector172:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $172
80107230:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107235:	e9 c6 f2 ff ff       	jmp    80106500 <alltraps>

8010723a <vector173>:
.globl vector173
vector173:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $173
8010723c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107241:	e9 ba f2 ff ff       	jmp    80106500 <alltraps>

80107246 <vector174>:
.globl vector174
vector174:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $174
80107248:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010724d:	e9 ae f2 ff ff       	jmp    80106500 <alltraps>

80107252 <vector175>:
.globl vector175
vector175:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $175
80107254:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107259:	e9 a2 f2 ff ff       	jmp    80106500 <alltraps>

8010725e <vector176>:
.globl vector176
vector176:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $176
80107260:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107265:	e9 96 f2 ff ff       	jmp    80106500 <alltraps>

8010726a <vector177>:
.globl vector177
vector177:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $177
8010726c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107271:	e9 8a f2 ff ff       	jmp    80106500 <alltraps>

80107276 <vector178>:
.globl vector178
vector178:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $178
80107278:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010727d:	e9 7e f2 ff ff       	jmp    80106500 <alltraps>

80107282 <vector179>:
.globl vector179
vector179:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $179
80107284:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107289:	e9 72 f2 ff ff       	jmp    80106500 <alltraps>

8010728e <vector180>:
.globl vector180
vector180:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $180
80107290:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107295:	e9 66 f2 ff ff       	jmp    80106500 <alltraps>

8010729a <vector181>:
.globl vector181
vector181:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $181
8010729c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801072a1:	e9 5a f2 ff ff       	jmp    80106500 <alltraps>

801072a6 <vector182>:
.globl vector182
vector182:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $182
801072a8:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801072ad:	e9 4e f2 ff ff       	jmp    80106500 <alltraps>

801072b2 <vector183>:
.globl vector183
vector183:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $183
801072b4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801072b9:	e9 42 f2 ff ff       	jmp    80106500 <alltraps>

801072be <vector184>:
.globl vector184
vector184:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $184
801072c0:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801072c5:	e9 36 f2 ff ff       	jmp    80106500 <alltraps>

801072ca <vector185>:
.globl vector185
vector185:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $185
801072cc:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801072d1:	e9 2a f2 ff ff       	jmp    80106500 <alltraps>

801072d6 <vector186>:
.globl vector186
vector186:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $186
801072d8:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801072dd:	e9 1e f2 ff ff       	jmp    80106500 <alltraps>

801072e2 <vector187>:
.globl vector187
vector187:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $187
801072e4:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801072e9:	e9 12 f2 ff ff       	jmp    80106500 <alltraps>

801072ee <vector188>:
.globl vector188
vector188:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $188
801072f0:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801072f5:	e9 06 f2 ff ff       	jmp    80106500 <alltraps>

801072fa <vector189>:
.globl vector189
vector189:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $189
801072fc:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107301:	e9 fa f1 ff ff       	jmp    80106500 <alltraps>

80107306 <vector190>:
.globl vector190
vector190:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $190
80107308:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010730d:	e9 ee f1 ff ff       	jmp    80106500 <alltraps>

80107312 <vector191>:
.globl vector191
vector191:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $191
80107314:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107319:	e9 e2 f1 ff ff       	jmp    80106500 <alltraps>

8010731e <vector192>:
.globl vector192
vector192:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $192
80107320:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107325:	e9 d6 f1 ff ff       	jmp    80106500 <alltraps>

8010732a <vector193>:
.globl vector193
vector193:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $193
8010732c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107331:	e9 ca f1 ff ff       	jmp    80106500 <alltraps>

80107336 <vector194>:
.globl vector194
vector194:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $194
80107338:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010733d:	e9 be f1 ff ff       	jmp    80106500 <alltraps>

80107342 <vector195>:
.globl vector195
vector195:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $195
80107344:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107349:	e9 b2 f1 ff ff       	jmp    80106500 <alltraps>

8010734e <vector196>:
.globl vector196
vector196:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $196
80107350:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107355:	e9 a6 f1 ff ff       	jmp    80106500 <alltraps>

8010735a <vector197>:
.globl vector197
vector197:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $197
8010735c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107361:	e9 9a f1 ff ff       	jmp    80106500 <alltraps>

80107366 <vector198>:
.globl vector198
vector198:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $198
80107368:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010736d:	e9 8e f1 ff ff       	jmp    80106500 <alltraps>

80107372 <vector199>:
.globl vector199
vector199:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $199
80107374:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107379:	e9 82 f1 ff ff       	jmp    80106500 <alltraps>

8010737e <vector200>:
.globl vector200
vector200:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $200
80107380:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107385:	e9 76 f1 ff ff       	jmp    80106500 <alltraps>

8010738a <vector201>:
.globl vector201
vector201:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $201
8010738c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107391:	e9 6a f1 ff ff       	jmp    80106500 <alltraps>

80107396 <vector202>:
.globl vector202
vector202:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $202
80107398:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010739d:	e9 5e f1 ff ff       	jmp    80106500 <alltraps>

801073a2 <vector203>:
.globl vector203
vector203:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $203
801073a4:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801073a9:	e9 52 f1 ff ff       	jmp    80106500 <alltraps>

801073ae <vector204>:
.globl vector204
vector204:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $204
801073b0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801073b5:	e9 46 f1 ff ff       	jmp    80106500 <alltraps>

801073ba <vector205>:
.globl vector205
vector205:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $205
801073bc:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801073c1:	e9 3a f1 ff ff       	jmp    80106500 <alltraps>

801073c6 <vector206>:
.globl vector206
vector206:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $206
801073c8:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801073cd:	e9 2e f1 ff ff       	jmp    80106500 <alltraps>

801073d2 <vector207>:
.globl vector207
vector207:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $207
801073d4:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801073d9:	e9 22 f1 ff ff       	jmp    80106500 <alltraps>

801073de <vector208>:
.globl vector208
vector208:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $208
801073e0:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801073e5:	e9 16 f1 ff ff       	jmp    80106500 <alltraps>

801073ea <vector209>:
.globl vector209
vector209:
  pushl $0
801073ea:	6a 00                	push   $0x0
  pushl $209
801073ec:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801073f1:	e9 0a f1 ff ff       	jmp    80106500 <alltraps>

801073f6 <vector210>:
.globl vector210
vector210:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $210
801073f8:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801073fd:	e9 fe f0 ff ff       	jmp    80106500 <alltraps>

80107402 <vector211>:
.globl vector211
vector211:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $211
80107404:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107409:	e9 f2 f0 ff ff       	jmp    80106500 <alltraps>

8010740e <vector212>:
.globl vector212
vector212:
  pushl $0
8010740e:	6a 00                	push   $0x0
  pushl $212
80107410:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107415:	e9 e6 f0 ff ff       	jmp    80106500 <alltraps>

8010741a <vector213>:
.globl vector213
vector213:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $213
8010741c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107421:	e9 da f0 ff ff       	jmp    80106500 <alltraps>

80107426 <vector214>:
.globl vector214
vector214:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $214
80107428:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010742d:	e9 ce f0 ff ff       	jmp    80106500 <alltraps>

80107432 <vector215>:
.globl vector215
vector215:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $215
80107434:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107439:	e9 c2 f0 ff ff       	jmp    80106500 <alltraps>

8010743e <vector216>:
.globl vector216
vector216:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $216
80107440:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107445:	e9 b6 f0 ff ff       	jmp    80106500 <alltraps>

8010744a <vector217>:
.globl vector217
vector217:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $217
8010744c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107451:	e9 aa f0 ff ff       	jmp    80106500 <alltraps>

80107456 <vector218>:
.globl vector218
vector218:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $218
80107458:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010745d:	e9 9e f0 ff ff       	jmp    80106500 <alltraps>

80107462 <vector219>:
.globl vector219
vector219:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $219
80107464:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107469:	e9 92 f0 ff ff       	jmp    80106500 <alltraps>

8010746e <vector220>:
.globl vector220
vector220:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $220
80107470:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107475:	e9 86 f0 ff ff       	jmp    80106500 <alltraps>

8010747a <vector221>:
.globl vector221
vector221:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $221
8010747c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107481:	e9 7a f0 ff ff       	jmp    80106500 <alltraps>

80107486 <vector222>:
.globl vector222
vector222:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $222
80107488:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010748d:	e9 6e f0 ff ff       	jmp    80106500 <alltraps>

80107492 <vector223>:
.globl vector223
vector223:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $223
80107494:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107499:	e9 62 f0 ff ff       	jmp    80106500 <alltraps>

8010749e <vector224>:
.globl vector224
vector224:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $224
801074a0:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801074a5:	e9 56 f0 ff ff       	jmp    80106500 <alltraps>

801074aa <vector225>:
.globl vector225
vector225:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $225
801074ac:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801074b1:	e9 4a f0 ff ff       	jmp    80106500 <alltraps>

801074b6 <vector226>:
.globl vector226
vector226:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $226
801074b8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801074bd:	e9 3e f0 ff ff       	jmp    80106500 <alltraps>

801074c2 <vector227>:
.globl vector227
vector227:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $227
801074c4:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801074c9:	e9 32 f0 ff ff       	jmp    80106500 <alltraps>

801074ce <vector228>:
.globl vector228
vector228:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $228
801074d0:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801074d5:	e9 26 f0 ff ff       	jmp    80106500 <alltraps>

801074da <vector229>:
.globl vector229
vector229:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $229
801074dc:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801074e1:	e9 1a f0 ff ff       	jmp    80106500 <alltraps>

801074e6 <vector230>:
.globl vector230
vector230:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $230
801074e8:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801074ed:	e9 0e f0 ff ff       	jmp    80106500 <alltraps>

801074f2 <vector231>:
.globl vector231
vector231:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $231
801074f4:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801074f9:	e9 02 f0 ff ff       	jmp    80106500 <alltraps>

801074fe <vector232>:
.globl vector232
vector232:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $232
80107500:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107505:	e9 f6 ef ff ff       	jmp    80106500 <alltraps>

8010750a <vector233>:
.globl vector233
vector233:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $233
8010750c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107511:	e9 ea ef ff ff       	jmp    80106500 <alltraps>

80107516 <vector234>:
.globl vector234
vector234:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $234
80107518:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010751d:	e9 de ef ff ff       	jmp    80106500 <alltraps>

80107522 <vector235>:
.globl vector235
vector235:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $235
80107524:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107529:	e9 d2 ef ff ff       	jmp    80106500 <alltraps>

8010752e <vector236>:
.globl vector236
vector236:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $236
80107530:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107535:	e9 c6 ef ff ff       	jmp    80106500 <alltraps>

8010753a <vector237>:
.globl vector237
vector237:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $237
8010753c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107541:	e9 ba ef ff ff       	jmp    80106500 <alltraps>

80107546 <vector238>:
.globl vector238
vector238:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $238
80107548:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010754d:	e9 ae ef ff ff       	jmp    80106500 <alltraps>

80107552 <vector239>:
.globl vector239
vector239:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $239
80107554:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107559:	e9 a2 ef ff ff       	jmp    80106500 <alltraps>

8010755e <vector240>:
.globl vector240
vector240:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $240
80107560:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107565:	e9 96 ef ff ff       	jmp    80106500 <alltraps>

8010756a <vector241>:
.globl vector241
vector241:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $241
8010756c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107571:	e9 8a ef ff ff       	jmp    80106500 <alltraps>

80107576 <vector242>:
.globl vector242
vector242:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $242
80107578:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010757d:	e9 7e ef ff ff       	jmp    80106500 <alltraps>

80107582 <vector243>:
.globl vector243
vector243:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $243
80107584:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107589:	e9 72 ef ff ff       	jmp    80106500 <alltraps>

8010758e <vector244>:
.globl vector244
vector244:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $244
80107590:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107595:	e9 66 ef ff ff       	jmp    80106500 <alltraps>

8010759a <vector245>:
.globl vector245
vector245:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $245
8010759c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801075a1:	e9 5a ef ff ff       	jmp    80106500 <alltraps>

801075a6 <vector246>:
.globl vector246
vector246:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $246
801075a8:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801075ad:	e9 4e ef ff ff       	jmp    80106500 <alltraps>

801075b2 <vector247>:
.globl vector247
vector247:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $247
801075b4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801075b9:	e9 42 ef ff ff       	jmp    80106500 <alltraps>

801075be <vector248>:
.globl vector248
vector248:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $248
801075c0:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801075c5:	e9 36 ef ff ff       	jmp    80106500 <alltraps>

801075ca <vector249>:
.globl vector249
vector249:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $249
801075cc:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801075d1:	e9 2a ef ff ff       	jmp    80106500 <alltraps>

801075d6 <vector250>:
.globl vector250
vector250:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $250
801075d8:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801075dd:	e9 1e ef ff ff       	jmp    80106500 <alltraps>

801075e2 <vector251>:
.globl vector251
vector251:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $251
801075e4:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801075e9:	e9 12 ef ff ff       	jmp    80106500 <alltraps>

801075ee <vector252>:
.globl vector252
vector252:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $252
801075f0:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801075f5:	e9 06 ef ff ff       	jmp    80106500 <alltraps>

801075fa <vector253>:
.globl vector253
vector253:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $253
801075fc:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107601:	e9 fa ee ff ff       	jmp    80106500 <alltraps>

80107606 <vector254>:
.globl vector254
vector254:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $254
80107608:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010760d:	e9 ee ee ff ff       	jmp    80106500 <alltraps>

80107612 <vector255>:
.globl vector255
vector255:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $255
80107614:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107619:	e9 e2 ee ff ff       	jmp    80106500 <alltraps>
	...

80107620 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107620:	55                   	push   %ebp
80107621:	89 e5                	mov    %esp,%ebp
80107623:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107626:	8b 45 0c             	mov    0xc(%ebp),%eax
80107629:	83 e8 01             	sub    $0x1,%eax
8010762c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107630:	8b 45 08             	mov    0x8(%ebp),%eax
80107633:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107637:	8b 45 08             	mov    0x8(%ebp),%eax
8010763a:	c1 e8 10             	shr    $0x10,%eax
8010763d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107641:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107644:	0f 01 10             	lgdtl  (%eax)
}
80107647:	c9                   	leave  
80107648:	c3                   	ret    

80107649 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107649:	55                   	push   %ebp
8010764a:	89 e5                	mov    %esp,%ebp
8010764c:	83 ec 04             	sub    $0x4,%esp
8010764f:	8b 45 08             	mov    0x8(%ebp),%eax
80107652:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107656:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010765a:	0f 00 d8             	ltr    %ax
}
8010765d:	c9                   	leave  
8010765e:	c3                   	ret    

8010765f <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010765f:	55                   	push   %ebp
80107660:	89 e5                	mov    %esp,%ebp
80107662:	83 ec 04             	sub    $0x4,%esp
80107665:	8b 45 08             	mov    0x8(%ebp),%eax
80107668:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010766c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107670:	8e e8                	mov    %eax,%gs
}
80107672:	c9                   	leave  
80107673:	c3                   	ret    

80107674 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107674:	55                   	push   %ebp
80107675:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107677:	8b 45 08             	mov    0x8(%ebp),%eax
8010767a:	0f 22 d8             	mov    %eax,%cr3
}
8010767d:	5d                   	pop    %ebp
8010767e:	c3                   	ret    

8010767f <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010767f:	55                   	push   %ebp
80107680:	89 e5                	mov    %esp,%ebp
80107682:	8b 45 08             	mov    0x8(%ebp),%eax
80107685:	05 00 00 00 80       	add    $0x80000000,%eax
8010768a:	5d                   	pop    %ebp
8010768b:	c3                   	ret    

8010768c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010768c:	55                   	push   %ebp
8010768d:	89 e5                	mov    %esp,%ebp
8010768f:	8b 45 08             	mov    0x8(%ebp),%eax
80107692:	05 00 00 00 80       	add    $0x80000000,%eax
80107697:	5d                   	pop    %ebp
80107698:	c3                   	ret    

80107699 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107699:	55                   	push   %ebp
8010769a:	89 e5                	mov    %esp,%ebp
8010769c:	53                   	push   %ebx
8010769d:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801076a0:	e8 1e b8 ff ff       	call   80102ec3 <cpunum>
801076a5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801076ab:	05 60 23 11 80       	add    $0x80112360,%eax
801076b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801076b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b6:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801076bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076bf:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801076c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c8:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801076cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cf:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076d3:	83 e2 f0             	and    $0xfffffff0,%edx
801076d6:	83 ca 0a             	or     $0xa,%edx
801076d9:	88 50 7d             	mov    %dl,0x7d(%eax)
801076dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076df:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076e3:	83 ca 10             	or     $0x10,%edx
801076e6:	88 50 7d             	mov    %dl,0x7d(%eax)
801076e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ec:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076f0:	83 e2 9f             	and    $0xffffff9f,%edx
801076f3:	88 50 7d             	mov    %dl,0x7d(%eax)
801076f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f9:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076fd:	83 ca 80             	or     $0xffffff80,%edx
80107700:	88 50 7d             	mov    %dl,0x7d(%eax)
80107703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107706:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010770a:	83 ca 0f             	or     $0xf,%edx
8010770d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107713:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107717:	83 e2 ef             	and    $0xffffffef,%edx
8010771a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010771d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107720:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107724:	83 e2 df             	and    $0xffffffdf,%edx
80107727:	88 50 7e             	mov    %dl,0x7e(%eax)
8010772a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107731:	83 ca 40             	or     $0x40,%edx
80107734:	88 50 7e             	mov    %dl,0x7e(%eax)
80107737:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010773a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010773e:	83 ca 80             	or     $0xffffff80,%edx
80107741:	88 50 7e             	mov    %dl,0x7e(%eax)
80107744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107747:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010774b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010774e:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107755:	ff ff 
80107757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775a:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107761:	00 00 
80107763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107766:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010776d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107770:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107777:	83 e2 f0             	and    $0xfffffff0,%edx
8010777a:	83 ca 02             	or     $0x2,%edx
8010777d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107783:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107786:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010778d:	83 ca 10             	or     $0x10,%edx
80107790:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107799:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801077a0:	83 e2 9f             	and    $0xffffff9f,%edx
801077a3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801077a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ac:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801077b3:	83 ca 80             	or     $0xffffff80,%edx
801077b6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801077bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077bf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077c6:	83 ca 0f             	or     $0xf,%edx
801077c9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077d9:	83 e2 ef             	and    $0xffffffef,%edx
801077dc:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e5:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077ec:	83 e2 df             	and    $0xffffffdf,%edx
801077ef:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077ff:	83 ca 40             	or     $0x40,%edx
80107802:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107808:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010780b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107812:	83 ca 80             	or     $0xffffff80,%edx
80107815:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010781b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107825:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107828:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010782f:	ff ff 
80107831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107834:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010783b:	00 00 
8010783d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107840:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107851:	83 e2 f0             	and    $0xfffffff0,%edx
80107854:	83 ca 0a             	or     $0xa,%edx
80107857:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010785d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107860:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107867:	83 ca 10             	or     $0x10,%edx
8010786a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107873:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010787a:	83 ca 60             	or     $0x60,%edx
8010787d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107886:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010788d:	83 ca 80             	or     $0xffffff80,%edx
80107890:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107899:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078a0:	83 ca 0f             	or     $0xf,%edx
801078a3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078ac:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078b3:	83 e2 ef             	and    $0xffffffef,%edx
801078b6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078bf:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078c6:	83 e2 df             	and    $0xffffffdf,%edx
801078c9:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078d2:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078d9:	83 ca 40             	or     $0x40,%edx
801078dc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078ec:	83 ca 80             	or     $0xffffff80,%edx
801078ef:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f8:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801078ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107902:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107909:	ff ff 
8010790b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107915:	00 00 
80107917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791a:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107921:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107924:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010792b:	83 e2 f0             	and    $0xfffffff0,%edx
8010792e:	83 ca 02             	or     $0x2,%edx
80107931:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010793a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107941:	83 ca 10             	or     $0x10,%edx
80107944:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010794a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107954:	83 ca 60             	or     $0x60,%edx
80107957:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010795d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107960:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107967:	83 ca 80             	or     $0xffffff80,%edx
8010796a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107973:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010797a:	83 ca 0f             	or     $0xf,%edx
8010797d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107986:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010798d:	83 e2 ef             	and    $0xffffffef,%edx
80107990:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107999:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801079a0:	83 e2 df             	and    $0xffffffdf,%edx
801079a3:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801079a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ac:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801079b3:	83 ca 40             	or     $0x40,%edx
801079b6:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801079bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079bf:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801079c6:	83 ca 80             	or     $0xffffff80,%edx
801079c9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801079cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d2:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801079d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079dc:	05 b4 00 00 00       	add    $0xb4,%eax
801079e1:	89 c3                	mov    %eax,%ebx
801079e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e6:	05 b4 00 00 00       	add    $0xb4,%eax
801079eb:	c1 e8 10             	shr    $0x10,%eax
801079ee:	89 c1                	mov    %eax,%ecx
801079f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f3:	05 b4 00 00 00       	add    $0xb4,%eax
801079f8:	c1 e8 18             	shr    $0x18,%eax
801079fb:	89 c2                	mov    %eax,%edx
801079fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a00:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107a07:	00 00 
80107a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a16:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a26:	83 e1 f0             	and    $0xfffffff0,%ecx
80107a29:	83 c9 02             	or     $0x2,%ecx
80107a2c:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a35:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a3c:	83 c9 10             	or     $0x10,%ecx
80107a3f:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a48:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a4f:	83 e1 9f             	and    $0xffffff9f,%ecx
80107a52:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5b:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a62:	83 c9 80             	or     $0xffffff80,%ecx
80107a65:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107a75:	83 e1 f0             	and    $0xfffffff0,%ecx
80107a78:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a81:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107a88:	83 e1 ef             	and    $0xffffffef,%ecx
80107a8b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107a9b:	83 e1 df             	and    $0xffffffdf,%ecx
80107a9e:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa7:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107aae:	83 c9 40             	or     $0x40,%ecx
80107ab1:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aba:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107ac1:	83 c9 80             	or     $0xffffff80,%ecx
80107ac4:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acd:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad6:	83 c0 70             	add    $0x70,%eax
80107ad9:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107ae0:	00 
80107ae1:	89 04 24             	mov    %eax,(%esp)
80107ae4:	e8 37 fb ff ff       	call   80107620 <lgdt>
  loadgs(SEG_KCPU << 3);
80107ae9:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107af0:	e8 6a fb ff ff       	call   8010765f <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af8:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107afe:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107b05:	00 00 00 00 
}
80107b09:	83 c4 24             	add    $0x24,%esp
80107b0c:	5b                   	pop    %ebx
80107b0d:	5d                   	pop    %ebp
80107b0e:	c3                   	ret    

80107b0f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107b0f:	55                   	push   %ebp
80107b10:	89 e5                	mov    %esp,%ebp
80107b12:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107b15:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b18:	c1 e8 16             	shr    $0x16,%eax
80107b1b:	c1 e0 02             	shl    $0x2,%eax
80107b1e:	03 45 08             	add    0x8(%ebp),%eax
80107b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b27:	8b 00                	mov    (%eax),%eax
80107b29:	83 e0 01             	and    $0x1,%eax
80107b2c:	84 c0                	test   %al,%al
80107b2e:	74 17                	je     80107b47 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b33:	8b 00                	mov    (%eax),%eax
80107b35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b3a:	89 04 24             	mov    %eax,(%esp)
80107b3d:	e8 4a fb ff ff       	call   8010768c <p2v>
80107b42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b45:	eb 4b                	jmp    80107b92 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107b47:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107b4b:	74 0e                	je     80107b5b <walkpgdir+0x4c>
80107b4d:	e8 b9 af ff ff       	call   80102b0b <kalloc>
80107b52:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b55:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b59:	75 07                	jne    80107b62 <walkpgdir+0x53>
      return 0;
80107b5b:	b8 00 00 00 00       	mov    $0x0,%eax
80107b60:	eb 41                	jmp    80107ba3 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107b62:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107b69:	00 
80107b6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107b71:	00 
80107b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b75:	89 04 24             	mov    %eax,(%esp)
80107b78:	e8 49 d5 ff ff       	call   801050c6 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b80:	89 04 24             	mov    %eax,(%esp)
80107b83:	e8 f7 fa ff ff       	call   8010767f <v2p>
80107b88:	89 c2                	mov    %eax,%edx
80107b8a:	83 ca 07             	or     $0x7,%edx
80107b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b90:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107b92:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b95:	c1 e8 0c             	shr    $0xc,%eax
80107b98:	25 ff 03 00 00       	and    $0x3ff,%eax
80107b9d:	c1 e0 02             	shl    $0x2,%eax
80107ba0:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107ba3:	c9                   	leave  
80107ba4:	c3                   	ret    

80107ba5 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107ba5:	55                   	push   %ebp
80107ba6:	89 e5                	mov    %esp,%ebp
80107ba8:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107bab:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bb9:	03 45 10             	add    0x10(%ebp),%eax
80107bbc:	83 e8 01             	sub    $0x1,%eax
80107bbf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107bc7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107bce:	00 
80107bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80107bd6:	8b 45 08             	mov    0x8(%ebp),%eax
80107bd9:	89 04 24             	mov    %eax,(%esp)
80107bdc:	e8 2e ff ff ff       	call   80107b0f <walkpgdir>
80107be1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107be4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107be8:	75 07                	jne    80107bf1 <mappages+0x4c>
      return -1;
80107bea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bef:	eb 46                	jmp    80107c37 <mappages+0x92>
    if(*pte & PTE_P)
80107bf1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107bf4:	8b 00                	mov    (%eax),%eax
80107bf6:	83 e0 01             	and    $0x1,%eax
80107bf9:	84 c0                	test   %al,%al
80107bfb:	74 0c                	je     80107c09 <mappages+0x64>
      panic("remap");
80107bfd:	c7 04 24 30 8a 10 80 	movl   $0x80108a30,(%esp)
80107c04:	e8 34 89 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107c09:	8b 45 18             	mov    0x18(%ebp),%eax
80107c0c:	0b 45 14             	or     0x14(%ebp),%eax
80107c0f:	89 c2                	mov    %eax,%edx
80107c11:	83 ca 01             	or     $0x1,%edx
80107c14:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c17:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c1f:	74 10                	je     80107c31 <mappages+0x8c>
      break;
    a += PGSIZE;
80107c21:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107c28:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107c2f:	eb 96                	jmp    80107bc7 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107c31:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107c32:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c37:	c9                   	leave  
80107c38:	c3                   	ret    

80107c39 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107c39:	55                   	push   %ebp
80107c3a:	89 e5                	mov    %esp,%ebp
80107c3c:	53                   	push   %ebx
80107c3d:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107c40:	e8 c6 ae ff ff       	call   80102b0b <kalloc>
80107c45:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c48:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c4c:	75 0a                	jne    80107c58 <setupkvm+0x1f>
    return 0;
80107c4e:	b8 00 00 00 00       	mov    $0x0,%eax
80107c53:	e9 98 00 00 00       	jmp    80107cf0 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107c58:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c5f:	00 
80107c60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c67:	00 
80107c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c6b:	89 04 24             	mov    %eax,(%esp)
80107c6e:	e8 53 d4 ff ff       	call   801050c6 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107c73:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107c7a:	e8 0d fa ff ff       	call   8010768c <p2v>
80107c7f:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107c84:	76 0c                	jbe    80107c92 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107c86:	c7 04 24 36 8a 10 80 	movl   $0x80108a36,(%esp)
80107c8d:	e8 ab 88 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c92:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107c99:	eb 49                	jmp    80107ce4 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80107c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107c9e:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107ca4:	8b 50 04             	mov    0x4(%eax),%edx
80107ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caa:	8b 58 08             	mov    0x8(%eax),%ebx
80107cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb0:	8b 40 04             	mov    0x4(%eax),%eax
80107cb3:	29 c3                	sub    %eax,%ebx
80107cb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb8:	8b 00                	mov    (%eax),%eax
80107cba:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107cbe:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107cc2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107cc6:	89 44 24 04          	mov    %eax,0x4(%esp)
80107cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ccd:	89 04 24             	mov    %eax,(%esp)
80107cd0:	e8 d0 fe ff ff       	call   80107ba5 <mappages>
80107cd5:	85 c0                	test   %eax,%eax
80107cd7:	79 07                	jns    80107ce0 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107cd9:	b8 00 00 00 00       	mov    $0x0,%eax
80107cde:	eb 10                	jmp    80107cf0 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ce0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107ce4:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107ceb:	72 ae                	jb     80107c9b <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107cf0:	83 c4 34             	add    $0x34,%esp
80107cf3:	5b                   	pop    %ebx
80107cf4:	5d                   	pop    %ebp
80107cf5:	c3                   	ret    

80107cf6 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107cf6:	55                   	push   %ebp
80107cf7:	89 e5                	mov    %esp,%ebp
80107cf9:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107cfc:	e8 38 ff ff ff       	call   80107c39 <setupkvm>
80107d01:	a3 38 52 11 80       	mov    %eax,0x80115238
  switchkvm();
80107d06:	e8 02 00 00 00       	call   80107d0d <switchkvm>
}
80107d0b:	c9                   	leave  
80107d0c:	c3                   	ret    

80107d0d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d0d:	55                   	push   %ebp
80107d0e:	89 e5                	mov    %esp,%ebp
80107d10:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107d13:	a1 38 52 11 80       	mov    0x80115238,%eax
80107d18:	89 04 24             	mov    %eax,(%esp)
80107d1b:	e8 5f f9 ff ff       	call   8010767f <v2p>
80107d20:	89 04 24             	mov    %eax,(%esp)
80107d23:	e8 4c f9 ff ff       	call   80107674 <lcr3>
}
80107d28:	c9                   	leave  
80107d29:	c3                   	ret    

80107d2a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107d2a:	55                   	push   %ebp
80107d2b:	89 e5                	mov    %esp,%ebp
80107d2d:	53                   	push   %ebx
80107d2e:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107d31:	e8 89 d2 ff ff       	call   80104fbf <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107d36:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d3c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107d43:	83 c2 08             	add    $0x8,%edx
80107d46:	89 d3                	mov    %edx,%ebx
80107d48:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107d4f:	83 c2 08             	add    $0x8,%edx
80107d52:	c1 ea 10             	shr    $0x10,%edx
80107d55:	89 d1                	mov    %edx,%ecx
80107d57:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107d5e:	83 c2 08             	add    $0x8,%edx
80107d61:	c1 ea 18             	shr    $0x18,%edx
80107d64:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107d6b:	67 00 
80107d6d:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107d74:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107d7a:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107d81:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d84:	83 c9 09             	or     $0x9,%ecx
80107d87:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107d8d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107d94:	83 c9 10             	or     $0x10,%ecx
80107d97:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107d9d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107da4:	83 e1 9f             	and    $0xffffff9f,%ecx
80107da7:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107dad:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107db4:	83 c9 80             	or     $0xffffff80,%ecx
80107db7:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107dbd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107dc4:	83 e1 f0             	and    $0xfffffff0,%ecx
80107dc7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107dcd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107dd4:	83 e1 ef             	and    $0xffffffef,%ecx
80107dd7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107ddd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107de4:	83 e1 df             	and    $0xffffffdf,%ecx
80107de7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107ded:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107df4:	83 c9 40             	or     $0x40,%ecx
80107df7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107dfd:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107e04:	83 e1 7f             	and    $0x7f,%ecx
80107e07:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107e0d:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107e13:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e19:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e20:	83 e2 ef             	and    $0xffffffef,%edx
80107e23:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107e29:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e2f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107e35:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e3b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107e42:	8b 52 08             	mov    0x8(%edx),%edx
80107e45:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107e4b:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107e4e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107e55:	e8 ef f7 ff ff       	call   80107649 <ltr>
  if(p->pgdir == 0)
80107e5a:	8b 45 08             	mov    0x8(%ebp),%eax
80107e5d:	8b 40 04             	mov    0x4(%eax),%eax
80107e60:	85 c0                	test   %eax,%eax
80107e62:	75 0c                	jne    80107e70 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107e64:	c7 04 24 47 8a 10 80 	movl   $0x80108a47,(%esp)
80107e6b:	e8 cd 86 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107e70:	8b 45 08             	mov    0x8(%ebp),%eax
80107e73:	8b 40 04             	mov    0x4(%eax),%eax
80107e76:	89 04 24             	mov    %eax,(%esp)
80107e79:	e8 01 f8 ff ff       	call   8010767f <v2p>
80107e7e:	89 04 24             	mov    %eax,(%esp)
80107e81:	e8 ee f7 ff ff       	call   80107674 <lcr3>
  popcli();
80107e86:	e8 7c d1 ff ff       	call   80105007 <popcli>
}
80107e8b:	83 c4 14             	add    $0x14,%esp
80107e8e:	5b                   	pop    %ebx
80107e8f:	5d                   	pop    %ebp
80107e90:	c3                   	ret    

80107e91 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107e91:	55                   	push   %ebp
80107e92:	89 e5                	mov    %esp,%ebp
80107e94:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107e97:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107e9e:	76 0c                	jbe    80107eac <inituvm+0x1b>
    panic("inituvm: more than a page");
80107ea0:	c7 04 24 5b 8a 10 80 	movl   $0x80108a5b,(%esp)
80107ea7:	e8 91 86 ff ff       	call   8010053d <panic>
  mem = kalloc();
80107eac:	e8 5a ac ff ff       	call   80102b0b <kalloc>
80107eb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107eb4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ebb:	00 
80107ebc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ec3:	00 
80107ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec7:	89 04 24             	mov    %eax,(%esp)
80107eca:	e8 f7 d1 ff ff       	call   801050c6 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed2:	89 04 24             	mov    %eax,(%esp)
80107ed5:	e8 a5 f7 ff ff       	call   8010767f <v2p>
80107eda:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107ee1:	00 
80107ee2:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107ee6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107eed:	00 
80107eee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ef5:	00 
80107ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80107ef9:	89 04 24             	mov    %eax,(%esp)
80107efc:	e8 a4 fc ff ff       	call   80107ba5 <mappages>
  memmove(mem, init, sz);
80107f01:	8b 45 10             	mov    0x10(%ebp),%eax
80107f04:	89 44 24 08          	mov    %eax,0x8(%esp)
80107f08:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f12:	89 04 24             	mov    %eax,(%esp)
80107f15:	e8 7f d2 ff ff       	call   80105199 <memmove>
}
80107f1a:	c9                   	leave  
80107f1b:	c3                   	ret    

80107f1c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107f1c:	55                   	push   %ebp
80107f1d:	89 e5                	mov    %esp,%ebp
80107f1f:	53                   	push   %ebx
80107f20:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107f23:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f26:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f2b:	85 c0                	test   %eax,%eax
80107f2d:	74 0c                	je     80107f3b <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107f2f:	c7 04 24 78 8a 10 80 	movl   $0x80108a78,(%esp)
80107f36:	e8 02 86 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107f3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f42:	e9 ad 00 00 00       	jmp    80107ff4 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4a:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f4d:	01 d0                	add    %edx,%eax
80107f4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f56:	00 
80107f57:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80107f5e:	89 04 24             	mov    %eax,(%esp)
80107f61:	e8 a9 fb ff ff       	call   80107b0f <walkpgdir>
80107f66:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f69:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f6d:	75 0c                	jne    80107f7b <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80107f6f:	c7 04 24 9b 8a 10 80 	movl   $0x80108a9b,(%esp)
80107f76:	e8 c2 85 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80107f7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f7e:	8b 00                	mov    (%eax),%eax
80107f80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f85:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8b:	8b 55 18             	mov    0x18(%ebp),%edx
80107f8e:	89 d1                	mov    %edx,%ecx
80107f90:	29 c1                	sub    %eax,%ecx
80107f92:	89 c8                	mov    %ecx,%eax
80107f94:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107f99:	77 11                	ja     80107fac <loaduvm+0x90>
      n = sz - i;
80107f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9e:	8b 55 18             	mov    0x18(%ebp),%edx
80107fa1:	89 d1                	mov    %edx,%ecx
80107fa3:	29 c1                	sub    %eax,%ecx
80107fa5:	89 c8                	mov    %ecx,%eax
80107fa7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107faa:	eb 07                	jmp    80107fb3 <loaduvm+0x97>
    else
      n = PGSIZE;
80107fac:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb6:	8b 55 14             	mov    0x14(%ebp),%edx
80107fb9:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107fbc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107fbf:	89 04 24             	mov    %eax,(%esp)
80107fc2:	e8 c5 f6 ff ff       	call   8010768c <p2v>
80107fc7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107fca:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107fce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107fd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fd6:	8b 45 10             	mov    0x10(%ebp),%eax
80107fd9:	89 04 24             	mov    %eax,(%esp)
80107fdc:	e8 89 9d ff ff       	call   80101d6a <readi>
80107fe1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fe4:	74 07                	je     80107fed <loaduvm+0xd1>
      return -1;
80107fe6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107feb:	eb 18                	jmp    80108005 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107fed:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff7:	3b 45 18             	cmp    0x18(%ebp),%eax
80107ffa:	0f 82 47 ff ff ff    	jb     80107f47 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108000:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108005:	83 c4 24             	add    $0x24,%esp
80108008:	5b                   	pop    %ebx
80108009:	5d                   	pop    %ebp
8010800a:	c3                   	ret    

8010800b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010800b:	55                   	push   %ebp
8010800c:	89 e5                	mov    %esp,%ebp
8010800e:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108011:	8b 45 10             	mov    0x10(%ebp),%eax
80108014:	85 c0                	test   %eax,%eax
80108016:	79 0a                	jns    80108022 <allocuvm+0x17>
    return 0;
80108018:	b8 00 00 00 00       	mov    $0x0,%eax
8010801d:	e9 c1 00 00 00       	jmp    801080e3 <allocuvm+0xd8>
  if(newsz < oldsz)
80108022:	8b 45 10             	mov    0x10(%ebp),%eax
80108025:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108028:	73 08                	jae    80108032 <allocuvm+0x27>
    return oldsz;
8010802a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010802d:	e9 b1 00 00 00       	jmp    801080e3 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108032:	8b 45 0c             	mov    0xc(%ebp),%eax
80108035:	05 ff 0f 00 00       	add    $0xfff,%eax
8010803a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010803f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108042:	e9 8d 00 00 00       	jmp    801080d4 <allocuvm+0xc9>
    mem = kalloc();
80108047:	e8 bf aa ff ff       	call   80102b0b <kalloc>
8010804c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010804f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108053:	75 2c                	jne    80108081 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108055:	c7 04 24 b9 8a 10 80 	movl   $0x80108ab9,(%esp)
8010805c:	e8 40 83 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108061:	8b 45 0c             	mov    0xc(%ebp),%eax
80108064:	89 44 24 08          	mov    %eax,0x8(%esp)
80108068:	8b 45 10             	mov    0x10(%ebp),%eax
8010806b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010806f:	8b 45 08             	mov    0x8(%ebp),%eax
80108072:	89 04 24             	mov    %eax,(%esp)
80108075:	e8 6b 00 00 00       	call   801080e5 <deallocuvm>
      return 0;
8010807a:	b8 00 00 00 00       	mov    $0x0,%eax
8010807f:	eb 62                	jmp    801080e3 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80108081:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108088:	00 
80108089:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108090:	00 
80108091:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108094:	89 04 24             	mov    %eax,(%esp)
80108097:	e8 2a d0 ff ff       	call   801050c6 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010809c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010809f:	89 04 24             	mov    %eax,(%esp)
801080a2:	e8 d8 f5 ff ff       	call   8010767f <v2p>
801080a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080aa:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801080b1:	00 
801080b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
801080b6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080bd:	00 
801080be:	89 54 24 04          	mov    %edx,0x4(%esp)
801080c2:	8b 45 08             	mov    0x8(%ebp),%eax
801080c5:	89 04 24             	mov    %eax,(%esp)
801080c8:	e8 d8 fa ff ff       	call   80107ba5 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801080cd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d7:	3b 45 10             	cmp    0x10(%ebp),%eax
801080da:	0f 82 67 ff ff ff    	jb     80108047 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801080e0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801080e3:	c9                   	leave  
801080e4:	c3                   	ret    

801080e5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801080e5:	55                   	push   %ebp
801080e6:	89 e5                	mov    %esp,%ebp
801080e8:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801080eb:	8b 45 10             	mov    0x10(%ebp),%eax
801080ee:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080f1:	72 08                	jb     801080fb <deallocuvm+0x16>
    return oldsz;
801080f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801080f6:	e9 a4 00 00 00       	jmp    8010819f <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
801080fb:	8b 45 10             	mov    0x10(%ebp),%eax
801080fe:	05 ff 0f 00 00       	add    $0xfff,%eax
80108103:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108108:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010810b:	e9 80 00 00 00       	jmp    80108190 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108113:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010811a:	00 
8010811b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010811f:	8b 45 08             	mov    0x8(%ebp),%eax
80108122:	89 04 24             	mov    %eax,(%esp)
80108125:	e8 e5 f9 ff ff       	call   80107b0f <walkpgdir>
8010812a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010812d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108131:	75 09                	jne    8010813c <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108133:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010813a:	eb 4d                	jmp    80108189 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
8010813c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010813f:	8b 00                	mov    (%eax),%eax
80108141:	83 e0 01             	and    $0x1,%eax
80108144:	84 c0                	test   %al,%al
80108146:	74 41                	je     80108189 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108148:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010814b:	8b 00                	mov    (%eax),%eax
8010814d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108152:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108155:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108159:	75 0c                	jne    80108167 <deallocuvm+0x82>
        panic("kfree");
8010815b:	c7 04 24 d1 8a 10 80 	movl   $0x80108ad1,(%esp)
80108162:	e8 d6 83 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80108167:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010816a:	89 04 24             	mov    %eax,(%esp)
8010816d:	e8 1a f5 ff ff       	call   8010768c <p2v>
80108172:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108175:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108178:	89 04 24             	mov    %eax,(%esp)
8010817b:	e8 f2 a8 ff ff       	call   80102a72 <kfree>
      *pte = 0;
80108180:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108183:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108189:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108193:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108196:	0f 82 74 ff ff ff    	jb     80108110 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010819c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010819f:	c9                   	leave  
801081a0:	c3                   	ret    

801081a1 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801081a1:	55                   	push   %ebp
801081a2:	89 e5                	mov    %esp,%ebp
801081a4:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801081a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081ab:	75 0c                	jne    801081b9 <freevm+0x18>
    panic("freevm: no pgdir");
801081ad:	c7 04 24 d7 8a 10 80 	movl   $0x80108ad7,(%esp)
801081b4:	e8 84 83 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801081b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081c0:	00 
801081c1:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801081c8:	80 
801081c9:	8b 45 08             	mov    0x8(%ebp),%eax
801081cc:	89 04 24             	mov    %eax,(%esp)
801081cf:	e8 11 ff ff ff       	call   801080e5 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801081d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081db:	eb 3c                	jmp    80108219 <freevm+0x78>
    if(pgdir[i] & PTE_P){
801081dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e0:	c1 e0 02             	shl    $0x2,%eax
801081e3:	03 45 08             	add    0x8(%ebp),%eax
801081e6:	8b 00                	mov    (%eax),%eax
801081e8:	83 e0 01             	and    $0x1,%eax
801081eb:	84 c0                	test   %al,%al
801081ed:	74 26                	je     80108215 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801081ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f2:	c1 e0 02             	shl    $0x2,%eax
801081f5:	03 45 08             	add    0x8(%ebp),%eax
801081f8:	8b 00                	mov    (%eax),%eax
801081fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081ff:	89 04 24             	mov    %eax,(%esp)
80108202:	e8 85 f4 ff ff       	call   8010768c <p2v>
80108207:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010820a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010820d:	89 04 24             	mov    %eax,(%esp)
80108210:	e8 5d a8 ff ff       	call   80102a72 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108215:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108219:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108220:	76 bb                	jbe    801081dd <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108222:	8b 45 08             	mov    0x8(%ebp),%eax
80108225:	89 04 24             	mov    %eax,(%esp)
80108228:	e8 45 a8 ff ff       	call   80102a72 <kfree>
}
8010822d:	c9                   	leave  
8010822e:	c3                   	ret    

8010822f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010822f:	55                   	push   %ebp
80108230:	89 e5                	mov    %esp,%ebp
80108232:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108235:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010823c:	00 
8010823d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108240:	89 44 24 04          	mov    %eax,0x4(%esp)
80108244:	8b 45 08             	mov    0x8(%ebp),%eax
80108247:	89 04 24             	mov    %eax,(%esp)
8010824a:	e8 c0 f8 ff ff       	call   80107b0f <walkpgdir>
8010824f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108252:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108256:	75 0c                	jne    80108264 <clearpteu+0x35>
    panic("clearpteu");
80108258:	c7 04 24 e8 8a 10 80 	movl   $0x80108ae8,(%esp)
8010825f:	e8 d9 82 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108267:	8b 00                	mov    (%eax),%eax
80108269:	89 c2                	mov    %eax,%edx
8010826b:	83 e2 fb             	and    $0xfffffffb,%edx
8010826e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108271:	89 10                	mov    %edx,(%eax)
}
80108273:	c9                   	leave  
80108274:	c3                   	ret    

80108275 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108275:	55                   	push   %ebp
80108276:	89 e5                	mov    %esp,%ebp
80108278:	53                   	push   %ebx
80108279:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010827c:	e8 b8 f9 ff ff       	call   80107c39 <setupkvm>
80108281:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108284:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108288:	75 0a                	jne    80108294 <copyuvm+0x1f>
    return 0;
8010828a:	b8 00 00 00 00       	mov    $0x0,%eax
8010828f:	e9 fd 00 00 00       	jmp    80108391 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108294:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010829b:	e9 cc 00 00 00       	jmp    8010836c <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801082a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801082aa:	00 
801082ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801082af:	8b 45 08             	mov    0x8(%ebp),%eax
801082b2:	89 04 24             	mov    %eax,(%esp)
801082b5:	e8 55 f8 ff ff       	call   80107b0f <walkpgdir>
801082ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082c1:	75 0c                	jne    801082cf <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
801082c3:	c7 04 24 f2 8a 10 80 	movl   $0x80108af2,(%esp)
801082ca:	e8 6e 82 ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801082cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082d2:	8b 00                	mov    (%eax),%eax
801082d4:	83 e0 01             	and    $0x1,%eax
801082d7:	85 c0                	test   %eax,%eax
801082d9:	75 0c                	jne    801082e7 <copyuvm+0x72>
      panic("copyuvm: page not present");
801082db:	c7 04 24 0c 8b 10 80 	movl   $0x80108b0c,(%esp)
801082e2:	e8 56 82 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801082e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082ea:	8b 00                	mov    (%eax),%eax
801082ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082f1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801082f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f7:	8b 00                	mov    (%eax),%eax
801082f9:	25 ff 0f 00 00       	and    $0xfff,%eax
801082fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108301:	e8 05 a8 ff ff       	call   80102b0b <kalloc>
80108306:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108309:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010830d:	74 6e                	je     8010837d <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010830f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108312:	89 04 24             	mov    %eax,(%esp)
80108315:	e8 72 f3 ff ff       	call   8010768c <p2v>
8010831a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108321:	00 
80108322:	89 44 24 04          	mov    %eax,0x4(%esp)
80108326:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108329:	89 04 24             	mov    %eax,(%esp)
8010832c:	e8 68 ce ff ff       	call   80105199 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108331:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108334:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108337:	89 04 24             	mov    %eax,(%esp)
8010833a:	e8 40 f3 ff ff       	call   8010767f <v2p>
8010833f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108342:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108346:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010834a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108351:	00 
80108352:	89 54 24 04          	mov    %edx,0x4(%esp)
80108356:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108359:	89 04 24             	mov    %eax,(%esp)
8010835c:	e8 44 f8 ff ff       	call   80107ba5 <mappages>
80108361:	85 c0                	test   %eax,%eax
80108363:	78 1b                	js     80108380 <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108365:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010836c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108372:	0f 82 28 ff ff ff    	jb     801082a0 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108378:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010837b:	eb 14                	jmp    80108391 <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010837d:	90                   	nop
8010837e:	eb 01                	jmp    80108381 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108380:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108381:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108384:	89 04 24             	mov    %eax,(%esp)
80108387:	e8 15 fe ff ff       	call   801081a1 <freevm>
  return 0;
8010838c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108391:	83 c4 44             	add    $0x44,%esp
80108394:	5b                   	pop    %ebx
80108395:	5d                   	pop    %ebp
80108396:	c3                   	ret    

80108397 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108397:	55                   	push   %ebp
80108398:	89 e5                	mov    %esp,%ebp
8010839a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010839d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083a4:	00 
801083a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801083a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801083ac:	8b 45 08             	mov    0x8(%ebp),%eax
801083af:	89 04 24             	mov    %eax,(%esp)
801083b2:	e8 58 f7 ff ff       	call   80107b0f <walkpgdir>
801083b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801083ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bd:	8b 00                	mov    (%eax),%eax
801083bf:	83 e0 01             	and    $0x1,%eax
801083c2:	85 c0                	test   %eax,%eax
801083c4:	75 07                	jne    801083cd <uva2ka+0x36>
    return 0;
801083c6:	b8 00 00 00 00       	mov    $0x0,%eax
801083cb:	eb 25                	jmp    801083f2 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801083cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d0:	8b 00                	mov    (%eax),%eax
801083d2:	83 e0 04             	and    $0x4,%eax
801083d5:	85 c0                	test   %eax,%eax
801083d7:	75 07                	jne    801083e0 <uva2ka+0x49>
    return 0;
801083d9:	b8 00 00 00 00       	mov    $0x0,%eax
801083de:	eb 12                	jmp    801083f2 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801083e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e3:	8b 00                	mov    (%eax),%eax
801083e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083ea:	89 04 24             	mov    %eax,(%esp)
801083ed:	e8 9a f2 ff ff       	call   8010768c <p2v>
}
801083f2:	c9                   	leave  
801083f3:	c3                   	ret    

801083f4 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801083f4:	55                   	push   %ebp
801083f5:	89 e5                	mov    %esp,%ebp
801083f7:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801083fa:	8b 45 10             	mov    0x10(%ebp),%eax
801083fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108400:	e9 8b 00 00 00       	jmp    80108490 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108405:	8b 45 0c             	mov    0xc(%ebp),%eax
80108408:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010840d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108410:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108413:	89 44 24 04          	mov    %eax,0x4(%esp)
80108417:	8b 45 08             	mov    0x8(%ebp),%eax
8010841a:	89 04 24             	mov    %eax,(%esp)
8010841d:	e8 75 ff ff ff       	call   80108397 <uva2ka>
80108422:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108425:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108429:	75 07                	jne    80108432 <copyout+0x3e>
      return -1;
8010842b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108430:	eb 6d                	jmp    8010849f <copyout+0xab>
    n = PGSIZE - (va - va0);
80108432:	8b 45 0c             	mov    0xc(%ebp),%eax
80108435:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108438:	89 d1                	mov    %edx,%ecx
8010843a:	29 c1                	sub    %eax,%ecx
8010843c:	89 c8                	mov    %ecx,%eax
8010843e:	05 00 10 00 00       	add    $0x1000,%eax
80108443:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108446:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108449:	3b 45 14             	cmp    0x14(%ebp),%eax
8010844c:	76 06                	jbe    80108454 <copyout+0x60>
      n = len;
8010844e:	8b 45 14             	mov    0x14(%ebp),%eax
80108451:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108454:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108457:	8b 55 0c             	mov    0xc(%ebp),%edx
8010845a:	89 d1                	mov    %edx,%ecx
8010845c:	29 c1                	sub    %eax,%ecx
8010845e:	89 c8                	mov    %ecx,%eax
80108460:	03 45 e8             	add    -0x18(%ebp),%eax
80108463:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108466:	89 54 24 08          	mov    %edx,0x8(%esp)
8010846a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010846d:	89 54 24 04          	mov    %edx,0x4(%esp)
80108471:	89 04 24             	mov    %eax,(%esp)
80108474:	e8 20 cd ff ff       	call   80105199 <memmove>
    len -= n;
80108479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010847c:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010847f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108482:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108485:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108488:	05 00 10 00 00       	add    $0x1000,%eax
8010848d:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108490:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108494:	0f 85 6b ff ff ff    	jne    80108405 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010849a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010849f:	c9                   	leave  
801084a0:	c3                   	ret    
