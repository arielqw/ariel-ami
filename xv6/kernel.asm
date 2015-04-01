
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
8010003a:	c7 44 24 04 b0 84 10 	movl   $0x801084b0,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 14 4e 00 00       	call   80104e62 <initlock>

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
801000bd:	e8 c1 4d 00 00       	call   80104e83 <acquire>

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
80100104:	e8 dc 4d 00 00       	call   80104ee5 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 80 4a 00 00       	call   80104ba4 <sleep>
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
8010017c:	e8 64 4d 00 00       	call   80104ee5 <release>
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
80100198:	c7 04 24 b7 84 10 80 	movl   $0x801084b7,(%esp)
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
801001ef:	c7 04 24 c8 84 10 80 	movl   $0x801084c8,(%esp)
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
80100229:	c7 04 24 cf 84 10 80 	movl   $0x801084cf,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 42 4c 00 00       	call   80104e83 <acquire>

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
8010029d:	e8 db 49 00 00       	call   80104c7d <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 37 4c 00 00       	call   80104ee5 <release>
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
801003bc:	e8 c2 4a 00 00       	call   80104e83 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 d6 84 10 80 	movl   $0x801084d6,(%esp)
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
801004af:	c7 45 ec df 84 10 80 	movl   $0x801084df,-0x14(%ebp)
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
80100536:	e8 aa 49 00 00       	call   80104ee5 <release>
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
80100562:	c7 04 24 e6 84 10 80 	movl   $0x801084e6,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 f5 84 10 80 	movl   $0x801084f5,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 9d 49 00 00       	call   80104f34 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 f7 84 10 80 	movl   $0x801084f7,(%esp)
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
801006b2:	e8 ee 4a 00 00       	call   801051a5 <memmove>
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
801006e1:	e8 ec 49 00 00       	call   801050d2 <memset>
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
80100776:	e8 86 63 00 00       	call   80106b01 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 7a 63 00 00       	call   80106b01 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 6e 63 00 00       	call   80106b01 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 61 63 00 00       	call   80106b01 <uartputc>
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
801007ba:	e8 c4 46 00 00       	call   80104e83 <acquire>
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
801007ea:	e8 31 45 00 00       	call   80104d20 <procdump>
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
801008f7:	e8 81 43 00 00       	call   80104c7d <wakeup>
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
8010091e:	e8 c2 45 00 00       	call   80104ee5 <release>
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
80100943:	e8 3b 45 00 00       	call   80104e83 <acquire>
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
80100961:	e8 7f 45 00 00       	call   80104ee5 <release>
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
8010098a:	e8 15 42 00 00       	call   80104ba4 <sleep>
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
80100a08:	e8 d8 44 00 00       	call   80104ee5 <release>
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
80100a3e:	e8 40 44 00 00       	call   80104e83 <acquire>
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
80100a78:	e8 68 44 00 00       	call   80104ee5 <release>
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
80100a93:	c7 44 24 04 fb 84 10 	movl   $0x801084fb,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100aa2:	e8 bb 43 00 00       	call   80104e62 <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 03 85 10 	movl   $0x80108503,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100ab6:	e8 a7 43 00 00       	call   80104e62 <initlock>

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
80100b7e:	e8 c2 70 00 00       	call   80107c45 <setupkvm>
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
80100c17:	e8 fb 73 00 00       	call   80108017 <allocuvm>
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
80100c54:	e8 cf 72 00 00       	call   80107f28 <loaduvm>
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
80100cc4:	e8 4e 73 00 00       	call   80108017 <allocuvm>
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
80100ce8:	e8 4e 75 00 00       	call   8010823b <clearpteu>
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
80100d17:	e8 34 46 00 00       	call   80105350 <strlen>
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
80100d35:	e8 16 46 00 00       	call   80105350 <strlen>
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
80100d5f:	e8 9c 76 00 00       	call   80108400 <copyout>
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
80100dff:	e8 fc 75 00 00       	call   80108400 <copyout>
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
80100e56:	e8 a7 44 00 00       	call   80105302 <safestrcpy>

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
80100ea8:	e8 89 6e 00 00       	call   80107d36 <switchuvm>
  freevm(oldpgdir);
80100ead:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eb0:	89 04 24             	mov    %eax,(%esp)
80100eb3:	e8 f5 72 00 00       	call   801081ad <freevm>
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
80100eea:	e8 be 72 00 00       	call   801081ad <freevm>
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
80100f12:	c7 44 24 04 09 85 10 	movl   $0x80108509,0x4(%esp)
80100f19:	80 
80100f1a:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f21:	e8 3c 3f 00 00       	call   80104e62 <initlock>
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
80100f35:	e8 49 3f 00 00       	call   80104e83 <acquire>
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
80100f5e:	e8 82 3f 00 00       	call   80104ee5 <release>
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
80100f7c:	e8 64 3f 00 00       	call   80104ee5 <release>
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
80100f95:	e8 e9 3e 00 00       	call   80104e83 <acquire>
  if(f->ref < 1)
80100f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9d:	8b 40 04             	mov    0x4(%eax),%eax
80100fa0:	85 c0                	test   %eax,%eax
80100fa2:	7f 0c                	jg     80100fb0 <filedup+0x28>
    panic("filedup");
80100fa4:	c7 04 24 10 85 10 80 	movl   $0x80108510,(%esp)
80100fab:	e8 8d f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb3:	8b 40 04             	mov    0x4(%eax),%eax
80100fb6:	8d 50 01             	lea    0x1(%eax),%edx
80100fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fbc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbf:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fc6:	e8 1a 3f 00 00       	call   80104ee5 <release>
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
80100fdd:	e8 a1 3e 00 00       	call   80104e83 <acquire>
  if(f->ref < 1)
80100fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe5:	8b 40 04             	mov    0x4(%eax),%eax
80100fe8:	85 c0                	test   %eax,%eax
80100fea:	7f 0c                	jg     80100ff8 <fileclose+0x28>
    panic("fileclose");
80100fec:	c7 04 24 18 85 10 80 	movl   $0x80108518,(%esp)
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
80101018:	e8 c8 3e 00 00       	call   80104ee5 <release>
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
80101062:	e8 7e 3e 00 00       	call   80104ee5 <release>
  
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
801011a3:	c7 04 24 22 85 10 80 	movl   $0x80108522,(%esp)
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
801012af:	c7 04 24 2b 85 10 80 	movl   $0x8010852b,(%esp)
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
801012e4:	c7 04 24 3b 85 10 80 	movl   $0x8010853b,(%esp)
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
8010132c:	e8 74 3e 00 00       	call   801051a5 <memmove>
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
80101372:	e8 5b 3d 00 00       	call   801050d2 <memset>
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
801014da:	c7 04 24 45 85 10 80 	movl   $0x80108545,(%esp)
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
80101571:	c7 04 24 5b 85 10 80 	movl   $0x8010855b,(%esp)
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
801015c5:	c7 44 24 04 6e 85 10 	movl   $0x8010856e,0x4(%esp)
801015cc:	80 
801015cd:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801015d4:	e8 89 38 00 00       	call   80104e62 <initlock>
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
80101656:	e8 77 3a 00 00       	call   801050d2 <memset>
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
801016ac:	c7 04 24 75 85 10 80 	movl   $0x80108575,(%esp)
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
80101753:	e8 4d 3a 00 00       	call   801051a5 <memmove>
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
8010177d:	e8 01 37 00 00       	call   80104e83 <acquire>

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
801017c7:	e8 19 37 00 00       	call   80104ee5 <release>
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
801017fa:	c7 04 24 87 85 10 80 	movl   $0x80108587,(%esp)
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
80101838:	e8 a8 36 00 00       	call   80104ee5 <release>

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
8010184f:	e8 2f 36 00 00       	call   80104e83 <acquire>
  ip->ref++;
80101854:	8b 45 08             	mov    0x8(%ebp),%eax
80101857:	8b 40 08             	mov    0x8(%eax),%eax
8010185a:	8d 50 01             	lea    0x1(%eax),%edx
8010185d:	8b 45 08             	mov    0x8(%ebp),%eax
80101860:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101863:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010186a:	e8 76 36 00 00       	call   80104ee5 <release>
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
8010188a:	c7 04 24 97 85 10 80 	movl   $0x80108597,(%esp)
80101891:	e8 a7 ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101896:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010189d:	e8 e1 35 00 00       	call   80104e83 <acquire>
  while(ip->flags & I_BUSY)
801018a2:	eb 13                	jmp    801018b7 <ilock+0x43>
    sleep(ip, &icache.lock);
801018a4:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801018ab:	80 
801018ac:	8b 45 08             	mov    0x8(%ebp),%eax
801018af:	89 04 24             	mov    %eax,(%esp)
801018b2:	e8 ed 32 00 00       	call   80104ba4 <sleep>

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
801018dc:	e8 04 36 00 00       	call   80104ee5 <release>

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
80101987:	e8 19 38 00 00       	call   801051a5 <memmove>
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
801019b4:	c7 04 24 9d 85 10 80 	movl   $0x8010859d,(%esp)
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
801019e5:	c7 04 24 ac 85 10 80 	movl   $0x801085ac,(%esp)
801019ec:	e8 4c eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801019f1:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801019f8:	e8 86 34 00 00       	call   80104e83 <acquire>
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
80101a14:	e8 64 32 00 00       	call   80104c7d <wakeup>
  release(&icache.lock);
80101a19:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a20:	e8 c0 34 00 00       	call   80104ee5 <release>
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
80101a34:	e8 4a 34 00 00       	call   80104e83 <acquire>
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
80101a72:	c7 04 24 b4 85 10 80 	movl   $0x801085b4,(%esp)
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
80101a96:	e8 4a 34 00 00       	call   80104ee5 <release>
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
80101ac1:	e8 bd 33 00 00       	call   80104e83 <acquire>
    ip->flags = 0;
80101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	89 04 24             	mov    %eax,(%esp)
80101ad6:	e8 a2 31 00 00       	call   80104c7d <wakeup>
  }
  ip->ref--;
80101adb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ade:	8b 40 08             	mov    0x8(%eax),%eax
80101ae1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101aea:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101af1:	e8 ef 33 00 00       	call   80104ee5 <release>
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
80101c06:	c7 04 24 be 85 10 80 	movl   $0x801085be,(%esp)
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
80101e9e:	e8 02 33 00 00       	call   801051a5 <memmove>
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
80102004:	e8 9c 31 00 00       	call   801051a5 <memmove>
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
80102086:	e8 be 31 00 00       	call   80105249 <strncmp>
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
801020a0:	c7 04 24 d1 85 10 80 	movl   $0x801085d1,(%esp)
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
801020de:	c7 04 24 e3 85 10 80 	movl   $0x801085e3,(%esp)
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
801021c2:	c7 04 24 e3 85 10 80 	movl   $0x801085e3,(%esp)
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
80102208:	e8 94 30 00 00       	call   801052a1 <strncpy>
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
8010223a:	c7 04 24 f0 85 10 80 	movl   $0x801085f0,(%esp)
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
801022c1:	e8 df 2e 00 00       	call   801051a5 <memmove>
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
801022dc:	e8 c4 2e 00 00       	call   801051a5 <memmove>
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
80102538:	c7 44 24 04 f8 85 10 	movl   $0x801085f8,0x4(%esp)
8010253f:	80 
80102540:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102547:	e8 16 29 00 00       	call   80104e62 <initlock>
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
801025e4:	c7 04 24 fc 85 10 80 	movl   $0x801085fc,(%esp)
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
8010270a:	e8 74 27 00 00       	call   80104e83 <acquire>
  if((b = idequeue) == 0){
8010270f:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102714:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010271b:	75 11                	jne    8010272e <ideintr+0x31>
    release(&idelock);
8010271d:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102724:	e8 bc 27 00 00       	call   80104ee5 <release>
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
80102797:	e8 e1 24 00 00       	call   80104c7d <wakeup>
  
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
801027b9:	e8 27 27 00 00       	call   80104ee5 <release>
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
801027d2:	c7 04 24 05 86 10 80 	movl   $0x80108605,(%esp)
801027d9:	e8 5f dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027de:	8b 45 08             	mov    0x8(%ebp),%eax
801027e1:	8b 00                	mov    (%eax),%eax
801027e3:	83 e0 06             	and    $0x6,%eax
801027e6:	83 f8 02             	cmp    $0x2,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x37>
    panic("iderw: nothing to do");
801027eb:	c7 04 24 19 86 10 80 	movl   $0x80108619,(%esp)
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
8010280a:	c7 04 24 2e 86 10 80 	movl   $0x8010862e,(%esp)
80102811:	e8 27 dd ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102816:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010281d:	e8 61 26 00 00       	call   80104e83 <acquire>

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
80102876:	e8 29 23 00 00       	call   80104ba4 <sleep>
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
80102892:	e8 4e 26 00 00       	call   80104ee5 <release>
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
80102922:	c7 04 24 4c 86 10 80 	movl   $0x8010864c,(%esp)
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
801029e3:	c7 44 24 04 7e 86 10 	movl   $0x8010867e,0x4(%esp)
801029ea:	80 
801029eb:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
801029f2:	e8 6b 24 00 00       	call   80104e62 <initlock>
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
80102a9f:	c7 04 24 83 86 10 80 	movl   $0x80108683,(%esp)
80102aa6:	e8 92 da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102aab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102ab2:	00 
80102ab3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102aba:	00 
80102abb:	8b 45 08             	mov    0x8(%ebp),%eax
80102abe:	89 04 24             	mov    %eax,(%esp)
80102ac1:	e8 0c 26 00 00       	call   801050d2 <memset>

  if(kmem.use_lock)
80102ac6:	a1 54 22 11 80       	mov    0x80112254,%eax
80102acb:	85 c0                	test   %eax,%eax
80102acd:	74 0c                	je     80102adb <kfree+0x69>
    acquire(&kmem.lock);
80102acf:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102ad6:	e8 a8 23 00 00       	call   80104e83 <acquire>
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
80102b04:	e8 dc 23 00 00       	call   80104ee5 <release>
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
80102b21:	e8 5d 23 00 00       	call   80104e83 <acquire>
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
80102b4e:	e8 92 23 00 00       	call   80104ee5 <release>
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
80102ef4:	c7 04 24 8c 86 10 80 	movl   $0x8010868c,(%esp)
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
80103158:	e8 ec 1f 00 00       	call   80105149 <memcmp>
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
8010325a:	c7 44 24 04 b8 86 10 	movl   $0x801086b8,0x4(%esp)
80103261:	80 
80103262:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103269:	e8 f4 1b 00 00       	call   80104e62 <initlock>
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
8010331c:	e8 84 1e 00 00       	call   801051a5 <memmove>
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
8010346e:	e8 10 1a 00 00       	call   80104e83 <acquire>
  while(1){
    if(log.committing){
80103473:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103478:	85 c0                	test   %eax,%eax
8010347a:	74 16                	je     80103492 <begin_op+0x31>
      sleep(&log, &log.lock);
8010347c:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103483:	80 
80103484:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010348b:	e8 14 17 00 00       	call   80104ba4 <sleep>
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
801034bf:	e8 e0 16 00 00       	call   80104ba4 <sleep>
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
801034da:	e8 06 1a 00 00       	call   80104ee5 <release>
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
801034f6:	e8 88 19 00 00       	call   80104e83 <acquire>
  log.outstanding -= 1;
801034fb:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103500:	83 e8 01             	sub    $0x1,%eax
80103503:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
80103508:	a1 a0 22 11 80       	mov    0x801122a0,%eax
8010350d:	85 c0                	test   %eax,%eax
8010350f:	74 0c                	je     8010351d <end_op+0x3b>
    panic("log.committing");
80103511:	c7 04 24 bc 86 10 80 	movl   $0x801086bc,(%esp)
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
80103540:	e8 38 17 00 00       	call   80104c7d <wakeup>
  }
  release(&log.lock);
80103545:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010354c:	e8 94 19 00 00       	call   80104ee5 <release>

  if(do_commit){
80103551:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103555:	74 33                	je     8010358a <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103557:	e8 db 00 00 00       	call   80103637 <commit>
    acquire(&log.lock);
8010355c:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103563:	e8 1b 19 00 00       	call   80104e83 <acquire>
    log.committing = 0;
80103568:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
8010356f:	00 00 00 
    wakeup(&log);
80103572:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103579:	e8 ff 16 00 00       	call   80104c7d <wakeup>
    release(&log.lock);
8010357e:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103585:	e8 5b 19 00 00       	call   80104ee5 <release>
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
801035fd:	e8 a3 1b 00 00       	call   801051a5 <memmove>
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
80103688:	c7 04 24 cb 86 10 80 	movl   $0x801086cb,(%esp)
8010368f:	e8 a9 ce ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
80103694:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103699:	85 c0                	test   %eax,%eax
8010369b:	7f 0c                	jg     801036a9 <log_write+0x43>
    panic("log_write outside of trans");
8010369d:	c7 04 24 e1 86 10 80 	movl   $0x801086e1,(%esp)
801036a4:	e8 94 ce ff ff       	call   8010053d <panic>

  acquire(&log.lock);
801036a9:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036b0:	e8 ce 17 00 00       	call   80104e83 <acquire>
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
80103728:	e8 b8 17 00 00       	call   80104ee5 <release>
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
8010378c:	e8 71 45 00 00       	call   80107d02 <kvmalloc>
  mpinit();        // collect info about this machine
80103791:	e8 53 04 00 00       	call   80103be9 <mpinit>
  lapicinit();
80103796:	e8 cb f5 ff ff       	call   80102d66 <lapicinit>
  seginit();       // set up segments
8010379b:	e8 05 3f 00 00       	call   801076a5 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037a0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037a6:	0f b6 00             	movzbl (%eax),%eax
801037a9:	0f b6 c0             	movzbl %al,%eax
801037ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801037b0:	c7 04 24 fc 86 10 80 	movl   $0x801086fc,(%esp)
801037b7:	e8 e5 cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037bc:	e8 8d 06 00 00       	call   80103e4e <picinit>
  ioapicinit();    // another interrupt controller
801037c1:	e8 07 f1 ff ff       	call   801028cd <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037c6:	e8 c2 d2 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
801037cb:	e8 20 32 00 00       	call   801069f0 <uartinit>
  pinit();         // process table
801037d0:	e8 8e 0b 00 00       	call   80104363 <pinit>
  tvinit();        // trap vectors
801037d5:	e8 9d 2d 00 00       	call   80106577 <tvinit>
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
801037f7:	e8 be 2c 00 00       	call   801064ba <timerinit>
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
80103825:	e8 ef 44 00 00       	call   80107d19 <switchkvm>
  seginit();
8010382a:	e8 76 3e 00 00       	call   801076a5 <seginit>
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
8010384f:	c7 04 24 13 87 10 80 	movl   $0x80108713,(%esp)
80103856:	e8 46 cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
8010385b:	e8 8b 2e 00 00       	call   801066eb <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103860:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103866:	05 a8 00 00 00       	add    $0xa8,%eax
8010386b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103872:	00 
80103873:	89 04 24             	mov    %eax,(%esp)
80103876:	e8 cf fe ff ff       	call   8010374a <xchg>
  scheduler();     // start running processes
8010387b:	e8 7b 11 00 00       	call   801049fb <scheduler>

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
801038ad:	e8 f3 18 00 00       	call   801051a5 <memmove>

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
80103a3c:	c7 44 24 04 24 87 10 	movl   $0x80108724,0x4(%esp)
80103a43:	80 
80103a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a47:	89 04 24             	mov    %eax,(%esp)
80103a4a:	e8 fa 16 00 00       	call   80105149 <memcmp>
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
80103b7d:	c7 44 24 04 29 87 10 	movl   $0x80108729,0x4(%esp)
80103b84:	80 
80103b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b88:	89 04 24             	mov    %eax,(%esp)
80103b8b:	e8 b9 15 00 00       	call   80105149 <memcmp>
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
80103c56:	8b 04 85 6c 87 10 80 	mov    -0x7fef7894(,%eax,4),%eax
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
80103c8f:	c7 04 24 2e 87 10 80 	movl   $0x8010872e,(%esp)
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
80103d22:	c7 04 24 4c 87 10 80 	movl   $0x8010874c,(%esp)
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
80104027:	c7 44 24 04 80 87 10 	movl   $0x80108780,0x4(%esp)
8010402e:	80 
8010402f:	89 04 24             	mov    %eax,(%esp)
80104032:	e8 2b 0e 00 00       	call   80104e62 <initlock>
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
801040df:	e8 9f 0d 00 00       	call   80104e83 <acquire>
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
80104102:	e8 76 0b 00 00       	call   80104c7d <wakeup>
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
80104121:	e8 57 0b 00 00       	call   80104c7d <wakeup>
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
80104146:	e8 9a 0d 00 00       	call   80104ee5 <release>
    kfree((char*)p);
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	89 04 24             	mov    %eax,(%esp)
80104151:	e8 1c e9 ff ff       	call   80102a72 <kfree>
80104156:	eb 0b                	jmp    80104163 <pipeclose+0x90>
  } else
    release(&p->lock);
80104158:	8b 45 08             	mov    0x8(%ebp),%eax
8010415b:	89 04 24             	mov    %eax,(%esp)
8010415e:	e8 82 0d 00 00       	call   80104ee5 <release>
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
80104172:	e8 0c 0d 00 00       	call   80104e83 <acquire>
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
801041a3:	e8 3d 0d 00 00       	call   80104ee5 <release>
        return -1;
801041a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ad:	e9 9d 00 00 00       	jmp    8010424f <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041b2:	8b 45 08             	mov    0x8(%ebp),%eax
801041b5:	05 34 02 00 00       	add    $0x234,%eax
801041ba:	89 04 24             	mov    %eax,(%esp)
801041bd:	e8 bb 0a 00 00       	call   80104c7d <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041c2:	8b 45 08             	mov    0x8(%ebp),%eax
801041c5:	8b 55 08             	mov    0x8(%ebp),%edx
801041c8:	81 c2 38 02 00 00    	add    $0x238,%edx
801041ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801041d2:	89 14 24             	mov    %edx,(%esp)
801041d5:	e8 ca 09 00 00       	call   80104ba4 <sleep>
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
8010423c:	e8 3c 0a 00 00       	call   80104c7d <wakeup>
  release(&p->lock);
80104241:	8b 45 08             	mov    0x8(%ebp),%eax
80104244:	89 04 24             	mov    %eax,(%esp)
80104247:	e8 99 0c 00 00       	call   80104ee5 <release>
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
80104262:	e8 1c 0c 00 00       	call   80104e83 <acquire>
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
8010427c:	e8 64 0c 00 00       	call   80104ee5 <release>
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
8010429e:	e8 01 09 00 00       	call   80104ba4 <sleep>
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
8010432e:	e8 4a 09 00 00       	call   80104c7d <wakeup>
  release(&p->lock);
80104333:	8b 45 08             	mov    0x8(%ebp),%eax
80104336:	89 04 24             	mov    %eax,(%esp)
80104339:	e8 a7 0b 00 00       	call   80104ee5 <release>
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
80104369:	c7 44 24 04 85 87 10 	movl   $0x80108785,0x4(%esp)
80104370:	80 
80104371:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104378:	e8 e5 0a 00 00       	call   80104e62 <initlock>
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
8010438c:	e8 f2 0a 00 00       	call   80104e83 <acquire>
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
801043b8:	e8 28 0b 00 00       	call   80104ee5 <release>
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
801043ec:	e8 f4 0a 00 00       	call   80104ee5 <release>

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
80104436:	ba 2c 65 10 80       	mov    $0x8010652c,%edx
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
80104466:	e8 67 0c 00 00       	call   801050d2 <memset>
  p->context->eip = (uint)forkret;
8010446b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104471:	ba 78 4b 10 80       	mov    $0x80104b78,%edx
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
80104494:	e8 ac 37 00 00       	call   80107c45 <setupkvm>
80104499:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010449c:	89 42 04             	mov    %eax,0x4(%edx)
8010449f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a2:	8b 40 04             	mov    0x4(%eax),%eax
801044a5:	85 c0                	test   %eax,%eax
801044a7:	75 0c                	jne    801044b5 <userinit+0x37>
    panic("userinit: out of memory?");
801044a9:	c7 04 24 8c 87 10 80 	movl   $0x8010878c,(%esp)
801044b0:	e8 88 c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044b5:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bd:	8b 40 04             	mov    0x4(%eax),%eax
801044c0:	89 54 24 08          	mov    %edx,0x8(%esp)
801044c4:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044cb:	80 
801044cc:	89 04 24             	mov    %eax,(%esp)
801044cf:	e8 c9 39 00 00       	call   80107e9d <inituvm>
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
801044f6:	e8 d7 0b 00 00       	call   801050d2 <memset>
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
80104570:	c7 44 24 04 a5 87 10 	movl   $0x801087a5,0x4(%esp)
80104577:	80 
80104578:	89 04 24             	mov    %eax,(%esp)
8010457b:	e8 82 0d 00 00       	call   80105302 <safestrcpy>
  p->cwd = namei("/");
80104580:	c7 04 24 ae 87 10 80 	movl   $0x801087ae,(%esp)
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
801045d4:	e8 3e 3a 00 00       	call   80108017 <allocuvm>
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
8010460e:	e8 de 3a 00 00       	call   801080f1 <deallocuvm>
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
80104637:	e8 fa 36 00 00       	call   80107d36 <switchuvm>
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
8010467c:	e8 00 3c 00 00       	call   80108281 <copyuvm>
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
80104783:	e8 7a 0b 00 00       	call   80105302 <safestrcpy>
 
  pid = np->pid;
80104788:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478b:	8b 40 10             	mov    0x10(%eax),%eax
8010478e:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104791:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104798:	e8 e6 06 00 00       	call   80104e83 <acquire>
  np->state = RUNNABLE;
8010479d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801047a7:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047ae:	e8 32 07 00 00       	call   80104ee5 <release>
  
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
801047d4:	c7 04 24 b0 87 10 80 	movl   $0x801087b0,(%esp)
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

  proc->status = status;
8010485b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104861:	8b 55 08             	mov    0x8(%ebp),%edx
80104864:	89 50 7c             	mov    %edx,0x7c(%eax)
  acquire(&ptable.lock);
80104867:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
8010486e:	e8 10 06 00 00       	call   80104e83 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104873:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104879:	8b 40 14             	mov    0x14(%eax),%eax
8010487c:	89 04 24             	mov    %eax,(%esp)
8010487f:	e8 bb 03 00 00       	call   80104c3f <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104884:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
8010488b:	eb 38                	jmp    801048c5 <exit+0x107>
    if(p->parent == proc){
8010488d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104890:	8b 50 14             	mov    0x14(%eax),%edx
80104893:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104899:	39 c2                	cmp    %eax,%edx
8010489b:	75 24                	jne    801048c1 <exit+0x103>
      p->parent = initproc;
8010489d:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801048a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a6:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ac:	8b 40 0c             	mov    0xc(%eax),%eax
801048af:	83 f8 05             	cmp    $0x5,%eax
801048b2:	75 0d                	jne    801048c1 <exit+0x103>
        wakeup1(initproc);
801048b4:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048b9:	89 04 24             	mov    %eax,(%esp)
801048bc:	e8 7e 03 00 00       	call   80104c3f <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048c1:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801048c5:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
801048cc:	72 bf                	jb     8010488d <exit+0xcf>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801048ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d4:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048db:	e8 b4 01 00 00       	call   80104a94 <sched>
  panic("zombie exit");
801048e0:	c7 04 24 bd 87 10 80 	movl   $0x801087bd,(%esp)
801048e7:	e8 51 bc ff ff       	call   8010053d <panic>

801048ec <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801048ec:	55                   	push   %ebp
801048ed:	89 e5                	mov    %esp,%ebp
801048ef:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801048f2:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801048f9:	e8 85 05 00 00       	call   80104e83 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801048fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104905:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
8010490c:	e9 9a 00 00 00       	jmp    801049ab <wait+0xbf>
      if(p->parent != proc)
80104911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104914:	8b 50 14             	mov    0x14(%eax),%edx
80104917:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010491d:	39 c2                	cmp    %eax,%edx
8010491f:	0f 85 81 00 00 00    	jne    801049a6 <wait+0xba>
        continue;
      havekids = 1;
80104925:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010492c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492f:	8b 40 0c             	mov    0xc(%eax),%eax
80104932:	83 f8 05             	cmp    $0x5,%eax
80104935:	75 70                	jne    801049a7 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493a:	8b 40 10             	mov    0x10(%eax),%eax
8010493d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104943:	8b 40 08             	mov    0x8(%eax),%eax
80104946:	89 04 24             	mov    %eax,(%esp)
80104949:	e8 24 e1 ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
8010494e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104951:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495b:	8b 40 04             	mov    0x4(%eax),%eax
8010495e:	89 04 24             	mov    %eax,(%esp)
80104961:	e8 47 38 00 00       	call   801081ad <freevm>
        p->state = UNUSED;
80104966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104969:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104973:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010497a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104987:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010498b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498e:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104995:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
8010499c:	e8 44 05 00 00       	call   80104ee5 <release>
        return pid;
801049a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049a4:	eb 53                	jmp    801049f9 <wait+0x10d>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049a6:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049a7:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801049ab:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
801049b2:	0f 82 59 ff ff ff    	jb     80104911 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049bc:	74 0d                	je     801049cb <wait+0xdf>
801049be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c4:	8b 40 24             	mov    0x24(%eax),%eax
801049c7:	85 c0                	test   %eax,%eax
801049c9:	74 13                	je     801049de <wait+0xf2>
      release(&ptable.lock);
801049cb:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801049d2:	e8 0e 05 00 00       	call   80104ee5 <release>
      return -1;
801049d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049dc:	eb 1b                	jmp    801049f9 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801049de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e4:	c7 44 24 04 60 29 11 	movl   $0x80112960,0x4(%esp)
801049eb:	80 
801049ec:	89 04 24             	mov    %eax,(%esp)
801049ef:	e8 b0 01 00 00       	call   80104ba4 <sleep>
  }
801049f4:	e9 05 ff ff ff       	jmp    801048fe <wait+0x12>
}
801049f9:	c9                   	leave  
801049fa:	c3                   	ret    

801049fb <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801049fb:	55                   	push   %ebp
801049fc:	89 e5                	mov    %esp,%ebp
801049fe:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a01:	e8 57 f9 ff ff       	call   8010435d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a06:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a0d:	e8 71 04 00 00       	call   80104e83 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a12:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104a19:	eb 5f                	jmp    80104a7a <scheduler+0x7f>
      if(p->state != RUNNABLE)
80104a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1e:	8b 40 0c             	mov    0xc(%eax),%eax
80104a21:	83 f8 03             	cmp    $0x3,%eax
80104a24:	75 4f                	jne    80104a75 <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a29:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a32:	89 04 24             	mov    %eax,(%esp)
80104a35:	e8 fc 32 00 00       	call   80107d36 <switchuvm>
      p->state = RUNNING;
80104a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104a44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a4a:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a4d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104a54:	83 c2 04             	add    $0x4,%edx
80104a57:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a5b:	89 14 24             	mov    %edx,(%esp)
80104a5e:	e8 15 09 00 00       	call   80105378 <swtch>
      switchkvm();
80104a63:	e8 b1 32 00 00       	call   80107d19 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104a68:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104a6f:	00 00 00 00 
80104a73:	eb 01                	jmp    80104a76 <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104a75:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a76:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104a7a:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
80104a81:	72 98                	jb     80104a1b <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104a83:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a8a:	e8 56 04 00 00       	call   80104ee5 <release>

  }
80104a8f:	e9 6d ff ff ff       	jmp    80104a01 <scheduler+0x6>

80104a94 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104a94:	55                   	push   %ebp
80104a95:	89 e5                	mov    %esp,%ebp
80104a97:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104a9a:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104aa1:	e8 fb 04 00 00       	call   80104fa1 <holding>
80104aa6:	85 c0                	test   %eax,%eax
80104aa8:	75 0c                	jne    80104ab6 <sched+0x22>
    panic("sched ptable.lock");
80104aaa:	c7 04 24 c9 87 10 80 	movl   $0x801087c9,(%esp)
80104ab1:	e8 87 ba ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104ab6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104abc:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104ac2:	83 f8 01             	cmp    $0x1,%eax
80104ac5:	74 0c                	je     80104ad3 <sched+0x3f>
    panic("sched locks");
80104ac7:	c7 04 24 db 87 10 80 	movl   $0x801087db,(%esp)
80104ace:	e8 6a ba ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104ad3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ad9:	8b 40 0c             	mov    0xc(%eax),%eax
80104adc:	83 f8 04             	cmp    $0x4,%eax
80104adf:	75 0c                	jne    80104aed <sched+0x59>
    panic("sched running");
80104ae1:	c7 04 24 e7 87 10 80 	movl   $0x801087e7,(%esp)
80104ae8:	e8 50 ba ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104aed:	e8 56 f8 ff ff       	call   80104348 <readeflags>
80104af2:	25 00 02 00 00       	and    $0x200,%eax
80104af7:	85 c0                	test   %eax,%eax
80104af9:	74 0c                	je     80104b07 <sched+0x73>
    panic("sched interruptible");
80104afb:	c7 04 24 f5 87 10 80 	movl   $0x801087f5,(%esp)
80104b02:	e8 36 ba ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104b07:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b0d:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104b13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104b16:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b1c:	8b 40 04             	mov    0x4(%eax),%eax
80104b1f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b26:	83 c2 1c             	add    $0x1c,%edx
80104b29:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b2d:	89 14 24             	mov    %edx,(%esp)
80104b30:	e8 43 08 00 00       	call   80105378 <swtch>
  cpu->intena = intena;
80104b35:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b3e:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104b44:	c9                   	leave  
80104b45:	c3                   	ret    

80104b46 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b46:	55                   	push   %ebp
80104b47:	89 e5                	mov    %esp,%ebp
80104b49:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b4c:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b53:	e8 2b 03 00 00       	call   80104e83 <acquire>
  proc->state = RUNNABLE;
80104b58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b5e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b65:	e8 2a ff ff ff       	call   80104a94 <sched>
  release(&ptable.lock);
80104b6a:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b71:	e8 6f 03 00 00       	call   80104ee5 <release>
}
80104b76:	c9                   	leave  
80104b77:	c3                   	ret    

80104b78 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b78:	55                   	push   %ebp
80104b79:	89 e5                	mov    %esp,%ebp
80104b7b:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b7e:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b85:	e8 5b 03 00 00       	call   80104ee5 <release>

  if (first) {
80104b8a:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104b8f:	85 c0                	test   %eax,%eax
80104b91:	74 0f                	je     80104ba2 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104b93:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104b9a:	00 00 00 
    initlog();
80104b9d:	e8 b2 e6 ff ff       	call   80103254 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104ba2:	c9                   	leave  
80104ba3:	c3                   	ret    

80104ba4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104ba4:	55                   	push   %ebp
80104ba5:	89 e5                	mov    %esp,%ebp
80104ba7:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104baa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bb0:	85 c0                	test   %eax,%eax
80104bb2:	75 0c                	jne    80104bc0 <sleep+0x1c>
    panic("sleep");
80104bb4:	c7 04 24 09 88 10 80 	movl   $0x80108809,(%esp)
80104bbb:	e8 7d b9 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104bc0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104bc4:	75 0c                	jne    80104bd2 <sleep+0x2e>
    panic("sleep without lk");
80104bc6:	c7 04 24 0f 88 10 80 	movl   $0x8010880f,(%esp)
80104bcd:	e8 6b b9 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104bd2:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104bd9:	74 17                	je     80104bf2 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104bdb:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104be2:	e8 9c 02 00 00       	call   80104e83 <acquire>
    release(lk);
80104be7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bea:	89 04 24             	mov    %eax,(%esp)
80104bed:	e8 f3 02 00 00       	call   80104ee5 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104bf2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf8:	8b 55 08             	mov    0x8(%ebp),%edx
80104bfb:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104bfe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c04:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104c0b:	e8 84 fe ff ff       	call   80104a94 <sched>

  // Tidy up.
  proc->chan = 0;
80104c10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c16:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c1d:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104c24:	74 17                	je     80104c3d <sleep+0x99>
    release(&ptable.lock);
80104c26:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c2d:	e8 b3 02 00 00       	call   80104ee5 <release>
    acquire(lk);
80104c32:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c35:	89 04 24             	mov    %eax,(%esp)
80104c38:	e8 46 02 00 00       	call   80104e83 <acquire>
  }
}
80104c3d:	c9                   	leave  
80104c3e:	c3                   	ret    

80104c3f <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c3f:	55                   	push   %ebp
80104c40:	89 e5                	mov    %esp,%ebp
80104c42:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c45:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104c4c:	eb 24                	jmp    80104c72 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104c4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c51:	8b 40 0c             	mov    0xc(%eax),%eax
80104c54:	83 f8 02             	cmp    $0x2,%eax
80104c57:	75 15                	jne    80104c6e <wakeup1+0x2f>
80104c59:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c5c:	8b 40 20             	mov    0x20(%eax),%eax
80104c5f:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c62:	75 0a                	jne    80104c6e <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c64:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c67:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c6e:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104c72:	81 7d fc 94 49 11 80 	cmpl   $0x80114994,-0x4(%ebp)
80104c79:	72 d3                	jb     80104c4e <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c7b:	c9                   	leave  
80104c7c:	c3                   	ret    

80104c7d <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c7d:	55                   	push   %ebp
80104c7e:	89 e5                	mov    %esp,%ebp
80104c80:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104c83:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c8a:	e8 f4 01 00 00       	call   80104e83 <acquire>
  wakeup1(chan);
80104c8f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c92:	89 04 24             	mov    %eax,(%esp)
80104c95:	e8 a5 ff ff ff       	call   80104c3f <wakeup1>
  release(&ptable.lock);
80104c9a:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ca1:	e8 3f 02 00 00       	call   80104ee5 <release>
}
80104ca6:	c9                   	leave  
80104ca7:	c3                   	ret    

80104ca8 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ca8:	55                   	push   %ebp
80104ca9:	89 e5                	mov    %esp,%ebp
80104cab:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104cae:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104cb5:	e8 c9 01 00 00       	call   80104e83 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cba:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104cc1:	eb 41                	jmp    80104d04 <kill+0x5c>
    if(p->pid == pid){
80104cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc6:	8b 40 10             	mov    0x10(%eax),%eax
80104cc9:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ccc:	75 32                	jne    80104d00 <kill+0x58>
      p->killed = 1;
80104cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cdb:	8b 40 0c             	mov    0xc(%eax),%eax
80104cde:	83 f8 02             	cmp    $0x2,%eax
80104ce1:	75 0a                	jne    80104ced <kill+0x45>
        p->state = RUNNABLE;
80104ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104ced:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104cf4:	e8 ec 01 00 00       	call   80104ee5 <release>
      return 0;
80104cf9:	b8 00 00 00 00       	mov    $0x0,%eax
80104cfe:	eb 1e                	jmp    80104d1e <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d00:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104d04:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
80104d0b:	72 b6                	jb     80104cc3 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d0d:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d14:	e8 cc 01 00 00       	call   80104ee5 <release>
  return -1;
80104d19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d1e:	c9                   	leave  
80104d1f:	c3                   	ret    

80104d20 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d20:	55                   	push   %ebp
80104d21:	89 e5                	mov    %esp,%ebp
80104d23:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d26:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104d2d:	e9 d8 00 00 00       	jmp    80104e0a <procdump+0xea>
    if(p->state == UNUSED)
80104d32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d35:	8b 40 0c             	mov    0xc(%eax),%eax
80104d38:	85 c0                	test   %eax,%eax
80104d3a:	0f 84 c5 00 00 00    	je     80104e05 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d43:	8b 40 0c             	mov    0xc(%eax),%eax
80104d46:	83 f8 05             	cmp    $0x5,%eax
80104d49:	77 23                	ja     80104d6e <procdump+0x4e>
80104d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d4e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d51:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104d58:	85 c0                	test   %eax,%eax
80104d5a:	74 12                	je     80104d6e <procdump+0x4e>
      state = states[p->state];
80104d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d5f:	8b 40 0c             	mov    0xc(%eax),%eax
80104d62:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104d69:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d6c:	eb 07                	jmp    80104d75 <procdump+0x55>
    else
      state = "???";
80104d6e:	c7 45 ec 20 88 10 80 	movl   $0x80108820,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d78:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d7e:	8b 40 10             	mov    0x10(%eax),%eax
80104d81:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104d85:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d88:	89 54 24 08          	mov    %edx,0x8(%esp)
80104d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d90:	c7 04 24 24 88 10 80 	movl   $0x80108824,(%esp)
80104d97:	e8 05 b6 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d9f:	8b 40 0c             	mov    0xc(%eax),%eax
80104da2:	83 f8 02             	cmp    $0x2,%eax
80104da5:	75 50                	jne    80104df7 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104daa:	8b 40 1c             	mov    0x1c(%eax),%eax
80104dad:	8b 40 0c             	mov    0xc(%eax),%eax
80104db0:	83 c0 08             	add    $0x8,%eax
80104db3:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104db6:	89 54 24 04          	mov    %edx,0x4(%esp)
80104dba:	89 04 24             	mov    %eax,(%esp)
80104dbd:	e8 72 01 00 00       	call   80104f34 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104dc2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104dc9:	eb 1b                	jmp    80104de6 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dce:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dd6:	c7 04 24 2d 88 10 80 	movl   $0x8010882d,(%esp)
80104ddd:	e8 bf b5 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104de2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104de6:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104dea:	7f 0b                	jg     80104df7 <procdump+0xd7>
80104dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104def:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104df3:	85 c0                	test   %eax,%eax
80104df5:	75 d4                	jne    80104dcb <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104df7:	c7 04 24 31 88 10 80 	movl   $0x80108831,(%esp)
80104dfe:	e8 9e b5 ff ff       	call   801003a1 <cprintf>
80104e03:	eb 01                	jmp    80104e06 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104e05:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e06:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104e0a:	81 7d f0 94 49 11 80 	cmpl   $0x80114994,-0x10(%ebp)
80104e11:	0f 82 1b ff ff ff    	jb     80104d32 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104e17:	c9                   	leave  
80104e18:	c3                   	ret    
80104e19:	00 00                	add    %al,(%eax)
	...

80104e1c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104e1c:	55                   	push   %ebp
80104e1d:	89 e5                	mov    %esp,%ebp
80104e1f:	53                   	push   %ebx
80104e20:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104e23:	9c                   	pushf  
80104e24:	5b                   	pop    %ebx
80104e25:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104e28:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104e2b:	83 c4 10             	add    $0x10,%esp
80104e2e:	5b                   	pop    %ebx
80104e2f:	5d                   	pop    %ebp
80104e30:	c3                   	ret    

80104e31 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104e31:	55                   	push   %ebp
80104e32:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104e34:	fa                   	cli    
}
80104e35:	5d                   	pop    %ebp
80104e36:	c3                   	ret    

80104e37 <sti>:

static inline void
sti(void)
{
80104e37:	55                   	push   %ebp
80104e38:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104e3a:	fb                   	sti    
}
80104e3b:	5d                   	pop    %ebp
80104e3c:	c3                   	ret    

80104e3d <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104e3d:	55                   	push   %ebp
80104e3e:	89 e5                	mov    %esp,%ebp
80104e40:	53                   	push   %ebx
80104e41:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104e44:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104e47:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104e4d:	89 c3                	mov    %eax,%ebx
80104e4f:	89 d8                	mov    %ebx,%eax
80104e51:	f0 87 02             	lock xchg %eax,(%edx)
80104e54:	89 c3                	mov    %eax,%ebx
80104e56:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104e59:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104e5c:	83 c4 10             	add    $0x10,%esp
80104e5f:	5b                   	pop    %ebx
80104e60:	5d                   	pop    %ebp
80104e61:	c3                   	ret    

80104e62 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104e62:	55                   	push   %ebp
80104e63:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104e65:	8b 45 08             	mov    0x8(%ebp),%eax
80104e68:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e6b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104e77:	8b 45 08             	mov    0x8(%ebp),%eax
80104e7a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104e81:	5d                   	pop    %ebp
80104e82:	c3                   	ret    

80104e83 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104e83:	55                   	push   %ebp
80104e84:	89 e5                	mov    %esp,%ebp
80104e86:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104e89:	e8 3d 01 00 00       	call   80104fcb <pushcli>
  if(holding(lk))
80104e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104e91:	89 04 24             	mov    %eax,(%esp)
80104e94:	e8 08 01 00 00       	call   80104fa1 <holding>
80104e99:	85 c0                	test   %eax,%eax
80104e9b:	74 0c                	je     80104ea9 <acquire+0x26>
    panic("acquire");
80104e9d:	c7 04 24 5d 88 10 80 	movl   $0x8010885d,(%esp)
80104ea4:	e8 94 b6 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104ea9:	90                   	nop
80104eaa:	8b 45 08             	mov    0x8(%ebp),%eax
80104ead:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104eb4:	00 
80104eb5:	89 04 24             	mov    %eax,(%esp)
80104eb8:	e8 80 ff ff ff       	call   80104e3d <xchg>
80104ebd:	85 c0                	test   %eax,%eax
80104ebf:	75 e9                	jne    80104eaa <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ecb:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104ece:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed1:	83 c0 0c             	add    $0xc,%eax
80104ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ed8:	8d 45 08             	lea    0x8(%ebp),%eax
80104edb:	89 04 24             	mov    %eax,(%esp)
80104ede:	e8 51 00 00 00       	call   80104f34 <getcallerpcs>
}
80104ee3:	c9                   	leave  
80104ee4:	c3                   	ret    

80104ee5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104ee5:	55                   	push   %ebp
80104ee6:	89 e5                	mov    %esp,%ebp
80104ee8:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80104eee:	89 04 24             	mov    %eax,(%esp)
80104ef1:	e8 ab 00 00 00       	call   80104fa1 <holding>
80104ef6:	85 c0                	test   %eax,%eax
80104ef8:	75 0c                	jne    80104f06 <release+0x21>
    panic("release");
80104efa:	c7 04 24 65 88 10 80 	movl   $0x80108865,(%esp)
80104f01:	e8 37 b6 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80104f06:	8b 45 08             	mov    0x8(%ebp),%eax
80104f09:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104f10:	8b 45 08             	mov    0x8(%ebp),%eax
80104f13:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104f24:	00 
80104f25:	89 04 24             	mov    %eax,(%esp)
80104f28:	e8 10 ff ff ff       	call   80104e3d <xchg>

  popcli();
80104f2d:	e8 e1 00 00 00       	call   80105013 <popcli>
}
80104f32:	c9                   	leave  
80104f33:	c3                   	ret    

80104f34 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104f34:	55                   	push   %ebp
80104f35:	89 e5                	mov    %esp,%ebp
80104f37:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3d:	83 e8 08             	sub    $0x8,%eax
80104f40:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104f43:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104f4a:	eb 32                	jmp    80104f7e <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104f4c:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104f50:	74 47                	je     80104f99 <getcallerpcs+0x65>
80104f52:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104f59:	76 3e                	jbe    80104f99 <getcallerpcs+0x65>
80104f5b:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104f5f:	74 38                	je     80104f99 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104f61:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f64:	c1 e0 02             	shl    $0x2,%eax
80104f67:	03 45 0c             	add    0xc(%ebp),%eax
80104f6a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f6d:	8b 52 04             	mov    0x4(%edx),%edx
80104f70:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80104f72:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f75:	8b 00                	mov    (%eax),%eax
80104f77:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104f7a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104f7e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f82:	7e c8                	jle    80104f4c <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104f84:	eb 13                	jmp    80104f99 <getcallerpcs+0x65>
    pcs[i] = 0;
80104f86:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f89:	c1 e0 02             	shl    $0x2,%eax
80104f8c:	03 45 0c             	add    0xc(%ebp),%eax
80104f8f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104f95:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104f99:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f9d:	7e e7                	jle    80104f86 <getcallerpcs+0x52>
    pcs[i] = 0;
}
80104f9f:	c9                   	leave  
80104fa0:	c3                   	ret    

80104fa1 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104fa1:	55                   	push   %ebp
80104fa2:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa7:	8b 00                	mov    (%eax),%eax
80104fa9:	85 c0                	test   %eax,%eax
80104fab:	74 17                	je     80104fc4 <holding+0x23>
80104fad:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb0:	8b 50 08             	mov    0x8(%eax),%edx
80104fb3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fb9:	39 c2                	cmp    %eax,%edx
80104fbb:	75 07                	jne    80104fc4 <holding+0x23>
80104fbd:	b8 01 00 00 00       	mov    $0x1,%eax
80104fc2:	eb 05                	jmp    80104fc9 <holding+0x28>
80104fc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fc9:	5d                   	pop    %ebp
80104fca:	c3                   	ret    

80104fcb <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104fcb:	55                   	push   %ebp
80104fcc:	89 e5                	mov    %esp,%ebp
80104fce:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104fd1:	e8 46 fe ff ff       	call   80104e1c <readeflags>
80104fd6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104fd9:	e8 53 fe ff ff       	call   80104e31 <cli>
  if(cpu->ncli++ == 0)
80104fde:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fe4:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104fea:	85 d2                	test   %edx,%edx
80104fec:	0f 94 c1             	sete   %cl
80104fef:	83 c2 01             	add    $0x1,%edx
80104ff2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104ff8:	84 c9                	test   %cl,%cl
80104ffa:	74 15                	je     80105011 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80104ffc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105002:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105005:	81 e2 00 02 00 00    	and    $0x200,%edx
8010500b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105011:	c9                   	leave  
80105012:	c3                   	ret    

80105013 <popcli>:

void
popcli(void)
{
80105013:	55                   	push   %ebp
80105014:	89 e5                	mov    %esp,%ebp
80105016:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105019:	e8 fe fd ff ff       	call   80104e1c <readeflags>
8010501e:	25 00 02 00 00       	and    $0x200,%eax
80105023:	85 c0                	test   %eax,%eax
80105025:	74 0c                	je     80105033 <popcli+0x20>
    panic("popcli - interruptible");
80105027:	c7 04 24 6d 88 10 80 	movl   $0x8010886d,(%esp)
8010502e:	e8 0a b5 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80105033:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105039:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010503f:	83 ea 01             	sub    $0x1,%edx
80105042:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105048:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010504e:	85 c0                	test   %eax,%eax
80105050:	79 0c                	jns    8010505e <popcli+0x4b>
    panic("popcli");
80105052:	c7 04 24 84 88 10 80 	movl   $0x80108884,(%esp)
80105059:	e8 df b4 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010505e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105064:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010506a:	85 c0                	test   %eax,%eax
8010506c:	75 15                	jne    80105083 <popcli+0x70>
8010506e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105074:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010507a:	85 c0                	test   %eax,%eax
8010507c:	74 05                	je     80105083 <popcli+0x70>
    sti();
8010507e:	e8 b4 fd ff ff       	call   80104e37 <sti>
}
80105083:	c9                   	leave  
80105084:	c3                   	ret    
80105085:	00 00                	add    %al,(%eax)
	...

80105088 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105088:	55                   	push   %ebp
80105089:	89 e5                	mov    %esp,%ebp
8010508b:	57                   	push   %edi
8010508c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010508d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105090:	8b 55 10             	mov    0x10(%ebp),%edx
80105093:	8b 45 0c             	mov    0xc(%ebp),%eax
80105096:	89 cb                	mov    %ecx,%ebx
80105098:	89 df                	mov    %ebx,%edi
8010509a:	89 d1                	mov    %edx,%ecx
8010509c:	fc                   	cld    
8010509d:	f3 aa                	rep stos %al,%es:(%edi)
8010509f:	89 ca                	mov    %ecx,%edx
801050a1:	89 fb                	mov    %edi,%ebx
801050a3:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050a6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801050a9:	5b                   	pop    %ebx
801050aa:	5f                   	pop    %edi
801050ab:	5d                   	pop    %ebp
801050ac:	c3                   	ret    

801050ad <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801050ad:	55                   	push   %ebp
801050ae:	89 e5                	mov    %esp,%ebp
801050b0:	57                   	push   %edi
801050b1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801050b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050b5:	8b 55 10             	mov    0x10(%ebp),%edx
801050b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801050bb:	89 cb                	mov    %ecx,%ebx
801050bd:	89 df                	mov    %ebx,%edi
801050bf:	89 d1                	mov    %edx,%ecx
801050c1:	fc                   	cld    
801050c2:	f3 ab                	rep stos %eax,%es:(%edi)
801050c4:	89 ca                	mov    %ecx,%edx
801050c6:	89 fb                	mov    %edi,%ebx
801050c8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050cb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801050ce:	5b                   	pop    %ebx
801050cf:	5f                   	pop    %edi
801050d0:	5d                   	pop    %ebp
801050d1:	c3                   	ret    

801050d2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801050d2:	55                   	push   %ebp
801050d3:	89 e5                	mov    %esp,%ebp
801050d5:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801050d8:	8b 45 08             	mov    0x8(%ebp),%eax
801050db:	83 e0 03             	and    $0x3,%eax
801050de:	85 c0                	test   %eax,%eax
801050e0:	75 49                	jne    8010512b <memset+0x59>
801050e2:	8b 45 10             	mov    0x10(%ebp),%eax
801050e5:	83 e0 03             	and    $0x3,%eax
801050e8:	85 c0                	test   %eax,%eax
801050ea:	75 3f                	jne    8010512b <memset+0x59>
    c &= 0xFF;
801050ec:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801050f3:	8b 45 10             	mov    0x10(%ebp),%eax
801050f6:	c1 e8 02             	shr    $0x2,%eax
801050f9:	89 c2                	mov    %eax,%edx
801050fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fe:	89 c1                	mov    %eax,%ecx
80105100:	c1 e1 18             	shl    $0x18,%ecx
80105103:	8b 45 0c             	mov    0xc(%ebp),%eax
80105106:	c1 e0 10             	shl    $0x10,%eax
80105109:	09 c1                	or     %eax,%ecx
8010510b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510e:	c1 e0 08             	shl    $0x8,%eax
80105111:	09 c8                	or     %ecx,%eax
80105113:	0b 45 0c             	or     0xc(%ebp),%eax
80105116:	89 54 24 08          	mov    %edx,0x8(%esp)
8010511a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010511e:	8b 45 08             	mov    0x8(%ebp),%eax
80105121:	89 04 24             	mov    %eax,(%esp)
80105124:	e8 84 ff ff ff       	call   801050ad <stosl>
80105129:	eb 19                	jmp    80105144 <memset+0x72>
  } else
    stosb(dst, c, n);
8010512b:	8b 45 10             	mov    0x10(%ebp),%eax
8010512e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105132:	8b 45 0c             	mov    0xc(%ebp),%eax
80105135:	89 44 24 04          	mov    %eax,0x4(%esp)
80105139:	8b 45 08             	mov    0x8(%ebp),%eax
8010513c:	89 04 24             	mov    %eax,(%esp)
8010513f:	e8 44 ff ff ff       	call   80105088 <stosb>
  return dst;
80105144:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105147:	c9                   	leave  
80105148:	c3                   	ret    

80105149 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105149:	55                   	push   %ebp
8010514a:	89 e5                	mov    %esp,%ebp
8010514c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010514f:	8b 45 08             	mov    0x8(%ebp),%eax
80105152:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105155:	8b 45 0c             	mov    0xc(%ebp),%eax
80105158:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010515b:	eb 32                	jmp    8010518f <memcmp+0x46>
    if(*s1 != *s2)
8010515d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105160:	0f b6 10             	movzbl (%eax),%edx
80105163:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105166:	0f b6 00             	movzbl (%eax),%eax
80105169:	38 c2                	cmp    %al,%dl
8010516b:	74 1a                	je     80105187 <memcmp+0x3e>
      return *s1 - *s2;
8010516d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105170:	0f b6 00             	movzbl (%eax),%eax
80105173:	0f b6 d0             	movzbl %al,%edx
80105176:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105179:	0f b6 00             	movzbl (%eax),%eax
8010517c:	0f b6 c0             	movzbl %al,%eax
8010517f:	89 d1                	mov    %edx,%ecx
80105181:	29 c1                	sub    %eax,%ecx
80105183:	89 c8                	mov    %ecx,%eax
80105185:	eb 1c                	jmp    801051a3 <memcmp+0x5a>
    s1++, s2++;
80105187:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010518b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010518f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105193:	0f 95 c0             	setne  %al
80105196:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010519a:	84 c0                	test   %al,%al
8010519c:	75 bf                	jne    8010515d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010519e:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051a3:	c9                   	leave  
801051a4:	c3                   	ret    

801051a5 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801051a5:	55                   	push   %ebp
801051a6:	89 e5                	mov    %esp,%ebp
801051a8:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801051ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801051b1:	8b 45 08             	mov    0x8(%ebp),%eax
801051b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801051b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051ba:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051bd:	73 54                	jae    80105213 <memmove+0x6e>
801051bf:	8b 45 10             	mov    0x10(%ebp),%eax
801051c2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051c5:	01 d0                	add    %edx,%eax
801051c7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051ca:	76 47                	jbe    80105213 <memmove+0x6e>
    s += n;
801051cc:	8b 45 10             	mov    0x10(%ebp),%eax
801051cf:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801051d2:	8b 45 10             	mov    0x10(%ebp),%eax
801051d5:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801051d8:	eb 13                	jmp    801051ed <memmove+0x48>
      *--d = *--s;
801051da:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801051de:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801051e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051e5:	0f b6 10             	movzbl (%eax),%edx
801051e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801051eb:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801051ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051f1:	0f 95 c0             	setne  %al
801051f4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051f8:	84 c0                	test   %al,%al
801051fa:	75 de                	jne    801051da <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801051fc:	eb 25                	jmp    80105223 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801051fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105201:	0f b6 10             	movzbl (%eax),%edx
80105204:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105207:	88 10                	mov    %dl,(%eax)
80105209:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010520d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105211:	eb 01                	jmp    80105214 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105213:	90                   	nop
80105214:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105218:	0f 95 c0             	setne  %al
8010521b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010521f:	84 c0                	test   %al,%al
80105221:	75 db                	jne    801051fe <memmove+0x59>
      *d++ = *s++;

  return dst;
80105223:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105226:	c9                   	leave  
80105227:	c3                   	ret    

80105228 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105228:	55                   	push   %ebp
80105229:	89 e5                	mov    %esp,%ebp
8010522b:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010522e:	8b 45 10             	mov    0x10(%ebp),%eax
80105231:	89 44 24 08          	mov    %eax,0x8(%esp)
80105235:	8b 45 0c             	mov    0xc(%ebp),%eax
80105238:	89 44 24 04          	mov    %eax,0x4(%esp)
8010523c:	8b 45 08             	mov    0x8(%ebp),%eax
8010523f:	89 04 24             	mov    %eax,(%esp)
80105242:	e8 5e ff ff ff       	call   801051a5 <memmove>
}
80105247:	c9                   	leave  
80105248:	c3                   	ret    

80105249 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105249:	55                   	push   %ebp
8010524a:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010524c:	eb 0c                	jmp    8010525a <strncmp+0x11>
    n--, p++, q++;
8010524e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105252:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105256:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010525a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010525e:	74 1a                	je     8010527a <strncmp+0x31>
80105260:	8b 45 08             	mov    0x8(%ebp),%eax
80105263:	0f b6 00             	movzbl (%eax),%eax
80105266:	84 c0                	test   %al,%al
80105268:	74 10                	je     8010527a <strncmp+0x31>
8010526a:	8b 45 08             	mov    0x8(%ebp),%eax
8010526d:	0f b6 10             	movzbl (%eax),%edx
80105270:	8b 45 0c             	mov    0xc(%ebp),%eax
80105273:	0f b6 00             	movzbl (%eax),%eax
80105276:	38 c2                	cmp    %al,%dl
80105278:	74 d4                	je     8010524e <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010527a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010527e:	75 07                	jne    80105287 <strncmp+0x3e>
    return 0;
80105280:	b8 00 00 00 00       	mov    $0x0,%eax
80105285:	eb 18                	jmp    8010529f <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
80105287:	8b 45 08             	mov    0x8(%ebp),%eax
8010528a:	0f b6 00             	movzbl (%eax),%eax
8010528d:	0f b6 d0             	movzbl %al,%edx
80105290:	8b 45 0c             	mov    0xc(%ebp),%eax
80105293:	0f b6 00             	movzbl (%eax),%eax
80105296:	0f b6 c0             	movzbl %al,%eax
80105299:	89 d1                	mov    %edx,%ecx
8010529b:	29 c1                	sub    %eax,%ecx
8010529d:	89 c8                	mov    %ecx,%eax
}
8010529f:	5d                   	pop    %ebp
801052a0:	c3                   	ret    

801052a1 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801052a1:	55                   	push   %ebp
801052a2:	89 e5                	mov    %esp,%ebp
801052a4:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801052a7:	8b 45 08             	mov    0x8(%ebp),%eax
801052aa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801052ad:	90                   	nop
801052ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052b2:	0f 9f c0             	setg   %al
801052b5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801052b9:	84 c0                	test   %al,%al
801052bb:	74 30                	je     801052ed <strncpy+0x4c>
801052bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c0:	0f b6 10             	movzbl (%eax),%edx
801052c3:	8b 45 08             	mov    0x8(%ebp),%eax
801052c6:	88 10                	mov    %dl,(%eax)
801052c8:	8b 45 08             	mov    0x8(%ebp),%eax
801052cb:	0f b6 00             	movzbl (%eax),%eax
801052ce:	84 c0                	test   %al,%al
801052d0:	0f 95 c0             	setne  %al
801052d3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801052d7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801052db:	84 c0                	test   %al,%al
801052dd:	75 cf                	jne    801052ae <strncpy+0xd>
    ;
  while(n-- > 0)
801052df:	eb 0c                	jmp    801052ed <strncpy+0x4c>
    *s++ = 0;
801052e1:	8b 45 08             	mov    0x8(%ebp),%eax
801052e4:	c6 00 00             	movb   $0x0,(%eax)
801052e7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801052eb:	eb 01                	jmp    801052ee <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801052ed:	90                   	nop
801052ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052f2:	0f 9f c0             	setg   %al
801052f5:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801052f9:	84 c0                	test   %al,%al
801052fb:	75 e4                	jne    801052e1 <strncpy+0x40>
    *s++ = 0;
  return os;
801052fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105300:	c9                   	leave  
80105301:	c3                   	ret    

80105302 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105302:	55                   	push   %ebp
80105303:	89 e5                	mov    %esp,%ebp
80105305:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105308:	8b 45 08             	mov    0x8(%ebp),%eax
8010530b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010530e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105312:	7f 05                	jg     80105319 <safestrcpy+0x17>
    return os;
80105314:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105317:	eb 35                	jmp    8010534e <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105319:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010531d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105321:	7e 22                	jle    80105345 <safestrcpy+0x43>
80105323:	8b 45 0c             	mov    0xc(%ebp),%eax
80105326:	0f b6 10             	movzbl (%eax),%edx
80105329:	8b 45 08             	mov    0x8(%ebp),%eax
8010532c:	88 10                	mov    %dl,(%eax)
8010532e:	8b 45 08             	mov    0x8(%ebp),%eax
80105331:	0f b6 00             	movzbl (%eax),%eax
80105334:	84 c0                	test   %al,%al
80105336:	0f 95 c0             	setne  %al
80105339:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010533d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105341:	84 c0                	test   %al,%al
80105343:	75 d4                	jne    80105319 <safestrcpy+0x17>
    ;
  *s = 0;
80105345:	8b 45 08             	mov    0x8(%ebp),%eax
80105348:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010534b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010534e:	c9                   	leave  
8010534f:	c3                   	ret    

80105350 <strlen>:

int
strlen(const char *s)
{
80105350:	55                   	push   %ebp
80105351:	89 e5                	mov    %esp,%ebp
80105353:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105356:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010535d:	eb 04                	jmp    80105363 <strlen+0x13>
8010535f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105363:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105366:	03 45 08             	add    0x8(%ebp),%eax
80105369:	0f b6 00             	movzbl (%eax),%eax
8010536c:	84 c0                	test   %al,%al
8010536e:	75 ef                	jne    8010535f <strlen+0xf>
    ;
  return n;
80105370:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105373:	c9                   	leave  
80105374:	c3                   	ret    
80105375:	00 00                	add    %al,(%eax)
	...

80105378 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105378:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010537c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105380:	55                   	push   %ebp
  pushl %ebx
80105381:	53                   	push   %ebx
  pushl %esi
80105382:	56                   	push   %esi
  pushl %edi
80105383:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105384:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105386:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105388:	5f                   	pop    %edi
  popl %esi
80105389:	5e                   	pop    %esi
  popl %ebx
8010538a:	5b                   	pop    %ebx
  popl %ebp
8010538b:	5d                   	pop    %ebp
  ret
8010538c:	c3                   	ret    
8010538d:	00 00                	add    %al,(%eax)
	...

80105390 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105390:	55                   	push   %ebp
80105391:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105393:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105399:	8b 00                	mov    (%eax),%eax
8010539b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010539e:	76 12                	jbe    801053b2 <fetchint+0x22>
801053a0:	8b 45 08             	mov    0x8(%ebp),%eax
801053a3:	8d 50 04             	lea    0x4(%eax),%edx
801053a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ac:	8b 00                	mov    (%eax),%eax
801053ae:	39 c2                	cmp    %eax,%edx
801053b0:	76 07                	jbe    801053b9 <fetchint+0x29>
    return -1;
801053b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053b7:	eb 0f                	jmp    801053c8 <fetchint+0x38>
  *ip = *(int*)(addr);
801053b9:	8b 45 08             	mov    0x8(%ebp),%eax
801053bc:	8b 10                	mov    (%eax),%edx
801053be:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c1:	89 10                	mov    %edx,(%eax)
  return 0;
801053c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053c8:	5d                   	pop    %ebp
801053c9:	c3                   	ret    

801053ca <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801053ca:	55                   	push   %ebp
801053cb:	89 e5                	mov    %esp,%ebp
801053cd:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801053d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053d6:	8b 00                	mov    (%eax),%eax
801053d8:	3b 45 08             	cmp    0x8(%ebp),%eax
801053db:	77 07                	ja     801053e4 <fetchstr+0x1a>
    return -1;
801053dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e2:	eb 48                	jmp    8010542c <fetchstr+0x62>
  *pp = (char*)addr;
801053e4:	8b 55 08             	mov    0x8(%ebp),%edx
801053e7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ea:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801053ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053f2:	8b 00                	mov    (%eax),%eax
801053f4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801053f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053fa:	8b 00                	mov    (%eax),%eax
801053fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
801053ff:	eb 1e                	jmp    8010541f <fetchstr+0x55>
    if(*s == 0)
80105401:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105404:	0f b6 00             	movzbl (%eax),%eax
80105407:	84 c0                	test   %al,%al
80105409:	75 10                	jne    8010541b <fetchstr+0x51>
      return s - *pp;
8010540b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010540e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105411:	8b 00                	mov    (%eax),%eax
80105413:	89 d1                	mov    %edx,%ecx
80105415:	29 c1                	sub    %eax,%ecx
80105417:	89 c8                	mov    %ecx,%eax
80105419:	eb 11                	jmp    8010542c <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010541b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010541f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105422:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105425:	72 da                	jb     80105401 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105427:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010542c:	c9                   	leave  
8010542d:	c3                   	ret    

8010542e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010542e:	55                   	push   %ebp
8010542f:	89 e5                	mov    %esp,%ebp
80105431:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105434:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010543a:	8b 40 18             	mov    0x18(%eax),%eax
8010543d:	8b 50 44             	mov    0x44(%eax),%edx
80105440:	8b 45 08             	mov    0x8(%ebp),%eax
80105443:	c1 e0 02             	shl    $0x2,%eax
80105446:	01 d0                	add    %edx,%eax
80105448:	8d 50 04             	lea    0x4(%eax),%edx
8010544b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010544e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105452:	89 14 24             	mov    %edx,(%esp)
80105455:	e8 36 ff ff ff       	call   80105390 <fetchint>
}
8010545a:	c9                   	leave  
8010545b:	c3                   	ret    

8010545c <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010545c:	55                   	push   %ebp
8010545d:	89 e5                	mov    %esp,%ebp
8010545f:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105462:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105465:	89 44 24 04          	mov    %eax,0x4(%esp)
80105469:	8b 45 08             	mov    0x8(%ebp),%eax
8010546c:	89 04 24             	mov    %eax,(%esp)
8010546f:	e8 ba ff ff ff       	call   8010542e <argint>
80105474:	85 c0                	test   %eax,%eax
80105476:	79 07                	jns    8010547f <argptr+0x23>
    return -1;
80105478:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010547d:	eb 3d                	jmp    801054bc <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010547f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105482:	89 c2                	mov    %eax,%edx
80105484:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010548a:	8b 00                	mov    (%eax),%eax
8010548c:	39 c2                	cmp    %eax,%edx
8010548e:	73 16                	jae    801054a6 <argptr+0x4a>
80105490:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105493:	89 c2                	mov    %eax,%edx
80105495:	8b 45 10             	mov    0x10(%ebp),%eax
80105498:	01 c2                	add    %eax,%edx
8010549a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054a0:	8b 00                	mov    (%eax),%eax
801054a2:	39 c2                	cmp    %eax,%edx
801054a4:	76 07                	jbe    801054ad <argptr+0x51>
    return -1;
801054a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ab:	eb 0f                	jmp    801054bc <argptr+0x60>
  *pp = (char*)i;
801054ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054b0:	89 c2                	mov    %eax,%edx
801054b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801054b5:	89 10                	mov    %edx,(%eax)
  return 0;
801054b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054bc:	c9                   	leave  
801054bd:	c3                   	ret    

801054be <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801054be:	55                   	push   %ebp
801054bf:	89 e5                	mov    %esp,%ebp
801054c1:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801054c4:	8d 45 fc             	lea    -0x4(%ebp),%eax
801054c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801054cb:	8b 45 08             	mov    0x8(%ebp),%eax
801054ce:	89 04 24             	mov    %eax,(%esp)
801054d1:	e8 58 ff ff ff       	call   8010542e <argint>
801054d6:	85 c0                	test   %eax,%eax
801054d8:	79 07                	jns    801054e1 <argstr+0x23>
    return -1;
801054da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054df:	eb 12                	jmp    801054f3 <argstr+0x35>
  return fetchstr(addr, pp);
801054e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054e4:	8b 55 0c             	mov    0xc(%ebp),%edx
801054e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801054eb:	89 04 24             	mov    %eax,(%esp)
801054ee:	e8 d7 fe ff ff       	call   801053ca <fetchstr>
}
801054f3:	c9                   	leave  
801054f4:	c3                   	ret    

801054f5 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801054f5:	55                   	push   %ebp
801054f6:	89 e5                	mov    %esp,%ebp
801054f8:	53                   	push   %ebx
801054f9:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801054fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105502:	8b 40 18             	mov    0x18(%eax),%eax
80105505:	8b 40 1c             	mov    0x1c(%eax),%eax
80105508:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010550b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010550f:	7e 30                	jle    80105541 <syscall+0x4c>
80105511:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105514:	83 f8 15             	cmp    $0x15,%eax
80105517:	77 28                	ja     80105541 <syscall+0x4c>
80105519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010551c:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105523:	85 c0                	test   %eax,%eax
80105525:	74 1a                	je     80105541 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105527:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010552d:	8b 58 18             	mov    0x18(%eax),%ebx
80105530:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105533:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010553a:	ff d0                	call   *%eax
8010553c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010553f:	eb 3d                	jmp    8010557e <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105541:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105547:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010554a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105550:	8b 40 10             	mov    0x10(%eax),%eax
80105553:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105556:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010555a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010555e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105562:	c7 04 24 8b 88 10 80 	movl   $0x8010888b,(%esp)
80105569:	e8 33 ae ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010556e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105574:	8b 40 18             	mov    0x18(%eax),%eax
80105577:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010557e:	83 c4 24             	add    $0x24,%esp
80105581:	5b                   	pop    %ebx
80105582:	5d                   	pop    %ebp
80105583:	c3                   	ret    

80105584 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105584:	55                   	push   %ebp
80105585:	89 e5                	mov    %esp,%ebp
80105587:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010558a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010558d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105591:	8b 45 08             	mov    0x8(%ebp),%eax
80105594:	89 04 24             	mov    %eax,(%esp)
80105597:	e8 92 fe ff ff       	call   8010542e <argint>
8010559c:	85 c0                	test   %eax,%eax
8010559e:	79 07                	jns    801055a7 <argfd+0x23>
    return -1;
801055a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055a5:	eb 50                	jmp    801055f7 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801055a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055aa:	85 c0                	test   %eax,%eax
801055ac:	78 21                	js     801055cf <argfd+0x4b>
801055ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055b1:	83 f8 0f             	cmp    $0xf,%eax
801055b4:	7f 19                	jg     801055cf <argfd+0x4b>
801055b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055bf:	83 c2 08             	add    $0x8,%edx
801055c2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801055c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055cd:	75 07                	jne    801055d6 <argfd+0x52>
    return -1;
801055cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055d4:	eb 21                	jmp    801055f7 <argfd+0x73>
  if(pfd)
801055d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801055da:	74 08                	je     801055e4 <argfd+0x60>
    *pfd = fd;
801055dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055df:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e2:	89 10                	mov    %edx,(%eax)
  if(pf)
801055e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055e8:	74 08                	je     801055f2 <argfd+0x6e>
    *pf = f;
801055ea:	8b 45 10             	mov    0x10(%ebp),%eax
801055ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055f0:	89 10                	mov    %edx,(%eax)
  return 0;
801055f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055f7:	c9                   	leave  
801055f8:	c3                   	ret    

801055f9 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801055f9:	55                   	push   %ebp
801055fa:	89 e5                	mov    %esp,%ebp
801055fc:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801055ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105606:	eb 30                	jmp    80105638 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105608:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010560e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105611:	83 c2 08             	add    $0x8,%edx
80105614:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105618:	85 c0                	test   %eax,%eax
8010561a:	75 18                	jne    80105634 <fdalloc+0x3b>
      proc->ofile[fd] = f;
8010561c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105622:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105625:	8d 4a 08             	lea    0x8(%edx),%ecx
80105628:	8b 55 08             	mov    0x8(%ebp),%edx
8010562b:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010562f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105632:	eb 0f                	jmp    80105643 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105634:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105638:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
8010563c:	7e ca                	jle    80105608 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010563e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105643:	c9                   	leave  
80105644:	c3                   	ret    

80105645 <sys_dup>:

int
sys_dup(void)
{
80105645:	55                   	push   %ebp
80105646:	89 e5                	mov    %esp,%ebp
80105648:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010564b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010564e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105652:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105659:	00 
8010565a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105661:	e8 1e ff ff ff       	call   80105584 <argfd>
80105666:	85 c0                	test   %eax,%eax
80105668:	79 07                	jns    80105671 <sys_dup+0x2c>
    return -1;
8010566a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010566f:	eb 29                	jmp    8010569a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105671:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105674:	89 04 24             	mov    %eax,(%esp)
80105677:	e8 7d ff ff ff       	call   801055f9 <fdalloc>
8010567c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010567f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105683:	79 07                	jns    8010568c <sys_dup+0x47>
    return -1;
80105685:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010568a:	eb 0e                	jmp    8010569a <sys_dup+0x55>
  filedup(f);
8010568c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010568f:	89 04 24             	mov    %eax,(%esp)
80105692:	e8 f1 b8 ff ff       	call   80100f88 <filedup>
  return fd;
80105697:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010569a:	c9                   	leave  
8010569b:	c3                   	ret    

8010569c <sys_read>:

int
sys_read(void)
{
8010569c:	55                   	push   %ebp
8010569d:	89 e5                	mov    %esp,%ebp
8010569f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801056a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056a5:	89 44 24 08          	mov    %eax,0x8(%esp)
801056a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056b0:	00 
801056b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056b8:	e8 c7 fe ff ff       	call   80105584 <argfd>
801056bd:	85 c0                	test   %eax,%eax
801056bf:	78 35                	js     801056f6 <sys_read+0x5a>
801056c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801056c8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801056cf:	e8 5a fd ff ff       	call   8010542e <argint>
801056d4:	85 c0                	test   %eax,%eax
801056d6:	78 1e                	js     801056f6 <sys_read+0x5a>
801056d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056db:	89 44 24 08          	mov    %eax,0x8(%esp)
801056df:	8d 45 ec             	lea    -0x14(%ebp),%eax
801056e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801056e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801056ed:	e8 6a fd ff ff       	call   8010545c <argptr>
801056f2:	85 c0                	test   %eax,%eax
801056f4:	79 07                	jns    801056fd <sys_read+0x61>
    return -1;
801056f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056fb:	eb 19                	jmp    80105716 <sys_read+0x7a>
  return fileread(f, p, n);
801056fd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105700:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105706:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010570a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010570e:	89 04 24             	mov    %eax,(%esp)
80105711:	e8 df b9 ff ff       	call   801010f5 <fileread>
}
80105716:	c9                   	leave  
80105717:	c3                   	ret    

80105718 <sys_write>:

int
sys_write(void)
{
80105718:	55                   	push   %ebp
80105719:	89 e5                	mov    %esp,%ebp
8010571b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010571e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105721:	89 44 24 08          	mov    %eax,0x8(%esp)
80105725:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010572c:	00 
8010572d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105734:	e8 4b fe ff ff       	call   80105584 <argfd>
80105739:	85 c0                	test   %eax,%eax
8010573b:	78 35                	js     80105772 <sys_write+0x5a>
8010573d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105740:	89 44 24 04          	mov    %eax,0x4(%esp)
80105744:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010574b:	e8 de fc ff ff       	call   8010542e <argint>
80105750:	85 c0                	test   %eax,%eax
80105752:	78 1e                	js     80105772 <sys_write+0x5a>
80105754:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105757:	89 44 24 08          	mov    %eax,0x8(%esp)
8010575b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010575e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105762:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105769:	e8 ee fc ff ff       	call   8010545c <argptr>
8010576e:	85 c0                	test   %eax,%eax
80105770:	79 07                	jns    80105779 <sys_write+0x61>
    return -1;
80105772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105777:	eb 19                	jmp    80105792 <sys_write+0x7a>
  return filewrite(f, p, n);
80105779:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010577c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010577f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105782:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105786:	89 54 24 04          	mov    %edx,0x4(%esp)
8010578a:	89 04 24             	mov    %eax,(%esp)
8010578d:	e8 1f ba ff ff       	call   801011b1 <filewrite>
}
80105792:	c9                   	leave  
80105793:	c3                   	ret    

80105794 <sys_close>:

int
sys_close(void)
{
80105794:	55                   	push   %ebp
80105795:	89 e5                	mov    %esp,%ebp
80105797:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010579a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010579d:	89 44 24 08          	mov    %eax,0x8(%esp)
801057a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801057a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057af:	e8 d0 fd ff ff       	call   80105584 <argfd>
801057b4:	85 c0                	test   %eax,%eax
801057b6:	79 07                	jns    801057bf <sys_close+0x2b>
    return -1;
801057b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057bd:	eb 24                	jmp    801057e3 <sys_close+0x4f>
  proc->ofile[fd] = 0;
801057bf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057c8:	83 c2 08             	add    $0x8,%edx
801057cb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801057d2:	00 
  fileclose(f);
801057d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d6:	89 04 24             	mov    %eax,(%esp)
801057d9:	e8 f2 b7 ff ff       	call   80100fd0 <fileclose>
  return 0;
801057de:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057e3:	c9                   	leave  
801057e4:	c3                   	ret    

801057e5 <sys_fstat>:

int
sys_fstat(void)
{
801057e5:	55                   	push   %ebp
801057e6:	89 e5                	mov    %esp,%ebp
801057e8:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801057eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057ee:	89 44 24 08          	mov    %eax,0x8(%esp)
801057f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801057f9:	00 
801057fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105801:	e8 7e fd ff ff       	call   80105584 <argfd>
80105806:	85 c0                	test   %eax,%eax
80105808:	78 1f                	js     80105829 <sys_fstat+0x44>
8010580a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105811:	00 
80105812:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105815:	89 44 24 04          	mov    %eax,0x4(%esp)
80105819:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105820:	e8 37 fc ff ff       	call   8010545c <argptr>
80105825:	85 c0                	test   %eax,%eax
80105827:	79 07                	jns    80105830 <sys_fstat+0x4b>
    return -1;
80105829:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582e:	eb 12                	jmp    80105842 <sys_fstat+0x5d>
  return filestat(f, st);
80105830:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105836:	89 54 24 04          	mov    %edx,0x4(%esp)
8010583a:	89 04 24             	mov    %eax,(%esp)
8010583d:	e8 64 b8 ff ff       	call   801010a6 <filestat>
}
80105842:	c9                   	leave  
80105843:	c3                   	ret    

80105844 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105844:	55                   	push   %ebp
80105845:	89 e5                	mov    %esp,%ebp
80105847:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010584a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010584d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105851:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105858:	e8 61 fc ff ff       	call   801054be <argstr>
8010585d:	85 c0                	test   %eax,%eax
8010585f:	78 17                	js     80105878 <sys_link+0x34>
80105861:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105864:	89 44 24 04          	mov    %eax,0x4(%esp)
80105868:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010586f:	e8 4a fc ff ff       	call   801054be <argstr>
80105874:	85 c0                	test   %eax,%eax
80105876:	79 0a                	jns    80105882 <sys_link+0x3e>
    return -1;
80105878:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010587d:	e9 41 01 00 00       	jmp    801059c3 <sys_link+0x17f>

  begin_op();
80105882:	e8 da db ff ff       	call   80103461 <begin_op>
  if((ip = namei(old)) == 0){
80105887:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010588a:	89 04 24             	mov    %eax,(%esp)
8010588d:	e8 84 cb ff ff       	call   80102416 <namei>
80105892:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105895:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105899:	75 0f                	jne    801058aa <sys_link+0x66>
    end_op();
8010589b:	e8 42 dc ff ff       	call   801034e2 <end_op>
    return -1;
801058a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a5:	e9 19 01 00 00       	jmp    801059c3 <sys_link+0x17f>
  }

  ilock(ip);
801058aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ad:	89 04 24             	mov    %eax,(%esp)
801058b0:	e8 bf bf ff ff       	call   80101874 <ilock>
  if(ip->type == T_DIR){
801058b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801058bc:	66 83 f8 01          	cmp    $0x1,%ax
801058c0:	75 1a                	jne    801058dc <sys_link+0x98>
    iunlockput(ip);
801058c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c5:	89 04 24             	mov    %eax,(%esp)
801058c8:	e8 2b c2 ff ff       	call   80101af8 <iunlockput>
    end_op();
801058cd:	e8 10 dc ff ff       	call   801034e2 <end_op>
    return -1;
801058d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058d7:	e9 e7 00 00 00       	jmp    801059c3 <sys_link+0x17f>
  }

  ip->nlink++;
801058dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058df:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801058e3:	8d 50 01             	lea    0x1(%eax),%edx
801058e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e9:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801058ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058f0:	89 04 24             	mov    %eax,(%esp)
801058f3:	e8 c0 bd ff ff       	call   801016b8 <iupdate>
  iunlock(ip);
801058f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fb:	89 04 24             	mov    %eax,(%esp)
801058fe:	e8 bf c0 ff ff       	call   801019c2 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105903:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105906:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105909:	89 54 24 04          	mov    %edx,0x4(%esp)
8010590d:	89 04 24             	mov    %eax,(%esp)
80105910:	e8 23 cb ff ff       	call   80102438 <nameiparent>
80105915:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105918:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010591c:	74 68                	je     80105986 <sys_link+0x142>
    goto bad;
  ilock(dp);
8010591e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105921:	89 04 24             	mov    %eax,(%esp)
80105924:	e8 4b bf ff ff       	call   80101874 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105929:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010592c:	8b 10                	mov    (%eax),%edx
8010592e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105931:	8b 00                	mov    (%eax),%eax
80105933:	39 c2                	cmp    %eax,%edx
80105935:	75 20                	jne    80105957 <sys_link+0x113>
80105937:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010593a:	8b 40 04             	mov    0x4(%eax),%eax
8010593d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105941:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105944:	89 44 24 04          	mov    %eax,0x4(%esp)
80105948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010594b:	89 04 24             	mov    %eax,(%esp)
8010594e:	e8 02 c8 ff ff       	call   80102155 <dirlink>
80105953:	85 c0                	test   %eax,%eax
80105955:	79 0d                	jns    80105964 <sys_link+0x120>
    iunlockput(dp);
80105957:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010595a:	89 04 24             	mov    %eax,(%esp)
8010595d:	e8 96 c1 ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105962:	eb 23                	jmp    80105987 <sys_link+0x143>
  }
  iunlockput(dp);
80105964:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105967:	89 04 24             	mov    %eax,(%esp)
8010596a:	e8 89 c1 ff ff       	call   80101af8 <iunlockput>
  iput(ip);
8010596f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105972:	89 04 24             	mov    %eax,(%esp)
80105975:	e8 ad c0 ff ff       	call   80101a27 <iput>

  end_op();
8010597a:	e8 63 db ff ff       	call   801034e2 <end_op>

  return 0;
8010597f:	b8 00 00 00 00       	mov    $0x0,%eax
80105984:	eb 3d                	jmp    801059c3 <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105986:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598a:	89 04 24             	mov    %eax,(%esp)
8010598d:	e8 e2 be ff ff       	call   80101874 <ilock>
  ip->nlink--;
80105992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105995:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105999:	8d 50 ff             	lea    -0x1(%eax),%edx
8010599c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010599f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801059a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a6:	89 04 24             	mov    %eax,(%esp)
801059a9:	e8 0a bd ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
801059ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b1:	89 04 24             	mov    %eax,(%esp)
801059b4:	e8 3f c1 ff ff       	call   80101af8 <iunlockput>
  end_op();
801059b9:	e8 24 db ff ff       	call   801034e2 <end_op>
  return -1;
801059be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059c3:	c9                   	leave  
801059c4:	c3                   	ret    

801059c5 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801059c5:	55                   	push   %ebp
801059c6:	89 e5                	mov    %esp,%ebp
801059c8:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801059cb:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801059d2:	eb 4b                	jmp    80105a1f <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801059d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059d7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801059de:	00 
801059df:	89 44 24 08          	mov    %eax,0x8(%esp)
801059e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801059e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ea:	8b 45 08             	mov    0x8(%ebp),%eax
801059ed:	89 04 24             	mov    %eax,(%esp)
801059f0:	e8 75 c3 ff ff       	call   80101d6a <readi>
801059f5:	83 f8 10             	cmp    $0x10,%eax
801059f8:	74 0c                	je     80105a06 <isdirempty+0x41>
      panic("isdirempty: readi");
801059fa:	c7 04 24 a7 88 10 80 	movl   $0x801088a7,(%esp)
80105a01:	e8 37 ab ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105a06:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105a0a:	66 85 c0             	test   %ax,%ax
80105a0d:	74 07                	je     80105a16 <isdirempty+0x51>
      return 0;
80105a0f:	b8 00 00 00 00       	mov    $0x0,%eax
80105a14:	eb 1b                	jmp    80105a31 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a19:	83 c0 10             	add    $0x10,%eax
80105a1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a22:	8b 45 08             	mov    0x8(%ebp),%eax
80105a25:	8b 40 18             	mov    0x18(%eax),%eax
80105a28:	39 c2                	cmp    %eax,%edx
80105a2a:	72 a8                	jb     801059d4 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105a2c:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105a31:	c9                   	leave  
80105a32:	c3                   	ret    

80105a33 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105a33:	55                   	push   %ebp
80105a34:	89 e5                	mov    %esp,%ebp
80105a36:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105a39:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a47:	e8 72 fa ff ff       	call   801054be <argstr>
80105a4c:	85 c0                	test   %eax,%eax
80105a4e:	79 0a                	jns    80105a5a <sys_unlink+0x27>
    return -1;
80105a50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a55:	e9 af 01 00 00       	jmp    80105c09 <sys_unlink+0x1d6>

  begin_op();
80105a5a:	e8 02 da ff ff       	call   80103461 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105a5f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105a62:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105a65:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a69:	89 04 24             	mov    %eax,(%esp)
80105a6c:	e8 c7 c9 ff ff       	call   80102438 <nameiparent>
80105a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a78:	75 0f                	jne    80105a89 <sys_unlink+0x56>
    end_op();
80105a7a:	e8 63 da ff ff       	call   801034e2 <end_op>
    return -1;
80105a7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a84:	e9 80 01 00 00       	jmp    80105c09 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8c:	89 04 24             	mov    %eax,(%esp)
80105a8f:	e8 e0 bd ff ff       	call   80101874 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105a94:	c7 44 24 04 b9 88 10 	movl   $0x801088b9,0x4(%esp)
80105a9b:	80 
80105a9c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105a9f:	89 04 24             	mov    %eax,(%esp)
80105aa2:	e8 c4 c5 ff ff       	call   8010206b <namecmp>
80105aa7:	85 c0                	test   %eax,%eax
80105aa9:	0f 84 45 01 00 00    	je     80105bf4 <sys_unlink+0x1c1>
80105aaf:	c7 44 24 04 bb 88 10 	movl   $0x801088bb,0x4(%esp)
80105ab6:	80 
80105ab7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105aba:	89 04 24             	mov    %eax,(%esp)
80105abd:	e8 a9 c5 ff ff       	call   8010206b <namecmp>
80105ac2:	85 c0                	test   %eax,%eax
80105ac4:	0f 84 2a 01 00 00    	je     80105bf4 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105aca:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105acd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ad1:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105adb:	89 04 24             	mov    %eax,(%esp)
80105ade:	e8 aa c5 ff ff       	call   8010208d <dirlookup>
80105ae3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ae6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105aea:	0f 84 03 01 00 00    	je     80105bf3 <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
80105af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af3:	89 04 24             	mov    %eax,(%esp)
80105af6:	e8 79 bd ff ff       	call   80101874 <ilock>

  if(ip->nlink < 1)
80105afb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105afe:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b02:	66 85 c0             	test   %ax,%ax
80105b05:	7f 0c                	jg     80105b13 <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
80105b07:	c7 04 24 be 88 10 80 	movl   $0x801088be,(%esp)
80105b0e:	e8 2a aa ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b16:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b1a:	66 83 f8 01          	cmp    $0x1,%ax
80105b1e:	75 1f                	jne    80105b3f <sys_unlink+0x10c>
80105b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b23:	89 04 24             	mov    %eax,(%esp)
80105b26:	e8 9a fe ff ff       	call   801059c5 <isdirempty>
80105b2b:	85 c0                	test   %eax,%eax
80105b2d:	75 10                	jne    80105b3f <sys_unlink+0x10c>
    iunlockput(ip);
80105b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b32:	89 04 24             	mov    %eax,(%esp)
80105b35:	e8 be bf ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105b3a:	e9 b5 00 00 00       	jmp    80105bf4 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105b3f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105b46:	00 
80105b47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b4e:	00 
80105b4f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b52:	89 04 24             	mov    %eax,(%esp)
80105b55:	e8 78 f5 ff ff       	call   801050d2 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b5a:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105b5d:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b64:	00 
80105b65:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b69:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b73:	89 04 24             	mov    %eax,(%esp)
80105b76:	e8 5a c3 ff ff       	call   80101ed5 <writei>
80105b7b:	83 f8 10             	cmp    $0x10,%eax
80105b7e:	74 0c                	je     80105b8c <sys_unlink+0x159>
    panic("unlink: writei");
80105b80:	c7 04 24 d0 88 10 80 	movl   $0x801088d0,(%esp)
80105b87:	e8 b1 a9 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b93:	66 83 f8 01          	cmp    $0x1,%ax
80105b97:	75 1c                	jne    80105bb5 <sys_unlink+0x182>
    dp->nlink--;
80105b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ba0:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba6:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bad:	89 04 24             	mov    %eax,(%esp)
80105bb0:	e8 03 bb ff ff       	call   801016b8 <iupdate>
  }
  iunlockput(dp);
80105bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb8:	89 04 24             	mov    %eax,(%esp)
80105bbb:	e8 38 bf ff ff       	call   80101af8 <iunlockput>

  ip->nlink--;
80105bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc3:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bc7:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcd:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd4:	89 04 24             	mov    %eax,(%esp)
80105bd7:	e8 dc ba ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
80105bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bdf:	89 04 24             	mov    %eax,(%esp)
80105be2:	e8 11 bf ff ff       	call   80101af8 <iunlockput>

  end_op();
80105be7:	e8 f6 d8 ff ff       	call   801034e2 <end_op>

  return 0;
80105bec:	b8 00 00 00 00       	mov    $0x0,%eax
80105bf1:	eb 16                	jmp    80105c09 <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105bf3:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf7:	89 04 24             	mov    %eax,(%esp)
80105bfa:	e8 f9 be ff ff       	call   80101af8 <iunlockput>
  end_op();
80105bff:	e8 de d8 ff ff       	call   801034e2 <end_op>
  return -1;
80105c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c09:	c9                   	leave  
80105c0a:	c3                   	ret    

80105c0b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105c0b:	55                   	push   %ebp
80105c0c:	89 e5                	mov    %esp,%ebp
80105c0e:	83 ec 48             	sub    $0x48,%esp
80105c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105c14:	8b 55 10             	mov    0x10(%ebp),%edx
80105c17:	8b 45 14             	mov    0x14(%ebp),%eax
80105c1a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105c1e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105c22:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105c26:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c29:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c30:	89 04 24             	mov    %eax,(%esp)
80105c33:	e8 00 c8 ff ff       	call   80102438 <nameiparent>
80105c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c3f:	75 0a                	jne    80105c4b <create+0x40>
    return 0;
80105c41:	b8 00 00 00 00       	mov    $0x0,%eax
80105c46:	e9 7e 01 00 00       	jmp    80105dc9 <create+0x1be>
  ilock(dp);
80105c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4e:	89 04 24             	mov    %eax,(%esp)
80105c51:	e8 1e bc ff ff       	call   80101874 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105c56:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c59:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c5d:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c60:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c67:	89 04 24             	mov    %eax,(%esp)
80105c6a:	e8 1e c4 ff ff       	call   8010208d <dirlookup>
80105c6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c72:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c76:	74 47                	je     80105cbf <create+0xb4>
    iunlockput(dp);
80105c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7b:	89 04 24             	mov    %eax,(%esp)
80105c7e:	e8 75 be ff ff       	call   80101af8 <iunlockput>
    ilock(ip);
80105c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c86:	89 04 24             	mov    %eax,(%esp)
80105c89:	e8 e6 bb ff ff       	call   80101874 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105c8e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105c93:	75 15                	jne    80105caa <create+0x9f>
80105c95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c98:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c9c:	66 83 f8 02          	cmp    $0x2,%ax
80105ca0:	75 08                	jne    80105caa <create+0x9f>
      return ip;
80105ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca5:	e9 1f 01 00 00       	jmp    80105dc9 <create+0x1be>
    iunlockput(ip);
80105caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cad:	89 04 24             	mov    %eax,(%esp)
80105cb0:	e8 43 be ff ff       	call   80101af8 <iunlockput>
    return 0;
80105cb5:	b8 00 00 00 00       	mov    $0x0,%eax
80105cba:	e9 0a 01 00 00       	jmp    80105dc9 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105cbf:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc6:	8b 00                	mov    (%eax),%eax
80105cc8:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ccc:	89 04 24             	mov    %eax,(%esp)
80105ccf:	e8 07 b9 ff ff       	call   801015db <ialloc>
80105cd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cd7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cdb:	75 0c                	jne    80105ce9 <create+0xde>
    panic("create: ialloc");
80105cdd:	c7 04 24 df 88 10 80 	movl   $0x801088df,(%esp)
80105ce4:	e8 54 a8 ff ff       	call   8010053d <panic>

  ilock(ip);
80105ce9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cec:	89 04 24             	mov    %eax,(%esp)
80105cef:	e8 80 bb ff ff       	call   80101874 <ilock>
  ip->major = major;
80105cf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf7:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105cfb:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105cff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d02:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105d06:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105d0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0d:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d16:	89 04 24             	mov    %eax,(%esp)
80105d19:	e8 9a b9 ff ff       	call   801016b8 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105d1e:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105d23:	75 6a                	jne    80105d8f <create+0x184>
    dp->nlink++;  // for ".."
80105d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d28:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d2c:	8d 50 01             	lea    0x1(%eax),%edx
80105d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d32:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d39:	89 04 24             	mov    %eax,(%esp)
80105d3c:	e8 77 b9 ff ff       	call   801016b8 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d44:	8b 40 04             	mov    0x4(%eax),%eax
80105d47:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d4b:	c7 44 24 04 b9 88 10 	movl   $0x801088b9,0x4(%esp)
80105d52:	80 
80105d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d56:	89 04 24             	mov    %eax,(%esp)
80105d59:	e8 f7 c3 ff ff       	call   80102155 <dirlink>
80105d5e:	85 c0                	test   %eax,%eax
80105d60:	78 21                	js     80105d83 <create+0x178>
80105d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d65:	8b 40 04             	mov    0x4(%eax),%eax
80105d68:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d6c:	c7 44 24 04 bb 88 10 	movl   $0x801088bb,0x4(%esp)
80105d73:	80 
80105d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d77:	89 04 24             	mov    %eax,(%esp)
80105d7a:	e8 d6 c3 ff ff       	call   80102155 <dirlink>
80105d7f:	85 c0                	test   %eax,%eax
80105d81:	79 0c                	jns    80105d8f <create+0x184>
      panic("create dots");
80105d83:	c7 04 24 ee 88 10 80 	movl   $0x801088ee,(%esp)
80105d8a:	e8 ae a7 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105d8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d92:	8b 40 04             	mov    0x4(%eax),%eax
80105d95:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d99:	8d 45 de             	lea    -0x22(%ebp),%eax
80105d9c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da3:	89 04 24             	mov    %eax,(%esp)
80105da6:	e8 aa c3 ff ff       	call   80102155 <dirlink>
80105dab:	85 c0                	test   %eax,%eax
80105dad:	79 0c                	jns    80105dbb <create+0x1b0>
    panic("create: dirlink");
80105daf:	c7 04 24 fa 88 10 80 	movl   $0x801088fa,(%esp)
80105db6:	e8 82 a7 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80105dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbe:	89 04 24             	mov    %eax,(%esp)
80105dc1:	e8 32 bd ff ff       	call   80101af8 <iunlockput>

  return ip;
80105dc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105dc9:	c9                   	leave  
80105dca:	c3                   	ret    

80105dcb <sys_open>:

int
sys_open(void)
{
80105dcb:	55                   	push   %ebp
80105dcc:	89 e5                	mov    %esp,%ebp
80105dce:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105dd1:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dd8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ddf:	e8 da f6 ff ff       	call   801054be <argstr>
80105de4:	85 c0                	test   %eax,%eax
80105de6:	78 17                	js     80105dff <sys_open+0x34>
80105de8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105deb:	89 44 24 04          	mov    %eax,0x4(%esp)
80105def:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105df6:	e8 33 f6 ff ff       	call   8010542e <argint>
80105dfb:	85 c0                	test   %eax,%eax
80105dfd:	79 0a                	jns    80105e09 <sys_open+0x3e>
    return -1;
80105dff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e04:	e9 5a 01 00 00       	jmp    80105f63 <sys_open+0x198>

  begin_op();
80105e09:	e8 53 d6 ff ff       	call   80103461 <begin_op>

  if(omode & O_CREATE){
80105e0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e11:	25 00 02 00 00       	and    $0x200,%eax
80105e16:	85 c0                	test   %eax,%eax
80105e18:	74 3b                	je     80105e55 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e1d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105e24:	00 
80105e25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e2c:	00 
80105e2d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105e34:	00 
80105e35:	89 04 24             	mov    %eax,(%esp)
80105e38:	e8 ce fd ff ff       	call   80105c0b <create>
80105e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105e40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e44:	75 6b                	jne    80105eb1 <sys_open+0xe6>
      end_op();
80105e46:	e8 97 d6 ff ff       	call   801034e2 <end_op>
      return -1;
80105e4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e50:	e9 0e 01 00 00       	jmp    80105f63 <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
80105e55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e58:	89 04 24             	mov    %eax,(%esp)
80105e5b:	e8 b6 c5 ff ff       	call   80102416 <namei>
80105e60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e63:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e67:	75 0f                	jne    80105e78 <sys_open+0xad>
      end_op();
80105e69:	e8 74 d6 ff ff       	call   801034e2 <end_op>
      return -1;
80105e6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e73:	e9 eb 00 00 00       	jmp    80105f63 <sys_open+0x198>
    }
    ilock(ip);
80105e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7b:	89 04 24             	mov    %eax,(%esp)
80105e7e:	e8 f1 b9 ff ff       	call   80101874 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e86:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e8a:	66 83 f8 01          	cmp    $0x1,%ax
80105e8e:	75 21                	jne    80105eb1 <sys_open+0xe6>
80105e90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e93:	85 c0                	test   %eax,%eax
80105e95:	74 1a                	je     80105eb1 <sys_open+0xe6>
      iunlockput(ip);
80105e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e9a:	89 04 24             	mov    %eax,(%esp)
80105e9d:	e8 56 bc ff ff       	call   80101af8 <iunlockput>
      end_op();
80105ea2:	e8 3b d6 ff ff       	call   801034e2 <end_op>
      return -1;
80105ea7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eac:	e9 b2 00 00 00       	jmp    80105f63 <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105eb1:	e8 72 b0 ff ff       	call   80100f28 <filealloc>
80105eb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105eb9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ebd:	74 14                	je     80105ed3 <sys_open+0x108>
80105ebf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec2:	89 04 24             	mov    %eax,(%esp)
80105ec5:	e8 2f f7 ff ff       	call   801055f9 <fdalloc>
80105eca:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105ecd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105ed1:	79 28                	jns    80105efb <sys_open+0x130>
    if(f)
80105ed3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ed7:	74 0b                	je     80105ee4 <sys_open+0x119>
      fileclose(f);
80105ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105edc:	89 04 24             	mov    %eax,(%esp)
80105edf:	e8 ec b0 ff ff       	call   80100fd0 <fileclose>
    iunlockput(ip);
80105ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee7:	89 04 24             	mov    %eax,(%esp)
80105eea:	e8 09 bc ff ff       	call   80101af8 <iunlockput>
    end_op();
80105eef:	e8 ee d5 ff ff       	call   801034e2 <end_op>
    return -1;
80105ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ef9:	eb 68                	jmp    80105f63 <sys_open+0x198>
  }
  iunlock(ip);
80105efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efe:	89 04 24             	mov    %eax,(%esp)
80105f01:	e8 bc ba ff ff       	call   801019c2 <iunlock>
  end_op();
80105f06:	e8 d7 d5 ff ff       	call   801034e2 <end_op>

  f->type = FD_INODE;
80105f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f0e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f17:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f1a:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f20:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105f27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f2a:	83 e0 01             	and    $0x1,%eax
80105f2d:	85 c0                	test   %eax,%eax
80105f2f:	0f 94 c2             	sete   %dl
80105f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f35:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105f38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f3b:	83 e0 01             	and    $0x1,%eax
80105f3e:	84 c0                	test   %al,%al
80105f40:	75 0a                	jne    80105f4c <sys_open+0x181>
80105f42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f45:	83 e0 02             	and    $0x2,%eax
80105f48:	85 c0                	test   %eax,%eax
80105f4a:	74 07                	je     80105f53 <sys_open+0x188>
80105f4c:	b8 01 00 00 00       	mov    $0x1,%eax
80105f51:	eb 05                	jmp    80105f58 <sys_open+0x18d>
80105f53:	b8 00 00 00 00       	mov    $0x0,%eax
80105f58:	89 c2                	mov    %eax,%edx
80105f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5d:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105f60:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105f63:	c9                   	leave  
80105f64:	c3                   	ret    

80105f65 <sys_mkdir>:

int
sys_mkdir(void)
{
80105f65:	55                   	push   %ebp
80105f66:	89 e5                	mov    %esp,%ebp
80105f68:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105f6b:	e8 f1 d4 ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105f70:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f73:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f7e:	e8 3b f5 ff ff       	call   801054be <argstr>
80105f83:	85 c0                	test   %eax,%eax
80105f85:	78 2c                	js     80105fb3 <sys_mkdir+0x4e>
80105f87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105f91:	00 
80105f92:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105f99:	00 
80105f9a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105fa1:	00 
80105fa2:	89 04 24             	mov    %eax,(%esp)
80105fa5:	e8 61 fc ff ff       	call   80105c0b <create>
80105faa:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fb1:	75 0c                	jne    80105fbf <sys_mkdir+0x5a>
    end_op();
80105fb3:	e8 2a d5 ff ff       	call   801034e2 <end_op>
    return -1;
80105fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fbd:	eb 15                	jmp    80105fd4 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fc2:	89 04 24             	mov    %eax,(%esp)
80105fc5:	e8 2e bb ff ff       	call   80101af8 <iunlockput>
  end_op();
80105fca:	e8 13 d5 ff ff       	call   801034e2 <end_op>
  return 0;
80105fcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fd4:	c9                   	leave  
80105fd5:	c3                   	ret    

80105fd6 <sys_mknod>:

int
sys_mknod(void)
{
80105fd6:	55                   	push   %ebp
80105fd7:	89 e5                	mov    %esp,%ebp
80105fd9:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80105fdc:	e8 80 d4 ff ff       	call   80103461 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80105fe1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105fe4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fe8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fef:	e8 ca f4 ff ff       	call   801054be <argstr>
80105ff4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ff7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ffb:	78 5e                	js     8010605b <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80105ffd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106000:	89 44 24 04          	mov    %eax,0x4(%esp)
80106004:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010600b:	e8 1e f4 ff ff       	call   8010542e <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106010:	85 c0                	test   %eax,%eax
80106012:	78 47                	js     8010605b <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106014:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106017:	89 44 24 04          	mov    %eax,0x4(%esp)
8010601b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106022:	e8 07 f4 ff ff       	call   8010542e <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106027:	85 c0                	test   %eax,%eax
80106029:	78 30                	js     8010605b <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010602b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010602e:	0f bf c8             	movswl %ax,%ecx
80106031:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106034:	0f bf d0             	movswl %ax,%edx
80106037:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010603a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010603e:	89 54 24 08          	mov    %edx,0x8(%esp)
80106042:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106049:	00 
8010604a:	89 04 24             	mov    %eax,(%esp)
8010604d:	e8 b9 fb ff ff       	call   80105c0b <create>
80106052:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106055:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106059:	75 0c                	jne    80106067 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010605b:	e8 82 d4 ff ff       	call   801034e2 <end_op>
    return -1;
80106060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106065:	eb 15                	jmp    8010607c <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106067:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606a:	89 04 24             	mov    %eax,(%esp)
8010606d:	e8 86 ba ff ff       	call   80101af8 <iunlockput>
  end_op();
80106072:	e8 6b d4 ff ff       	call   801034e2 <end_op>
  return 0;
80106077:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010607c:	c9                   	leave  
8010607d:	c3                   	ret    

8010607e <sys_chdir>:

int
sys_chdir(void)
{
8010607e:	55                   	push   %ebp
8010607f:	89 e5                	mov    %esp,%ebp
80106081:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106084:	e8 d8 d3 ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106089:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010608c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106090:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106097:	e8 22 f4 ff ff       	call   801054be <argstr>
8010609c:	85 c0                	test   %eax,%eax
8010609e:	78 14                	js     801060b4 <sys_chdir+0x36>
801060a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a3:	89 04 24             	mov    %eax,(%esp)
801060a6:	e8 6b c3 ff ff       	call   80102416 <namei>
801060ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060b2:	75 0c                	jne    801060c0 <sys_chdir+0x42>
    end_op();
801060b4:	e8 29 d4 ff ff       	call   801034e2 <end_op>
    return -1;
801060b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060be:	eb 61                	jmp    80106121 <sys_chdir+0xa3>
  }
  ilock(ip);
801060c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c3:	89 04 24             	mov    %eax,(%esp)
801060c6:	e8 a9 b7 ff ff       	call   80101874 <ilock>
  if(ip->type != T_DIR){
801060cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ce:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060d2:	66 83 f8 01          	cmp    $0x1,%ax
801060d6:	74 17                	je     801060ef <sys_chdir+0x71>
    iunlockput(ip);
801060d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060db:	89 04 24             	mov    %eax,(%esp)
801060de:	e8 15 ba ff ff       	call   80101af8 <iunlockput>
    end_op();
801060e3:	e8 fa d3 ff ff       	call   801034e2 <end_op>
    return -1;
801060e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ed:	eb 32                	jmp    80106121 <sys_chdir+0xa3>
  }
  iunlock(ip);
801060ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f2:	89 04 24             	mov    %eax,(%esp)
801060f5:	e8 c8 b8 ff ff       	call   801019c2 <iunlock>
  iput(proc->cwd);
801060fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106100:	8b 40 68             	mov    0x68(%eax),%eax
80106103:	89 04 24             	mov    %eax,(%esp)
80106106:	e8 1c b9 ff ff       	call   80101a27 <iput>
  end_op();
8010610b:	e8 d2 d3 ff ff       	call   801034e2 <end_op>
  proc->cwd = ip;
80106110:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106116:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106119:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010611c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106121:	c9                   	leave  
80106122:	c3                   	ret    

80106123 <sys_exec>:

int
sys_exec(void)
{
80106123:	55                   	push   %ebp
80106124:	89 e5                	mov    %esp,%ebp
80106126:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010612c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010612f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010613a:	e8 7f f3 ff ff       	call   801054be <argstr>
8010613f:	85 c0                	test   %eax,%eax
80106141:	78 1a                	js     8010615d <sys_exec+0x3a>
80106143:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106149:	89 44 24 04          	mov    %eax,0x4(%esp)
8010614d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106154:	e8 d5 f2 ff ff       	call   8010542e <argint>
80106159:	85 c0                	test   %eax,%eax
8010615b:	79 0a                	jns    80106167 <sys_exec+0x44>
    return -1;
8010615d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106162:	e9 cc 00 00 00       	jmp    80106233 <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
80106167:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010616e:	00 
8010616f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106176:	00 
80106177:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010617d:	89 04 24             	mov    %eax,(%esp)
80106180:	e8 4d ef ff ff       	call   801050d2 <memset>
  for(i=0;; i++){
80106185:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010618c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010618f:	83 f8 1f             	cmp    $0x1f,%eax
80106192:	76 0a                	jbe    8010619e <sys_exec+0x7b>
      return -1;
80106194:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106199:	e9 95 00 00 00       	jmp    80106233 <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010619e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a1:	c1 e0 02             	shl    $0x2,%eax
801061a4:	89 c2                	mov    %eax,%edx
801061a6:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801061ac:	01 c2                	add    %eax,%edx
801061ae:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801061b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801061b8:	89 14 24             	mov    %edx,(%esp)
801061bb:	e8 d0 f1 ff ff       	call   80105390 <fetchint>
801061c0:	85 c0                	test   %eax,%eax
801061c2:	79 07                	jns    801061cb <sys_exec+0xa8>
      return -1;
801061c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c9:	eb 68                	jmp    80106233 <sys_exec+0x110>
    if(uarg == 0){
801061cb:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801061d1:	85 c0                	test   %eax,%eax
801061d3:	75 26                	jne    801061fb <sys_exec+0xd8>
      argv[i] = 0;
801061d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d8:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801061df:	00 00 00 00 
      break;
801061e3:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801061e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e7:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801061ed:	89 54 24 04          	mov    %edx,0x4(%esp)
801061f1:	89 04 24             	mov    %eax,(%esp)
801061f4:	e8 03 a9 ff ff       	call   80100afc <exec>
801061f9:	eb 38                	jmp    80106233 <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801061fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061fe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106205:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010620b:	01 c2                	add    %eax,%edx
8010620d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106213:	89 54 24 04          	mov    %edx,0x4(%esp)
80106217:	89 04 24             	mov    %eax,(%esp)
8010621a:	e8 ab f1 ff ff       	call   801053ca <fetchstr>
8010621f:	85 c0                	test   %eax,%eax
80106221:	79 07                	jns    8010622a <sys_exec+0x107>
      return -1;
80106223:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106228:	eb 09                	jmp    80106233 <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010622a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010622e:	e9 59 ff ff ff       	jmp    8010618c <sys_exec+0x69>
  return exec(path, argv);
}
80106233:	c9                   	leave  
80106234:	c3                   	ret    

80106235 <sys_pipe>:

int
sys_pipe(void)
{
80106235:	55                   	push   %ebp
80106236:	89 e5                	mov    %esp,%ebp
80106238:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010623b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106242:	00 
80106243:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106246:	89 44 24 04          	mov    %eax,0x4(%esp)
8010624a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106251:	e8 06 f2 ff ff       	call   8010545c <argptr>
80106256:	85 c0                	test   %eax,%eax
80106258:	79 0a                	jns    80106264 <sys_pipe+0x2f>
    return -1;
8010625a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010625f:	e9 9b 00 00 00       	jmp    801062ff <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106264:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106267:	89 44 24 04          	mov    %eax,0x4(%esp)
8010626b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010626e:	89 04 24             	mov    %eax,(%esp)
80106271:	e8 1a dd ff ff       	call   80103f90 <pipealloc>
80106276:	85 c0                	test   %eax,%eax
80106278:	79 07                	jns    80106281 <sys_pipe+0x4c>
    return -1;
8010627a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627f:	eb 7e                	jmp    801062ff <sys_pipe+0xca>
  fd0 = -1;
80106281:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106288:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010628b:	89 04 24             	mov    %eax,(%esp)
8010628e:	e8 66 f3 ff ff       	call   801055f9 <fdalloc>
80106293:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106296:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010629a:	78 14                	js     801062b0 <sys_pipe+0x7b>
8010629c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010629f:	89 04 24             	mov    %eax,(%esp)
801062a2:	e8 52 f3 ff ff       	call   801055f9 <fdalloc>
801062a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062ae:	79 37                	jns    801062e7 <sys_pipe+0xb2>
    if(fd0 >= 0)
801062b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062b4:	78 14                	js     801062ca <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801062b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062bf:	83 c2 08             	add    $0x8,%edx
801062c2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801062c9:	00 
    fileclose(rf);
801062ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062cd:	89 04 24             	mov    %eax,(%esp)
801062d0:	e8 fb ac ff ff       	call   80100fd0 <fileclose>
    fileclose(wf);
801062d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062d8:	89 04 24             	mov    %eax,(%esp)
801062db:	e8 f0 ac ff ff       	call   80100fd0 <fileclose>
    return -1;
801062e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e5:	eb 18                	jmp    801062ff <sys_pipe+0xca>
  }
  fd[0] = fd0;
801062e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062ed:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801062ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062f2:	8d 50 04             	lea    0x4(%eax),%edx
801062f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f8:	89 02                	mov    %eax,(%edx)
  return 0;
801062fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062ff:	c9                   	leave  
80106300:	c3                   	ret    
80106301:	00 00                	add    %al,(%eax)
	...

80106304 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106304:	55                   	push   %ebp
80106305:	89 e5                	mov    %esp,%ebp
80106307:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010630a:	e8 34 e3 ff ff       	call   80104643 <fork>
}
8010630f:	c9                   	leave  
80106310:	c3                   	ret    

80106311 <sys_exit>:

int
sys_exit(void)
{
80106311:	55                   	push   %ebp
80106312:	89 e5                	mov    %esp,%ebp
80106314:	83 ec 28             	sub    $0x28,%esp
	int status;
	if(argint(0, &status) < 0)
80106317:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010631a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010631e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106325:	e8 04 f1 ff ff       	call   8010542e <argint>
8010632a:	85 c0                	test   %eax,%eax
8010632c:	79 07                	jns    80106335 <sys_exit+0x24>
	    return -1;
8010632e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106333:	eb 10                	jmp    80106345 <sys_exit+0x34>

	exit(status);
80106335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106338:	89 04 24             	mov    %eax,(%esp)
8010633b:	e8 7e e4 ff ff       	call   801047be <exit>
	return 0;  // not reached
80106340:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106345:	c9                   	leave  
80106346:	c3                   	ret    

80106347 <sys_wait>:

int
sys_wait(void)
{
80106347:	55                   	push   %ebp
80106348:	89 e5                	mov    %esp,%ebp
8010634a:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010634d:	e8 9a e5 ff ff       	call   801048ec <wait>
}
80106352:	c9                   	leave  
80106353:	c3                   	ret    

80106354 <sys_kill>:

int
sys_kill(void)
{
80106354:	55                   	push   %ebp
80106355:	89 e5                	mov    %esp,%ebp
80106357:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010635a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010635d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106361:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106368:	e8 c1 f0 ff ff       	call   8010542e <argint>
8010636d:	85 c0                	test   %eax,%eax
8010636f:	79 07                	jns    80106378 <sys_kill+0x24>
    return -1;
80106371:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106376:	eb 0b                	jmp    80106383 <sys_kill+0x2f>
  return kill(pid);
80106378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637b:	89 04 24             	mov    %eax,(%esp)
8010637e:	e8 25 e9 ff ff       	call   80104ca8 <kill>
}
80106383:	c9                   	leave  
80106384:	c3                   	ret    

80106385 <sys_getpid>:

int
sys_getpid(void)
{
80106385:	55                   	push   %ebp
80106386:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106388:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010638e:	8b 40 10             	mov    0x10(%eax),%eax
}
80106391:	5d                   	pop    %ebp
80106392:	c3                   	ret    

80106393 <sys_sbrk>:

int
sys_sbrk(void)
{
80106393:	55                   	push   %ebp
80106394:	89 e5                	mov    %esp,%ebp
80106396:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106399:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010639c:	89 44 24 04          	mov    %eax,0x4(%esp)
801063a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063a7:	e8 82 f0 ff ff       	call   8010542e <argint>
801063ac:	85 c0                	test   %eax,%eax
801063ae:	79 07                	jns    801063b7 <sys_sbrk+0x24>
    return -1;
801063b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b5:	eb 24                	jmp    801063db <sys_sbrk+0x48>
  addr = proc->sz;
801063b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063bd:	8b 00                	mov    (%eax),%eax
801063bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801063c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c5:	89 04 24             	mov    %eax,(%esp)
801063c8:	e8 d1 e1 ff ff       	call   8010459e <growproc>
801063cd:	85 c0                	test   %eax,%eax
801063cf:	79 07                	jns    801063d8 <sys_sbrk+0x45>
    return -1;
801063d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d6:	eb 03                	jmp    801063db <sys_sbrk+0x48>
  return addr;
801063d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063db:	c9                   	leave  
801063dc:	c3                   	ret    

801063dd <sys_sleep>:

int
sys_sleep(void)
{
801063dd:	55                   	push   %ebp
801063de:	89 e5                	mov    %esp,%ebp
801063e0:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801063e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801063ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063f1:	e8 38 f0 ff ff       	call   8010542e <argint>
801063f6:	85 c0                	test   %eax,%eax
801063f8:	79 07                	jns    80106401 <sys_sleep+0x24>
    return -1;
801063fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ff:	eb 6c                	jmp    8010646d <sys_sleep+0x90>
  acquire(&tickslock);
80106401:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106408:	e8 76 ea ff ff       	call   80104e83 <acquire>
  ticks0 = ticks;
8010640d:	a1 e0 51 11 80       	mov    0x801151e0,%eax
80106412:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106415:	eb 34                	jmp    8010644b <sys_sleep+0x6e>
    if(proc->killed){
80106417:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010641d:	8b 40 24             	mov    0x24(%eax),%eax
80106420:	85 c0                	test   %eax,%eax
80106422:	74 13                	je     80106437 <sys_sleep+0x5a>
      release(&tickslock);
80106424:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
8010642b:	e8 b5 ea ff ff       	call   80104ee5 <release>
      return -1;
80106430:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106435:	eb 36                	jmp    8010646d <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106437:	c7 44 24 04 a0 49 11 	movl   $0x801149a0,0x4(%esp)
8010643e:	80 
8010643f:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80106446:	e8 59 e7 ff ff       	call   80104ba4 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010644b:	a1 e0 51 11 80       	mov    0x801151e0,%eax
80106450:	89 c2                	mov    %eax,%edx
80106452:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106455:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106458:	39 c2                	cmp    %eax,%edx
8010645a:	72 bb                	jb     80106417 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010645c:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106463:	e8 7d ea ff ff       	call   80104ee5 <release>
  return 0;
80106468:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010646d:	c9                   	leave  
8010646e:	c3                   	ret    

8010646f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010646f:	55                   	push   %ebp
80106470:	89 e5                	mov    %esp,%ebp
80106472:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106475:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
8010647c:	e8 02 ea ff ff       	call   80104e83 <acquire>
  xticks = ticks;
80106481:	a1 e0 51 11 80       	mov    0x801151e0,%eax
80106486:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106489:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106490:	e8 50 ea ff ff       	call   80104ee5 <release>
  return xticks;
80106495:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106498:	c9                   	leave  
80106499:	c3                   	ret    
	...

8010649c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010649c:	55                   	push   %ebp
8010649d:	89 e5                	mov    %esp,%ebp
8010649f:	83 ec 08             	sub    $0x8,%esp
801064a2:	8b 55 08             	mov    0x8(%ebp),%edx
801064a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801064a8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801064ac:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801064af:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801064b3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801064b7:	ee                   	out    %al,(%dx)
}
801064b8:	c9                   	leave  
801064b9:	c3                   	ret    

801064ba <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801064ba:	55                   	push   %ebp
801064bb:	89 e5                	mov    %esp,%ebp
801064bd:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801064c0:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801064c7:	00 
801064c8:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801064cf:	e8 c8 ff ff ff       	call   8010649c <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801064d4:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801064db:	00 
801064dc:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801064e3:	e8 b4 ff ff ff       	call   8010649c <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801064e8:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801064ef:	00 
801064f0:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801064f7:	e8 a0 ff ff ff       	call   8010649c <outb>
  picenable(IRQ_TIMER);
801064fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106503:	e8 11 d9 ff ff       	call   80103e19 <picenable>
}
80106508:	c9                   	leave  
80106509:	c3                   	ret    
	...

8010650c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010650c:	1e                   	push   %ds
  pushl %es
8010650d:	06                   	push   %es
  pushl %fs
8010650e:	0f a0                	push   %fs
  pushl %gs
80106510:	0f a8                	push   %gs
  pushal
80106512:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106513:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106517:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106519:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010651b:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010651f:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106521:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106523:	54                   	push   %esp
  call trap
80106524:	e8 de 01 00 00       	call   80106707 <trap>
  addl $4, %esp
80106529:	83 c4 04             	add    $0x4,%esp

8010652c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010652c:	61                   	popa   
  popl %gs
8010652d:	0f a9                	pop    %gs
  popl %fs
8010652f:	0f a1                	pop    %fs
  popl %es
80106531:	07                   	pop    %es
  popl %ds
80106532:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106533:	83 c4 08             	add    $0x8,%esp
  iret
80106536:	cf                   	iret   
	...

80106538 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106538:	55                   	push   %ebp
80106539:	89 e5                	mov    %esp,%ebp
8010653b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010653e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106541:	83 e8 01             	sub    $0x1,%eax
80106544:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106548:	8b 45 08             	mov    0x8(%ebp),%eax
8010654b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010654f:	8b 45 08             	mov    0x8(%ebp),%eax
80106552:	c1 e8 10             	shr    $0x10,%eax
80106555:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106559:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010655c:	0f 01 18             	lidtl  (%eax)
}
8010655f:	c9                   	leave  
80106560:	c3                   	ret    

80106561 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106561:	55                   	push   %ebp
80106562:	89 e5                	mov    %esp,%ebp
80106564:	53                   	push   %ebx
80106565:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106568:	0f 20 d3             	mov    %cr2,%ebx
8010656b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
8010656e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106571:	83 c4 10             	add    $0x10,%esp
80106574:	5b                   	pop    %ebx
80106575:	5d                   	pop    %ebp
80106576:	c3                   	ret    

80106577 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106577:	55                   	push   %ebp
80106578:	89 e5                	mov    %esp,%ebp
8010657a:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010657d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106584:	e9 c3 00 00 00       	jmp    8010664c <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658c:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106593:	89 c2                	mov    %eax,%edx
80106595:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106598:	66 89 14 c5 e0 49 11 	mov    %dx,-0x7feeb620(,%eax,8)
8010659f:	80 
801065a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065a3:	66 c7 04 c5 e2 49 11 	movw   $0x8,-0x7feeb61e(,%eax,8)
801065aa:	80 08 00 
801065ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b0:	0f b6 14 c5 e4 49 11 	movzbl -0x7feeb61c(,%eax,8),%edx
801065b7:	80 
801065b8:	83 e2 e0             	and    $0xffffffe0,%edx
801065bb:	88 14 c5 e4 49 11 80 	mov    %dl,-0x7feeb61c(,%eax,8)
801065c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c5:	0f b6 14 c5 e4 49 11 	movzbl -0x7feeb61c(,%eax,8),%edx
801065cc:	80 
801065cd:	83 e2 1f             	and    $0x1f,%edx
801065d0:	88 14 c5 e4 49 11 80 	mov    %dl,-0x7feeb61c(,%eax,8)
801065d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065da:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
801065e1:	80 
801065e2:	83 e2 f0             	and    $0xfffffff0,%edx
801065e5:	83 ca 0e             	or     $0xe,%edx
801065e8:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
801065ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f2:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
801065f9:	80 
801065fa:	83 e2 ef             	and    $0xffffffef,%edx
801065fd:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
80106604:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106607:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
8010660e:	80 
8010660f:	83 e2 9f             	and    $0xffffff9f,%edx
80106612:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
80106619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661c:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
80106623:	80 
80106624:	83 ca 80             	or     $0xffffff80,%edx
80106627:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
8010662e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106631:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
80106638:	c1 e8 10             	shr    $0x10,%eax
8010663b:	89 c2                	mov    %eax,%edx
8010663d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106640:	66 89 14 c5 e6 49 11 	mov    %dx,-0x7feeb61a(,%eax,8)
80106647:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106648:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010664c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106653:	0f 8e 30 ff ff ff    	jle    80106589 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106659:	a1 98 b1 10 80       	mov    0x8010b198,%eax
8010665e:	66 a3 e0 4b 11 80    	mov    %ax,0x80114be0
80106664:	66 c7 05 e2 4b 11 80 	movw   $0x8,0x80114be2
8010666b:	08 00 
8010666d:	0f b6 05 e4 4b 11 80 	movzbl 0x80114be4,%eax
80106674:	83 e0 e0             	and    $0xffffffe0,%eax
80106677:	a2 e4 4b 11 80       	mov    %al,0x80114be4
8010667c:	0f b6 05 e4 4b 11 80 	movzbl 0x80114be4,%eax
80106683:	83 e0 1f             	and    $0x1f,%eax
80106686:	a2 e4 4b 11 80       	mov    %al,0x80114be4
8010668b:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
80106692:	83 c8 0f             	or     $0xf,%eax
80106695:	a2 e5 4b 11 80       	mov    %al,0x80114be5
8010669a:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801066a1:	83 e0 ef             	and    $0xffffffef,%eax
801066a4:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801066a9:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801066b0:	83 c8 60             	or     $0x60,%eax
801066b3:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801066b8:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801066bf:	83 c8 80             	or     $0xffffff80,%eax
801066c2:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801066c7:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801066cc:	c1 e8 10             	shr    $0x10,%eax
801066cf:	66 a3 e6 4b 11 80    	mov    %ax,0x80114be6
  
  initlock(&tickslock, "time");
801066d5:	c7 44 24 04 0c 89 10 	movl   $0x8010890c,0x4(%esp)
801066dc:	80 
801066dd:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801066e4:	e8 79 e7 ff ff       	call   80104e62 <initlock>
}
801066e9:	c9                   	leave  
801066ea:	c3                   	ret    

801066eb <idtinit>:

void
idtinit(void)
{
801066eb:	55                   	push   %ebp
801066ec:	89 e5                	mov    %esp,%ebp
801066ee:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801066f1:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801066f8:	00 
801066f9:	c7 04 24 e0 49 11 80 	movl   $0x801149e0,(%esp)
80106700:	e8 33 fe ff ff       	call   80106538 <lidt>
}
80106705:	c9                   	leave  
80106706:	c3                   	ret    

80106707 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106707:	55                   	push   %ebp
80106708:	89 e5                	mov    %esp,%ebp
8010670a:	57                   	push   %edi
8010670b:	56                   	push   %esi
8010670c:	53                   	push   %ebx
8010670d:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106710:	8b 45 08             	mov    0x8(%ebp),%eax
80106713:	8b 40 30             	mov    0x30(%eax),%eax
80106716:	83 f8 40             	cmp    $0x40,%eax
80106719:	75 4c                	jne    80106767 <trap+0x60>
    if(proc->killed)
8010671b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106721:	8b 40 24             	mov    0x24(%eax),%eax
80106724:	85 c0                	test   %eax,%eax
80106726:	74 0c                	je     80106734 <trap+0x2d>
      exit(EXIT_STATUS_DEFAULT);
80106728:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010672f:	e8 8a e0 ff ff       	call   801047be <exit>
    proc->tf = tf;
80106734:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010673a:	8b 55 08             	mov    0x8(%ebp),%edx
8010673d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106740:	e8 b0 ed ff ff       	call   801054f5 <syscall>
    if(proc->killed)
80106745:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010674b:	8b 40 24             	mov    0x24(%eax),%eax
8010674e:	85 c0                	test   %eax,%eax
80106750:	0f 84 49 02 00 00    	je     8010699f <trap+0x298>
      exit(EXIT_STATUS_DEFAULT);
80106756:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010675d:	e8 5c e0 ff ff       	call   801047be <exit>
    return;
80106762:	e9 38 02 00 00       	jmp    8010699f <trap+0x298>
  }

  switch(tf->trapno){
80106767:	8b 45 08             	mov    0x8(%ebp),%eax
8010676a:	8b 40 30             	mov    0x30(%eax),%eax
8010676d:	83 e8 20             	sub    $0x20,%eax
80106770:	83 f8 1f             	cmp    $0x1f,%eax
80106773:	0f 87 bc 00 00 00    	ja     80106835 <trap+0x12e>
80106779:	8b 04 85 b4 89 10 80 	mov    -0x7fef764c(,%eax,4),%eax
80106780:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106782:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106788:	0f b6 00             	movzbl (%eax),%eax
8010678b:	84 c0                	test   %al,%al
8010678d:	75 31                	jne    801067c0 <trap+0xb9>
      acquire(&tickslock);
8010678f:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106796:	e8 e8 e6 ff ff       	call   80104e83 <acquire>
      ticks++;
8010679b:	a1 e0 51 11 80       	mov    0x801151e0,%eax
801067a0:	83 c0 01             	add    $0x1,%eax
801067a3:	a3 e0 51 11 80       	mov    %eax,0x801151e0
      wakeup(&ticks);
801067a8:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
801067af:	e8 c9 e4 ff ff       	call   80104c7d <wakeup>
      release(&tickslock);
801067b4:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801067bb:	e8 25 e7 ff ff       	call   80104ee5 <release>
    }
    lapiceoi();
801067c0:	e8 5a c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067c5:	e9 41 01 00 00       	jmp    8010690b <trap+0x204>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801067ca:	e8 2e bf ff ff       	call   801026fd <ideintr>
    lapiceoi();
801067cf:	e8 4b c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067d4:	e9 32 01 00 00       	jmp    8010690b <trap+0x204>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801067d9:	e8 f5 c4 ff ff       	call   80102cd3 <kbdintr>
    lapiceoi();
801067de:	e8 3c c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067e3:	e9 23 01 00 00       	jmp    8010690b <trap+0x204>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801067e8:	e8 b7 03 00 00       	call   80106ba4 <uartintr>
    lapiceoi();
801067ed:	e8 2d c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067f2:	e9 14 01 00 00       	jmp    8010690b <trap+0x204>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
801067f7:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801067fa:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801067fd:	8b 45 08             	mov    0x8(%ebp),%eax
80106800:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106804:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106807:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010680d:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106810:	0f b6 c0             	movzbl %al,%eax
80106813:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106817:	89 54 24 08          	mov    %edx,0x8(%esp)
8010681b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010681f:	c7 04 24 14 89 10 80 	movl   $0x80108914,(%esp)
80106826:	e8 76 9b ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010682b:	e8 ef c6 ff ff       	call   80102f1f <lapiceoi>
    break;
80106830:	e9 d6 00 00 00       	jmp    8010690b <trap+0x204>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106835:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010683b:	85 c0                	test   %eax,%eax
8010683d:	74 11                	je     80106850 <trap+0x149>
8010683f:	8b 45 08             	mov    0x8(%ebp),%eax
80106842:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106846:	0f b7 c0             	movzwl %ax,%eax
80106849:	83 e0 03             	and    $0x3,%eax
8010684c:	85 c0                	test   %eax,%eax
8010684e:	75 46                	jne    80106896 <trap+0x18f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106850:	e8 0c fd ff ff       	call   80106561 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106855:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106858:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010685b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106862:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106865:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106868:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010686b:	8b 52 30             	mov    0x30(%edx),%edx
8010686e:	89 44 24 10          	mov    %eax,0x10(%esp)
80106872:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106876:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010687a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010687e:	c7 04 24 38 89 10 80 	movl   $0x80108938,(%esp)
80106885:	e8 17 9b ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010688a:	c7 04 24 6a 89 10 80 	movl   $0x8010896a,(%esp)
80106891:	e8 a7 9c ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106896:	e8 c6 fc ff ff       	call   80106561 <rcr2>
8010689b:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010689d:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068a0:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801068a3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801068a9:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068ac:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801068af:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068b2:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801068b5:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068b8:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801068bb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068c1:	83 c0 6c             	add    $0x6c,%eax
801068c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801068c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801068cd:	8b 40 10             	mov    0x10(%eax),%eax
801068d0:	89 54 24 1c          	mov    %edx,0x1c(%esp)
801068d4:	89 7c 24 18          	mov    %edi,0x18(%esp)
801068d8:	89 74 24 14          	mov    %esi,0x14(%esp)
801068dc:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801068e0:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801068e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801068e7:	89 54 24 08          	mov    %edx,0x8(%esp)
801068eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801068ef:	c7 04 24 70 89 10 80 	movl   $0x80108970,(%esp)
801068f6:	e8 a6 9a ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801068fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106901:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106908:	eb 01                	jmp    8010690b <trap+0x204>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010690a:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010690b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106911:	85 c0                	test   %eax,%eax
80106913:	74 2b                	je     80106940 <trap+0x239>
80106915:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010691b:	8b 40 24             	mov    0x24(%eax),%eax
8010691e:	85 c0                	test   %eax,%eax
80106920:	74 1e                	je     80106940 <trap+0x239>
80106922:	8b 45 08             	mov    0x8(%ebp),%eax
80106925:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106929:	0f b7 c0             	movzwl %ax,%eax
8010692c:	83 e0 03             	and    $0x3,%eax
8010692f:	83 f8 03             	cmp    $0x3,%eax
80106932:	75 0c                	jne    80106940 <trap+0x239>
    exit(EXIT_STATUS_DEFAULT);
80106934:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010693b:	e8 7e de ff ff       	call   801047be <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106940:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106946:	85 c0                	test   %eax,%eax
80106948:	74 1e                	je     80106968 <trap+0x261>
8010694a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106950:	8b 40 0c             	mov    0xc(%eax),%eax
80106953:	83 f8 04             	cmp    $0x4,%eax
80106956:	75 10                	jne    80106968 <trap+0x261>
80106958:	8b 45 08             	mov    0x8(%ebp),%eax
8010695b:	8b 40 30             	mov    0x30(%eax),%eax
8010695e:	83 f8 20             	cmp    $0x20,%eax
80106961:	75 05                	jne    80106968 <trap+0x261>
    yield();
80106963:	e8 de e1 ff ff       	call   80104b46 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106968:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010696e:	85 c0                	test   %eax,%eax
80106970:	74 2e                	je     801069a0 <trap+0x299>
80106972:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106978:	8b 40 24             	mov    0x24(%eax),%eax
8010697b:	85 c0                	test   %eax,%eax
8010697d:	74 21                	je     801069a0 <trap+0x299>
8010697f:	8b 45 08             	mov    0x8(%ebp),%eax
80106982:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106986:	0f b7 c0             	movzwl %ax,%eax
80106989:	83 e0 03             	and    $0x3,%eax
8010698c:	83 f8 03             	cmp    $0x3,%eax
8010698f:	75 0f                	jne    801069a0 <trap+0x299>
    exit(EXIT_STATUS_DEFAULT);
80106991:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106998:	e8 21 de ff ff       	call   801047be <exit>
8010699d:	eb 01                	jmp    801069a0 <trap+0x299>
      exit(EXIT_STATUS_DEFAULT);
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit(EXIT_STATUS_DEFAULT);
    return;
8010699f:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit(EXIT_STATUS_DEFAULT);
}
801069a0:	83 c4 3c             	add    $0x3c,%esp
801069a3:	5b                   	pop    %ebx
801069a4:	5e                   	pop    %esi
801069a5:	5f                   	pop    %edi
801069a6:	5d                   	pop    %ebp
801069a7:	c3                   	ret    

801069a8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801069a8:	55                   	push   %ebp
801069a9:	89 e5                	mov    %esp,%ebp
801069ab:	53                   	push   %ebx
801069ac:	83 ec 14             	sub    $0x14,%esp
801069af:	8b 45 08             	mov    0x8(%ebp),%eax
801069b2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801069b6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801069ba:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801069be:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801069c2:	ec                   	in     (%dx),%al
801069c3:	89 c3                	mov    %eax,%ebx
801069c5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801069c8:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801069cc:	83 c4 14             	add    $0x14,%esp
801069cf:	5b                   	pop    %ebx
801069d0:	5d                   	pop    %ebp
801069d1:	c3                   	ret    

801069d2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801069d2:	55                   	push   %ebp
801069d3:	89 e5                	mov    %esp,%ebp
801069d5:	83 ec 08             	sub    $0x8,%esp
801069d8:	8b 55 08             	mov    0x8(%ebp),%edx
801069db:	8b 45 0c             	mov    0xc(%ebp),%eax
801069de:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801069e2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801069e5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801069e9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801069ed:	ee                   	out    %al,(%dx)
}
801069ee:	c9                   	leave  
801069ef:	c3                   	ret    

801069f0 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801069f0:	55                   	push   %ebp
801069f1:	89 e5                	mov    %esp,%ebp
801069f3:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801069f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801069fd:	00 
801069fe:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106a05:	e8 c8 ff ff ff       	call   801069d2 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106a0a:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106a11:	00 
80106a12:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106a19:	e8 b4 ff ff ff       	call   801069d2 <outb>
  outb(COM1+0, 115200/9600);
80106a1e:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106a25:	00 
80106a26:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106a2d:	e8 a0 ff ff ff       	call   801069d2 <outb>
  outb(COM1+1, 0);
80106a32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a39:	00 
80106a3a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106a41:	e8 8c ff ff ff       	call   801069d2 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106a46:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106a4d:	00 
80106a4e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106a55:	e8 78 ff ff ff       	call   801069d2 <outb>
  outb(COM1+4, 0);
80106a5a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a61:	00 
80106a62:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106a69:	e8 64 ff ff ff       	call   801069d2 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106a6e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106a75:	00 
80106a76:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106a7d:	e8 50 ff ff ff       	call   801069d2 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106a82:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106a89:	e8 1a ff ff ff       	call   801069a8 <inb>
80106a8e:	3c ff                	cmp    $0xff,%al
80106a90:	74 6c                	je     80106afe <uartinit+0x10e>
    return;
  uart = 1;
80106a92:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106a99:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106a9c:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106aa3:	e8 00 ff ff ff       	call   801069a8 <inb>
  inb(COM1+0);
80106aa8:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106aaf:	e8 f4 fe ff ff       	call   801069a8 <inb>
  picenable(IRQ_COM1);
80106ab4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106abb:	e8 59 d3 ff ff       	call   80103e19 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106ac0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ac7:	00 
80106ac8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106acf:	e8 ae be ff ff       	call   80102982 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106ad4:	c7 45 f4 34 8a 10 80 	movl   $0x80108a34,-0xc(%ebp)
80106adb:	eb 15                	jmp    80106af2 <uartinit+0x102>
    uartputc(*p);
80106add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae0:	0f b6 00             	movzbl (%eax),%eax
80106ae3:	0f be c0             	movsbl %al,%eax
80106ae6:	89 04 24             	mov    %eax,(%esp)
80106ae9:	e8 13 00 00 00       	call   80106b01 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106aee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af5:	0f b6 00             	movzbl (%eax),%eax
80106af8:	84 c0                	test   %al,%al
80106afa:	75 e1                	jne    80106add <uartinit+0xed>
80106afc:	eb 01                	jmp    80106aff <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106afe:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106aff:	c9                   	leave  
80106b00:	c3                   	ret    

80106b01 <uartputc>:

void
uartputc(int c)
{
80106b01:	55                   	push   %ebp
80106b02:	89 e5                	mov    %esp,%ebp
80106b04:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106b07:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106b0c:	85 c0                	test   %eax,%eax
80106b0e:	74 4d                	je     80106b5d <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b17:	eb 10                	jmp    80106b29 <uartputc+0x28>
    microdelay(10);
80106b19:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106b20:	e8 1f c4 ff ff       	call   80102f44 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106b25:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106b29:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106b2d:	7f 16                	jg     80106b45 <uartputc+0x44>
80106b2f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106b36:	e8 6d fe ff ff       	call   801069a8 <inb>
80106b3b:	0f b6 c0             	movzbl %al,%eax
80106b3e:	83 e0 20             	and    $0x20,%eax
80106b41:	85 c0                	test   %eax,%eax
80106b43:	74 d4                	je     80106b19 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106b45:	8b 45 08             	mov    0x8(%ebp),%eax
80106b48:	0f b6 c0             	movzbl %al,%eax
80106b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b4f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b56:	e8 77 fe ff ff       	call   801069d2 <outb>
80106b5b:	eb 01                	jmp    80106b5e <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106b5d:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106b5e:	c9                   	leave  
80106b5f:	c3                   	ret    

80106b60 <uartgetc>:

static int
uartgetc(void)
{
80106b60:	55                   	push   %ebp
80106b61:	89 e5                	mov    %esp,%ebp
80106b63:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106b66:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106b6b:	85 c0                	test   %eax,%eax
80106b6d:	75 07                	jne    80106b76 <uartgetc+0x16>
    return -1;
80106b6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b74:	eb 2c                	jmp    80106ba2 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106b76:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106b7d:	e8 26 fe ff ff       	call   801069a8 <inb>
80106b82:	0f b6 c0             	movzbl %al,%eax
80106b85:	83 e0 01             	and    $0x1,%eax
80106b88:	85 c0                	test   %eax,%eax
80106b8a:	75 07                	jne    80106b93 <uartgetc+0x33>
    return -1;
80106b8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b91:	eb 0f                	jmp    80106ba2 <uartgetc+0x42>
  return inb(COM1+0);
80106b93:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b9a:	e8 09 fe ff ff       	call   801069a8 <inb>
80106b9f:	0f b6 c0             	movzbl %al,%eax
}
80106ba2:	c9                   	leave  
80106ba3:	c3                   	ret    

80106ba4 <uartintr>:

void
uartintr(void)
{
80106ba4:	55                   	push   %ebp
80106ba5:	89 e5                	mov    %esp,%ebp
80106ba7:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106baa:	c7 04 24 60 6b 10 80 	movl   $0x80106b60,(%esp)
80106bb1:	e8 f7 9b ff ff       	call   801007ad <consoleintr>
}
80106bb6:	c9                   	leave  
80106bb7:	c3                   	ret    

80106bb8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $0
80106bba:	6a 00                	push   $0x0
  jmp alltraps
80106bbc:	e9 4b f9 ff ff       	jmp    8010650c <alltraps>

80106bc1 <vector1>:
.globl vector1
vector1:
  pushl $0
80106bc1:	6a 00                	push   $0x0
  pushl $1
80106bc3:	6a 01                	push   $0x1
  jmp alltraps
80106bc5:	e9 42 f9 ff ff       	jmp    8010650c <alltraps>

80106bca <vector2>:
.globl vector2
vector2:
  pushl $0
80106bca:	6a 00                	push   $0x0
  pushl $2
80106bcc:	6a 02                	push   $0x2
  jmp alltraps
80106bce:	e9 39 f9 ff ff       	jmp    8010650c <alltraps>

80106bd3 <vector3>:
.globl vector3
vector3:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $3
80106bd5:	6a 03                	push   $0x3
  jmp alltraps
80106bd7:	e9 30 f9 ff ff       	jmp    8010650c <alltraps>

80106bdc <vector4>:
.globl vector4
vector4:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $4
80106bde:	6a 04                	push   $0x4
  jmp alltraps
80106be0:	e9 27 f9 ff ff       	jmp    8010650c <alltraps>

80106be5 <vector5>:
.globl vector5
vector5:
  pushl $0
80106be5:	6a 00                	push   $0x0
  pushl $5
80106be7:	6a 05                	push   $0x5
  jmp alltraps
80106be9:	e9 1e f9 ff ff       	jmp    8010650c <alltraps>

80106bee <vector6>:
.globl vector6
vector6:
  pushl $0
80106bee:	6a 00                	push   $0x0
  pushl $6
80106bf0:	6a 06                	push   $0x6
  jmp alltraps
80106bf2:	e9 15 f9 ff ff       	jmp    8010650c <alltraps>

80106bf7 <vector7>:
.globl vector7
vector7:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $7
80106bf9:	6a 07                	push   $0x7
  jmp alltraps
80106bfb:	e9 0c f9 ff ff       	jmp    8010650c <alltraps>

80106c00 <vector8>:
.globl vector8
vector8:
  pushl $8
80106c00:	6a 08                	push   $0x8
  jmp alltraps
80106c02:	e9 05 f9 ff ff       	jmp    8010650c <alltraps>

80106c07 <vector9>:
.globl vector9
vector9:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $9
80106c09:	6a 09                	push   $0x9
  jmp alltraps
80106c0b:	e9 fc f8 ff ff       	jmp    8010650c <alltraps>

80106c10 <vector10>:
.globl vector10
vector10:
  pushl $10
80106c10:	6a 0a                	push   $0xa
  jmp alltraps
80106c12:	e9 f5 f8 ff ff       	jmp    8010650c <alltraps>

80106c17 <vector11>:
.globl vector11
vector11:
  pushl $11
80106c17:	6a 0b                	push   $0xb
  jmp alltraps
80106c19:	e9 ee f8 ff ff       	jmp    8010650c <alltraps>

80106c1e <vector12>:
.globl vector12
vector12:
  pushl $12
80106c1e:	6a 0c                	push   $0xc
  jmp alltraps
80106c20:	e9 e7 f8 ff ff       	jmp    8010650c <alltraps>

80106c25 <vector13>:
.globl vector13
vector13:
  pushl $13
80106c25:	6a 0d                	push   $0xd
  jmp alltraps
80106c27:	e9 e0 f8 ff ff       	jmp    8010650c <alltraps>

80106c2c <vector14>:
.globl vector14
vector14:
  pushl $14
80106c2c:	6a 0e                	push   $0xe
  jmp alltraps
80106c2e:	e9 d9 f8 ff ff       	jmp    8010650c <alltraps>

80106c33 <vector15>:
.globl vector15
vector15:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $15
80106c35:	6a 0f                	push   $0xf
  jmp alltraps
80106c37:	e9 d0 f8 ff ff       	jmp    8010650c <alltraps>

80106c3c <vector16>:
.globl vector16
vector16:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $16
80106c3e:	6a 10                	push   $0x10
  jmp alltraps
80106c40:	e9 c7 f8 ff ff       	jmp    8010650c <alltraps>

80106c45 <vector17>:
.globl vector17
vector17:
  pushl $17
80106c45:	6a 11                	push   $0x11
  jmp alltraps
80106c47:	e9 c0 f8 ff ff       	jmp    8010650c <alltraps>

80106c4c <vector18>:
.globl vector18
vector18:
  pushl $0
80106c4c:	6a 00                	push   $0x0
  pushl $18
80106c4e:	6a 12                	push   $0x12
  jmp alltraps
80106c50:	e9 b7 f8 ff ff       	jmp    8010650c <alltraps>

80106c55 <vector19>:
.globl vector19
vector19:
  pushl $0
80106c55:	6a 00                	push   $0x0
  pushl $19
80106c57:	6a 13                	push   $0x13
  jmp alltraps
80106c59:	e9 ae f8 ff ff       	jmp    8010650c <alltraps>

80106c5e <vector20>:
.globl vector20
vector20:
  pushl $0
80106c5e:	6a 00                	push   $0x0
  pushl $20
80106c60:	6a 14                	push   $0x14
  jmp alltraps
80106c62:	e9 a5 f8 ff ff       	jmp    8010650c <alltraps>

80106c67 <vector21>:
.globl vector21
vector21:
  pushl $0
80106c67:	6a 00                	push   $0x0
  pushl $21
80106c69:	6a 15                	push   $0x15
  jmp alltraps
80106c6b:	e9 9c f8 ff ff       	jmp    8010650c <alltraps>

80106c70 <vector22>:
.globl vector22
vector22:
  pushl $0
80106c70:	6a 00                	push   $0x0
  pushl $22
80106c72:	6a 16                	push   $0x16
  jmp alltraps
80106c74:	e9 93 f8 ff ff       	jmp    8010650c <alltraps>

80106c79 <vector23>:
.globl vector23
vector23:
  pushl $0
80106c79:	6a 00                	push   $0x0
  pushl $23
80106c7b:	6a 17                	push   $0x17
  jmp alltraps
80106c7d:	e9 8a f8 ff ff       	jmp    8010650c <alltraps>

80106c82 <vector24>:
.globl vector24
vector24:
  pushl $0
80106c82:	6a 00                	push   $0x0
  pushl $24
80106c84:	6a 18                	push   $0x18
  jmp alltraps
80106c86:	e9 81 f8 ff ff       	jmp    8010650c <alltraps>

80106c8b <vector25>:
.globl vector25
vector25:
  pushl $0
80106c8b:	6a 00                	push   $0x0
  pushl $25
80106c8d:	6a 19                	push   $0x19
  jmp alltraps
80106c8f:	e9 78 f8 ff ff       	jmp    8010650c <alltraps>

80106c94 <vector26>:
.globl vector26
vector26:
  pushl $0
80106c94:	6a 00                	push   $0x0
  pushl $26
80106c96:	6a 1a                	push   $0x1a
  jmp alltraps
80106c98:	e9 6f f8 ff ff       	jmp    8010650c <alltraps>

80106c9d <vector27>:
.globl vector27
vector27:
  pushl $0
80106c9d:	6a 00                	push   $0x0
  pushl $27
80106c9f:	6a 1b                	push   $0x1b
  jmp alltraps
80106ca1:	e9 66 f8 ff ff       	jmp    8010650c <alltraps>

80106ca6 <vector28>:
.globl vector28
vector28:
  pushl $0
80106ca6:	6a 00                	push   $0x0
  pushl $28
80106ca8:	6a 1c                	push   $0x1c
  jmp alltraps
80106caa:	e9 5d f8 ff ff       	jmp    8010650c <alltraps>

80106caf <vector29>:
.globl vector29
vector29:
  pushl $0
80106caf:	6a 00                	push   $0x0
  pushl $29
80106cb1:	6a 1d                	push   $0x1d
  jmp alltraps
80106cb3:	e9 54 f8 ff ff       	jmp    8010650c <alltraps>

80106cb8 <vector30>:
.globl vector30
vector30:
  pushl $0
80106cb8:	6a 00                	push   $0x0
  pushl $30
80106cba:	6a 1e                	push   $0x1e
  jmp alltraps
80106cbc:	e9 4b f8 ff ff       	jmp    8010650c <alltraps>

80106cc1 <vector31>:
.globl vector31
vector31:
  pushl $0
80106cc1:	6a 00                	push   $0x0
  pushl $31
80106cc3:	6a 1f                	push   $0x1f
  jmp alltraps
80106cc5:	e9 42 f8 ff ff       	jmp    8010650c <alltraps>

80106cca <vector32>:
.globl vector32
vector32:
  pushl $0
80106cca:	6a 00                	push   $0x0
  pushl $32
80106ccc:	6a 20                	push   $0x20
  jmp alltraps
80106cce:	e9 39 f8 ff ff       	jmp    8010650c <alltraps>

80106cd3 <vector33>:
.globl vector33
vector33:
  pushl $0
80106cd3:	6a 00                	push   $0x0
  pushl $33
80106cd5:	6a 21                	push   $0x21
  jmp alltraps
80106cd7:	e9 30 f8 ff ff       	jmp    8010650c <alltraps>

80106cdc <vector34>:
.globl vector34
vector34:
  pushl $0
80106cdc:	6a 00                	push   $0x0
  pushl $34
80106cde:	6a 22                	push   $0x22
  jmp alltraps
80106ce0:	e9 27 f8 ff ff       	jmp    8010650c <alltraps>

80106ce5 <vector35>:
.globl vector35
vector35:
  pushl $0
80106ce5:	6a 00                	push   $0x0
  pushl $35
80106ce7:	6a 23                	push   $0x23
  jmp alltraps
80106ce9:	e9 1e f8 ff ff       	jmp    8010650c <alltraps>

80106cee <vector36>:
.globl vector36
vector36:
  pushl $0
80106cee:	6a 00                	push   $0x0
  pushl $36
80106cf0:	6a 24                	push   $0x24
  jmp alltraps
80106cf2:	e9 15 f8 ff ff       	jmp    8010650c <alltraps>

80106cf7 <vector37>:
.globl vector37
vector37:
  pushl $0
80106cf7:	6a 00                	push   $0x0
  pushl $37
80106cf9:	6a 25                	push   $0x25
  jmp alltraps
80106cfb:	e9 0c f8 ff ff       	jmp    8010650c <alltraps>

80106d00 <vector38>:
.globl vector38
vector38:
  pushl $0
80106d00:	6a 00                	push   $0x0
  pushl $38
80106d02:	6a 26                	push   $0x26
  jmp alltraps
80106d04:	e9 03 f8 ff ff       	jmp    8010650c <alltraps>

80106d09 <vector39>:
.globl vector39
vector39:
  pushl $0
80106d09:	6a 00                	push   $0x0
  pushl $39
80106d0b:	6a 27                	push   $0x27
  jmp alltraps
80106d0d:	e9 fa f7 ff ff       	jmp    8010650c <alltraps>

80106d12 <vector40>:
.globl vector40
vector40:
  pushl $0
80106d12:	6a 00                	push   $0x0
  pushl $40
80106d14:	6a 28                	push   $0x28
  jmp alltraps
80106d16:	e9 f1 f7 ff ff       	jmp    8010650c <alltraps>

80106d1b <vector41>:
.globl vector41
vector41:
  pushl $0
80106d1b:	6a 00                	push   $0x0
  pushl $41
80106d1d:	6a 29                	push   $0x29
  jmp alltraps
80106d1f:	e9 e8 f7 ff ff       	jmp    8010650c <alltraps>

80106d24 <vector42>:
.globl vector42
vector42:
  pushl $0
80106d24:	6a 00                	push   $0x0
  pushl $42
80106d26:	6a 2a                	push   $0x2a
  jmp alltraps
80106d28:	e9 df f7 ff ff       	jmp    8010650c <alltraps>

80106d2d <vector43>:
.globl vector43
vector43:
  pushl $0
80106d2d:	6a 00                	push   $0x0
  pushl $43
80106d2f:	6a 2b                	push   $0x2b
  jmp alltraps
80106d31:	e9 d6 f7 ff ff       	jmp    8010650c <alltraps>

80106d36 <vector44>:
.globl vector44
vector44:
  pushl $0
80106d36:	6a 00                	push   $0x0
  pushl $44
80106d38:	6a 2c                	push   $0x2c
  jmp alltraps
80106d3a:	e9 cd f7 ff ff       	jmp    8010650c <alltraps>

80106d3f <vector45>:
.globl vector45
vector45:
  pushl $0
80106d3f:	6a 00                	push   $0x0
  pushl $45
80106d41:	6a 2d                	push   $0x2d
  jmp alltraps
80106d43:	e9 c4 f7 ff ff       	jmp    8010650c <alltraps>

80106d48 <vector46>:
.globl vector46
vector46:
  pushl $0
80106d48:	6a 00                	push   $0x0
  pushl $46
80106d4a:	6a 2e                	push   $0x2e
  jmp alltraps
80106d4c:	e9 bb f7 ff ff       	jmp    8010650c <alltraps>

80106d51 <vector47>:
.globl vector47
vector47:
  pushl $0
80106d51:	6a 00                	push   $0x0
  pushl $47
80106d53:	6a 2f                	push   $0x2f
  jmp alltraps
80106d55:	e9 b2 f7 ff ff       	jmp    8010650c <alltraps>

80106d5a <vector48>:
.globl vector48
vector48:
  pushl $0
80106d5a:	6a 00                	push   $0x0
  pushl $48
80106d5c:	6a 30                	push   $0x30
  jmp alltraps
80106d5e:	e9 a9 f7 ff ff       	jmp    8010650c <alltraps>

80106d63 <vector49>:
.globl vector49
vector49:
  pushl $0
80106d63:	6a 00                	push   $0x0
  pushl $49
80106d65:	6a 31                	push   $0x31
  jmp alltraps
80106d67:	e9 a0 f7 ff ff       	jmp    8010650c <alltraps>

80106d6c <vector50>:
.globl vector50
vector50:
  pushl $0
80106d6c:	6a 00                	push   $0x0
  pushl $50
80106d6e:	6a 32                	push   $0x32
  jmp alltraps
80106d70:	e9 97 f7 ff ff       	jmp    8010650c <alltraps>

80106d75 <vector51>:
.globl vector51
vector51:
  pushl $0
80106d75:	6a 00                	push   $0x0
  pushl $51
80106d77:	6a 33                	push   $0x33
  jmp alltraps
80106d79:	e9 8e f7 ff ff       	jmp    8010650c <alltraps>

80106d7e <vector52>:
.globl vector52
vector52:
  pushl $0
80106d7e:	6a 00                	push   $0x0
  pushl $52
80106d80:	6a 34                	push   $0x34
  jmp alltraps
80106d82:	e9 85 f7 ff ff       	jmp    8010650c <alltraps>

80106d87 <vector53>:
.globl vector53
vector53:
  pushl $0
80106d87:	6a 00                	push   $0x0
  pushl $53
80106d89:	6a 35                	push   $0x35
  jmp alltraps
80106d8b:	e9 7c f7 ff ff       	jmp    8010650c <alltraps>

80106d90 <vector54>:
.globl vector54
vector54:
  pushl $0
80106d90:	6a 00                	push   $0x0
  pushl $54
80106d92:	6a 36                	push   $0x36
  jmp alltraps
80106d94:	e9 73 f7 ff ff       	jmp    8010650c <alltraps>

80106d99 <vector55>:
.globl vector55
vector55:
  pushl $0
80106d99:	6a 00                	push   $0x0
  pushl $55
80106d9b:	6a 37                	push   $0x37
  jmp alltraps
80106d9d:	e9 6a f7 ff ff       	jmp    8010650c <alltraps>

80106da2 <vector56>:
.globl vector56
vector56:
  pushl $0
80106da2:	6a 00                	push   $0x0
  pushl $56
80106da4:	6a 38                	push   $0x38
  jmp alltraps
80106da6:	e9 61 f7 ff ff       	jmp    8010650c <alltraps>

80106dab <vector57>:
.globl vector57
vector57:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $57
80106dad:	6a 39                	push   $0x39
  jmp alltraps
80106daf:	e9 58 f7 ff ff       	jmp    8010650c <alltraps>

80106db4 <vector58>:
.globl vector58
vector58:
  pushl $0
80106db4:	6a 00                	push   $0x0
  pushl $58
80106db6:	6a 3a                	push   $0x3a
  jmp alltraps
80106db8:	e9 4f f7 ff ff       	jmp    8010650c <alltraps>

80106dbd <vector59>:
.globl vector59
vector59:
  pushl $0
80106dbd:	6a 00                	push   $0x0
  pushl $59
80106dbf:	6a 3b                	push   $0x3b
  jmp alltraps
80106dc1:	e9 46 f7 ff ff       	jmp    8010650c <alltraps>

80106dc6 <vector60>:
.globl vector60
vector60:
  pushl $0
80106dc6:	6a 00                	push   $0x0
  pushl $60
80106dc8:	6a 3c                	push   $0x3c
  jmp alltraps
80106dca:	e9 3d f7 ff ff       	jmp    8010650c <alltraps>

80106dcf <vector61>:
.globl vector61
vector61:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $61
80106dd1:	6a 3d                	push   $0x3d
  jmp alltraps
80106dd3:	e9 34 f7 ff ff       	jmp    8010650c <alltraps>

80106dd8 <vector62>:
.globl vector62
vector62:
  pushl $0
80106dd8:	6a 00                	push   $0x0
  pushl $62
80106dda:	6a 3e                	push   $0x3e
  jmp alltraps
80106ddc:	e9 2b f7 ff ff       	jmp    8010650c <alltraps>

80106de1 <vector63>:
.globl vector63
vector63:
  pushl $0
80106de1:	6a 00                	push   $0x0
  pushl $63
80106de3:	6a 3f                	push   $0x3f
  jmp alltraps
80106de5:	e9 22 f7 ff ff       	jmp    8010650c <alltraps>

80106dea <vector64>:
.globl vector64
vector64:
  pushl $0
80106dea:	6a 00                	push   $0x0
  pushl $64
80106dec:	6a 40                	push   $0x40
  jmp alltraps
80106dee:	e9 19 f7 ff ff       	jmp    8010650c <alltraps>

80106df3 <vector65>:
.globl vector65
vector65:
  pushl $0
80106df3:	6a 00                	push   $0x0
  pushl $65
80106df5:	6a 41                	push   $0x41
  jmp alltraps
80106df7:	e9 10 f7 ff ff       	jmp    8010650c <alltraps>

80106dfc <vector66>:
.globl vector66
vector66:
  pushl $0
80106dfc:	6a 00                	push   $0x0
  pushl $66
80106dfe:	6a 42                	push   $0x42
  jmp alltraps
80106e00:	e9 07 f7 ff ff       	jmp    8010650c <alltraps>

80106e05 <vector67>:
.globl vector67
vector67:
  pushl $0
80106e05:	6a 00                	push   $0x0
  pushl $67
80106e07:	6a 43                	push   $0x43
  jmp alltraps
80106e09:	e9 fe f6 ff ff       	jmp    8010650c <alltraps>

80106e0e <vector68>:
.globl vector68
vector68:
  pushl $0
80106e0e:	6a 00                	push   $0x0
  pushl $68
80106e10:	6a 44                	push   $0x44
  jmp alltraps
80106e12:	e9 f5 f6 ff ff       	jmp    8010650c <alltraps>

80106e17 <vector69>:
.globl vector69
vector69:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $69
80106e19:	6a 45                	push   $0x45
  jmp alltraps
80106e1b:	e9 ec f6 ff ff       	jmp    8010650c <alltraps>

80106e20 <vector70>:
.globl vector70
vector70:
  pushl $0
80106e20:	6a 00                	push   $0x0
  pushl $70
80106e22:	6a 46                	push   $0x46
  jmp alltraps
80106e24:	e9 e3 f6 ff ff       	jmp    8010650c <alltraps>

80106e29 <vector71>:
.globl vector71
vector71:
  pushl $0
80106e29:	6a 00                	push   $0x0
  pushl $71
80106e2b:	6a 47                	push   $0x47
  jmp alltraps
80106e2d:	e9 da f6 ff ff       	jmp    8010650c <alltraps>

80106e32 <vector72>:
.globl vector72
vector72:
  pushl $0
80106e32:	6a 00                	push   $0x0
  pushl $72
80106e34:	6a 48                	push   $0x48
  jmp alltraps
80106e36:	e9 d1 f6 ff ff       	jmp    8010650c <alltraps>

80106e3b <vector73>:
.globl vector73
vector73:
  pushl $0
80106e3b:	6a 00                	push   $0x0
  pushl $73
80106e3d:	6a 49                	push   $0x49
  jmp alltraps
80106e3f:	e9 c8 f6 ff ff       	jmp    8010650c <alltraps>

80106e44 <vector74>:
.globl vector74
vector74:
  pushl $0
80106e44:	6a 00                	push   $0x0
  pushl $74
80106e46:	6a 4a                	push   $0x4a
  jmp alltraps
80106e48:	e9 bf f6 ff ff       	jmp    8010650c <alltraps>

80106e4d <vector75>:
.globl vector75
vector75:
  pushl $0
80106e4d:	6a 00                	push   $0x0
  pushl $75
80106e4f:	6a 4b                	push   $0x4b
  jmp alltraps
80106e51:	e9 b6 f6 ff ff       	jmp    8010650c <alltraps>

80106e56 <vector76>:
.globl vector76
vector76:
  pushl $0
80106e56:	6a 00                	push   $0x0
  pushl $76
80106e58:	6a 4c                	push   $0x4c
  jmp alltraps
80106e5a:	e9 ad f6 ff ff       	jmp    8010650c <alltraps>

80106e5f <vector77>:
.globl vector77
vector77:
  pushl $0
80106e5f:	6a 00                	push   $0x0
  pushl $77
80106e61:	6a 4d                	push   $0x4d
  jmp alltraps
80106e63:	e9 a4 f6 ff ff       	jmp    8010650c <alltraps>

80106e68 <vector78>:
.globl vector78
vector78:
  pushl $0
80106e68:	6a 00                	push   $0x0
  pushl $78
80106e6a:	6a 4e                	push   $0x4e
  jmp alltraps
80106e6c:	e9 9b f6 ff ff       	jmp    8010650c <alltraps>

80106e71 <vector79>:
.globl vector79
vector79:
  pushl $0
80106e71:	6a 00                	push   $0x0
  pushl $79
80106e73:	6a 4f                	push   $0x4f
  jmp alltraps
80106e75:	e9 92 f6 ff ff       	jmp    8010650c <alltraps>

80106e7a <vector80>:
.globl vector80
vector80:
  pushl $0
80106e7a:	6a 00                	push   $0x0
  pushl $80
80106e7c:	6a 50                	push   $0x50
  jmp alltraps
80106e7e:	e9 89 f6 ff ff       	jmp    8010650c <alltraps>

80106e83 <vector81>:
.globl vector81
vector81:
  pushl $0
80106e83:	6a 00                	push   $0x0
  pushl $81
80106e85:	6a 51                	push   $0x51
  jmp alltraps
80106e87:	e9 80 f6 ff ff       	jmp    8010650c <alltraps>

80106e8c <vector82>:
.globl vector82
vector82:
  pushl $0
80106e8c:	6a 00                	push   $0x0
  pushl $82
80106e8e:	6a 52                	push   $0x52
  jmp alltraps
80106e90:	e9 77 f6 ff ff       	jmp    8010650c <alltraps>

80106e95 <vector83>:
.globl vector83
vector83:
  pushl $0
80106e95:	6a 00                	push   $0x0
  pushl $83
80106e97:	6a 53                	push   $0x53
  jmp alltraps
80106e99:	e9 6e f6 ff ff       	jmp    8010650c <alltraps>

80106e9e <vector84>:
.globl vector84
vector84:
  pushl $0
80106e9e:	6a 00                	push   $0x0
  pushl $84
80106ea0:	6a 54                	push   $0x54
  jmp alltraps
80106ea2:	e9 65 f6 ff ff       	jmp    8010650c <alltraps>

80106ea7 <vector85>:
.globl vector85
vector85:
  pushl $0
80106ea7:	6a 00                	push   $0x0
  pushl $85
80106ea9:	6a 55                	push   $0x55
  jmp alltraps
80106eab:	e9 5c f6 ff ff       	jmp    8010650c <alltraps>

80106eb0 <vector86>:
.globl vector86
vector86:
  pushl $0
80106eb0:	6a 00                	push   $0x0
  pushl $86
80106eb2:	6a 56                	push   $0x56
  jmp alltraps
80106eb4:	e9 53 f6 ff ff       	jmp    8010650c <alltraps>

80106eb9 <vector87>:
.globl vector87
vector87:
  pushl $0
80106eb9:	6a 00                	push   $0x0
  pushl $87
80106ebb:	6a 57                	push   $0x57
  jmp alltraps
80106ebd:	e9 4a f6 ff ff       	jmp    8010650c <alltraps>

80106ec2 <vector88>:
.globl vector88
vector88:
  pushl $0
80106ec2:	6a 00                	push   $0x0
  pushl $88
80106ec4:	6a 58                	push   $0x58
  jmp alltraps
80106ec6:	e9 41 f6 ff ff       	jmp    8010650c <alltraps>

80106ecb <vector89>:
.globl vector89
vector89:
  pushl $0
80106ecb:	6a 00                	push   $0x0
  pushl $89
80106ecd:	6a 59                	push   $0x59
  jmp alltraps
80106ecf:	e9 38 f6 ff ff       	jmp    8010650c <alltraps>

80106ed4 <vector90>:
.globl vector90
vector90:
  pushl $0
80106ed4:	6a 00                	push   $0x0
  pushl $90
80106ed6:	6a 5a                	push   $0x5a
  jmp alltraps
80106ed8:	e9 2f f6 ff ff       	jmp    8010650c <alltraps>

80106edd <vector91>:
.globl vector91
vector91:
  pushl $0
80106edd:	6a 00                	push   $0x0
  pushl $91
80106edf:	6a 5b                	push   $0x5b
  jmp alltraps
80106ee1:	e9 26 f6 ff ff       	jmp    8010650c <alltraps>

80106ee6 <vector92>:
.globl vector92
vector92:
  pushl $0
80106ee6:	6a 00                	push   $0x0
  pushl $92
80106ee8:	6a 5c                	push   $0x5c
  jmp alltraps
80106eea:	e9 1d f6 ff ff       	jmp    8010650c <alltraps>

80106eef <vector93>:
.globl vector93
vector93:
  pushl $0
80106eef:	6a 00                	push   $0x0
  pushl $93
80106ef1:	6a 5d                	push   $0x5d
  jmp alltraps
80106ef3:	e9 14 f6 ff ff       	jmp    8010650c <alltraps>

80106ef8 <vector94>:
.globl vector94
vector94:
  pushl $0
80106ef8:	6a 00                	push   $0x0
  pushl $94
80106efa:	6a 5e                	push   $0x5e
  jmp alltraps
80106efc:	e9 0b f6 ff ff       	jmp    8010650c <alltraps>

80106f01 <vector95>:
.globl vector95
vector95:
  pushl $0
80106f01:	6a 00                	push   $0x0
  pushl $95
80106f03:	6a 5f                	push   $0x5f
  jmp alltraps
80106f05:	e9 02 f6 ff ff       	jmp    8010650c <alltraps>

80106f0a <vector96>:
.globl vector96
vector96:
  pushl $0
80106f0a:	6a 00                	push   $0x0
  pushl $96
80106f0c:	6a 60                	push   $0x60
  jmp alltraps
80106f0e:	e9 f9 f5 ff ff       	jmp    8010650c <alltraps>

80106f13 <vector97>:
.globl vector97
vector97:
  pushl $0
80106f13:	6a 00                	push   $0x0
  pushl $97
80106f15:	6a 61                	push   $0x61
  jmp alltraps
80106f17:	e9 f0 f5 ff ff       	jmp    8010650c <alltraps>

80106f1c <vector98>:
.globl vector98
vector98:
  pushl $0
80106f1c:	6a 00                	push   $0x0
  pushl $98
80106f1e:	6a 62                	push   $0x62
  jmp alltraps
80106f20:	e9 e7 f5 ff ff       	jmp    8010650c <alltraps>

80106f25 <vector99>:
.globl vector99
vector99:
  pushl $0
80106f25:	6a 00                	push   $0x0
  pushl $99
80106f27:	6a 63                	push   $0x63
  jmp alltraps
80106f29:	e9 de f5 ff ff       	jmp    8010650c <alltraps>

80106f2e <vector100>:
.globl vector100
vector100:
  pushl $0
80106f2e:	6a 00                	push   $0x0
  pushl $100
80106f30:	6a 64                	push   $0x64
  jmp alltraps
80106f32:	e9 d5 f5 ff ff       	jmp    8010650c <alltraps>

80106f37 <vector101>:
.globl vector101
vector101:
  pushl $0
80106f37:	6a 00                	push   $0x0
  pushl $101
80106f39:	6a 65                	push   $0x65
  jmp alltraps
80106f3b:	e9 cc f5 ff ff       	jmp    8010650c <alltraps>

80106f40 <vector102>:
.globl vector102
vector102:
  pushl $0
80106f40:	6a 00                	push   $0x0
  pushl $102
80106f42:	6a 66                	push   $0x66
  jmp alltraps
80106f44:	e9 c3 f5 ff ff       	jmp    8010650c <alltraps>

80106f49 <vector103>:
.globl vector103
vector103:
  pushl $0
80106f49:	6a 00                	push   $0x0
  pushl $103
80106f4b:	6a 67                	push   $0x67
  jmp alltraps
80106f4d:	e9 ba f5 ff ff       	jmp    8010650c <alltraps>

80106f52 <vector104>:
.globl vector104
vector104:
  pushl $0
80106f52:	6a 00                	push   $0x0
  pushl $104
80106f54:	6a 68                	push   $0x68
  jmp alltraps
80106f56:	e9 b1 f5 ff ff       	jmp    8010650c <alltraps>

80106f5b <vector105>:
.globl vector105
vector105:
  pushl $0
80106f5b:	6a 00                	push   $0x0
  pushl $105
80106f5d:	6a 69                	push   $0x69
  jmp alltraps
80106f5f:	e9 a8 f5 ff ff       	jmp    8010650c <alltraps>

80106f64 <vector106>:
.globl vector106
vector106:
  pushl $0
80106f64:	6a 00                	push   $0x0
  pushl $106
80106f66:	6a 6a                	push   $0x6a
  jmp alltraps
80106f68:	e9 9f f5 ff ff       	jmp    8010650c <alltraps>

80106f6d <vector107>:
.globl vector107
vector107:
  pushl $0
80106f6d:	6a 00                	push   $0x0
  pushl $107
80106f6f:	6a 6b                	push   $0x6b
  jmp alltraps
80106f71:	e9 96 f5 ff ff       	jmp    8010650c <alltraps>

80106f76 <vector108>:
.globl vector108
vector108:
  pushl $0
80106f76:	6a 00                	push   $0x0
  pushl $108
80106f78:	6a 6c                	push   $0x6c
  jmp alltraps
80106f7a:	e9 8d f5 ff ff       	jmp    8010650c <alltraps>

80106f7f <vector109>:
.globl vector109
vector109:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $109
80106f81:	6a 6d                	push   $0x6d
  jmp alltraps
80106f83:	e9 84 f5 ff ff       	jmp    8010650c <alltraps>

80106f88 <vector110>:
.globl vector110
vector110:
  pushl $0
80106f88:	6a 00                	push   $0x0
  pushl $110
80106f8a:	6a 6e                	push   $0x6e
  jmp alltraps
80106f8c:	e9 7b f5 ff ff       	jmp    8010650c <alltraps>

80106f91 <vector111>:
.globl vector111
vector111:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $111
80106f93:	6a 6f                	push   $0x6f
  jmp alltraps
80106f95:	e9 72 f5 ff ff       	jmp    8010650c <alltraps>

80106f9a <vector112>:
.globl vector112
vector112:
  pushl $0
80106f9a:	6a 00                	push   $0x0
  pushl $112
80106f9c:	6a 70                	push   $0x70
  jmp alltraps
80106f9e:	e9 69 f5 ff ff       	jmp    8010650c <alltraps>

80106fa3 <vector113>:
.globl vector113
vector113:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $113
80106fa5:	6a 71                	push   $0x71
  jmp alltraps
80106fa7:	e9 60 f5 ff ff       	jmp    8010650c <alltraps>

80106fac <vector114>:
.globl vector114
vector114:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $114
80106fae:	6a 72                	push   $0x72
  jmp alltraps
80106fb0:	e9 57 f5 ff ff       	jmp    8010650c <alltraps>

80106fb5 <vector115>:
.globl vector115
vector115:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $115
80106fb7:	6a 73                	push   $0x73
  jmp alltraps
80106fb9:	e9 4e f5 ff ff       	jmp    8010650c <alltraps>

80106fbe <vector116>:
.globl vector116
vector116:
  pushl $0
80106fbe:	6a 00                	push   $0x0
  pushl $116
80106fc0:	6a 74                	push   $0x74
  jmp alltraps
80106fc2:	e9 45 f5 ff ff       	jmp    8010650c <alltraps>

80106fc7 <vector117>:
.globl vector117
vector117:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $117
80106fc9:	6a 75                	push   $0x75
  jmp alltraps
80106fcb:	e9 3c f5 ff ff       	jmp    8010650c <alltraps>

80106fd0 <vector118>:
.globl vector118
vector118:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $118
80106fd2:	6a 76                	push   $0x76
  jmp alltraps
80106fd4:	e9 33 f5 ff ff       	jmp    8010650c <alltraps>

80106fd9 <vector119>:
.globl vector119
vector119:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $119
80106fdb:	6a 77                	push   $0x77
  jmp alltraps
80106fdd:	e9 2a f5 ff ff       	jmp    8010650c <alltraps>

80106fe2 <vector120>:
.globl vector120
vector120:
  pushl $0
80106fe2:	6a 00                	push   $0x0
  pushl $120
80106fe4:	6a 78                	push   $0x78
  jmp alltraps
80106fe6:	e9 21 f5 ff ff       	jmp    8010650c <alltraps>

80106feb <vector121>:
.globl vector121
vector121:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $121
80106fed:	6a 79                	push   $0x79
  jmp alltraps
80106fef:	e9 18 f5 ff ff       	jmp    8010650c <alltraps>

80106ff4 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $122
80106ff6:	6a 7a                	push   $0x7a
  jmp alltraps
80106ff8:	e9 0f f5 ff ff       	jmp    8010650c <alltraps>

80106ffd <vector123>:
.globl vector123
vector123:
  pushl $0
80106ffd:	6a 00                	push   $0x0
  pushl $123
80106fff:	6a 7b                	push   $0x7b
  jmp alltraps
80107001:	e9 06 f5 ff ff       	jmp    8010650c <alltraps>

80107006 <vector124>:
.globl vector124
vector124:
  pushl $0
80107006:	6a 00                	push   $0x0
  pushl $124
80107008:	6a 7c                	push   $0x7c
  jmp alltraps
8010700a:	e9 fd f4 ff ff       	jmp    8010650c <alltraps>

8010700f <vector125>:
.globl vector125
vector125:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $125
80107011:	6a 7d                	push   $0x7d
  jmp alltraps
80107013:	e9 f4 f4 ff ff       	jmp    8010650c <alltraps>

80107018 <vector126>:
.globl vector126
vector126:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $126
8010701a:	6a 7e                	push   $0x7e
  jmp alltraps
8010701c:	e9 eb f4 ff ff       	jmp    8010650c <alltraps>

80107021 <vector127>:
.globl vector127
vector127:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $127
80107023:	6a 7f                	push   $0x7f
  jmp alltraps
80107025:	e9 e2 f4 ff ff       	jmp    8010650c <alltraps>

8010702a <vector128>:
.globl vector128
vector128:
  pushl $0
8010702a:	6a 00                	push   $0x0
  pushl $128
8010702c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107031:	e9 d6 f4 ff ff       	jmp    8010650c <alltraps>

80107036 <vector129>:
.globl vector129
vector129:
  pushl $0
80107036:	6a 00                	push   $0x0
  pushl $129
80107038:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010703d:	e9 ca f4 ff ff       	jmp    8010650c <alltraps>

80107042 <vector130>:
.globl vector130
vector130:
  pushl $0
80107042:	6a 00                	push   $0x0
  pushl $130
80107044:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107049:	e9 be f4 ff ff       	jmp    8010650c <alltraps>

8010704e <vector131>:
.globl vector131
vector131:
  pushl $0
8010704e:	6a 00                	push   $0x0
  pushl $131
80107050:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107055:	e9 b2 f4 ff ff       	jmp    8010650c <alltraps>

8010705a <vector132>:
.globl vector132
vector132:
  pushl $0
8010705a:	6a 00                	push   $0x0
  pushl $132
8010705c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107061:	e9 a6 f4 ff ff       	jmp    8010650c <alltraps>

80107066 <vector133>:
.globl vector133
vector133:
  pushl $0
80107066:	6a 00                	push   $0x0
  pushl $133
80107068:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010706d:	e9 9a f4 ff ff       	jmp    8010650c <alltraps>

80107072 <vector134>:
.globl vector134
vector134:
  pushl $0
80107072:	6a 00                	push   $0x0
  pushl $134
80107074:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107079:	e9 8e f4 ff ff       	jmp    8010650c <alltraps>

8010707e <vector135>:
.globl vector135
vector135:
  pushl $0
8010707e:	6a 00                	push   $0x0
  pushl $135
80107080:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107085:	e9 82 f4 ff ff       	jmp    8010650c <alltraps>

8010708a <vector136>:
.globl vector136
vector136:
  pushl $0
8010708a:	6a 00                	push   $0x0
  pushl $136
8010708c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107091:	e9 76 f4 ff ff       	jmp    8010650c <alltraps>

80107096 <vector137>:
.globl vector137
vector137:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $137
80107098:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010709d:	e9 6a f4 ff ff       	jmp    8010650c <alltraps>

801070a2 <vector138>:
.globl vector138
vector138:
  pushl $0
801070a2:	6a 00                	push   $0x0
  pushl $138
801070a4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801070a9:	e9 5e f4 ff ff       	jmp    8010650c <alltraps>

801070ae <vector139>:
.globl vector139
vector139:
  pushl $0
801070ae:	6a 00                	push   $0x0
  pushl $139
801070b0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801070b5:	e9 52 f4 ff ff       	jmp    8010650c <alltraps>

801070ba <vector140>:
.globl vector140
vector140:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $140
801070bc:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801070c1:	e9 46 f4 ff ff       	jmp    8010650c <alltraps>

801070c6 <vector141>:
.globl vector141
vector141:
  pushl $0
801070c6:	6a 00                	push   $0x0
  pushl $141
801070c8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801070cd:	e9 3a f4 ff ff       	jmp    8010650c <alltraps>

801070d2 <vector142>:
.globl vector142
vector142:
  pushl $0
801070d2:	6a 00                	push   $0x0
  pushl $142
801070d4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801070d9:	e9 2e f4 ff ff       	jmp    8010650c <alltraps>

801070de <vector143>:
.globl vector143
vector143:
  pushl $0
801070de:	6a 00                	push   $0x0
  pushl $143
801070e0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801070e5:	e9 22 f4 ff ff       	jmp    8010650c <alltraps>

801070ea <vector144>:
.globl vector144
vector144:
  pushl $0
801070ea:	6a 00                	push   $0x0
  pushl $144
801070ec:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801070f1:	e9 16 f4 ff ff       	jmp    8010650c <alltraps>

801070f6 <vector145>:
.globl vector145
vector145:
  pushl $0
801070f6:	6a 00                	push   $0x0
  pushl $145
801070f8:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801070fd:	e9 0a f4 ff ff       	jmp    8010650c <alltraps>

80107102 <vector146>:
.globl vector146
vector146:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $146
80107104:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107109:	e9 fe f3 ff ff       	jmp    8010650c <alltraps>

8010710e <vector147>:
.globl vector147
vector147:
  pushl $0
8010710e:	6a 00                	push   $0x0
  pushl $147
80107110:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107115:	e9 f2 f3 ff ff       	jmp    8010650c <alltraps>

8010711a <vector148>:
.globl vector148
vector148:
  pushl $0
8010711a:	6a 00                	push   $0x0
  pushl $148
8010711c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107121:	e9 e6 f3 ff ff       	jmp    8010650c <alltraps>

80107126 <vector149>:
.globl vector149
vector149:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $149
80107128:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010712d:	e9 da f3 ff ff       	jmp    8010650c <alltraps>

80107132 <vector150>:
.globl vector150
vector150:
  pushl $0
80107132:	6a 00                	push   $0x0
  pushl $150
80107134:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107139:	e9 ce f3 ff ff       	jmp    8010650c <alltraps>

8010713e <vector151>:
.globl vector151
vector151:
  pushl $0
8010713e:	6a 00                	push   $0x0
  pushl $151
80107140:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107145:	e9 c2 f3 ff ff       	jmp    8010650c <alltraps>

8010714a <vector152>:
.globl vector152
vector152:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $152
8010714c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107151:	e9 b6 f3 ff ff       	jmp    8010650c <alltraps>

80107156 <vector153>:
.globl vector153
vector153:
  pushl $0
80107156:	6a 00                	push   $0x0
  pushl $153
80107158:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010715d:	e9 aa f3 ff ff       	jmp    8010650c <alltraps>

80107162 <vector154>:
.globl vector154
vector154:
  pushl $0
80107162:	6a 00                	push   $0x0
  pushl $154
80107164:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107169:	e9 9e f3 ff ff       	jmp    8010650c <alltraps>

8010716e <vector155>:
.globl vector155
vector155:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $155
80107170:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107175:	e9 92 f3 ff ff       	jmp    8010650c <alltraps>

8010717a <vector156>:
.globl vector156
vector156:
  pushl $0
8010717a:	6a 00                	push   $0x0
  pushl $156
8010717c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107181:	e9 86 f3 ff ff       	jmp    8010650c <alltraps>

80107186 <vector157>:
.globl vector157
vector157:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $157
80107188:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010718d:	e9 7a f3 ff ff       	jmp    8010650c <alltraps>

80107192 <vector158>:
.globl vector158
vector158:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $158
80107194:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107199:	e9 6e f3 ff ff       	jmp    8010650c <alltraps>

8010719e <vector159>:
.globl vector159
vector159:
  pushl $0
8010719e:	6a 00                	push   $0x0
  pushl $159
801071a0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801071a5:	e9 62 f3 ff ff       	jmp    8010650c <alltraps>

801071aa <vector160>:
.globl vector160
vector160:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $160
801071ac:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801071b1:	e9 56 f3 ff ff       	jmp    8010650c <alltraps>

801071b6 <vector161>:
.globl vector161
vector161:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $161
801071b8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801071bd:	e9 4a f3 ff ff       	jmp    8010650c <alltraps>

801071c2 <vector162>:
.globl vector162
vector162:
  pushl $0
801071c2:	6a 00                	push   $0x0
  pushl $162
801071c4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801071c9:	e9 3e f3 ff ff       	jmp    8010650c <alltraps>

801071ce <vector163>:
.globl vector163
vector163:
  pushl $0
801071ce:	6a 00                	push   $0x0
  pushl $163
801071d0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801071d5:	e9 32 f3 ff ff       	jmp    8010650c <alltraps>

801071da <vector164>:
.globl vector164
vector164:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $164
801071dc:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801071e1:	e9 26 f3 ff ff       	jmp    8010650c <alltraps>

801071e6 <vector165>:
.globl vector165
vector165:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $165
801071e8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801071ed:	e9 1a f3 ff ff       	jmp    8010650c <alltraps>

801071f2 <vector166>:
.globl vector166
vector166:
  pushl $0
801071f2:	6a 00                	push   $0x0
  pushl $166
801071f4:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801071f9:	e9 0e f3 ff ff       	jmp    8010650c <alltraps>

801071fe <vector167>:
.globl vector167
vector167:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $167
80107200:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107205:	e9 02 f3 ff ff       	jmp    8010650c <alltraps>

8010720a <vector168>:
.globl vector168
vector168:
  pushl $0
8010720a:	6a 00                	push   $0x0
  pushl $168
8010720c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107211:	e9 f6 f2 ff ff       	jmp    8010650c <alltraps>

80107216 <vector169>:
.globl vector169
vector169:
  pushl $0
80107216:	6a 00                	push   $0x0
  pushl $169
80107218:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010721d:	e9 ea f2 ff ff       	jmp    8010650c <alltraps>

80107222 <vector170>:
.globl vector170
vector170:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $170
80107224:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107229:	e9 de f2 ff ff       	jmp    8010650c <alltraps>

8010722e <vector171>:
.globl vector171
vector171:
  pushl $0
8010722e:	6a 00                	push   $0x0
  pushl $171
80107230:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107235:	e9 d2 f2 ff ff       	jmp    8010650c <alltraps>

8010723a <vector172>:
.globl vector172
vector172:
  pushl $0
8010723a:	6a 00                	push   $0x0
  pushl $172
8010723c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107241:	e9 c6 f2 ff ff       	jmp    8010650c <alltraps>

80107246 <vector173>:
.globl vector173
vector173:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $173
80107248:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010724d:	e9 ba f2 ff ff       	jmp    8010650c <alltraps>

80107252 <vector174>:
.globl vector174
vector174:
  pushl $0
80107252:	6a 00                	push   $0x0
  pushl $174
80107254:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107259:	e9 ae f2 ff ff       	jmp    8010650c <alltraps>

8010725e <vector175>:
.globl vector175
vector175:
  pushl $0
8010725e:	6a 00                	push   $0x0
  pushl $175
80107260:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107265:	e9 a2 f2 ff ff       	jmp    8010650c <alltraps>

8010726a <vector176>:
.globl vector176
vector176:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $176
8010726c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107271:	e9 96 f2 ff ff       	jmp    8010650c <alltraps>

80107276 <vector177>:
.globl vector177
vector177:
  pushl $0
80107276:	6a 00                	push   $0x0
  pushl $177
80107278:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010727d:	e9 8a f2 ff ff       	jmp    8010650c <alltraps>

80107282 <vector178>:
.globl vector178
vector178:
  pushl $0
80107282:	6a 00                	push   $0x0
  pushl $178
80107284:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107289:	e9 7e f2 ff ff       	jmp    8010650c <alltraps>

8010728e <vector179>:
.globl vector179
vector179:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $179
80107290:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107295:	e9 72 f2 ff ff       	jmp    8010650c <alltraps>

8010729a <vector180>:
.globl vector180
vector180:
  pushl $0
8010729a:	6a 00                	push   $0x0
  pushl $180
8010729c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801072a1:	e9 66 f2 ff ff       	jmp    8010650c <alltraps>

801072a6 <vector181>:
.globl vector181
vector181:
  pushl $0
801072a6:	6a 00                	push   $0x0
  pushl $181
801072a8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801072ad:	e9 5a f2 ff ff       	jmp    8010650c <alltraps>

801072b2 <vector182>:
.globl vector182
vector182:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $182
801072b4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801072b9:	e9 4e f2 ff ff       	jmp    8010650c <alltraps>

801072be <vector183>:
.globl vector183
vector183:
  pushl $0
801072be:	6a 00                	push   $0x0
  pushl $183
801072c0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801072c5:	e9 42 f2 ff ff       	jmp    8010650c <alltraps>

801072ca <vector184>:
.globl vector184
vector184:
  pushl $0
801072ca:	6a 00                	push   $0x0
  pushl $184
801072cc:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801072d1:	e9 36 f2 ff ff       	jmp    8010650c <alltraps>

801072d6 <vector185>:
.globl vector185
vector185:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $185
801072d8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801072dd:	e9 2a f2 ff ff       	jmp    8010650c <alltraps>

801072e2 <vector186>:
.globl vector186
vector186:
  pushl $0
801072e2:	6a 00                	push   $0x0
  pushl $186
801072e4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801072e9:	e9 1e f2 ff ff       	jmp    8010650c <alltraps>

801072ee <vector187>:
.globl vector187
vector187:
  pushl $0
801072ee:	6a 00                	push   $0x0
  pushl $187
801072f0:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801072f5:	e9 12 f2 ff ff       	jmp    8010650c <alltraps>

801072fa <vector188>:
.globl vector188
vector188:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $188
801072fc:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107301:	e9 06 f2 ff ff       	jmp    8010650c <alltraps>

80107306 <vector189>:
.globl vector189
vector189:
  pushl $0
80107306:	6a 00                	push   $0x0
  pushl $189
80107308:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010730d:	e9 fa f1 ff ff       	jmp    8010650c <alltraps>

80107312 <vector190>:
.globl vector190
vector190:
  pushl $0
80107312:	6a 00                	push   $0x0
  pushl $190
80107314:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107319:	e9 ee f1 ff ff       	jmp    8010650c <alltraps>

8010731e <vector191>:
.globl vector191
vector191:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $191
80107320:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107325:	e9 e2 f1 ff ff       	jmp    8010650c <alltraps>

8010732a <vector192>:
.globl vector192
vector192:
  pushl $0
8010732a:	6a 00                	push   $0x0
  pushl $192
8010732c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107331:	e9 d6 f1 ff ff       	jmp    8010650c <alltraps>

80107336 <vector193>:
.globl vector193
vector193:
  pushl $0
80107336:	6a 00                	push   $0x0
  pushl $193
80107338:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010733d:	e9 ca f1 ff ff       	jmp    8010650c <alltraps>

80107342 <vector194>:
.globl vector194
vector194:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $194
80107344:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107349:	e9 be f1 ff ff       	jmp    8010650c <alltraps>

8010734e <vector195>:
.globl vector195
vector195:
  pushl $0
8010734e:	6a 00                	push   $0x0
  pushl $195
80107350:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107355:	e9 b2 f1 ff ff       	jmp    8010650c <alltraps>

8010735a <vector196>:
.globl vector196
vector196:
  pushl $0
8010735a:	6a 00                	push   $0x0
  pushl $196
8010735c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107361:	e9 a6 f1 ff ff       	jmp    8010650c <alltraps>

80107366 <vector197>:
.globl vector197
vector197:
  pushl $0
80107366:	6a 00                	push   $0x0
  pushl $197
80107368:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010736d:	e9 9a f1 ff ff       	jmp    8010650c <alltraps>

80107372 <vector198>:
.globl vector198
vector198:
  pushl $0
80107372:	6a 00                	push   $0x0
  pushl $198
80107374:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107379:	e9 8e f1 ff ff       	jmp    8010650c <alltraps>

8010737e <vector199>:
.globl vector199
vector199:
  pushl $0
8010737e:	6a 00                	push   $0x0
  pushl $199
80107380:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107385:	e9 82 f1 ff ff       	jmp    8010650c <alltraps>

8010738a <vector200>:
.globl vector200
vector200:
  pushl $0
8010738a:	6a 00                	push   $0x0
  pushl $200
8010738c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107391:	e9 76 f1 ff ff       	jmp    8010650c <alltraps>

80107396 <vector201>:
.globl vector201
vector201:
  pushl $0
80107396:	6a 00                	push   $0x0
  pushl $201
80107398:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010739d:	e9 6a f1 ff ff       	jmp    8010650c <alltraps>

801073a2 <vector202>:
.globl vector202
vector202:
  pushl $0
801073a2:	6a 00                	push   $0x0
  pushl $202
801073a4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801073a9:	e9 5e f1 ff ff       	jmp    8010650c <alltraps>

801073ae <vector203>:
.globl vector203
vector203:
  pushl $0
801073ae:	6a 00                	push   $0x0
  pushl $203
801073b0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801073b5:	e9 52 f1 ff ff       	jmp    8010650c <alltraps>

801073ba <vector204>:
.globl vector204
vector204:
  pushl $0
801073ba:	6a 00                	push   $0x0
  pushl $204
801073bc:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801073c1:	e9 46 f1 ff ff       	jmp    8010650c <alltraps>

801073c6 <vector205>:
.globl vector205
vector205:
  pushl $0
801073c6:	6a 00                	push   $0x0
  pushl $205
801073c8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801073cd:	e9 3a f1 ff ff       	jmp    8010650c <alltraps>

801073d2 <vector206>:
.globl vector206
vector206:
  pushl $0
801073d2:	6a 00                	push   $0x0
  pushl $206
801073d4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801073d9:	e9 2e f1 ff ff       	jmp    8010650c <alltraps>

801073de <vector207>:
.globl vector207
vector207:
  pushl $0
801073de:	6a 00                	push   $0x0
  pushl $207
801073e0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801073e5:	e9 22 f1 ff ff       	jmp    8010650c <alltraps>

801073ea <vector208>:
.globl vector208
vector208:
  pushl $0
801073ea:	6a 00                	push   $0x0
  pushl $208
801073ec:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801073f1:	e9 16 f1 ff ff       	jmp    8010650c <alltraps>

801073f6 <vector209>:
.globl vector209
vector209:
  pushl $0
801073f6:	6a 00                	push   $0x0
  pushl $209
801073f8:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801073fd:	e9 0a f1 ff ff       	jmp    8010650c <alltraps>

80107402 <vector210>:
.globl vector210
vector210:
  pushl $0
80107402:	6a 00                	push   $0x0
  pushl $210
80107404:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107409:	e9 fe f0 ff ff       	jmp    8010650c <alltraps>

8010740e <vector211>:
.globl vector211
vector211:
  pushl $0
8010740e:	6a 00                	push   $0x0
  pushl $211
80107410:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107415:	e9 f2 f0 ff ff       	jmp    8010650c <alltraps>

8010741a <vector212>:
.globl vector212
vector212:
  pushl $0
8010741a:	6a 00                	push   $0x0
  pushl $212
8010741c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107421:	e9 e6 f0 ff ff       	jmp    8010650c <alltraps>

80107426 <vector213>:
.globl vector213
vector213:
  pushl $0
80107426:	6a 00                	push   $0x0
  pushl $213
80107428:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010742d:	e9 da f0 ff ff       	jmp    8010650c <alltraps>

80107432 <vector214>:
.globl vector214
vector214:
  pushl $0
80107432:	6a 00                	push   $0x0
  pushl $214
80107434:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107439:	e9 ce f0 ff ff       	jmp    8010650c <alltraps>

8010743e <vector215>:
.globl vector215
vector215:
  pushl $0
8010743e:	6a 00                	push   $0x0
  pushl $215
80107440:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107445:	e9 c2 f0 ff ff       	jmp    8010650c <alltraps>

8010744a <vector216>:
.globl vector216
vector216:
  pushl $0
8010744a:	6a 00                	push   $0x0
  pushl $216
8010744c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107451:	e9 b6 f0 ff ff       	jmp    8010650c <alltraps>

80107456 <vector217>:
.globl vector217
vector217:
  pushl $0
80107456:	6a 00                	push   $0x0
  pushl $217
80107458:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010745d:	e9 aa f0 ff ff       	jmp    8010650c <alltraps>

80107462 <vector218>:
.globl vector218
vector218:
  pushl $0
80107462:	6a 00                	push   $0x0
  pushl $218
80107464:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107469:	e9 9e f0 ff ff       	jmp    8010650c <alltraps>

8010746e <vector219>:
.globl vector219
vector219:
  pushl $0
8010746e:	6a 00                	push   $0x0
  pushl $219
80107470:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107475:	e9 92 f0 ff ff       	jmp    8010650c <alltraps>

8010747a <vector220>:
.globl vector220
vector220:
  pushl $0
8010747a:	6a 00                	push   $0x0
  pushl $220
8010747c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107481:	e9 86 f0 ff ff       	jmp    8010650c <alltraps>

80107486 <vector221>:
.globl vector221
vector221:
  pushl $0
80107486:	6a 00                	push   $0x0
  pushl $221
80107488:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010748d:	e9 7a f0 ff ff       	jmp    8010650c <alltraps>

80107492 <vector222>:
.globl vector222
vector222:
  pushl $0
80107492:	6a 00                	push   $0x0
  pushl $222
80107494:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107499:	e9 6e f0 ff ff       	jmp    8010650c <alltraps>

8010749e <vector223>:
.globl vector223
vector223:
  pushl $0
8010749e:	6a 00                	push   $0x0
  pushl $223
801074a0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801074a5:	e9 62 f0 ff ff       	jmp    8010650c <alltraps>

801074aa <vector224>:
.globl vector224
vector224:
  pushl $0
801074aa:	6a 00                	push   $0x0
  pushl $224
801074ac:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801074b1:	e9 56 f0 ff ff       	jmp    8010650c <alltraps>

801074b6 <vector225>:
.globl vector225
vector225:
  pushl $0
801074b6:	6a 00                	push   $0x0
  pushl $225
801074b8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801074bd:	e9 4a f0 ff ff       	jmp    8010650c <alltraps>

801074c2 <vector226>:
.globl vector226
vector226:
  pushl $0
801074c2:	6a 00                	push   $0x0
  pushl $226
801074c4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801074c9:	e9 3e f0 ff ff       	jmp    8010650c <alltraps>

801074ce <vector227>:
.globl vector227
vector227:
  pushl $0
801074ce:	6a 00                	push   $0x0
  pushl $227
801074d0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801074d5:	e9 32 f0 ff ff       	jmp    8010650c <alltraps>

801074da <vector228>:
.globl vector228
vector228:
  pushl $0
801074da:	6a 00                	push   $0x0
  pushl $228
801074dc:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801074e1:	e9 26 f0 ff ff       	jmp    8010650c <alltraps>

801074e6 <vector229>:
.globl vector229
vector229:
  pushl $0
801074e6:	6a 00                	push   $0x0
  pushl $229
801074e8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801074ed:	e9 1a f0 ff ff       	jmp    8010650c <alltraps>

801074f2 <vector230>:
.globl vector230
vector230:
  pushl $0
801074f2:	6a 00                	push   $0x0
  pushl $230
801074f4:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801074f9:	e9 0e f0 ff ff       	jmp    8010650c <alltraps>

801074fe <vector231>:
.globl vector231
vector231:
  pushl $0
801074fe:	6a 00                	push   $0x0
  pushl $231
80107500:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107505:	e9 02 f0 ff ff       	jmp    8010650c <alltraps>

8010750a <vector232>:
.globl vector232
vector232:
  pushl $0
8010750a:	6a 00                	push   $0x0
  pushl $232
8010750c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107511:	e9 f6 ef ff ff       	jmp    8010650c <alltraps>

80107516 <vector233>:
.globl vector233
vector233:
  pushl $0
80107516:	6a 00                	push   $0x0
  pushl $233
80107518:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010751d:	e9 ea ef ff ff       	jmp    8010650c <alltraps>

80107522 <vector234>:
.globl vector234
vector234:
  pushl $0
80107522:	6a 00                	push   $0x0
  pushl $234
80107524:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107529:	e9 de ef ff ff       	jmp    8010650c <alltraps>

8010752e <vector235>:
.globl vector235
vector235:
  pushl $0
8010752e:	6a 00                	push   $0x0
  pushl $235
80107530:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107535:	e9 d2 ef ff ff       	jmp    8010650c <alltraps>

8010753a <vector236>:
.globl vector236
vector236:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $236
8010753c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107541:	e9 c6 ef ff ff       	jmp    8010650c <alltraps>

80107546 <vector237>:
.globl vector237
vector237:
  pushl $0
80107546:	6a 00                	push   $0x0
  pushl $237
80107548:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010754d:	e9 ba ef ff ff       	jmp    8010650c <alltraps>

80107552 <vector238>:
.globl vector238
vector238:
  pushl $0
80107552:	6a 00                	push   $0x0
  pushl $238
80107554:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107559:	e9 ae ef ff ff       	jmp    8010650c <alltraps>

8010755e <vector239>:
.globl vector239
vector239:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $239
80107560:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107565:	e9 a2 ef ff ff       	jmp    8010650c <alltraps>

8010756a <vector240>:
.globl vector240
vector240:
  pushl $0
8010756a:	6a 00                	push   $0x0
  pushl $240
8010756c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107571:	e9 96 ef ff ff       	jmp    8010650c <alltraps>

80107576 <vector241>:
.globl vector241
vector241:
  pushl $0
80107576:	6a 00                	push   $0x0
  pushl $241
80107578:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010757d:	e9 8a ef ff ff       	jmp    8010650c <alltraps>

80107582 <vector242>:
.globl vector242
vector242:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $242
80107584:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107589:	e9 7e ef ff ff       	jmp    8010650c <alltraps>

8010758e <vector243>:
.globl vector243
vector243:
  pushl $0
8010758e:	6a 00                	push   $0x0
  pushl $243
80107590:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107595:	e9 72 ef ff ff       	jmp    8010650c <alltraps>

8010759a <vector244>:
.globl vector244
vector244:
  pushl $0
8010759a:	6a 00                	push   $0x0
  pushl $244
8010759c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801075a1:	e9 66 ef ff ff       	jmp    8010650c <alltraps>

801075a6 <vector245>:
.globl vector245
vector245:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $245
801075a8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801075ad:	e9 5a ef ff ff       	jmp    8010650c <alltraps>

801075b2 <vector246>:
.globl vector246
vector246:
  pushl $0
801075b2:	6a 00                	push   $0x0
  pushl $246
801075b4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801075b9:	e9 4e ef ff ff       	jmp    8010650c <alltraps>

801075be <vector247>:
.globl vector247
vector247:
  pushl $0
801075be:	6a 00                	push   $0x0
  pushl $247
801075c0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801075c5:	e9 42 ef ff ff       	jmp    8010650c <alltraps>

801075ca <vector248>:
.globl vector248
vector248:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $248
801075cc:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801075d1:	e9 36 ef ff ff       	jmp    8010650c <alltraps>

801075d6 <vector249>:
.globl vector249
vector249:
  pushl $0
801075d6:	6a 00                	push   $0x0
  pushl $249
801075d8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801075dd:	e9 2a ef ff ff       	jmp    8010650c <alltraps>

801075e2 <vector250>:
.globl vector250
vector250:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $250
801075e4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801075e9:	e9 1e ef ff ff       	jmp    8010650c <alltraps>

801075ee <vector251>:
.globl vector251
vector251:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $251
801075f0:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801075f5:	e9 12 ef ff ff       	jmp    8010650c <alltraps>

801075fa <vector252>:
.globl vector252
vector252:
  pushl $0
801075fa:	6a 00                	push   $0x0
  pushl $252
801075fc:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107601:	e9 06 ef ff ff       	jmp    8010650c <alltraps>

80107606 <vector253>:
.globl vector253
vector253:
  pushl $0
80107606:	6a 00                	push   $0x0
  pushl $253
80107608:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010760d:	e9 fa ee ff ff       	jmp    8010650c <alltraps>

80107612 <vector254>:
.globl vector254
vector254:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $254
80107614:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107619:	e9 ee ee ff ff       	jmp    8010650c <alltraps>

8010761e <vector255>:
.globl vector255
vector255:
  pushl $0
8010761e:	6a 00                	push   $0x0
  pushl $255
80107620:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107625:	e9 e2 ee ff ff       	jmp    8010650c <alltraps>
	...

8010762c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010762c:	55                   	push   %ebp
8010762d:	89 e5                	mov    %esp,%ebp
8010762f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107632:	8b 45 0c             	mov    0xc(%ebp),%eax
80107635:	83 e8 01             	sub    $0x1,%eax
80107638:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010763c:	8b 45 08             	mov    0x8(%ebp),%eax
8010763f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107643:	8b 45 08             	mov    0x8(%ebp),%eax
80107646:	c1 e8 10             	shr    $0x10,%eax
80107649:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010764d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107650:	0f 01 10             	lgdtl  (%eax)
}
80107653:	c9                   	leave  
80107654:	c3                   	ret    

80107655 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107655:	55                   	push   %ebp
80107656:	89 e5                	mov    %esp,%ebp
80107658:	83 ec 04             	sub    $0x4,%esp
8010765b:	8b 45 08             	mov    0x8(%ebp),%eax
8010765e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107662:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107666:	0f 00 d8             	ltr    %ax
}
80107669:	c9                   	leave  
8010766a:	c3                   	ret    

8010766b <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010766b:	55                   	push   %ebp
8010766c:	89 e5                	mov    %esp,%ebp
8010766e:	83 ec 04             	sub    $0x4,%esp
80107671:	8b 45 08             	mov    0x8(%ebp),%eax
80107674:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107678:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010767c:	8e e8                	mov    %eax,%gs
}
8010767e:	c9                   	leave  
8010767f:	c3                   	ret    

80107680 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107680:	55                   	push   %ebp
80107681:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107683:	8b 45 08             	mov    0x8(%ebp),%eax
80107686:	0f 22 d8             	mov    %eax,%cr3
}
80107689:	5d                   	pop    %ebp
8010768a:	c3                   	ret    

8010768b <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010768b:	55                   	push   %ebp
8010768c:	89 e5                	mov    %esp,%ebp
8010768e:	8b 45 08             	mov    0x8(%ebp),%eax
80107691:	05 00 00 00 80       	add    $0x80000000,%eax
80107696:	5d                   	pop    %ebp
80107697:	c3                   	ret    

80107698 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107698:	55                   	push   %ebp
80107699:	89 e5                	mov    %esp,%ebp
8010769b:	8b 45 08             	mov    0x8(%ebp),%eax
8010769e:	05 00 00 00 80       	add    $0x80000000,%eax
801076a3:	5d                   	pop    %ebp
801076a4:	c3                   	ret    

801076a5 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801076a5:	55                   	push   %ebp
801076a6:	89 e5                	mov    %esp,%ebp
801076a8:	53                   	push   %ebx
801076a9:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801076ac:	e8 12 b8 ff ff       	call   80102ec3 <cpunum>
801076b1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801076b7:	05 60 23 11 80       	add    $0x80112360,%eax
801076bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801076bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801076c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076cb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801076d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801076d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076db:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076df:	83 e2 f0             	and    $0xfffffff0,%edx
801076e2:	83 ca 0a             	or     $0xa,%edx
801076e5:	88 50 7d             	mov    %dl,0x7d(%eax)
801076e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076eb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076ef:	83 ca 10             	or     $0x10,%edx
801076f2:	88 50 7d             	mov    %dl,0x7d(%eax)
801076f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801076fc:	83 e2 9f             	and    $0xffffff9f,%edx
801076ff:	88 50 7d             	mov    %dl,0x7d(%eax)
80107702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107705:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107709:	83 ca 80             	or     $0xffffff80,%edx
8010770c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010770f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107712:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107716:	83 ca 0f             	or     $0xf,%edx
80107719:	88 50 7e             	mov    %dl,0x7e(%eax)
8010771c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010771f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107723:	83 e2 ef             	and    $0xffffffef,%edx
80107726:	88 50 7e             	mov    %dl,0x7e(%eax)
80107729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107730:	83 e2 df             	and    $0xffffffdf,%edx
80107733:	88 50 7e             	mov    %dl,0x7e(%eax)
80107736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107739:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010773d:	83 ca 40             	or     $0x40,%edx
80107740:	88 50 7e             	mov    %dl,0x7e(%eax)
80107743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107746:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010774a:	83 ca 80             	or     $0xffffff80,%edx
8010774d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107750:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107753:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107761:	ff ff 
80107763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107766:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010776d:	00 00 
8010776f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107772:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107783:	83 e2 f0             	and    $0xfffffff0,%edx
80107786:	83 ca 02             	or     $0x2,%edx
80107789:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010778f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107792:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107799:	83 ca 10             	or     $0x10,%edx
8010779c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801077a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801077ac:	83 e2 9f             	and    $0xffffff9f,%edx
801077af:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801077b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801077bf:	83 ca 80             	or     $0xffffff80,%edx
801077c2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801077c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077cb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077d2:	83 ca 0f             	or     $0xf,%edx
801077d5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077de:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077e5:	83 e2 ef             	and    $0xffffffef,%edx
801077e8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801077ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801077f8:	83 e2 df             	and    $0xffffffdf,%edx
801077fb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107804:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010780b:	83 ca 40             	or     $0x40,%edx
8010780e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107817:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010781e:	83 ca 80             	or     $0xffffff80,%edx
80107821:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107834:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010783b:	ff ff 
8010783d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107840:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107847:	00 00 
80107849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010784c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107853:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107856:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010785d:	83 e2 f0             	and    $0xfffffff0,%edx
80107860:	83 ca 0a             	or     $0xa,%edx
80107863:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107869:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010786c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107873:	83 ca 10             	or     $0x10,%edx
80107876:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010787c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107886:	83 ca 60             	or     $0x60,%edx
80107889:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010788f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107892:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107899:	83 ca 80             	or     $0xffffff80,%edx
8010789c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801078a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078ac:	83 ca 0f             	or     $0xf,%edx
801078af:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078bf:	83 e2 ef             	and    $0xffffffef,%edx
801078c2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078d2:	83 e2 df             	and    $0xffffffdf,%edx
801078d5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078de:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078e5:	83 ca 40             	or     $0x40,%edx
801078e8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801078ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801078f8:	83 ca 80             	or     $0xffffff80,%edx
801078fb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107904:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010790b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790e:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107915:	ff ff 
80107917:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791a:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107921:	00 00 
80107923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107926:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010792d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107930:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107937:	83 e2 f0             	and    $0xfffffff0,%edx
8010793a:	83 ca 02             	or     $0x2,%edx
8010793d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107943:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107946:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010794d:	83 ca 10             	or     $0x10,%edx
80107950:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107956:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107959:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107960:	83 ca 60             	or     $0x60,%edx
80107963:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107973:	83 ca 80             	or     $0xffffff80,%edx
80107976:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010797c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107986:	83 ca 0f             	or     $0xf,%edx
80107989:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010798f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107992:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107999:	83 e2 ef             	and    $0xffffffef,%edx
8010799c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801079a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a5:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801079ac:	83 e2 df             	and    $0xffffffdf,%edx
801079af:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801079b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b8:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801079bf:	83 ca 40             	or     $0x40,%edx
801079c2:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801079c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cb:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801079d2:	83 ca 80             	or     $0xffffff80,%edx
801079d5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801079db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079de:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801079e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e8:	05 b4 00 00 00       	add    $0xb4,%eax
801079ed:	89 c3                	mov    %eax,%ebx
801079ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f2:	05 b4 00 00 00       	add    $0xb4,%eax
801079f7:	c1 e8 10             	shr    $0x10,%eax
801079fa:	89 c1                	mov    %eax,%ecx
801079fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ff:	05 b4 00 00 00       	add    $0xb4,%eax
80107a04:	c1 e8 18             	shr    $0x18,%eax
80107a07:	89 c2                	mov    %eax,%edx
80107a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0c:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107a13:	00 00 
80107a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a18:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a22:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2b:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a32:	83 e1 f0             	and    $0xfffffff0,%ecx
80107a35:	83 c9 02             	or     $0x2,%ecx
80107a38:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a41:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a48:	83 c9 10             	or     $0x10,%ecx
80107a4b:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a54:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a5b:	83 e1 9f             	and    $0xffffff9f,%ecx
80107a5e:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a67:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107a6e:	83 c9 80             	or     $0xffffff80,%ecx
80107a71:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107a81:	83 e1 f0             	and    $0xfffffff0,%ecx
80107a84:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a8d:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107a94:	83 e1 ef             	and    $0xffffffef,%ecx
80107a97:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa0:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107aa7:	83 e1 df             	and    $0xffffffdf,%ecx
80107aaa:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab3:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107aba:	83 c9 40             	or     $0x40,%ecx
80107abd:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac6:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107acd:	83 c9 80             	or     $0xffffff80,%ecx
80107ad0:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad9:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae2:	83 c0 70             	add    $0x70,%eax
80107ae5:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107aec:	00 
80107aed:	89 04 24             	mov    %eax,(%esp)
80107af0:	e8 37 fb ff ff       	call   8010762c <lgdt>
  loadgs(SEG_KCPU << 3);
80107af5:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107afc:	e8 6a fb ff ff       	call   8010766b <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b04:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107b0a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107b11:	00 00 00 00 
}
80107b15:	83 c4 24             	add    $0x24,%esp
80107b18:	5b                   	pop    %ebx
80107b19:	5d                   	pop    %ebp
80107b1a:	c3                   	ret    

80107b1b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107b1b:	55                   	push   %ebp
80107b1c:	89 e5                	mov    %esp,%ebp
80107b1e:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107b21:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b24:	c1 e8 16             	shr    $0x16,%eax
80107b27:	c1 e0 02             	shl    $0x2,%eax
80107b2a:	03 45 08             	add    0x8(%ebp),%eax
80107b2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b33:	8b 00                	mov    (%eax),%eax
80107b35:	83 e0 01             	and    $0x1,%eax
80107b38:	84 c0                	test   %al,%al
80107b3a:	74 17                	je     80107b53 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b3f:	8b 00                	mov    (%eax),%eax
80107b41:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b46:	89 04 24             	mov    %eax,(%esp)
80107b49:	e8 4a fb ff ff       	call   80107698 <p2v>
80107b4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b51:	eb 4b                	jmp    80107b9e <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107b53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107b57:	74 0e                	je     80107b67 <walkpgdir+0x4c>
80107b59:	e8 ad af ff ff       	call   80102b0b <kalloc>
80107b5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107b61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107b65:	75 07                	jne    80107b6e <walkpgdir+0x53>
      return 0;
80107b67:	b8 00 00 00 00       	mov    $0x0,%eax
80107b6c:	eb 41                	jmp    80107baf <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107b6e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107b75:	00 
80107b76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107b7d:	00 
80107b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b81:	89 04 24             	mov    %eax,(%esp)
80107b84:	e8 49 d5 ff ff       	call   801050d2 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107b89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8c:	89 04 24             	mov    %eax,(%esp)
80107b8f:	e8 f7 fa ff ff       	call   8010768b <v2p>
80107b94:	89 c2                	mov    %eax,%edx
80107b96:	83 ca 07             	or     $0x7,%edx
80107b99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b9c:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ba1:	c1 e8 0c             	shr    $0xc,%eax
80107ba4:	25 ff 03 00 00       	and    $0x3ff,%eax
80107ba9:	c1 e0 02             	shl    $0x2,%eax
80107bac:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107baf:	c9                   	leave  
80107bb0:	c3                   	ret    

80107bb1 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107bb1:	55                   	push   %ebp
80107bb2:	89 e5                	mov    %esp,%ebp
80107bb4:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bc5:	03 45 10             	add    0x10(%ebp),%eax
80107bc8:	83 e8 01             	sub    $0x1,%eax
80107bcb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107bd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107bd3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107bda:	00 
80107bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bde:	89 44 24 04          	mov    %eax,0x4(%esp)
80107be2:	8b 45 08             	mov    0x8(%ebp),%eax
80107be5:	89 04 24             	mov    %eax,(%esp)
80107be8:	e8 2e ff ff ff       	call   80107b1b <walkpgdir>
80107bed:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107bf0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107bf4:	75 07                	jne    80107bfd <mappages+0x4c>
      return -1;
80107bf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bfb:	eb 46                	jmp    80107c43 <mappages+0x92>
    if(*pte & PTE_P)
80107bfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c00:	8b 00                	mov    (%eax),%eax
80107c02:	83 e0 01             	and    $0x1,%eax
80107c05:	84 c0                	test   %al,%al
80107c07:	74 0c                	je     80107c15 <mappages+0x64>
      panic("remap");
80107c09:	c7 04 24 3c 8a 10 80 	movl   $0x80108a3c,(%esp)
80107c10:	e8 28 89 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107c15:	8b 45 18             	mov    0x18(%ebp),%eax
80107c18:	0b 45 14             	or     0x14(%ebp),%eax
80107c1b:	89 c2                	mov    %eax,%edx
80107c1d:	83 ca 01             	or     $0x1,%edx
80107c20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c23:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c28:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107c2b:	74 10                	je     80107c3d <mappages+0x8c>
      break;
    a += PGSIZE;
80107c2d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107c34:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107c3b:	eb 96                	jmp    80107bd3 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107c3d:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107c3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c43:	c9                   	leave  
80107c44:	c3                   	ret    

80107c45 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107c45:	55                   	push   %ebp
80107c46:	89 e5                	mov    %esp,%ebp
80107c48:	53                   	push   %ebx
80107c49:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107c4c:	e8 ba ae ff ff       	call   80102b0b <kalloc>
80107c51:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107c54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107c58:	75 0a                	jne    80107c64 <setupkvm+0x1f>
    return 0;
80107c5a:	b8 00 00 00 00       	mov    $0x0,%eax
80107c5f:	e9 98 00 00 00       	jmp    80107cfc <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107c64:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107c6b:	00 
80107c6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c73:	00 
80107c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c77:	89 04 24             	mov    %eax,(%esp)
80107c7a:	e8 53 d4 ff ff       	call   801050d2 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107c7f:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107c86:	e8 0d fa ff ff       	call   80107698 <p2v>
80107c8b:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107c90:	76 0c                	jbe    80107c9e <setupkvm+0x59>
    panic("PHYSTOP too high");
80107c92:	c7 04 24 42 8a 10 80 	movl   $0x80108a42,(%esp)
80107c99:	e8 9f 88 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107c9e:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107ca5:	eb 49                	jmp    80107cf0 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80107ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107caa:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107cb0:	8b 50 04             	mov    0x4(%eax),%edx
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	8b 58 08             	mov    0x8(%eax),%ebx
80107cb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbc:	8b 40 04             	mov    0x4(%eax),%eax
80107cbf:	29 c3                	sub    %eax,%ebx
80107cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc4:	8b 00                	mov    (%eax),%eax
80107cc6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107cca:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107cce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80107cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cd9:	89 04 24             	mov    %eax,(%esp)
80107cdc:	e8 d0 fe ff ff       	call   80107bb1 <mappages>
80107ce1:	85 c0                	test   %eax,%eax
80107ce3:	79 07                	jns    80107cec <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107ce5:	b8 00 00 00 00       	mov    $0x0,%eax
80107cea:	eb 10                	jmp    80107cfc <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107cec:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107cf0:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107cf7:	72 ae                	jb     80107ca7 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107cfc:	83 c4 34             	add    $0x34,%esp
80107cff:	5b                   	pop    %ebx
80107d00:	5d                   	pop    %ebp
80107d01:	c3                   	ret    

80107d02 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107d02:	55                   	push   %ebp
80107d03:	89 e5                	mov    %esp,%ebp
80107d05:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107d08:	e8 38 ff ff ff       	call   80107c45 <setupkvm>
80107d0d:	a3 38 52 11 80       	mov    %eax,0x80115238
  switchkvm();
80107d12:	e8 02 00 00 00       	call   80107d19 <switchkvm>
}
80107d17:	c9                   	leave  
80107d18:	c3                   	ret    

80107d19 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107d19:	55                   	push   %ebp
80107d1a:	89 e5                	mov    %esp,%ebp
80107d1c:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107d1f:	a1 38 52 11 80       	mov    0x80115238,%eax
80107d24:	89 04 24             	mov    %eax,(%esp)
80107d27:	e8 5f f9 ff ff       	call   8010768b <v2p>
80107d2c:	89 04 24             	mov    %eax,(%esp)
80107d2f:	e8 4c f9 ff ff       	call   80107680 <lcr3>
}
80107d34:	c9                   	leave  
80107d35:	c3                   	ret    

80107d36 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107d36:	55                   	push   %ebp
80107d37:	89 e5                	mov    %esp,%ebp
80107d39:	53                   	push   %ebx
80107d3a:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107d3d:	e8 89 d2 ff ff       	call   80104fcb <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107d42:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107d48:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107d4f:	83 c2 08             	add    $0x8,%edx
80107d52:	89 d3                	mov    %edx,%ebx
80107d54:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107d5b:	83 c2 08             	add    $0x8,%edx
80107d5e:	c1 ea 10             	shr    $0x10,%edx
80107d61:	89 d1                	mov    %edx,%ecx
80107d63:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107d6a:	83 c2 08             	add    $0x8,%edx
80107d6d:	c1 ea 18             	shr    $0x18,%edx
80107d70:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107d77:	67 00 
80107d79:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107d80:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107d86:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107d8d:	83 e1 f0             	and    $0xfffffff0,%ecx
80107d90:	83 c9 09             	or     $0x9,%ecx
80107d93:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107d99:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107da0:	83 c9 10             	or     $0x10,%ecx
80107da3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107da9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107db0:	83 e1 9f             	and    $0xffffff9f,%ecx
80107db3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107db9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107dc0:	83 c9 80             	or     $0xffffff80,%ecx
80107dc3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107dc9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107dd0:	83 e1 f0             	and    $0xfffffff0,%ecx
80107dd3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107dd9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107de0:	83 e1 ef             	and    $0xffffffef,%ecx
80107de3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107de9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107df0:	83 e1 df             	and    $0xffffffdf,%ecx
80107df3:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107df9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107e00:	83 c9 40             	or     $0x40,%ecx
80107e03:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107e09:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107e10:	83 e1 7f             	and    $0x7f,%ecx
80107e13:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107e19:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107e1f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e25:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e2c:	83 e2 ef             	and    $0xffffffef,%edx
80107e2f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107e35:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e3b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107e41:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e47:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107e4e:	8b 52 08             	mov    0x8(%edx),%edx
80107e51:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107e57:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107e5a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107e61:	e8 ef f7 ff ff       	call   80107655 <ltr>
  if(p->pgdir == 0)
80107e66:	8b 45 08             	mov    0x8(%ebp),%eax
80107e69:	8b 40 04             	mov    0x4(%eax),%eax
80107e6c:	85 c0                	test   %eax,%eax
80107e6e:	75 0c                	jne    80107e7c <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80107e70:	c7 04 24 53 8a 10 80 	movl   $0x80108a53,(%esp)
80107e77:	e8 c1 86 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80107e7f:	8b 40 04             	mov    0x4(%eax),%eax
80107e82:	89 04 24             	mov    %eax,(%esp)
80107e85:	e8 01 f8 ff ff       	call   8010768b <v2p>
80107e8a:	89 04 24             	mov    %eax,(%esp)
80107e8d:	e8 ee f7 ff ff       	call   80107680 <lcr3>
  popcli();
80107e92:	e8 7c d1 ff ff       	call   80105013 <popcli>
}
80107e97:	83 c4 14             	add    $0x14,%esp
80107e9a:	5b                   	pop    %ebx
80107e9b:	5d                   	pop    %ebp
80107e9c:	c3                   	ret    

80107e9d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107e9d:	55                   	push   %ebp
80107e9e:	89 e5                	mov    %esp,%ebp
80107ea0:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107ea3:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107eaa:	76 0c                	jbe    80107eb8 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107eac:	c7 04 24 67 8a 10 80 	movl   $0x80108a67,(%esp)
80107eb3:	e8 85 86 ff ff       	call   8010053d <panic>
  mem = kalloc();
80107eb8:	e8 4e ac ff ff       	call   80102b0b <kalloc>
80107ebd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107ec0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ec7:	00 
80107ec8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ecf:	00 
80107ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed3:	89 04 24             	mov    %eax,(%esp)
80107ed6:	e8 f7 d1 ff ff       	call   801050d2 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ede:	89 04 24             	mov    %eax,(%esp)
80107ee1:	e8 a5 f7 ff ff       	call   8010768b <v2p>
80107ee6:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107eed:	00 
80107eee:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107ef2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107ef9:	00 
80107efa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f01:	00 
80107f02:	8b 45 08             	mov    0x8(%ebp),%eax
80107f05:	89 04 24             	mov    %eax,(%esp)
80107f08:	e8 a4 fc ff ff       	call   80107bb1 <mappages>
  memmove(mem, init, sz);
80107f0d:	8b 45 10             	mov    0x10(%ebp),%eax
80107f10:	89 44 24 08          	mov    %eax,0x8(%esp)
80107f14:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f17:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1e:	89 04 24             	mov    %eax,(%esp)
80107f21:	e8 7f d2 ff ff       	call   801051a5 <memmove>
}
80107f26:	c9                   	leave  
80107f27:	c3                   	ret    

80107f28 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107f28:	55                   	push   %ebp
80107f29:	89 e5                	mov    %esp,%ebp
80107f2b:	53                   	push   %ebx
80107f2c:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f32:	25 ff 0f 00 00       	and    $0xfff,%eax
80107f37:	85 c0                	test   %eax,%eax
80107f39:	74 0c                	je     80107f47 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107f3b:	c7 04 24 84 8a 10 80 	movl   $0x80108a84,(%esp)
80107f42:	e8 f6 85 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107f47:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107f4e:	e9 ad 00 00 00       	jmp    80108000 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f56:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f59:	01 d0                	add    %edx,%eax
80107f5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f62:	00 
80107f63:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f67:	8b 45 08             	mov    0x8(%ebp),%eax
80107f6a:	89 04 24             	mov    %eax,(%esp)
80107f6d:	e8 a9 fb ff ff       	call   80107b1b <walkpgdir>
80107f72:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f75:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f79:	75 0c                	jne    80107f87 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80107f7b:	c7 04 24 a7 8a 10 80 	movl   $0x80108aa7,(%esp)
80107f82:	e8 b6 85 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80107f87:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f8a:	8b 00                	mov    (%eax),%eax
80107f8c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f91:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f97:	8b 55 18             	mov    0x18(%ebp),%edx
80107f9a:	89 d1                	mov    %edx,%ecx
80107f9c:	29 c1                	sub    %eax,%ecx
80107f9e:	89 c8                	mov    %ecx,%eax
80107fa0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107fa5:	77 11                	ja     80107fb8 <loaduvm+0x90>
      n = sz - i;
80107fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107faa:	8b 55 18             	mov    0x18(%ebp),%edx
80107fad:	89 d1                	mov    %edx,%ecx
80107faf:	29 c1                	sub    %eax,%ecx
80107fb1:	89 c8                	mov    %ecx,%eax
80107fb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fb6:	eb 07                	jmp    80107fbf <loaduvm+0x97>
    else
      n = PGSIZE;
80107fb8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc2:	8b 55 14             	mov    0x14(%ebp),%edx
80107fc5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107fc8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107fcb:	89 04 24             	mov    %eax,(%esp)
80107fce:	e8 c5 f6 ff ff       	call   80107698 <p2v>
80107fd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107fd6:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107fda:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107fde:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fe2:	8b 45 10             	mov    0x10(%ebp),%eax
80107fe5:	89 04 24             	mov    %eax,(%esp)
80107fe8:	e8 7d 9d ff ff       	call   80101d6a <readi>
80107fed:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107ff0:	74 07                	je     80107ff9 <loaduvm+0xd1>
      return -1;
80107ff2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107ff7:	eb 18                	jmp    80108011 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107ff9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108000:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108003:	3b 45 18             	cmp    0x18(%ebp),%eax
80108006:	0f 82 47 ff ff ff    	jb     80107f53 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010800c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108011:	83 c4 24             	add    $0x24,%esp
80108014:	5b                   	pop    %ebx
80108015:	5d                   	pop    %ebp
80108016:	c3                   	ret    

80108017 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108017:	55                   	push   %ebp
80108018:	89 e5                	mov    %esp,%ebp
8010801a:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010801d:	8b 45 10             	mov    0x10(%ebp),%eax
80108020:	85 c0                	test   %eax,%eax
80108022:	79 0a                	jns    8010802e <allocuvm+0x17>
    return 0;
80108024:	b8 00 00 00 00       	mov    $0x0,%eax
80108029:	e9 c1 00 00 00       	jmp    801080ef <allocuvm+0xd8>
  if(newsz < oldsz)
8010802e:	8b 45 10             	mov    0x10(%ebp),%eax
80108031:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108034:	73 08                	jae    8010803e <allocuvm+0x27>
    return oldsz;
80108036:	8b 45 0c             	mov    0xc(%ebp),%eax
80108039:	e9 b1 00 00 00       	jmp    801080ef <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010803e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108041:	05 ff 0f 00 00       	add    $0xfff,%eax
80108046:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010804b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010804e:	e9 8d 00 00 00       	jmp    801080e0 <allocuvm+0xc9>
    mem = kalloc();
80108053:	e8 b3 aa ff ff       	call   80102b0b <kalloc>
80108058:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010805b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010805f:	75 2c                	jne    8010808d <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108061:	c7 04 24 c5 8a 10 80 	movl   $0x80108ac5,(%esp)
80108068:	e8 34 83 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010806d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108070:	89 44 24 08          	mov    %eax,0x8(%esp)
80108074:	8b 45 10             	mov    0x10(%ebp),%eax
80108077:	89 44 24 04          	mov    %eax,0x4(%esp)
8010807b:	8b 45 08             	mov    0x8(%ebp),%eax
8010807e:	89 04 24             	mov    %eax,(%esp)
80108081:	e8 6b 00 00 00       	call   801080f1 <deallocuvm>
      return 0;
80108086:	b8 00 00 00 00       	mov    $0x0,%eax
8010808b:	eb 62                	jmp    801080ef <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010808d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108094:	00 
80108095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010809c:	00 
8010809d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080a0:	89 04 24             	mov    %eax,(%esp)
801080a3:	e8 2a d0 ff ff       	call   801050d2 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801080a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080ab:	89 04 24             	mov    %eax,(%esp)
801080ae:	e8 d8 f5 ff ff       	call   8010768b <v2p>
801080b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080b6:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801080bd:	00 
801080be:	89 44 24 0c          	mov    %eax,0xc(%esp)
801080c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080c9:	00 
801080ca:	89 54 24 04          	mov    %edx,0x4(%esp)
801080ce:	8b 45 08             	mov    0x8(%ebp),%eax
801080d1:	89 04 24             	mov    %eax,(%esp)
801080d4:	e8 d8 fa ff ff       	call   80107bb1 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801080d9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e3:	3b 45 10             	cmp    0x10(%ebp),%eax
801080e6:	0f 82 67 ff ff ff    	jb     80108053 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801080ec:	8b 45 10             	mov    0x10(%ebp),%eax
}
801080ef:	c9                   	leave  
801080f0:	c3                   	ret    

801080f1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801080f1:	55                   	push   %ebp
801080f2:	89 e5                	mov    %esp,%ebp
801080f4:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801080f7:	8b 45 10             	mov    0x10(%ebp),%eax
801080fa:	3b 45 0c             	cmp    0xc(%ebp),%eax
801080fd:	72 08                	jb     80108107 <deallocuvm+0x16>
    return oldsz;
801080ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80108102:	e9 a4 00 00 00       	jmp    801081ab <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108107:	8b 45 10             	mov    0x10(%ebp),%eax
8010810a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010810f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108114:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108117:	e9 80 00 00 00       	jmp    8010819c <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010811c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108126:	00 
80108127:	89 44 24 04          	mov    %eax,0x4(%esp)
8010812b:	8b 45 08             	mov    0x8(%ebp),%eax
8010812e:	89 04 24             	mov    %eax,(%esp)
80108131:	e8 e5 f9 ff ff       	call   80107b1b <walkpgdir>
80108136:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108139:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010813d:	75 09                	jne    80108148 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010813f:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108146:	eb 4d                	jmp    80108195 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108148:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010814b:	8b 00                	mov    (%eax),%eax
8010814d:	83 e0 01             	and    $0x1,%eax
80108150:	84 c0                	test   %al,%al
80108152:	74 41                	je     80108195 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108157:	8b 00                	mov    (%eax),%eax
80108159:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010815e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108161:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108165:	75 0c                	jne    80108173 <deallocuvm+0x82>
        panic("kfree");
80108167:	c7 04 24 dd 8a 10 80 	movl   $0x80108add,(%esp)
8010816e:	e8 ca 83 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
80108173:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108176:	89 04 24             	mov    %eax,(%esp)
80108179:	e8 1a f5 ff ff       	call   80107698 <p2v>
8010817e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108181:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108184:	89 04 24             	mov    %eax,(%esp)
80108187:	e8 e6 a8 ff ff       	call   80102a72 <kfree>
      *pte = 0;
8010818c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010818f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108195:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010819c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010819f:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081a2:	0f 82 74 ff ff ff    	jb     8010811c <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801081a8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801081ab:	c9                   	leave  
801081ac:	c3                   	ret    

801081ad <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801081ad:	55                   	push   %ebp
801081ae:	89 e5                	mov    %esp,%ebp
801081b0:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801081b3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801081b7:	75 0c                	jne    801081c5 <freevm+0x18>
    panic("freevm: no pgdir");
801081b9:	c7 04 24 e3 8a 10 80 	movl   $0x80108ae3,(%esp)
801081c0:	e8 78 83 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801081c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081cc:	00 
801081cd:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801081d4:	80 
801081d5:	8b 45 08             	mov    0x8(%ebp),%eax
801081d8:	89 04 24             	mov    %eax,(%esp)
801081db:	e8 11 ff ff ff       	call   801080f1 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801081e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801081e7:	eb 3c                	jmp    80108225 <freevm+0x78>
    if(pgdir[i] & PTE_P){
801081e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ec:	c1 e0 02             	shl    $0x2,%eax
801081ef:	03 45 08             	add    0x8(%ebp),%eax
801081f2:	8b 00                	mov    (%eax),%eax
801081f4:	83 e0 01             	and    $0x1,%eax
801081f7:	84 c0                	test   %al,%al
801081f9:	74 26                	je     80108221 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801081fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081fe:	c1 e0 02             	shl    $0x2,%eax
80108201:	03 45 08             	add    0x8(%ebp),%eax
80108204:	8b 00                	mov    (%eax),%eax
80108206:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010820b:	89 04 24             	mov    %eax,(%esp)
8010820e:	e8 85 f4 ff ff       	call   80107698 <p2v>
80108213:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108216:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108219:	89 04 24             	mov    %eax,(%esp)
8010821c:	e8 51 a8 ff ff       	call   80102a72 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108221:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108225:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010822c:	76 bb                	jbe    801081e9 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010822e:	8b 45 08             	mov    0x8(%ebp),%eax
80108231:	89 04 24             	mov    %eax,(%esp)
80108234:	e8 39 a8 ff ff       	call   80102a72 <kfree>
}
80108239:	c9                   	leave  
8010823a:	c3                   	ret    

8010823b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010823b:	55                   	push   %ebp
8010823c:	89 e5                	mov    %esp,%ebp
8010823e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108241:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108248:	00 
80108249:	8b 45 0c             	mov    0xc(%ebp),%eax
8010824c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108250:	8b 45 08             	mov    0x8(%ebp),%eax
80108253:	89 04 24             	mov    %eax,(%esp)
80108256:	e8 c0 f8 ff ff       	call   80107b1b <walkpgdir>
8010825b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010825e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108262:	75 0c                	jne    80108270 <clearpteu+0x35>
    panic("clearpteu");
80108264:	c7 04 24 f4 8a 10 80 	movl   $0x80108af4,(%esp)
8010826b:	e8 cd 82 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
80108270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108273:	8b 00                	mov    (%eax),%eax
80108275:	89 c2                	mov    %eax,%edx
80108277:	83 e2 fb             	and    $0xfffffffb,%edx
8010827a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827d:	89 10                	mov    %edx,(%eax)
}
8010827f:	c9                   	leave  
80108280:	c3                   	ret    

80108281 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108281:	55                   	push   %ebp
80108282:	89 e5                	mov    %esp,%ebp
80108284:	53                   	push   %ebx
80108285:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108288:	e8 b8 f9 ff ff       	call   80107c45 <setupkvm>
8010828d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108290:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108294:	75 0a                	jne    801082a0 <copyuvm+0x1f>
    return 0;
80108296:	b8 00 00 00 00       	mov    $0x0,%eax
8010829b:	e9 fd 00 00 00       	jmp    8010839d <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801082a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082a7:	e9 cc 00 00 00       	jmp    80108378 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801082ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801082b6:	00 
801082b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801082bb:	8b 45 08             	mov    0x8(%ebp),%eax
801082be:	89 04 24             	mov    %eax,(%esp)
801082c1:	e8 55 f8 ff ff       	call   80107b1b <walkpgdir>
801082c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801082c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801082cd:	75 0c                	jne    801082db <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
801082cf:	c7 04 24 fe 8a 10 80 	movl   $0x80108afe,(%esp)
801082d6:	e8 62 82 ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
801082db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082de:	8b 00                	mov    (%eax),%eax
801082e0:	83 e0 01             	and    $0x1,%eax
801082e3:	85 c0                	test   %eax,%eax
801082e5:	75 0c                	jne    801082f3 <copyuvm+0x72>
      panic("copyuvm: page not present");
801082e7:	c7 04 24 18 8b 10 80 	movl   $0x80108b18,(%esp)
801082ee:	e8 4a 82 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801082f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f6:	8b 00                	mov    (%eax),%eax
801082f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108300:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108303:	8b 00                	mov    (%eax),%eax
80108305:	25 ff 0f 00 00       	and    $0xfff,%eax
8010830a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010830d:	e8 f9 a7 ff ff       	call   80102b0b <kalloc>
80108312:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108315:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108319:	74 6e                	je     80108389 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010831b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010831e:	89 04 24             	mov    %eax,(%esp)
80108321:	e8 72 f3 ff ff       	call   80107698 <p2v>
80108326:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010832d:	00 
8010832e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108332:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108335:	89 04 24             	mov    %eax,(%esp)
80108338:	e8 68 ce ff ff       	call   801051a5 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010833d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108340:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108343:	89 04 24             	mov    %eax,(%esp)
80108346:	e8 40 f3 ff ff       	call   8010768b <v2p>
8010834b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010834e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108352:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108356:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010835d:	00 
8010835e:	89 54 24 04          	mov    %edx,0x4(%esp)
80108362:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108365:	89 04 24             	mov    %eax,(%esp)
80108368:	e8 44 f8 ff ff       	call   80107bb1 <mappages>
8010836d:	85 c0                	test   %eax,%eax
8010836f:	78 1b                	js     8010838c <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108371:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010837e:	0f 82 28 ff ff ff    	jb     801082ac <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108384:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108387:	eb 14                	jmp    8010839d <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108389:	90                   	nop
8010838a:	eb 01                	jmp    8010838d <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
8010838c:	90                   	nop
  }
  return d;

bad:
  freevm(d);
8010838d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108390:	89 04 24             	mov    %eax,(%esp)
80108393:	e8 15 fe ff ff       	call   801081ad <freevm>
  return 0;
80108398:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010839d:	83 c4 44             	add    $0x44,%esp
801083a0:	5b                   	pop    %ebx
801083a1:	5d                   	pop    %ebp
801083a2:	c3                   	ret    

801083a3 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801083a3:	55                   	push   %ebp
801083a4:	89 e5                	mov    %esp,%ebp
801083a6:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801083a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083b0:	00 
801083b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801083b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801083b8:	8b 45 08             	mov    0x8(%ebp),%eax
801083bb:	89 04 24             	mov    %eax,(%esp)
801083be:	e8 58 f7 ff ff       	call   80107b1b <walkpgdir>
801083c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801083c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c9:	8b 00                	mov    (%eax),%eax
801083cb:	83 e0 01             	and    $0x1,%eax
801083ce:	85 c0                	test   %eax,%eax
801083d0:	75 07                	jne    801083d9 <uva2ka+0x36>
    return 0;
801083d2:	b8 00 00 00 00       	mov    $0x0,%eax
801083d7:	eb 25                	jmp    801083fe <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801083d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083dc:	8b 00                	mov    (%eax),%eax
801083de:	83 e0 04             	and    $0x4,%eax
801083e1:	85 c0                	test   %eax,%eax
801083e3:	75 07                	jne    801083ec <uva2ka+0x49>
    return 0;
801083e5:	b8 00 00 00 00       	mov    $0x0,%eax
801083ea:	eb 12                	jmp    801083fe <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801083ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ef:	8b 00                	mov    (%eax),%eax
801083f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083f6:	89 04 24             	mov    %eax,(%esp)
801083f9:	e8 9a f2 ff ff       	call   80107698 <p2v>
}
801083fe:	c9                   	leave  
801083ff:	c3                   	ret    

80108400 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108400:	55                   	push   %ebp
80108401:	89 e5                	mov    %esp,%ebp
80108403:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108406:	8b 45 10             	mov    0x10(%ebp),%eax
80108409:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010840c:	e9 8b 00 00 00       	jmp    8010849c <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108411:	8b 45 0c             	mov    0xc(%ebp),%eax
80108414:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108419:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010841c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010841f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108423:	8b 45 08             	mov    0x8(%ebp),%eax
80108426:	89 04 24             	mov    %eax,(%esp)
80108429:	e8 75 ff ff ff       	call   801083a3 <uva2ka>
8010842e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108431:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108435:	75 07                	jne    8010843e <copyout+0x3e>
      return -1;
80108437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010843c:	eb 6d                	jmp    801084ab <copyout+0xab>
    n = PGSIZE - (va - va0);
8010843e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108441:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108444:	89 d1                	mov    %edx,%ecx
80108446:	29 c1                	sub    %eax,%ecx
80108448:	89 c8                	mov    %ecx,%eax
8010844a:	05 00 10 00 00       	add    $0x1000,%eax
8010844f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108452:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108455:	3b 45 14             	cmp    0x14(%ebp),%eax
80108458:	76 06                	jbe    80108460 <copyout+0x60>
      n = len;
8010845a:	8b 45 14             	mov    0x14(%ebp),%eax
8010845d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108460:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108463:	8b 55 0c             	mov    0xc(%ebp),%edx
80108466:	89 d1                	mov    %edx,%ecx
80108468:	29 c1                	sub    %eax,%ecx
8010846a:	89 c8                	mov    %ecx,%eax
8010846c:	03 45 e8             	add    -0x18(%ebp),%eax
8010846f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108472:	89 54 24 08          	mov    %edx,0x8(%esp)
80108476:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108479:	89 54 24 04          	mov    %edx,0x4(%esp)
8010847d:	89 04 24             	mov    %eax,(%esp)
80108480:	e8 20 cd ff ff       	call   801051a5 <memmove>
    len -= n;
80108485:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108488:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
8010848b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010848e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108491:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108494:	05 00 10 00 00       	add    $0x1000,%eax
80108499:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010849c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801084a0:	0f 85 6b ff ff ff    	jne    80108411 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801084a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801084ab:	c9                   	leave  
801084ac:	c3                   	ret    
