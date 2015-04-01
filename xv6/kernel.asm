
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
8010003a:	c7 44 24 04 e0 86 10 	movl   $0x801086e0,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 a4 4f 00 00       	call   80104ff2 <initlock>

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
801000bd:	e8 51 4f 00 00       	call   80105013 <acquire>

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
80100104:	e8 6c 4f 00 00       	call   80105075 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 12 4c 00 00       	call   80104d36 <sleep>
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
8010017c:	e8 f4 4e 00 00       	call   80105075 <release>
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
80100198:	c7 04 24 e7 86 10 80 	movl   $0x801086e7,(%esp)
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
801001ef:	c7 04 24 f8 86 10 80 	movl   $0x801086f8,(%esp)
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
80100229:	c7 04 24 ff 86 10 80 	movl   $0x801086ff,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 d2 4d 00 00       	call   80105013 <acquire>

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
8010029d:	e8 6d 4b 00 00       	call   80104e0f <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 c7 4d 00 00       	call   80105075 <release>
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
801003bc:	e8 52 4c 00 00       	call   80105013 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 06 87 10 80 	movl   $0x80108706,(%esp)
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
801004af:	c7 45 ec 0f 87 10 80 	movl   $0x8010870f,-0x14(%ebp)
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
80100536:	e8 3a 4b 00 00       	call   80105075 <release>
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
80100562:	c7 04 24 16 87 10 80 	movl   $0x80108716,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 25 87 10 80 	movl   $0x80108725,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 2d 4b 00 00       	call   801050c4 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 27 87 10 80 	movl   $0x80108727,(%esp)
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
801006b2:	e8 7e 4c 00 00       	call   80105335 <memmove>
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
801006e1:	e8 7c 4b 00 00       	call   80105262 <memset>
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
80100776:	e8 b6 65 00 00       	call   80106d31 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 aa 65 00 00       	call   80106d31 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 9e 65 00 00       	call   80106d31 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 91 65 00 00       	call   80106d31 <uartputc>
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
801007ba:	e8 54 48 00 00       	call   80105013 <acquire>
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
801007ea:	e8 c3 46 00 00       	call   80104eb2 <procdump>
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
801008f7:	e8 13 45 00 00       	call   80104e0f <wakeup>
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
8010091e:	e8 52 47 00 00       	call   80105075 <release>
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
80100943:	e8 cb 46 00 00       	call   80105013 <acquire>
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
80100961:	e8 0f 47 00 00       	call   80105075 <release>
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
8010098a:	e8 a7 43 00 00       	call   80104d36 <sleep>
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
80100a08:	e8 68 46 00 00       	call   80105075 <release>
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
80100a3e:	e8 d0 45 00 00       	call   80105013 <acquire>
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
80100a78:	e8 f8 45 00 00       	call   80105075 <release>
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
80100a93:	c7 44 24 04 2b 87 10 	movl   $0x8010872b,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100aa2:	e8 4b 45 00 00       	call   80104ff2 <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 33 87 10 	movl   $0x80108733,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100ab6:	e8 37 45 00 00       	call   80104ff2 <initlock>

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
80100b7e:	e8 f2 72 00 00       	call   80107e75 <setupkvm>
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
80100c17:	e8 2b 76 00 00       	call   80108247 <allocuvm>
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
80100c54:	e8 ff 74 00 00       	call   80108158 <loaduvm>
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
80100cc4:	e8 7e 75 00 00       	call   80108247 <allocuvm>
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
80100ce8:	e8 7e 77 00 00       	call   8010846b <clearpteu>
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
80100d17:	e8 c4 47 00 00       	call   801054e0 <strlen>
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
80100d35:	e8 a6 47 00 00       	call   801054e0 <strlen>
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
80100d5f:	e8 cc 78 00 00       	call   80108630 <copyout>
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
80100dff:	e8 2c 78 00 00       	call   80108630 <copyout>
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
80100e56:	e8 37 46 00 00       	call   80105492 <safestrcpy>

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
80100ea8:	e8 b9 70 00 00       	call   80107f66 <switchuvm>
  freevm(oldpgdir);
80100ead:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eb0:	89 04 24             	mov    %eax,(%esp)
80100eb3:	e8 25 75 00 00       	call   801083dd <freevm>
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
80100eea:	e8 ee 74 00 00       	call   801083dd <freevm>
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
80100f12:	c7 44 24 04 39 87 10 	movl   $0x80108739,0x4(%esp)
80100f19:	80 
80100f1a:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f21:	e8 cc 40 00 00       	call   80104ff2 <initlock>
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
80100f35:	e8 d9 40 00 00       	call   80105013 <acquire>
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
80100f5e:	e8 12 41 00 00       	call   80105075 <release>
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
80100f7c:	e8 f4 40 00 00       	call   80105075 <release>
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
80100f95:	e8 79 40 00 00       	call   80105013 <acquire>
  if(f->ref < 1)
80100f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9d:	8b 40 04             	mov    0x4(%eax),%eax
80100fa0:	85 c0                	test   %eax,%eax
80100fa2:	7f 0c                	jg     80100fb0 <filedup+0x28>
    panic("filedup");
80100fa4:	c7 04 24 40 87 10 80 	movl   $0x80108740,(%esp)
80100fab:	e8 8d f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb3:	8b 40 04             	mov    0x4(%eax),%eax
80100fb6:	8d 50 01             	lea    0x1(%eax),%edx
80100fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fbc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbf:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fc6:	e8 aa 40 00 00       	call   80105075 <release>
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
80100fdd:	e8 31 40 00 00       	call   80105013 <acquire>
  if(f->ref < 1)
80100fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe5:	8b 40 04             	mov    0x4(%eax),%eax
80100fe8:	85 c0                	test   %eax,%eax
80100fea:	7f 0c                	jg     80100ff8 <fileclose+0x28>
    panic("fileclose");
80100fec:	c7 04 24 48 87 10 80 	movl   $0x80108748,(%esp)
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
80101018:	e8 58 40 00 00       	call   80105075 <release>
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
80101062:	e8 0e 40 00 00       	call   80105075 <release>
  
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
801011a3:	c7 04 24 52 87 10 80 	movl   $0x80108752,(%esp)
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
801012af:	c7 04 24 5b 87 10 80 	movl   $0x8010875b,(%esp)
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
801012e4:	c7 04 24 6b 87 10 80 	movl   $0x8010876b,(%esp)
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
8010132c:	e8 04 40 00 00       	call   80105335 <memmove>
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
80101372:	e8 eb 3e 00 00       	call   80105262 <memset>
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
801014da:	c7 04 24 75 87 10 80 	movl   $0x80108775,(%esp)
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
80101571:	c7 04 24 8b 87 10 80 	movl   $0x8010878b,(%esp)
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
801015c5:	c7 44 24 04 9e 87 10 	movl   $0x8010879e,0x4(%esp)
801015cc:	80 
801015cd:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801015d4:	e8 19 3a 00 00       	call   80104ff2 <initlock>
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
80101656:	e8 07 3c 00 00       	call   80105262 <memset>
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
801016ac:	c7 04 24 a5 87 10 80 	movl   $0x801087a5,(%esp)
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
80101753:	e8 dd 3b 00 00       	call   80105335 <memmove>
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
8010177d:	e8 91 38 00 00       	call   80105013 <acquire>

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
801017c7:	e8 a9 38 00 00       	call   80105075 <release>
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
801017fa:	c7 04 24 b7 87 10 80 	movl   $0x801087b7,(%esp)
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
80101838:	e8 38 38 00 00       	call   80105075 <release>

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
8010184f:	e8 bf 37 00 00       	call   80105013 <acquire>
  ip->ref++;
80101854:	8b 45 08             	mov    0x8(%ebp),%eax
80101857:	8b 40 08             	mov    0x8(%eax),%eax
8010185a:	8d 50 01             	lea    0x1(%eax),%edx
8010185d:	8b 45 08             	mov    0x8(%ebp),%eax
80101860:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101863:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010186a:	e8 06 38 00 00       	call   80105075 <release>
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
8010188a:	c7 04 24 c7 87 10 80 	movl   $0x801087c7,(%esp)
80101891:	e8 a7 ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101896:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
8010189d:	e8 71 37 00 00       	call   80105013 <acquire>
  while(ip->flags & I_BUSY)
801018a2:	eb 13                	jmp    801018b7 <ilock+0x43>
    sleep(ip, &icache.lock);
801018a4:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801018ab:	80 
801018ac:	8b 45 08             	mov    0x8(%ebp),%eax
801018af:	89 04 24             	mov    %eax,(%esp)
801018b2:	e8 7f 34 00 00       	call   80104d36 <sleep>

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
801018dc:	e8 94 37 00 00       	call   80105075 <release>

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
80101987:	e8 a9 39 00 00       	call   80105335 <memmove>
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
801019b4:	c7 04 24 cd 87 10 80 	movl   $0x801087cd,(%esp)
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
801019e5:	c7 04 24 dc 87 10 80 	movl   $0x801087dc,(%esp)
801019ec:	e8 4c eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801019f1:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801019f8:	e8 16 36 00 00       	call   80105013 <acquire>
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
80101a14:	e8 f6 33 00 00       	call   80104e0f <wakeup>
  release(&icache.lock);
80101a19:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a20:	e8 50 36 00 00       	call   80105075 <release>
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
80101a34:	e8 da 35 00 00       	call   80105013 <acquire>
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
80101a72:	c7 04 24 e4 87 10 80 	movl   $0x801087e4,(%esp)
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
80101a96:	e8 da 35 00 00       	call   80105075 <release>
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
80101ac1:	e8 4d 35 00 00       	call   80105013 <acquire>
    ip->flags = 0;
80101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	89 04 24             	mov    %eax,(%esp)
80101ad6:	e8 34 33 00 00       	call   80104e0f <wakeup>
  }
  ip->ref--;
80101adb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ade:	8b 40 08             	mov    0x8(%eax),%eax
80101ae1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101aea:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101af1:	e8 7f 35 00 00       	call   80105075 <release>
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
80101c06:	c7 04 24 ee 87 10 80 	movl   $0x801087ee,(%esp)
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
80101e9e:	e8 92 34 00 00       	call   80105335 <memmove>
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
80102004:	e8 2c 33 00 00       	call   80105335 <memmove>
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
80102086:	e8 4e 33 00 00       	call   801053d9 <strncmp>
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
801020a0:	c7 04 24 01 88 10 80 	movl   $0x80108801,(%esp)
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
801020de:	c7 04 24 13 88 10 80 	movl   $0x80108813,(%esp)
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
801021c2:	c7 04 24 13 88 10 80 	movl   $0x80108813,(%esp)
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
80102208:	e8 24 32 00 00       	call   80105431 <strncpy>
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
8010223a:	c7 04 24 20 88 10 80 	movl   $0x80108820,(%esp)
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
801022c1:	e8 6f 30 00 00       	call   80105335 <memmove>
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
801022dc:	e8 54 30 00 00       	call   80105335 <memmove>
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
80102538:	c7 44 24 04 28 88 10 	movl   $0x80108828,0x4(%esp)
8010253f:	80 
80102540:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102547:	e8 a6 2a 00 00       	call   80104ff2 <initlock>
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
801025e4:	c7 04 24 2c 88 10 80 	movl   $0x8010882c,(%esp)
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
8010270a:	e8 04 29 00 00       	call   80105013 <acquire>
  if((b = idequeue) == 0){
8010270f:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102714:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010271b:	75 11                	jne    8010272e <ideintr+0x31>
    release(&idelock);
8010271d:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102724:	e8 4c 29 00 00       	call   80105075 <release>
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
80102797:	e8 73 26 00 00       	call   80104e0f <wakeup>
  
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
801027b9:	e8 b7 28 00 00       	call   80105075 <release>
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
801027d2:	c7 04 24 35 88 10 80 	movl   $0x80108835,(%esp)
801027d9:	e8 5f dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027de:	8b 45 08             	mov    0x8(%ebp),%eax
801027e1:	8b 00                	mov    (%eax),%eax
801027e3:	83 e0 06             	and    $0x6,%eax
801027e6:	83 f8 02             	cmp    $0x2,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x37>
    panic("iderw: nothing to do");
801027eb:	c7 04 24 49 88 10 80 	movl   $0x80108849,(%esp)
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
8010280a:	c7 04 24 5e 88 10 80 	movl   $0x8010885e,(%esp)
80102811:	e8 27 dd ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102816:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010281d:	e8 f1 27 00 00       	call   80105013 <acquire>

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
80102876:	e8 bb 24 00 00       	call   80104d36 <sleep>
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
80102892:	e8 de 27 00 00       	call   80105075 <release>
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
80102922:	c7 04 24 7c 88 10 80 	movl   $0x8010887c,(%esp)
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
801029e3:	c7 44 24 04 ae 88 10 	movl   $0x801088ae,0x4(%esp)
801029ea:	80 
801029eb:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
801029f2:	e8 fb 25 00 00       	call   80104ff2 <initlock>
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
80102a9f:	c7 04 24 b3 88 10 80 	movl   $0x801088b3,(%esp)
80102aa6:	e8 92 da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102aab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102ab2:	00 
80102ab3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102aba:	00 
80102abb:	8b 45 08             	mov    0x8(%ebp),%eax
80102abe:	89 04 24             	mov    %eax,(%esp)
80102ac1:	e8 9c 27 00 00       	call   80105262 <memset>

  if(kmem.use_lock)
80102ac6:	a1 54 22 11 80       	mov    0x80112254,%eax
80102acb:	85 c0                	test   %eax,%eax
80102acd:	74 0c                	je     80102adb <kfree+0x69>
    acquire(&kmem.lock);
80102acf:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102ad6:	e8 38 25 00 00       	call   80105013 <acquire>
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
80102b04:	e8 6c 25 00 00       	call   80105075 <release>
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
80102b21:	e8 ed 24 00 00       	call   80105013 <acquire>
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
80102b4e:	e8 22 25 00 00       	call   80105075 <release>
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
80102ef4:	c7 04 24 bc 88 10 80 	movl   $0x801088bc,(%esp)
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
80103158:	e8 7c 21 00 00       	call   801052d9 <memcmp>
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
8010325a:	c7 44 24 04 e8 88 10 	movl   $0x801088e8,0x4(%esp)
80103261:	80 
80103262:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103269:	e8 84 1d 00 00       	call   80104ff2 <initlock>
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
8010331c:	e8 14 20 00 00       	call   80105335 <memmove>
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
8010346e:	e8 a0 1b 00 00       	call   80105013 <acquire>
  while(1){
    if(log.committing){
80103473:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103478:	85 c0                	test   %eax,%eax
8010347a:	74 16                	je     80103492 <begin_op+0x31>
      sleep(&log, &log.lock);
8010347c:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80103483:	80 
80103484:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010348b:	e8 a6 18 00 00       	call   80104d36 <sleep>
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
801034bf:	e8 72 18 00 00       	call   80104d36 <sleep>
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
801034da:	e8 96 1b 00 00       	call   80105075 <release>
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
801034f6:	e8 18 1b 00 00       	call   80105013 <acquire>
  log.outstanding -= 1;
801034fb:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103500:	83 e8 01             	sub    $0x1,%eax
80103503:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
80103508:	a1 a0 22 11 80       	mov    0x801122a0,%eax
8010350d:	85 c0                	test   %eax,%eax
8010350f:	74 0c                	je     8010351d <end_op+0x3b>
    panic("log.committing");
80103511:	c7 04 24 ec 88 10 80 	movl   $0x801088ec,(%esp)
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
80103540:	e8 ca 18 00 00       	call   80104e0f <wakeup>
  }
  release(&log.lock);
80103545:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010354c:	e8 24 1b 00 00       	call   80105075 <release>

  if(do_commit){
80103551:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103555:	74 33                	je     8010358a <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103557:	e8 db 00 00 00       	call   80103637 <commit>
    acquire(&log.lock);
8010355c:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103563:	e8 ab 1a 00 00       	call   80105013 <acquire>
    log.committing = 0;
80103568:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
8010356f:	00 00 00 
    wakeup(&log);
80103572:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103579:	e8 91 18 00 00       	call   80104e0f <wakeup>
    release(&log.lock);
8010357e:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103585:	e8 eb 1a 00 00       	call   80105075 <release>
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
801035fd:	e8 33 1d 00 00       	call   80105335 <memmove>
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
80103688:	c7 04 24 fb 88 10 80 	movl   $0x801088fb,(%esp)
8010368f:	e8 a9 ce ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
80103694:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103699:	85 c0                	test   %eax,%eax
8010369b:	7f 0c                	jg     801036a9 <log_write+0x43>
    panic("log_write outside of trans");
8010369d:	c7 04 24 11 89 10 80 	movl   $0x80108911,(%esp)
801036a4:	e8 94 ce ff ff       	call   8010053d <panic>

  acquire(&log.lock);
801036a9:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036b0:	e8 5e 19 00 00       	call   80105013 <acquire>
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
80103728:	e8 48 19 00 00       	call   80105075 <release>
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
8010378c:	e8 a1 47 00 00       	call   80107f32 <kvmalloc>
  mpinit();        // collect info about this machine
80103791:	e8 53 04 00 00       	call   80103be9 <mpinit>
  lapicinit();
80103796:	e8 cb f5 ff ff       	call   80102d66 <lapicinit>
  seginit();       // set up segments
8010379b:	e8 35 41 00 00       	call   801078d5 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037a0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037a6:	0f b6 00             	movzbl (%eax),%eax
801037a9:	0f b6 c0             	movzbl %al,%eax
801037ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801037b0:	c7 04 24 2c 89 10 80 	movl   $0x8010892c,(%esp)
801037b7:	e8 e5 cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037bc:	e8 8d 06 00 00       	call   80103e4e <picinit>
  ioapicinit();    // another interrupt controller
801037c1:	e8 07 f1 ff ff       	call   801028cd <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037c6:	e8 c2 d2 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
801037cb:	e8 50 34 00 00       	call   80106c20 <uartinit>
  pinit();         // process table
801037d0:	e8 8e 0b 00 00       	call   80104363 <pinit>
  tvinit();        // trap vectors
801037d5:	e8 cd 2f 00 00       	call   801067a7 <tvinit>
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
801037f7:	e8 ee 2e 00 00       	call   801066ea <timerinit>
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
80103825:	e8 1f 47 00 00       	call   80107f49 <switchkvm>
  seginit();
8010382a:	e8 a6 40 00 00       	call   801078d5 <seginit>
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
8010384f:	c7 04 24 43 89 10 80 	movl   $0x80108943,(%esp)
80103856:	e8 46 cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
8010385b:	e8 bb 30 00 00       	call   8010691b <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103860:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103866:	05 a8 00 00 00       	add    $0xa8,%eax
8010386b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103872:	00 
80103873:	89 04 24             	mov    %eax,(%esp)
80103876:	e8 cf fe ff ff       	call   8010374a <xchg>
  scheduler();     // start running processes
8010387b:	e8 0d 13 00 00       	call   80104b8d <scheduler>

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
801038ad:	e8 83 1a 00 00       	call   80105335 <memmove>

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
80103a3c:	c7 44 24 04 54 89 10 	movl   $0x80108954,0x4(%esp)
80103a43:	80 
80103a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a47:	89 04 24             	mov    %eax,(%esp)
80103a4a:	e8 8a 18 00 00       	call   801052d9 <memcmp>
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
80103b7d:	c7 44 24 04 59 89 10 	movl   $0x80108959,0x4(%esp)
80103b84:	80 
80103b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b88:	89 04 24             	mov    %eax,(%esp)
80103b8b:	e8 49 17 00 00       	call   801052d9 <memcmp>
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
80103c56:	8b 04 85 9c 89 10 80 	mov    -0x7fef7664(,%eax,4),%eax
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
80103c8f:	c7 04 24 5e 89 10 80 	movl   $0x8010895e,(%esp)
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
80103d22:	c7 04 24 7c 89 10 80 	movl   $0x8010897c,(%esp)
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
80104027:	c7 44 24 04 b0 89 10 	movl   $0x801089b0,0x4(%esp)
8010402e:	80 
8010402f:	89 04 24             	mov    %eax,(%esp)
80104032:	e8 bb 0f 00 00       	call   80104ff2 <initlock>
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
801040df:	e8 2f 0f 00 00       	call   80105013 <acquire>
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
80104102:	e8 08 0d 00 00       	call   80104e0f <wakeup>
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
80104121:	e8 e9 0c 00 00       	call   80104e0f <wakeup>
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
80104146:	e8 2a 0f 00 00       	call   80105075 <release>
    kfree((char*)p);
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	89 04 24             	mov    %eax,(%esp)
80104151:	e8 1c e9 ff ff       	call   80102a72 <kfree>
80104156:	eb 0b                	jmp    80104163 <pipeclose+0x90>
  } else
    release(&p->lock);
80104158:	8b 45 08             	mov    0x8(%ebp),%eax
8010415b:	89 04 24             	mov    %eax,(%esp)
8010415e:	e8 12 0f 00 00       	call   80105075 <release>
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
80104172:	e8 9c 0e 00 00       	call   80105013 <acquire>
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
801041a3:	e8 cd 0e 00 00       	call   80105075 <release>
        return -1;
801041a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ad:	e9 9d 00 00 00       	jmp    8010424f <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041b2:	8b 45 08             	mov    0x8(%ebp),%eax
801041b5:	05 34 02 00 00       	add    $0x234,%eax
801041ba:	89 04 24             	mov    %eax,(%esp)
801041bd:	e8 4d 0c 00 00       	call   80104e0f <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041c2:	8b 45 08             	mov    0x8(%ebp),%eax
801041c5:	8b 55 08             	mov    0x8(%ebp),%edx
801041c8:	81 c2 38 02 00 00    	add    $0x238,%edx
801041ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801041d2:	89 14 24             	mov    %edx,(%esp)
801041d5:	e8 5c 0b 00 00       	call   80104d36 <sleep>
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
8010423c:	e8 ce 0b 00 00       	call   80104e0f <wakeup>
  release(&p->lock);
80104241:	8b 45 08             	mov    0x8(%ebp),%eax
80104244:	89 04 24             	mov    %eax,(%esp)
80104247:	e8 29 0e 00 00       	call   80105075 <release>
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
80104262:	e8 ac 0d 00 00       	call   80105013 <acquire>
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
8010427c:	e8 f4 0d 00 00       	call   80105075 <release>
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
8010429e:	e8 93 0a 00 00       	call   80104d36 <sleep>
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
8010432e:	e8 dc 0a 00 00       	call   80104e0f <wakeup>
  release(&p->lock);
80104333:	8b 45 08             	mov    0x8(%ebp),%eax
80104336:	89 04 24             	mov    %eax,(%esp)
80104339:	e8 37 0d 00 00       	call   80105075 <release>
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
80104369:	c7 44 24 04 b5 89 10 	movl   $0x801089b5,0x4(%esp)
80104370:	80 
80104371:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104378:	e8 75 0c 00 00       	call   80104ff2 <initlock>
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
8010438c:	e8 82 0c 00 00       	call   80105013 <acquire>
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
801043b8:	e8 b8 0c 00 00       	call   80105075 <release>
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
801043ec:	e8 84 0c 00 00       	call   80105075 <release>

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
80104436:	ba 5c 67 10 80       	mov    $0x8010675c,%edx
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
80104466:	e8 f7 0d 00 00       	call   80105262 <memset>
  p->context->eip = (uint)forkret;
8010446b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104471:	ba 0a 4d 10 80       	mov    $0x80104d0a,%edx
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
80104494:	e8 dc 39 00 00       	call   80107e75 <setupkvm>
80104499:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010449c:	89 42 04             	mov    %eax,0x4(%edx)
8010449f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a2:	8b 40 04             	mov    0x4(%eax),%eax
801044a5:	85 c0                	test   %eax,%eax
801044a7:	75 0c                	jne    801044b5 <userinit+0x37>
    panic("userinit: out of memory?");
801044a9:	c7 04 24 bc 89 10 80 	movl   $0x801089bc,(%esp)
801044b0:	e8 88 c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044b5:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bd:	8b 40 04             	mov    0x4(%eax),%eax
801044c0:	89 54 24 08          	mov    %edx,0x8(%esp)
801044c4:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044cb:	80 
801044cc:	89 04 24             	mov    %eax,(%esp)
801044cf:	e8 f9 3b 00 00       	call   801080cd <inituvm>
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
801044f6:	e8 67 0d 00 00       	call   80105262 <memset>
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
80104570:	c7 44 24 04 d5 89 10 	movl   $0x801089d5,0x4(%esp)
80104577:	80 
80104578:	89 04 24             	mov    %eax,(%esp)
8010457b:	e8 12 0f 00 00       	call   80105492 <safestrcpy>
  p->cwd = namei("/");
80104580:	c7 04 24 de 89 10 80 	movl   $0x801089de,(%esp)
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
801045d4:	e8 6e 3c 00 00       	call   80108247 <allocuvm>
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
8010460e:	e8 0e 3d 00 00       	call   80108321 <deallocuvm>
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
80104637:	e8 2a 39 00 00       	call   80107f66 <switchuvm>
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
8010467c:	e8 30 3e 00 00       	call   801084b1 <copyuvm>
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
80104783:	e8 0a 0d 00 00       	call   80105492 <safestrcpy>
 
  pid = np->pid;
80104788:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010478b:	8b 40 10             	mov    0x10(%eax),%eax
8010478e:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104791:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104798:	e8 76 08 00 00       	call   80105013 <acquire>
  np->state = RUNNABLE;
8010479d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801047a7:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047ae:	e8 c2 08 00 00       	call   80105075 <release>
  
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
801047d4:	c7 04 24 e0 89 10 80 	movl   $0x801089e0,(%esp)
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
8010486e:	e8 a0 07 00 00       	call   80105013 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104873:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104879:	8b 40 14             	mov    0x14(%eax),%eax
8010487c:	89 04 24             	mov    %eax,(%esp)
8010487f:	e8 4d 05 00 00       	call   80104dd1 <wakeup1>

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
801048bc:	e8 10 05 00 00       	call   80104dd1 <wakeup1>

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
801048db:	e8 46 03 00 00       	call   80104c26 <sched>
  panic("zombie exit");
801048e0:	c7 04 24 ed 89 10 80 	movl   $0x801089ed,(%esp)
801048e7:	e8 51 bc ff ff       	call   8010053d <panic>

801048ec <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(int* status)
{
801048ec:	55                   	push   %ebp
801048ed:	89 e5                	mov    %esp,%ebp
801048ef:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801048f2:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801048f9:	e8 15 07 00 00       	call   80105013 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801048fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104905:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
8010490c:	e9 af 00 00 00       	jmp    801049c0 <wait+0xd4>
      if(p->parent != proc)
80104911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104914:	8b 50 14             	mov    0x14(%eax),%edx
80104917:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010491d:	39 c2                	cmp    %eax,%edx
8010491f:	0f 85 96 00 00 00    	jne    801049bb <wait+0xcf>
        continue;
      havekids = 1;
80104925:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010492c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492f:	8b 40 0c             	mov    0xc(%eax),%eax
80104932:	83 f8 05             	cmp    $0x5,%eax
80104935:	0f 85 81 00 00 00    	jne    801049bc <wait+0xd0>
        // Found one.
        pid = p->pid;
8010493b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493e:	8b 40 10             	mov    0x10(%eax),%eax
80104941:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104947:	8b 40 08             	mov    0x8(%eax),%eax
8010494a:	89 04 24             	mov    %eax,(%esp)
8010494d:	e8 20 e1 ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
80104952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104955:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010495c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495f:	8b 40 04             	mov    0x4(%eax),%eax
80104962:	89 04 24             	mov    %eax,(%esp)
80104965:	e8 73 3a 00 00       	call   801083dd <freevm>
        p->state = UNUSED;
8010496a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104977:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010497e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104981:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104988:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010498f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104992:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

        if(status){ // if user did not send status=0 (do not care)
80104999:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010499d:	74 0b                	je     801049aa <wait+0xbe>
            *status = p->status; //return status to caller
8010499f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a2:	8b 50 7c             	mov    0x7c(%eax),%edx
801049a5:	8b 45 08             	mov    0x8(%ebp),%eax
801049a8:	89 10                	mov    %edx,(%eax)
        }

        release(&ptable.lock);
801049aa:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801049b1:	e8 bf 06 00 00       	call   80105075 <release>

        return pid;
801049b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049b9:	eb 53                	jmp    80104a0e <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049bb:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049bc:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801049c0:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
801049c7:	0f 82 44 ff ff ff    	jb     80104911 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049d1:	74 0d                	je     801049e0 <wait+0xf4>
801049d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d9:	8b 40 24             	mov    0x24(%eax),%eax
801049dc:	85 c0                	test   %eax,%eax
801049de:	74 13                	je     801049f3 <wait+0x107>
      release(&ptable.lock);
801049e0:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801049e7:	e8 89 06 00 00       	call   80105075 <release>
      return -1;
801049ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049f1:	eb 1b                	jmp    80104a0e <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801049f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f9:	c7 44 24 04 60 29 11 	movl   $0x80112960,0x4(%esp)
80104a00:	80 
80104a01:	89 04 24             	mov    %eax,(%esp)
80104a04:	e8 2d 03 00 00       	call   80104d36 <sleep>
  }
80104a09:	e9 f0 fe ff ff       	jmp    801048fe <wait+0x12>
}
80104a0e:	c9                   	leave  
80104a0f:	c3                   	ret    

80104a10 <waitpid>:

// Wait for a child process *with a specific pid* to exit and return its pid.
// Return -1 if this process has no children.
int
waitpid(int childPid, int* status, int options)
{
80104a10:	55                   	push   %ebp
80104a11:	89 e5                	mov    %esp,%ebp
80104a13:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid, isMyChild;

  acquire(&ptable.lock);
80104a16:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a1d:	e8 f1 05 00 00       	call   80105013 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a22:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    isMyChild = 0;
80104a29:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a30:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104a37:	e9 c8 00 00 00       	jmp    80104b04 <waitpid+0xf4>
      if(p->parent != proc)
80104a3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3f:	8b 50 14             	mov    0x14(%eax),%edx
80104a42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a48:	39 c2                	cmp    %eax,%edx
80104a4a:	0f 85 af 00 00 00    	jne    80104aff <waitpid+0xef>
        continue;
      havekids = 1;
80104a50:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if( p->pid == childPid ){
80104a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5a:	8b 40 10             	mov    0x10(%eax),%eax
80104a5d:	3b 45 08             	cmp    0x8(%ebp),%eax
80104a60:	0f 85 9a 00 00 00    	jne    80104b00 <waitpid+0xf0>
    	 isMyChild = 1;
80104a66:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
		 if(p->state == ZOMBIE ){
80104a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a70:	8b 40 0c             	mov    0xc(%eax),%eax
80104a73:	83 f8 05             	cmp    $0x5,%eax
80104a76:	0f 85 84 00 00 00    	jne    80104b00 <waitpid+0xf0>
			// Found one.
			pid = p->pid;
80104a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7f:	8b 40 10             	mov    0x10(%eax),%eax
80104a82:	89 45 e8             	mov    %eax,-0x18(%ebp)
			kfree(p->kstack);
80104a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a88:	8b 40 08             	mov    0x8(%eax),%eax
80104a8b:	89 04 24             	mov    %eax,(%esp)
80104a8e:	e8 df df ff ff       	call   80102a72 <kfree>
			p->kstack = 0;
80104a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a96:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
			freevm(p->pgdir);
80104a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa0:	8b 40 04             	mov    0x4(%eax),%eax
80104aa3:	89 04 24             	mov    %eax,(%esp)
80104aa6:	e8 32 39 00 00       	call   801083dd <freevm>
			p->state = UNUSED;
80104aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aae:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
			p->pid = 0;
80104ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab8:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
			p->parent = 0;
80104abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
			p->name[0] = 0;
80104ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acc:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
			p->killed = 0;
80104ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad3:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

			if(status){ // if user did not send status=0 (do not care)
80104ada:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ade:	74 0b                	je     80104aeb <waitpid+0xdb>
				*status = p->status; //return status to caller
80104ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae3:	8b 50 7c             	mov    0x7c(%eax),%edx
80104ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ae9:	89 10                	mov    %edx,(%eax)
			}

			release(&ptable.lock);
80104aeb:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104af2:	e8 7e 05 00 00       	call   80105075 <release>

			return pid;
80104af7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104afa:	e9 8c 00 00 00       	jmp    80104b8b <waitpid+0x17b>
    havekids = 0;
    isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104aff:	90                   	nop
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b00:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104b04:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
80104b0b:	0f 82 2b ff ff ff    	jb     80104a3c <waitpid+0x2c>
      }

    }

    // No point waiting if we don't have any children.
    if(!havekids || !isMyChild || proc->killed){
80104b11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b15:	74 13                	je     80104b2a <waitpid+0x11a>
80104b17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104b1b:	74 0d                	je     80104b2a <waitpid+0x11a>
80104b1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b23:	8b 40 24             	mov    0x24(%eax),%eax
80104b26:	85 c0                	test   %eax,%eax
80104b28:	74 13                	je     80104b3d <waitpid+0x12d>
      release(&ptable.lock);
80104b2a:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b31:	e8 3f 05 00 00       	call   80105075 <release>
      return -1;
80104b36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b3b:	eb 4e                	jmp    80104b8b <waitpid+0x17b>
    }

    switch (options) {
80104b3d:	8b 45 10             	mov    0x10(%ebp),%eax
80104b40:	85 c0                	test   %eax,%eax
80104b42:	74 07                	je     80104b4b <waitpid+0x13b>
80104b44:	83 f8 01             	cmp    $0x1,%eax
80104b47:	74 1e                	je     80104b67 <waitpid+0x157>
80104b49:	eb 2f                	jmp    80104b7a <waitpid+0x16a>
		case BLOCKING:
			sleep(proc, &ptable.lock);
80104b4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b51:	c7 44 24 04 60 29 11 	movl   $0x80112960,0x4(%esp)
80104b58:	80 
80104b59:	89 04 24             	mov    %eax,(%esp)
80104b5c:	e8 d5 01 00 00       	call   80104d36 <sleep>
			break;
80104b61:	90                   	nop
			release(&ptable.lock);
			return -1;
			break;
	}

  }
80104b62:	e9 bb fe ff ff       	jmp    80104a22 <waitpid+0x12>
    switch (options) {
		case BLOCKING:
			sleep(proc, &ptable.lock);
			break;
		case NONBLOCKING:
			release(&ptable.lock);
80104b67:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b6e:	e8 02 05 00 00       	call   80105075 <release>
			return -1;
80104b73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b78:	eb 11                	jmp    80104b8b <waitpid+0x17b>
			break;
		default:
			release(&ptable.lock);
80104b7a:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b81:	e8 ef 04 00 00       	call   80105075 <release>
			return -1;
80104b86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			break;
	}

  }
}
80104b8b:	c9                   	leave  
80104b8c:	c3                   	ret    

80104b8d <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b8d:	55                   	push   %ebp
80104b8e:	89 e5                	mov    %esp,%ebp
80104b90:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b93:	e8 c5 f7 ff ff       	call   8010435d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b98:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b9f:	e8 6f 04 00 00       	call   80105013 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ba4:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104bab:	eb 5f                	jmp    80104c0c <scheduler+0x7f>
      if(p->state != RUNNABLE)
80104bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb0:	8b 40 0c             	mov    0xc(%eax),%eax
80104bb3:	83 f8 03             	cmp    $0x3,%eax
80104bb6:	75 4f                	jne    80104c07 <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbb:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc4:	89 04 24             	mov    %eax,(%esp)
80104bc7:	e8 9a 33 00 00       	call   80107f66 <switchuvm>
      p->state = RUNNING;
80104bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcf:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104bd6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bdc:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bdf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104be6:	83 c2 04             	add    $0x4,%edx
80104be9:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bed:	89 14 24             	mov    %edx,(%esp)
80104bf0:	e8 13 09 00 00       	call   80105508 <swtch>
      switchkvm();
80104bf5:	e8 4f 33 00 00       	call   80107f49 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104bfa:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c01:	00 00 00 00 
80104c05:	eb 01                	jmp    80104c08 <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104c07:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c08:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104c0c:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
80104c13:	72 98                	jb     80104bad <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104c15:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c1c:	e8 54 04 00 00       	call   80105075 <release>

  }
80104c21:	e9 6d ff ff ff       	jmp    80104b93 <scheduler+0x6>

80104c26 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c26:	55                   	push   %ebp
80104c27:	89 e5                	mov    %esp,%ebp
80104c29:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c2c:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c33:	e8 f9 04 00 00       	call   80105131 <holding>
80104c38:	85 c0                	test   %eax,%eax
80104c3a:	75 0c                	jne    80104c48 <sched+0x22>
    panic("sched ptable.lock");
80104c3c:	c7 04 24 f9 89 10 80 	movl   $0x801089f9,(%esp)
80104c43:	e8 f5 b8 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104c48:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c4e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c54:	83 f8 01             	cmp    $0x1,%eax
80104c57:	74 0c                	je     80104c65 <sched+0x3f>
    panic("sched locks");
80104c59:	c7 04 24 0b 8a 10 80 	movl   $0x80108a0b,(%esp)
80104c60:	e8 d8 b8 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104c65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c6b:	8b 40 0c             	mov    0xc(%eax),%eax
80104c6e:	83 f8 04             	cmp    $0x4,%eax
80104c71:	75 0c                	jne    80104c7f <sched+0x59>
    panic("sched running");
80104c73:	c7 04 24 17 8a 10 80 	movl   $0x80108a17,(%esp)
80104c7a:	e8 be b8 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104c7f:	e8 c4 f6 ff ff       	call   80104348 <readeflags>
80104c84:	25 00 02 00 00       	and    $0x200,%eax
80104c89:	85 c0                	test   %eax,%eax
80104c8b:	74 0c                	je     80104c99 <sched+0x73>
    panic("sched interruptible");
80104c8d:	c7 04 24 25 8a 10 80 	movl   $0x80108a25,(%esp)
80104c94:	e8 a4 b8 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104c99:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c9f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104ca8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cae:	8b 40 04             	mov    0x4(%eax),%eax
80104cb1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cb8:	83 c2 1c             	add    $0x1c,%edx
80104cbb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cbf:	89 14 24             	mov    %edx,(%esp)
80104cc2:	e8 41 08 00 00       	call   80105508 <swtch>
  cpu->intena = intena;
80104cc7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cd0:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104cd6:	c9                   	leave  
80104cd7:	c3                   	ret    

80104cd8 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104cd8:	55                   	push   %ebp
80104cd9:	89 e5                	mov    %esp,%ebp
80104cdb:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104cde:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ce5:	e8 29 03 00 00       	call   80105013 <acquire>
  proc->state = RUNNABLE;
80104cea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cf0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104cf7:	e8 2a ff ff ff       	call   80104c26 <sched>
  release(&ptable.lock);
80104cfc:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d03:	e8 6d 03 00 00       	call   80105075 <release>
}
80104d08:	c9                   	leave  
80104d09:	c3                   	ret    

80104d0a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d0a:	55                   	push   %ebp
80104d0b:	89 e5                	mov    %esp,%ebp
80104d0d:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d10:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d17:	e8 59 03 00 00       	call   80105075 <release>

  if (first) {
80104d1c:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104d21:	85 c0                	test   %eax,%eax
80104d23:	74 0f                	je     80104d34 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d25:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104d2c:	00 00 00 
    initlog();
80104d2f:	e8 20 e5 ff ff       	call   80103254 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d34:	c9                   	leave  
80104d35:	c3                   	ret    

80104d36 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d36:	55                   	push   %ebp
80104d37:	89 e5                	mov    %esp,%ebp
80104d39:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104d3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d42:	85 c0                	test   %eax,%eax
80104d44:	75 0c                	jne    80104d52 <sleep+0x1c>
    panic("sleep");
80104d46:	c7 04 24 39 8a 10 80 	movl   $0x80108a39,(%esp)
80104d4d:	e8 eb b7 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104d52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d56:	75 0c                	jne    80104d64 <sleep+0x2e>
    panic("sleep without lk");
80104d58:	c7 04 24 3f 8a 10 80 	movl   $0x80108a3f,(%esp)
80104d5f:	e8 d9 b7 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d64:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104d6b:	74 17                	je     80104d84 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d6d:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d74:	e8 9a 02 00 00       	call   80105013 <acquire>
    release(lk);
80104d79:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d7c:	89 04 24             	mov    %eax,(%esp)
80104d7f:	e8 f1 02 00 00       	call   80105075 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104d84:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d8a:	8b 55 08             	mov    0x8(%ebp),%edx
80104d8d:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104d90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d96:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104d9d:	e8 84 fe ff ff       	call   80104c26 <sched>

  // Tidy up.
  proc->chan = 0;
80104da2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da8:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104daf:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104db6:	74 17                	je     80104dcf <sleep+0x99>
    release(&ptable.lock);
80104db8:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104dbf:	e8 b1 02 00 00       	call   80105075 <release>
    acquire(lk);
80104dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dc7:	89 04 24             	mov    %eax,(%esp)
80104dca:	e8 44 02 00 00       	call   80105013 <acquire>
  }
}
80104dcf:	c9                   	leave  
80104dd0:	c3                   	ret    

80104dd1 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104dd1:	55                   	push   %ebp
80104dd2:	89 e5                	mov    %esp,%ebp
80104dd4:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104dd7:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104dde:	eb 24                	jmp    80104e04 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104de0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104de3:	8b 40 0c             	mov    0xc(%eax),%eax
80104de6:	83 f8 02             	cmp    $0x2,%eax
80104de9:	75 15                	jne    80104e00 <wakeup1+0x2f>
80104deb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dee:	8b 40 20             	mov    0x20(%eax),%eax
80104df1:	3b 45 08             	cmp    0x8(%ebp),%eax
80104df4:	75 0a                	jne    80104e00 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104df6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104df9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e00:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104e04:	81 7d fc 94 49 11 80 	cmpl   $0x80114994,-0x4(%ebp)
80104e0b:	72 d3                	jb     80104de0 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104e0d:	c9                   	leave  
80104e0e:	c3                   	ret    

80104e0f <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e0f:	55                   	push   %ebp
80104e10:	89 e5                	mov    %esp,%ebp
80104e12:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104e15:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e1c:	e8 f2 01 00 00       	call   80105013 <acquire>
  wakeup1(chan);
80104e21:	8b 45 08             	mov    0x8(%ebp),%eax
80104e24:	89 04 24             	mov    %eax,(%esp)
80104e27:	e8 a5 ff ff ff       	call   80104dd1 <wakeup1>
  release(&ptable.lock);
80104e2c:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e33:	e8 3d 02 00 00       	call   80105075 <release>
}
80104e38:	c9                   	leave  
80104e39:	c3                   	ret    

80104e3a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e3a:	55                   	push   %ebp
80104e3b:	89 e5                	mov    %esp,%ebp
80104e3d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e40:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e47:	e8 c7 01 00 00       	call   80105013 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e4c:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104e53:	eb 41                	jmp    80104e96 <kill+0x5c>
    if(p->pid == pid){
80104e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e58:	8b 40 10             	mov    0x10(%eax),%eax
80104e5b:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e5e:	75 32                	jne    80104e92 <kill+0x58>
      p->killed = 1;
80104e60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e63:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e6d:	8b 40 0c             	mov    0xc(%eax),%eax
80104e70:	83 f8 02             	cmp    $0x2,%eax
80104e73:	75 0a                	jne    80104e7f <kill+0x45>
        p->state = RUNNABLE;
80104e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e78:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e7f:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e86:	e8 ea 01 00 00       	call   80105075 <release>
      return 0;
80104e8b:	b8 00 00 00 00       	mov    $0x0,%eax
80104e90:	eb 1e                	jmp    80104eb0 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e92:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104e96:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
80104e9d:	72 b6                	jb     80104e55 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104e9f:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ea6:	e8 ca 01 00 00       	call   80105075 <release>
  return -1;
80104eab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104eb0:	c9                   	leave  
80104eb1:	c3                   	ret    

80104eb2 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104eb2:	55                   	push   %ebp
80104eb3:	89 e5                	mov    %esp,%ebp
80104eb5:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104eb8:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104ebf:	e9 d8 00 00 00       	jmp    80104f9c <procdump+0xea>
    if(p->state == UNUSED)
80104ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ec7:	8b 40 0c             	mov    0xc(%eax),%eax
80104eca:	85 c0                	test   %eax,%eax
80104ecc:	0f 84 c5 00 00 00    	je     80104f97 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ed5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ed8:	83 f8 05             	cmp    $0x5,%eax
80104edb:	77 23                	ja     80104f00 <procdump+0x4e>
80104edd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ee0:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee3:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104eea:	85 c0                	test   %eax,%eax
80104eec:	74 12                	je     80104f00 <procdump+0x4e>
      state = states[p->state];
80104eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef4:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104efb:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104efe:	eb 07                	jmp    80104f07 <procdump+0x55>
    else
      state = "???";
80104f00:	c7 45 ec 50 8a 10 80 	movl   $0x80108a50,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f0a:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f10:	8b 40 10             	mov    0x10(%eax),%eax
80104f13:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f17:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f1a:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f22:	c7 04 24 54 8a 10 80 	movl   $0x80108a54,(%esp)
80104f29:	e8 73 b4 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f31:	8b 40 0c             	mov    0xc(%eax),%eax
80104f34:	83 f8 02             	cmp    $0x2,%eax
80104f37:	75 50                	jne    80104f89 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f3c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f3f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f42:	83 c0 08             	add    $0x8,%eax
80104f45:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104f48:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f4c:	89 04 24             	mov    %eax,(%esp)
80104f4f:	e8 70 01 00 00       	call   801050c4 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104f54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f5b:	eb 1b                	jmp    80104f78 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f60:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f64:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f68:	c7 04 24 5d 8a 10 80 	movl   $0x80108a5d,(%esp)
80104f6f:	e8 2d b4 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f78:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f7c:	7f 0b                	jg     80104f89 <procdump+0xd7>
80104f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f81:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f85:	85 c0                	test   %eax,%eax
80104f87:	75 d4                	jne    80104f5d <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104f89:	c7 04 24 61 8a 10 80 	movl   $0x80108a61,(%esp)
80104f90:	e8 0c b4 ff ff       	call   801003a1 <cprintf>
80104f95:	eb 01                	jmp    80104f98 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104f97:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f98:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104f9c:	81 7d f0 94 49 11 80 	cmpl   $0x80114994,-0x10(%ebp)
80104fa3:	0f 82 1b ff ff ff    	jb     80104ec4 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104fa9:	c9                   	leave  
80104faa:	c3                   	ret    
	...

80104fac <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104fac:	55                   	push   %ebp
80104fad:	89 e5                	mov    %esp,%ebp
80104faf:	53                   	push   %ebx
80104fb0:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104fb3:	9c                   	pushf  
80104fb4:	5b                   	pop    %ebx
80104fb5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104fb8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104fbb:	83 c4 10             	add    $0x10,%esp
80104fbe:	5b                   	pop    %ebx
80104fbf:	5d                   	pop    %ebp
80104fc0:	c3                   	ret    

80104fc1 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104fc1:	55                   	push   %ebp
80104fc2:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104fc4:	fa                   	cli    
}
80104fc5:	5d                   	pop    %ebp
80104fc6:	c3                   	ret    

80104fc7 <sti>:

static inline void
sti(void)
{
80104fc7:	55                   	push   %ebp
80104fc8:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104fca:	fb                   	sti    
}
80104fcb:	5d                   	pop    %ebp
80104fcc:	c3                   	ret    

80104fcd <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104fcd:	55                   	push   %ebp
80104fce:	89 e5                	mov    %esp,%ebp
80104fd0:	53                   	push   %ebx
80104fd1:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104fd4:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104fda:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104fdd:	89 c3                	mov    %eax,%ebx
80104fdf:	89 d8                	mov    %ebx,%eax
80104fe1:	f0 87 02             	lock xchg %eax,(%edx)
80104fe4:	89 c3                	mov    %eax,%ebx
80104fe6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104fe9:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104fec:	83 c4 10             	add    $0x10,%esp
80104fef:	5b                   	pop    %ebx
80104ff0:	5d                   	pop    %ebp
80104ff1:	c3                   	ret    

80104ff2 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104ff2:	55                   	push   %ebp
80104ff3:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff8:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ffb:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104ffe:	8b 45 08             	mov    0x8(%ebp),%eax
80105001:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105007:	8b 45 08             	mov    0x8(%ebp),%eax
8010500a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105011:	5d                   	pop    %ebp
80105012:	c3                   	ret    

80105013 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105013:	55                   	push   %ebp
80105014:	89 e5                	mov    %esp,%ebp
80105016:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105019:	e8 3d 01 00 00       	call   8010515b <pushcli>
  if(holding(lk))
8010501e:	8b 45 08             	mov    0x8(%ebp),%eax
80105021:	89 04 24             	mov    %eax,(%esp)
80105024:	e8 08 01 00 00       	call   80105131 <holding>
80105029:	85 c0                	test   %eax,%eax
8010502b:	74 0c                	je     80105039 <acquire+0x26>
    panic("acquire");
8010502d:	c7 04 24 8d 8a 10 80 	movl   $0x80108a8d,(%esp)
80105034:	e8 04 b5 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105039:	90                   	nop
8010503a:	8b 45 08             	mov    0x8(%ebp),%eax
8010503d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105044:	00 
80105045:	89 04 24             	mov    %eax,(%esp)
80105048:	e8 80 ff ff ff       	call   80104fcd <xchg>
8010504d:	85 c0                	test   %eax,%eax
8010504f:	75 e9                	jne    8010503a <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105051:	8b 45 08             	mov    0x8(%ebp),%eax
80105054:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010505b:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
8010505e:	8b 45 08             	mov    0x8(%ebp),%eax
80105061:	83 c0 0c             	add    $0xc,%eax
80105064:	89 44 24 04          	mov    %eax,0x4(%esp)
80105068:	8d 45 08             	lea    0x8(%ebp),%eax
8010506b:	89 04 24             	mov    %eax,(%esp)
8010506e:	e8 51 00 00 00       	call   801050c4 <getcallerpcs>
}
80105073:	c9                   	leave  
80105074:	c3                   	ret    

80105075 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105075:	55                   	push   %ebp
80105076:	89 e5                	mov    %esp,%ebp
80105078:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010507b:	8b 45 08             	mov    0x8(%ebp),%eax
8010507e:	89 04 24             	mov    %eax,(%esp)
80105081:	e8 ab 00 00 00       	call   80105131 <holding>
80105086:	85 c0                	test   %eax,%eax
80105088:	75 0c                	jne    80105096 <release+0x21>
    panic("release");
8010508a:	c7 04 24 95 8a 10 80 	movl   $0x80108a95,(%esp)
80105091:	e8 a7 b4 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80105096:	8b 45 08             	mov    0x8(%ebp),%eax
80105099:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050a0:	8b 45 08             	mov    0x8(%ebp),%eax
801050a3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801050aa:	8b 45 08             	mov    0x8(%ebp),%eax
801050ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801050b4:	00 
801050b5:	89 04 24             	mov    %eax,(%esp)
801050b8:	e8 10 ff ff ff       	call   80104fcd <xchg>

  popcli();
801050bd:	e8 e1 00 00 00       	call   801051a3 <popcli>
}
801050c2:	c9                   	leave  
801050c3:	c3                   	ret    

801050c4 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801050c4:	55                   	push   %ebp
801050c5:	89 e5                	mov    %esp,%ebp
801050c7:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801050ca:	8b 45 08             	mov    0x8(%ebp),%eax
801050cd:	83 e8 08             	sub    $0x8,%eax
801050d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801050d3:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801050da:	eb 32                	jmp    8010510e <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801050dc:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801050e0:	74 47                	je     80105129 <getcallerpcs+0x65>
801050e2:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801050e9:	76 3e                	jbe    80105129 <getcallerpcs+0x65>
801050eb:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801050ef:	74 38                	je     80105129 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
801050f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050f4:	c1 e0 02             	shl    $0x2,%eax
801050f7:	03 45 0c             	add    0xc(%ebp),%eax
801050fa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801050fd:	8b 52 04             	mov    0x4(%edx),%edx
80105100:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80105102:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105105:	8b 00                	mov    (%eax),%eax
80105107:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010510a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010510e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105112:	7e c8                	jle    801050dc <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105114:	eb 13                	jmp    80105129 <getcallerpcs+0x65>
    pcs[i] = 0;
80105116:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105119:	c1 e0 02             	shl    $0x2,%eax
8010511c:	03 45 0c             	add    0xc(%ebp),%eax
8010511f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105125:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105129:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010512d:	7e e7                	jle    80105116 <getcallerpcs+0x52>
    pcs[i] = 0;
}
8010512f:	c9                   	leave  
80105130:	c3                   	ret    

80105131 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105131:	55                   	push   %ebp
80105132:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105134:	8b 45 08             	mov    0x8(%ebp),%eax
80105137:	8b 00                	mov    (%eax),%eax
80105139:	85 c0                	test   %eax,%eax
8010513b:	74 17                	je     80105154 <holding+0x23>
8010513d:	8b 45 08             	mov    0x8(%ebp),%eax
80105140:	8b 50 08             	mov    0x8(%eax),%edx
80105143:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105149:	39 c2                	cmp    %eax,%edx
8010514b:	75 07                	jne    80105154 <holding+0x23>
8010514d:	b8 01 00 00 00       	mov    $0x1,%eax
80105152:	eb 05                	jmp    80105159 <holding+0x28>
80105154:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105159:	5d                   	pop    %ebp
8010515a:	c3                   	ret    

8010515b <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010515b:	55                   	push   %ebp
8010515c:	89 e5                	mov    %esp,%ebp
8010515e:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105161:	e8 46 fe ff ff       	call   80104fac <readeflags>
80105166:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105169:	e8 53 fe ff ff       	call   80104fc1 <cli>
  if(cpu->ncli++ == 0)
8010516e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105174:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010517a:	85 d2                	test   %edx,%edx
8010517c:	0f 94 c1             	sete   %cl
8010517f:	83 c2 01             	add    $0x1,%edx
80105182:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105188:	84 c9                	test   %cl,%cl
8010518a:	74 15                	je     801051a1 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
8010518c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105192:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105195:	81 e2 00 02 00 00    	and    $0x200,%edx
8010519b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801051a1:	c9                   	leave  
801051a2:	c3                   	ret    

801051a3 <popcli>:

void
popcli(void)
{
801051a3:	55                   	push   %ebp
801051a4:	89 e5                	mov    %esp,%ebp
801051a6:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801051a9:	e8 fe fd ff ff       	call   80104fac <readeflags>
801051ae:	25 00 02 00 00       	and    $0x200,%eax
801051b3:	85 c0                	test   %eax,%eax
801051b5:	74 0c                	je     801051c3 <popcli+0x20>
    panic("popcli - interruptible");
801051b7:	c7 04 24 9d 8a 10 80 	movl   $0x80108a9d,(%esp)
801051be:	e8 7a b3 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
801051c3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051c9:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801051cf:	83 ea 01             	sub    $0x1,%edx
801051d2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801051d8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801051de:	85 c0                	test   %eax,%eax
801051e0:	79 0c                	jns    801051ee <popcli+0x4b>
    panic("popcli");
801051e2:	c7 04 24 b4 8a 10 80 	movl   $0x80108ab4,(%esp)
801051e9:	e8 4f b3 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
801051ee:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051f4:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801051fa:	85 c0                	test   %eax,%eax
801051fc:	75 15                	jne    80105213 <popcli+0x70>
801051fe:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105204:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010520a:	85 c0                	test   %eax,%eax
8010520c:	74 05                	je     80105213 <popcli+0x70>
    sti();
8010520e:	e8 b4 fd ff ff       	call   80104fc7 <sti>
}
80105213:	c9                   	leave  
80105214:	c3                   	ret    
80105215:	00 00                	add    %al,(%eax)
	...

80105218 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105218:	55                   	push   %ebp
80105219:	89 e5                	mov    %esp,%ebp
8010521b:	57                   	push   %edi
8010521c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010521d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105220:	8b 55 10             	mov    0x10(%ebp),%edx
80105223:	8b 45 0c             	mov    0xc(%ebp),%eax
80105226:	89 cb                	mov    %ecx,%ebx
80105228:	89 df                	mov    %ebx,%edi
8010522a:	89 d1                	mov    %edx,%ecx
8010522c:	fc                   	cld    
8010522d:	f3 aa                	rep stos %al,%es:(%edi)
8010522f:	89 ca                	mov    %ecx,%edx
80105231:	89 fb                	mov    %edi,%ebx
80105233:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105236:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105239:	5b                   	pop    %ebx
8010523a:	5f                   	pop    %edi
8010523b:	5d                   	pop    %ebp
8010523c:	c3                   	ret    

8010523d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010523d:	55                   	push   %ebp
8010523e:	89 e5                	mov    %esp,%ebp
80105240:	57                   	push   %edi
80105241:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105242:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105245:	8b 55 10             	mov    0x10(%ebp),%edx
80105248:	8b 45 0c             	mov    0xc(%ebp),%eax
8010524b:	89 cb                	mov    %ecx,%ebx
8010524d:	89 df                	mov    %ebx,%edi
8010524f:	89 d1                	mov    %edx,%ecx
80105251:	fc                   	cld    
80105252:	f3 ab                	rep stos %eax,%es:(%edi)
80105254:	89 ca                	mov    %ecx,%edx
80105256:	89 fb                	mov    %edi,%ebx
80105258:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010525b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010525e:	5b                   	pop    %ebx
8010525f:	5f                   	pop    %edi
80105260:	5d                   	pop    %ebp
80105261:	c3                   	ret    

80105262 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105262:	55                   	push   %ebp
80105263:	89 e5                	mov    %esp,%ebp
80105265:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105268:	8b 45 08             	mov    0x8(%ebp),%eax
8010526b:	83 e0 03             	and    $0x3,%eax
8010526e:	85 c0                	test   %eax,%eax
80105270:	75 49                	jne    801052bb <memset+0x59>
80105272:	8b 45 10             	mov    0x10(%ebp),%eax
80105275:	83 e0 03             	and    $0x3,%eax
80105278:	85 c0                	test   %eax,%eax
8010527a:	75 3f                	jne    801052bb <memset+0x59>
    c &= 0xFF;
8010527c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105283:	8b 45 10             	mov    0x10(%ebp),%eax
80105286:	c1 e8 02             	shr    $0x2,%eax
80105289:	89 c2                	mov    %eax,%edx
8010528b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010528e:	89 c1                	mov    %eax,%ecx
80105290:	c1 e1 18             	shl    $0x18,%ecx
80105293:	8b 45 0c             	mov    0xc(%ebp),%eax
80105296:	c1 e0 10             	shl    $0x10,%eax
80105299:	09 c1                	or     %eax,%ecx
8010529b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010529e:	c1 e0 08             	shl    $0x8,%eax
801052a1:	09 c8                	or     %ecx,%eax
801052a3:	0b 45 0c             	or     0xc(%ebp),%eax
801052a6:	89 54 24 08          	mov    %edx,0x8(%esp)
801052aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801052ae:	8b 45 08             	mov    0x8(%ebp),%eax
801052b1:	89 04 24             	mov    %eax,(%esp)
801052b4:	e8 84 ff ff ff       	call   8010523d <stosl>
801052b9:	eb 19                	jmp    801052d4 <memset+0x72>
  } else
    stosb(dst, c, n);
801052bb:	8b 45 10             	mov    0x10(%ebp),%eax
801052be:	89 44 24 08          	mov    %eax,0x8(%esp)
801052c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801052c9:	8b 45 08             	mov    0x8(%ebp),%eax
801052cc:	89 04 24             	mov    %eax,(%esp)
801052cf:	e8 44 ff ff ff       	call   80105218 <stosb>
  return dst;
801052d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052d7:	c9                   	leave  
801052d8:	c3                   	ret    

801052d9 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801052d9:	55                   	push   %ebp
801052da:	89 e5                	mov    %esp,%ebp
801052dc:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801052df:	8b 45 08             	mov    0x8(%ebp),%eax
801052e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801052e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801052eb:	eb 32                	jmp    8010531f <memcmp+0x46>
    if(*s1 != *s2)
801052ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052f0:	0f b6 10             	movzbl (%eax),%edx
801052f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052f6:	0f b6 00             	movzbl (%eax),%eax
801052f9:	38 c2                	cmp    %al,%dl
801052fb:	74 1a                	je     80105317 <memcmp+0x3e>
      return *s1 - *s2;
801052fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105300:	0f b6 00             	movzbl (%eax),%eax
80105303:	0f b6 d0             	movzbl %al,%edx
80105306:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105309:	0f b6 00             	movzbl (%eax),%eax
8010530c:	0f b6 c0             	movzbl %al,%eax
8010530f:	89 d1                	mov    %edx,%ecx
80105311:	29 c1                	sub    %eax,%ecx
80105313:	89 c8                	mov    %ecx,%eax
80105315:	eb 1c                	jmp    80105333 <memcmp+0x5a>
    s1++, s2++;
80105317:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010531b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010531f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105323:	0f 95 c0             	setne  %al
80105326:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010532a:	84 c0                	test   %al,%al
8010532c:	75 bf                	jne    801052ed <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
8010532e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105333:	c9                   	leave  
80105334:	c3                   	ret    

80105335 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105335:	55                   	push   %ebp
80105336:	89 e5                	mov    %esp,%ebp
80105338:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010533b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010533e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105341:	8b 45 08             	mov    0x8(%ebp),%eax
80105344:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105347:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010534a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010534d:	73 54                	jae    801053a3 <memmove+0x6e>
8010534f:	8b 45 10             	mov    0x10(%ebp),%eax
80105352:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105355:	01 d0                	add    %edx,%eax
80105357:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010535a:	76 47                	jbe    801053a3 <memmove+0x6e>
    s += n;
8010535c:	8b 45 10             	mov    0x10(%ebp),%eax
8010535f:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105362:	8b 45 10             	mov    0x10(%ebp),%eax
80105365:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105368:	eb 13                	jmp    8010537d <memmove+0x48>
      *--d = *--s;
8010536a:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010536e:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105372:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105375:	0f b6 10             	movzbl (%eax),%edx
80105378:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010537b:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010537d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105381:	0f 95 c0             	setne  %al
80105384:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105388:	84 c0                	test   %al,%al
8010538a:	75 de                	jne    8010536a <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010538c:	eb 25                	jmp    801053b3 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010538e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105391:	0f b6 10             	movzbl (%eax),%edx
80105394:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105397:	88 10                	mov    %dl,(%eax)
80105399:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010539d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053a1:	eb 01                	jmp    801053a4 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053a3:	90                   	nop
801053a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053a8:	0f 95 c0             	setne  %al
801053ab:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053af:	84 c0                	test   %al,%al
801053b1:	75 db                	jne    8010538e <memmove+0x59>
      *d++ = *s++;

  return dst;
801053b3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053b6:	c9                   	leave  
801053b7:	c3                   	ret    

801053b8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053b8:	55                   	push   %ebp
801053b9:	89 e5                	mov    %esp,%ebp
801053bb:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801053be:	8b 45 10             	mov    0x10(%ebp),%eax
801053c1:	89 44 24 08          	mov    %eax,0x8(%esp)
801053c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801053c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801053cc:	8b 45 08             	mov    0x8(%ebp),%eax
801053cf:	89 04 24             	mov    %eax,(%esp)
801053d2:	e8 5e ff ff ff       	call   80105335 <memmove>
}
801053d7:	c9                   	leave  
801053d8:	c3                   	ret    

801053d9 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801053d9:	55                   	push   %ebp
801053da:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801053dc:	eb 0c                	jmp    801053ea <strncmp+0x11>
    n--, p++, q++;
801053de:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053e2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801053e6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801053ea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053ee:	74 1a                	je     8010540a <strncmp+0x31>
801053f0:	8b 45 08             	mov    0x8(%ebp),%eax
801053f3:	0f b6 00             	movzbl (%eax),%eax
801053f6:	84 c0                	test   %al,%al
801053f8:	74 10                	je     8010540a <strncmp+0x31>
801053fa:	8b 45 08             	mov    0x8(%ebp),%eax
801053fd:	0f b6 10             	movzbl (%eax),%edx
80105400:	8b 45 0c             	mov    0xc(%ebp),%eax
80105403:	0f b6 00             	movzbl (%eax),%eax
80105406:	38 c2                	cmp    %al,%dl
80105408:	74 d4                	je     801053de <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010540a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010540e:	75 07                	jne    80105417 <strncmp+0x3e>
    return 0;
80105410:	b8 00 00 00 00       	mov    $0x0,%eax
80105415:	eb 18                	jmp    8010542f <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
80105417:	8b 45 08             	mov    0x8(%ebp),%eax
8010541a:	0f b6 00             	movzbl (%eax),%eax
8010541d:	0f b6 d0             	movzbl %al,%edx
80105420:	8b 45 0c             	mov    0xc(%ebp),%eax
80105423:	0f b6 00             	movzbl (%eax),%eax
80105426:	0f b6 c0             	movzbl %al,%eax
80105429:	89 d1                	mov    %edx,%ecx
8010542b:	29 c1                	sub    %eax,%ecx
8010542d:	89 c8                	mov    %ecx,%eax
}
8010542f:	5d                   	pop    %ebp
80105430:	c3                   	ret    

80105431 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105431:	55                   	push   %ebp
80105432:	89 e5                	mov    %esp,%ebp
80105434:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105437:	8b 45 08             	mov    0x8(%ebp),%eax
8010543a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010543d:	90                   	nop
8010543e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105442:	0f 9f c0             	setg   %al
80105445:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105449:	84 c0                	test   %al,%al
8010544b:	74 30                	je     8010547d <strncpy+0x4c>
8010544d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105450:	0f b6 10             	movzbl (%eax),%edx
80105453:	8b 45 08             	mov    0x8(%ebp),%eax
80105456:	88 10                	mov    %dl,(%eax)
80105458:	8b 45 08             	mov    0x8(%ebp),%eax
8010545b:	0f b6 00             	movzbl (%eax),%eax
8010545e:	84 c0                	test   %al,%al
80105460:	0f 95 c0             	setne  %al
80105463:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105467:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010546b:	84 c0                	test   %al,%al
8010546d:	75 cf                	jne    8010543e <strncpy+0xd>
    ;
  while(n-- > 0)
8010546f:	eb 0c                	jmp    8010547d <strncpy+0x4c>
    *s++ = 0;
80105471:	8b 45 08             	mov    0x8(%ebp),%eax
80105474:	c6 00 00             	movb   $0x0,(%eax)
80105477:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010547b:	eb 01                	jmp    8010547e <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010547d:	90                   	nop
8010547e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105482:	0f 9f c0             	setg   %al
80105485:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105489:	84 c0                	test   %al,%al
8010548b:	75 e4                	jne    80105471 <strncpy+0x40>
    *s++ = 0;
  return os;
8010548d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105490:	c9                   	leave  
80105491:	c3                   	ret    

80105492 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105492:	55                   	push   %ebp
80105493:	89 e5                	mov    %esp,%ebp
80105495:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105498:	8b 45 08             	mov    0x8(%ebp),%eax
8010549b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010549e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054a2:	7f 05                	jg     801054a9 <safestrcpy+0x17>
    return os;
801054a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054a7:	eb 35                	jmp    801054de <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801054a9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054b1:	7e 22                	jle    801054d5 <safestrcpy+0x43>
801054b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801054b6:	0f b6 10             	movzbl (%eax),%edx
801054b9:	8b 45 08             	mov    0x8(%ebp),%eax
801054bc:	88 10                	mov    %dl,(%eax)
801054be:	8b 45 08             	mov    0x8(%ebp),%eax
801054c1:	0f b6 00             	movzbl (%eax),%eax
801054c4:	84 c0                	test   %al,%al
801054c6:	0f 95 c0             	setne  %al
801054c9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801054cd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801054d1:	84 c0                	test   %al,%al
801054d3:	75 d4                	jne    801054a9 <safestrcpy+0x17>
    ;
  *s = 0;
801054d5:	8b 45 08             	mov    0x8(%ebp),%eax
801054d8:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801054db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054de:	c9                   	leave  
801054df:	c3                   	ret    

801054e0 <strlen>:

int
strlen(const char *s)
{
801054e0:	55                   	push   %ebp
801054e1:	89 e5                	mov    %esp,%ebp
801054e3:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801054e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054ed:	eb 04                	jmp    801054f3 <strlen+0x13>
801054ef:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054f6:	03 45 08             	add    0x8(%ebp),%eax
801054f9:	0f b6 00             	movzbl (%eax),%eax
801054fc:	84 c0                	test   %al,%al
801054fe:	75 ef                	jne    801054ef <strlen+0xf>
    ;
  return n;
80105500:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105503:	c9                   	leave  
80105504:	c3                   	ret    
80105505:	00 00                	add    %al,(%eax)
	...

80105508 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105508:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010550c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105510:	55                   	push   %ebp
  pushl %ebx
80105511:	53                   	push   %ebx
  pushl %esi
80105512:	56                   	push   %esi
  pushl %edi
80105513:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105514:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105516:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105518:	5f                   	pop    %edi
  popl %esi
80105519:	5e                   	pop    %esi
  popl %ebx
8010551a:	5b                   	pop    %ebx
  popl %ebp
8010551b:	5d                   	pop    %ebp
  ret
8010551c:	c3                   	ret    
8010551d:	00 00                	add    %al,(%eax)
	...

80105520 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105520:	55                   	push   %ebp
80105521:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105523:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105529:	8b 00                	mov    (%eax),%eax
8010552b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010552e:	76 12                	jbe    80105542 <fetchint+0x22>
80105530:	8b 45 08             	mov    0x8(%ebp),%eax
80105533:	8d 50 04             	lea    0x4(%eax),%edx
80105536:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010553c:	8b 00                	mov    (%eax),%eax
8010553e:	39 c2                	cmp    %eax,%edx
80105540:	76 07                	jbe    80105549 <fetchint+0x29>
    return -1;
80105542:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105547:	eb 0f                	jmp    80105558 <fetchint+0x38>
  *ip = *(int*)(addr);
80105549:	8b 45 08             	mov    0x8(%ebp),%eax
8010554c:	8b 10                	mov    (%eax),%edx
8010554e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105551:	89 10                	mov    %edx,(%eax)
  return 0;
80105553:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105558:	5d                   	pop    %ebp
80105559:	c3                   	ret    

8010555a <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010555a:	55                   	push   %ebp
8010555b:	89 e5                	mov    %esp,%ebp
8010555d:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105560:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105566:	8b 00                	mov    (%eax),%eax
80105568:	3b 45 08             	cmp    0x8(%ebp),%eax
8010556b:	77 07                	ja     80105574 <fetchstr+0x1a>
    return -1;
8010556d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105572:	eb 48                	jmp    801055bc <fetchstr+0x62>
  *pp = (char*)addr;
80105574:	8b 55 08             	mov    0x8(%ebp),%edx
80105577:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557a:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010557c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105582:	8b 00                	mov    (%eax),%eax
80105584:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105587:	8b 45 0c             	mov    0xc(%ebp),%eax
8010558a:	8b 00                	mov    (%eax),%eax
8010558c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010558f:	eb 1e                	jmp    801055af <fetchstr+0x55>
    if(*s == 0)
80105591:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105594:	0f b6 00             	movzbl (%eax),%eax
80105597:	84 c0                	test   %al,%al
80105599:	75 10                	jne    801055ab <fetchstr+0x51>
      return s - *pp;
8010559b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010559e:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a1:	8b 00                	mov    (%eax),%eax
801055a3:	89 d1                	mov    %edx,%ecx
801055a5:	29 c1                	sub    %eax,%ecx
801055a7:	89 c8                	mov    %ecx,%eax
801055a9:	eb 11                	jmp    801055bc <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801055ab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055b5:	72 da                	jb     80105591 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801055b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055bc:	c9                   	leave  
801055bd:	c3                   	ret    

801055be <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055be:	55                   	push   %ebp
801055bf:	89 e5                	mov    %esp,%ebp
801055c1:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801055c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055ca:	8b 40 18             	mov    0x18(%eax),%eax
801055cd:	8b 50 44             	mov    0x44(%eax),%edx
801055d0:	8b 45 08             	mov    0x8(%ebp),%eax
801055d3:	c1 e0 02             	shl    $0x2,%eax
801055d6:	01 d0                	add    %edx,%eax
801055d8:	8d 50 04             	lea    0x4(%eax),%edx
801055db:	8b 45 0c             	mov    0xc(%ebp),%eax
801055de:	89 44 24 04          	mov    %eax,0x4(%esp)
801055e2:	89 14 24             	mov    %edx,(%esp)
801055e5:	e8 36 ff ff ff       	call   80105520 <fetchint>
}
801055ea:	c9                   	leave  
801055eb:	c3                   	ret    

801055ec <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801055ec:	55                   	push   %ebp
801055ed:	89 e5                	mov    %esp,%ebp
801055ef:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801055f2:	8d 45 fc             	lea    -0x4(%ebp),%eax
801055f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801055f9:	8b 45 08             	mov    0x8(%ebp),%eax
801055fc:	89 04 24             	mov    %eax,(%esp)
801055ff:	e8 ba ff ff ff       	call   801055be <argint>
80105604:	85 c0                	test   %eax,%eax
80105606:	79 07                	jns    8010560f <argptr+0x23>
    return -1;
80105608:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010560d:	eb 3d                	jmp    8010564c <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010560f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105612:	89 c2                	mov    %eax,%edx
80105614:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010561a:	8b 00                	mov    (%eax),%eax
8010561c:	39 c2                	cmp    %eax,%edx
8010561e:	73 16                	jae    80105636 <argptr+0x4a>
80105620:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105623:	89 c2                	mov    %eax,%edx
80105625:	8b 45 10             	mov    0x10(%ebp),%eax
80105628:	01 c2                	add    %eax,%edx
8010562a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105630:	8b 00                	mov    (%eax),%eax
80105632:	39 c2                	cmp    %eax,%edx
80105634:	76 07                	jbe    8010563d <argptr+0x51>
    return -1;
80105636:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010563b:	eb 0f                	jmp    8010564c <argptr+0x60>
  *pp = (char*)i;
8010563d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105640:	89 c2                	mov    %eax,%edx
80105642:	8b 45 0c             	mov    0xc(%ebp),%eax
80105645:	89 10                	mov    %edx,(%eax)
  return 0;
80105647:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010564c:	c9                   	leave  
8010564d:	c3                   	ret    

8010564e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010564e:	55                   	push   %ebp
8010564f:	89 e5                	mov    %esp,%ebp
80105651:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105654:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105657:	89 44 24 04          	mov    %eax,0x4(%esp)
8010565b:	8b 45 08             	mov    0x8(%ebp),%eax
8010565e:	89 04 24             	mov    %eax,(%esp)
80105661:	e8 58 ff ff ff       	call   801055be <argint>
80105666:	85 c0                	test   %eax,%eax
80105668:	79 07                	jns    80105671 <argstr+0x23>
    return -1;
8010566a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010566f:	eb 12                	jmp    80105683 <argstr+0x35>
  return fetchstr(addr, pp);
80105671:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105674:	8b 55 0c             	mov    0xc(%ebp),%edx
80105677:	89 54 24 04          	mov    %edx,0x4(%esp)
8010567b:	89 04 24             	mov    %eax,(%esp)
8010567e:	e8 d7 fe ff ff       	call   8010555a <fetchstr>
}
80105683:	c9                   	leave  
80105684:	c3                   	ret    

80105685 <syscall>:
[SYS_waitpid]    sys_waitpid,
};

void
syscall(void)
{
80105685:	55                   	push   %ebp
80105686:	89 e5                	mov    %esp,%ebp
80105688:	53                   	push   %ebx
80105689:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
8010568c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105692:	8b 40 18             	mov    0x18(%eax),%eax
80105695:	8b 40 1c             	mov    0x1c(%eax),%eax
80105698:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010569b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010569f:	7e 30                	jle    801056d1 <syscall+0x4c>
801056a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a4:	83 f8 16             	cmp    $0x16,%eax
801056a7:	77 28                	ja     801056d1 <syscall+0x4c>
801056a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ac:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056b3:	85 c0                	test   %eax,%eax
801056b5:	74 1a                	je     801056d1 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801056b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056bd:	8b 58 18             	mov    0x18(%eax),%ebx
801056c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c3:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056ca:	ff d0                	call   *%eax
801056cc:	89 43 1c             	mov    %eax,0x1c(%ebx)
801056cf:	eb 3d                	jmp    8010570e <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801056d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d7:	8d 48 6c             	lea    0x6c(%eax),%ecx
801056da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801056e0:	8b 40 10             	mov    0x10(%eax),%eax
801056e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
801056ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801056ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801056f2:	c7 04 24 bb 8a 10 80 	movl   $0x80108abb,(%esp)
801056f9:	e8 a3 ac ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801056fe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105704:	8b 40 18             	mov    0x18(%eax),%eax
80105707:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010570e:	83 c4 24             	add    $0x24,%esp
80105711:	5b                   	pop    %ebx
80105712:	5d                   	pop    %ebp
80105713:	c3                   	ret    

80105714 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105714:	55                   	push   %ebp
80105715:	89 e5                	mov    %esp,%ebp
80105717:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010571a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010571d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105721:	8b 45 08             	mov    0x8(%ebp),%eax
80105724:	89 04 24             	mov    %eax,(%esp)
80105727:	e8 92 fe ff ff       	call   801055be <argint>
8010572c:	85 c0                	test   %eax,%eax
8010572e:	79 07                	jns    80105737 <argfd+0x23>
    return -1;
80105730:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105735:	eb 50                	jmp    80105787 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105737:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010573a:	85 c0                	test   %eax,%eax
8010573c:	78 21                	js     8010575f <argfd+0x4b>
8010573e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105741:	83 f8 0f             	cmp    $0xf,%eax
80105744:	7f 19                	jg     8010575f <argfd+0x4b>
80105746:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010574c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010574f:	83 c2 08             	add    $0x8,%edx
80105752:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105756:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105759:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010575d:	75 07                	jne    80105766 <argfd+0x52>
    return -1;
8010575f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105764:	eb 21                	jmp    80105787 <argfd+0x73>
  if(pfd)
80105766:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010576a:	74 08                	je     80105774 <argfd+0x60>
    *pfd = fd;
8010576c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010576f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105772:	89 10                	mov    %edx,(%eax)
  if(pf)
80105774:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105778:	74 08                	je     80105782 <argfd+0x6e>
    *pf = f;
8010577a:	8b 45 10             	mov    0x10(%ebp),%eax
8010577d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105780:	89 10                	mov    %edx,(%eax)
  return 0;
80105782:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105787:	c9                   	leave  
80105788:	c3                   	ret    

80105789 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105789:	55                   	push   %ebp
8010578a:	89 e5                	mov    %esp,%ebp
8010578c:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010578f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105796:	eb 30                	jmp    801057c8 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105798:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010579e:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057a1:	83 c2 08             	add    $0x8,%edx
801057a4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057a8:	85 c0                	test   %eax,%eax
801057aa:	75 18                	jne    801057c4 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057ac:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057b5:	8d 4a 08             	lea    0x8(%edx),%ecx
801057b8:	8b 55 08             	mov    0x8(%ebp),%edx
801057bb:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057c2:	eb 0f                	jmp    801057d3 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057c4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057c8:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057cc:	7e ca                	jle    80105798 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801057ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057d3:	c9                   	leave  
801057d4:	c3                   	ret    

801057d5 <sys_dup>:

int
sys_dup(void)
{
801057d5:	55                   	push   %ebp
801057d6:	89 e5                	mov    %esp,%ebp
801057d8:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801057db:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057de:	89 44 24 08          	mov    %eax,0x8(%esp)
801057e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801057e9:	00 
801057ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057f1:	e8 1e ff ff ff       	call   80105714 <argfd>
801057f6:	85 c0                	test   %eax,%eax
801057f8:	79 07                	jns    80105801 <sys_dup+0x2c>
    return -1;
801057fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ff:	eb 29                	jmp    8010582a <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105801:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105804:	89 04 24             	mov    %eax,(%esp)
80105807:	e8 7d ff ff ff       	call   80105789 <fdalloc>
8010580c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010580f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105813:	79 07                	jns    8010581c <sys_dup+0x47>
    return -1;
80105815:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010581a:	eb 0e                	jmp    8010582a <sys_dup+0x55>
  filedup(f);
8010581c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581f:	89 04 24             	mov    %eax,(%esp)
80105822:	e8 61 b7 ff ff       	call   80100f88 <filedup>
  return fd;
80105827:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010582a:	c9                   	leave  
8010582b:	c3                   	ret    

8010582c <sys_read>:

int
sys_read(void)
{
8010582c:	55                   	push   %ebp
8010582d:	89 e5                	mov    %esp,%ebp
8010582f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105832:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105835:	89 44 24 08          	mov    %eax,0x8(%esp)
80105839:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105840:	00 
80105841:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105848:	e8 c7 fe ff ff       	call   80105714 <argfd>
8010584d:	85 c0                	test   %eax,%eax
8010584f:	78 35                	js     80105886 <sys_read+0x5a>
80105851:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105854:	89 44 24 04          	mov    %eax,0x4(%esp)
80105858:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010585f:	e8 5a fd ff ff       	call   801055be <argint>
80105864:	85 c0                	test   %eax,%eax
80105866:	78 1e                	js     80105886 <sys_read+0x5a>
80105868:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010586f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105872:	89 44 24 04          	mov    %eax,0x4(%esp)
80105876:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010587d:	e8 6a fd ff ff       	call   801055ec <argptr>
80105882:	85 c0                	test   %eax,%eax
80105884:	79 07                	jns    8010588d <sys_read+0x61>
    return -1;
80105886:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010588b:	eb 19                	jmp    801058a6 <sys_read+0x7a>
  return fileread(f, p, n);
8010588d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105890:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105896:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010589a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010589e:	89 04 24             	mov    %eax,(%esp)
801058a1:	e8 4f b8 ff ff       	call   801010f5 <fileread>
}
801058a6:	c9                   	leave  
801058a7:	c3                   	ret    

801058a8 <sys_write>:

int
sys_write(void)
{
801058a8:	55                   	push   %ebp
801058a9:	89 e5                	mov    %esp,%ebp
801058ab:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058b1:	89 44 24 08          	mov    %eax,0x8(%esp)
801058b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058bc:	00 
801058bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058c4:	e8 4b fe ff ff       	call   80105714 <argfd>
801058c9:	85 c0                	test   %eax,%eax
801058cb:	78 35                	js     80105902 <sys_write+0x5a>
801058cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801058d4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801058db:	e8 de fc ff ff       	call   801055be <argint>
801058e0:	85 c0                	test   %eax,%eax
801058e2:	78 1e                	js     80105902 <sys_write+0x5a>
801058e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e7:	89 44 24 08          	mov    %eax,0x8(%esp)
801058eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801058f9:	e8 ee fc ff ff       	call   801055ec <argptr>
801058fe:	85 c0                	test   %eax,%eax
80105900:	79 07                	jns    80105909 <sys_write+0x61>
    return -1;
80105902:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105907:	eb 19                	jmp    80105922 <sys_write+0x7a>
  return filewrite(f, p, n);
80105909:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010590c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010590f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105912:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105916:	89 54 24 04          	mov    %edx,0x4(%esp)
8010591a:	89 04 24             	mov    %eax,(%esp)
8010591d:	e8 8f b8 ff ff       	call   801011b1 <filewrite>
}
80105922:	c9                   	leave  
80105923:	c3                   	ret    

80105924 <sys_close>:

int
sys_close(void)
{
80105924:	55                   	push   %ebp
80105925:	89 e5                	mov    %esp,%ebp
80105927:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010592a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010592d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105931:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105934:	89 44 24 04          	mov    %eax,0x4(%esp)
80105938:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010593f:	e8 d0 fd ff ff       	call   80105714 <argfd>
80105944:	85 c0                	test   %eax,%eax
80105946:	79 07                	jns    8010594f <sys_close+0x2b>
    return -1;
80105948:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594d:	eb 24                	jmp    80105973 <sys_close+0x4f>
  proc->ofile[fd] = 0;
8010594f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105955:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105958:	83 c2 08             	add    $0x8,%edx
8010595b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105962:	00 
  fileclose(f);
80105963:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105966:	89 04 24             	mov    %eax,(%esp)
80105969:	e8 62 b6 ff ff       	call   80100fd0 <fileclose>
  return 0;
8010596e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105973:	c9                   	leave  
80105974:	c3                   	ret    

80105975 <sys_fstat>:

int
sys_fstat(void)
{
80105975:	55                   	push   %ebp
80105976:	89 e5                	mov    %esp,%ebp
80105978:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010597b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010597e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105982:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105989:	00 
8010598a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105991:	e8 7e fd ff ff       	call   80105714 <argfd>
80105996:	85 c0                	test   %eax,%eax
80105998:	78 1f                	js     801059b9 <sys_fstat+0x44>
8010599a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801059a1:	00 
801059a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801059a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059b0:	e8 37 fc ff ff       	call   801055ec <argptr>
801059b5:	85 c0                	test   %eax,%eax
801059b7:	79 07                	jns    801059c0 <sys_fstat+0x4b>
    return -1;
801059b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059be:	eb 12                	jmp    801059d2 <sys_fstat+0x5d>
  return filestat(f, st);
801059c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801059ca:	89 04 24             	mov    %eax,(%esp)
801059cd:	e8 d4 b6 ff ff       	call   801010a6 <filestat>
}
801059d2:	c9                   	leave  
801059d3:	c3                   	ret    

801059d4 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059d4:	55                   	push   %ebp
801059d5:	89 e5                	mov    %esp,%ebp
801059d7:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059da:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801059e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059e8:	e8 61 fc ff ff       	call   8010564e <argstr>
801059ed:	85 c0                	test   %eax,%eax
801059ef:	78 17                	js     80105a08 <sys_link+0x34>
801059f1:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801059f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059ff:	e8 4a fc ff ff       	call   8010564e <argstr>
80105a04:	85 c0                	test   %eax,%eax
80105a06:	79 0a                	jns    80105a12 <sys_link+0x3e>
    return -1;
80105a08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a0d:	e9 41 01 00 00       	jmp    80105b53 <sys_link+0x17f>

  begin_op();
80105a12:	e8 4a da ff ff       	call   80103461 <begin_op>
  if((ip = namei(old)) == 0){
80105a17:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a1a:	89 04 24             	mov    %eax,(%esp)
80105a1d:	e8 f4 c9 ff ff       	call   80102416 <namei>
80105a22:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a25:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a29:	75 0f                	jne    80105a3a <sys_link+0x66>
    end_op();
80105a2b:	e8 b2 da ff ff       	call   801034e2 <end_op>
    return -1;
80105a30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a35:	e9 19 01 00 00       	jmp    80105b53 <sys_link+0x17f>
  }

  ilock(ip);
80105a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3d:	89 04 24             	mov    %eax,(%esp)
80105a40:	e8 2f be ff ff       	call   80101874 <ilock>
  if(ip->type == T_DIR){
80105a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a48:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a4c:	66 83 f8 01          	cmp    $0x1,%ax
80105a50:	75 1a                	jne    80105a6c <sys_link+0x98>
    iunlockput(ip);
80105a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a55:	89 04 24             	mov    %eax,(%esp)
80105a58:	e8 9b c0 ff ff       	call   80101af8 <iunlockput>
    end_op();
80105a5d:	e8 80 da ff ff       	call   801034e2 <end_op>
    return -1;
80105a62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a67:	e9 e7 00 00 00       	jmp    80105b53 <sys_link+0x17f>
  }

  ip->nlink++;
80105a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a73:	8d 50 01             	lea    0x1(%eax),%edx
80105a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a79:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a80:	89 04 24             	mov    %eax,(%esp)
80105a83:	e8 30 bc ff ff       	call   801016b8 <iupdate>
  iunlock(ip);
80105a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8b:	89 04 24             	mov    %eax,(%esp)
80105a8e:	e8 2f bf ff ff       	call   801019c2 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105a93:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a96:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a99:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a9d:	89 04 24             	mov    %eax,(%esp)
80105aa0:	e8 93 c9 ff ff       	call   80102438 <nameiparent>
80105aa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105aa8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105aac:	74 68                	je     80105b16 <sys_link+0x142>
    goto bad;
  ilock(dp);
80105aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab1:	89 04 24             	mov    %eax,(%esp)
80105ab4:	e8 bb bd ff ff       	call   80101874 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abc:	8b 10                	mov    (%eax),%edx
80105abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac1:	8b 00                	mov    (%eax),%eax
80105ac3:	39 c2                	cmp    %eax,%edx
80105ac5:	75 20                	jne    80105ae7 <sys_link+0x113>
80105ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aca:	8b 40 04             	mov    0x4(%eax),%eax
80105acd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ad1:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105adb:	89 04 24             	mov    %eax,(%esp)
80105ade:	e8 72 c6 ff ff       	call   80102155 <dirlink>
80105ae3:	85 c0                	test   %eax,%eax
80105ae5:	79 0d                	jns    80105af4 <sys_link+0x120>
    iunlockput(dp);
80105ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aea:	89 04 24             	mov    %eax,(%esp)
80105aed:	e8 06 c0 ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105af2:	eb 23                	jmp    80105b17 <sys_link+0x143>
  }
  iunlockput(dp);
80105af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af7:	89 04 24             	mov    %eax,(%esp)
80105afa:	e8 f9 bf ff ff       	call   80101af8 <iunlockput>
  iput(ip);
80105aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b02:	89 04 24             	mov    %eax,(%esp)
80105b05:	e8 1d bf ff ff       	call   80101a27 <iput>

  end_op();
80105b0a:	e8 d3 d9 ff ff       	call   801034e2 <end_op>

  return 0;
80105b0f:	b8 00 00 00 00       	mov    $0x0,%eax
80105b14:	eb 3d                	jmp    80105b53 <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105b16:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1a:	89 04 24             	mov    %eax,(%esp)
80105b1d:	e8 52 bd ff ff       	call   80101874 <ilock>
  ip->nlink--;
80105b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b25:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b29:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2f:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b36:	89 04 24             	mov    %eax,(%esp)
80105b39:	e8 7a bb ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
80105b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b41:	89 04 24             	mov    %eax,(%esp)
80105b44:	e8 af bf ff ff       	call   80101af8 <iunlockput>
  end_op();
80105b49:	e8 94 d9 ff ff       	call   801034e2 <end_op>
  return -1;
80105b4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b53:	c9                   	leave  
80105b54:	c3                   	ret    

80105b55 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b55:	55                   	push   %ebp
80105b56:	89 e5                	mov    %esp,%ebp
80105b58:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b5b:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b62:	eb 4b                	jmp    80105baf <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b67:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b6e:	00 
80105b6f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b73:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b76:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b7d:	89 04 24             	mov    %eax,(%esp)
80105b80:	e8 e5 c1 ff ff       	call   80101d6a <readi>
80105b85:	83 f8 10             	cmp    $0x10,%eax
80105b88:	74 0c                	je     80105b96 <isdirempty+0x41>
      panic("isdirempty: readi");
80105b8a:	c7 04 24 d7 8a 10 80 	movl   $0x80108ad7,(%esp)
80105b91:	e8 a7 a9 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105b96:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b9a:	66 85 c0             	test   %ax,%ax
80105b9d:	74 07                	je     80105ba6 <isdirempty+0x51>
      return 0;
80105b9f:	b8 00 00 00 00       	mov    $0x0,%eax
80105ba4:	eb 1b                	jmp    80105bc1 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba9:	83 c0 10             	add    $0x10,%eax
80105bac:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105baf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb5:	8b 40 18             	mov    0x18(%eax),%eax
80105bb8:	39 c2                	cmp    %eax,%edx
80105bba:	72 a8                	jb     80105b64 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105bbc:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bc1:	c9                   	leave  
80105bc2:	c3                   	ret    

80105bc3 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bc3:	55                   	push   %ebp
80105bc4:	89 e5                	mov    %esp,%ebp
80105bc6:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bc9:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bd7:	e8 72 fa ff ff       	call   8010564e <argstr>
80105bdc:	85 c0                	test   %eax,%eax
80105bde:	79 0a                	jns    80105bea <sys_unlink+0x27>
    return -1;
80105be0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be5:	e9 af 01 00 00       	jmp    80105d99 <sys_unlink+0x1d6>

  begin_op();
80105bea:	e8 72 d8 ff ff       	call   80103461 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105bef:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105bf2:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105bf5:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bf9:	89 04 24             	mov    %eax,(%esp)
80105bfc:	e8 37 c8 ff ff       	call   80102438 <nameiparent>
80105c01:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c08:	75 0f                	jne    80105c19 <sys_unlink+0x56>
    end_op();
80105c0a:	e8 d3 d8 ff ff       	call   801034e2 <end_op>
    return -1;
80105c0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c14:	e9 80 01 00 00       	jmp    80105d99 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1c:	89 04 24             	mov    %eax,(%esp)
80105c1f:	e8 50 bc ff ff       	call   80101874 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c24:	c7 44 24 04 e9 8a 10 	movl   $0x80108ae9,0x4(%esp)
80105c2b:	80 
80105c2c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c2f:	89 04 24             	mov    %eax,(%esp)
80105c32:	e8 34 c4 ff ff       	call   8010206b <namecmp>
80105c37:	85 c0                	test   %eax,%eax
80105c39:	0f 84 45 01 00 00    	je     80105d84 <sys_unlink+0x1c1>
80105c3f:	c7 44 24 04 eb 8a 10 	movl   $0x80108aeb,0x4(%esp)
80105c46:	80 
80105c47:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c4a:	89 04 24             	mov    %eax,(%esp)
80105c4d:	e8 19 c4 ff ff       	call   8010206b <namecmp>
80105c52:	85 c0                	test   %eax,%eax
80105c54:	0f 84 2a 01 00 00    	je     80105d84 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c5a:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c5d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c61:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c64:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6b:	89 04 24             	mov    %eax,(%esp)
80105c6e:	e8 1a c4 ff ff       	call   8010208d <dirlookup>
80105c73:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c76:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c7a:	0f 84 03 01 00 00    	je     80105d83 <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
80105c80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c83:	89 04 24             	mov    %eax,(%esp)
80105c86:	e8 e9 bb ff ff       	call   80101874 <ilock>

  if(ip->nlink < 1)
80105c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c92:	66 85 c0             	test   %ax,%ax
80105c95:	7f 0c                	jg     80105ca3 <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
80105c97:	c7 04 24 ee 8a 10 80 	movl   $0x80108aee,(%esp)
80105c9e:	e8 9a a8 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105caa:	66 83 f8 01          	cmp    $0x1,%ax
80105cae:	75 1f                	jne    80105ccf <sys_unlink+0x10c>
80105cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb3:	89 04 24             	mov    %eax,(%esp)
80105cb6:	e8 9a fe ff ff       	call   80105b55 <isdirempty>
80105cbb:	85 c0                	test   %eax,%eax
80105cbd:	75 10                	jne    80105ccf <sys_unlink+0x10c>
    iunlockput(ip);
80105cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc2:	89 04 24             	mov    %eax,(%esp)
80105cc5:	e8 2e be ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105cca:	e9 b5 00 00 00       	jmp    80105d84 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105ccf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105cd6:	00 
80105cd7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cde:	00 
80105cdf:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105ce2:	89 04 24             	mov    %eax,(%esp)
80105ce5:	e8 78 f5 ff ff       	call   80105262 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cea:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ced:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105cf4:	00 
80105cf5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cf9:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d03:	89 04 24             	mov    %eax,(%esp)
80105d06:	e8 ca c1 ff ff       	call   80101ed5 <writei>
80105d0b:	83 f8 10             	cmp    $0x10,%eax
80105d0e:	74 0c                	je     80105d1c <sys_unlink+0x159>
    panic("unlink: writei");
80105d10:	c7 04 24 00 8b 10 80 	movl   $0x80108b00,(%esp)
80105d17:	e8 21 a8 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d23:	66 83 f8 01          	cmp    $0x1,%ax
80105d27:	75 1c                	jne    80105d45 <sys_unlink+0x182>
    dp->nlink--;
80105d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d30:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d36:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3d:	89 04 24             	mov    %eax,(%esp)
80105d40:	e8 73 b9 ff ff       	call   801016b8 <iupdate>
  }
  iunlockput(dp);
80105d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d48:	89 04 24             	mov    %eax,(%esp)
80105d4b:	e8 a8 bd ff ff       	call   80101af8 <iunlockput>

  ip->nlink--;
80105d50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d53:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d57:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d64:	89 04 24             	mov    %eax,(%esp)
80105d67:	e8 4c b9 ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
80105d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6f:	89 04 24             	mov    %eax,(%esp)
80105d72:	e8 81 bd ff ff       	call   80101af8 <iunlockput>

  end_op();
80105d77:	e8 66 d7 ff ff       	call   801034e2 <end_op>

  return 0;
80105d7c:	b8 00 00 00 00       	mov    $0x0,%eax
80105d81:	eb 16                	jmp    80105d99 <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105d83:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d87:	89 04 24             	mov    %eax,(%esp)
80105d8a:	e8 69 bd ff ff       	call   80101af8 <iunlockput>
  end_op();
80105d8f:	e8 4e d7 ff ff       	call   801034e2 <end_op>
  return -1;
80105d94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d99:	c9                   	leave  
80105d9a:	c3                   	ret    

80105d9b <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d9b:	55                   	push   %ebp
80105d9c:	89 e5                	mov    %esp,%ebp
80105d9e:	83 ec 48             	sub    $0x48,%esp
80105da1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105da4:	8b 55 10             	mov    0x10(%ebp),%edx
80105da7:	8b 45 14             	mov    0x14(%ebp),%eax
80105daa:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105dae:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105db2:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105db6:	8d 45 de             	lea    -0x22(%ebp),%eax
80105db9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dbd:	8b 45 08             	mov    0x8(%ebp),%eax
80105dc0:	89 04 24             	mov    %eax,(%esp)
80105dc3:	e8 70 c6 ff ff       	call   80102438 <nameiparent>
80105dc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dcb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dcf:	75 0a                	jne    80105ddb <create+0x40>
    return 0;
80105dd1:	b8 00 00 00 00       	mov    $0x0,%eax
80105dd6:	e9 7e 01 00 00       	jmp    80105f59 <create+0x1be>
  ilock(dp);
80105ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dde:	89 04 24             	mov    %eax,(%esp)
80105de1:	e8 8e ba ff ff       	call   80101874 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105de6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105de9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ded:	8d 45 de             	lea    -0x22(%ebp),%eax
80105df0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df7:	89 04 24             	mov    %eax,(%esp)
80105dfa:	e8 8e c2 ff ff       	call   8010208d <dirlookup>
80105dff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e06:	74 47                	je     80105e4f <create+0xb4>
    iunlockput(dp);
80105e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0b:	89 04 24             	mov    %eax,(%esp)
80105e0e:	e8 e5 bc ff ff       	call   80101af8 <iunlockput>
    ilock(ip);
80105e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e16:	89 04 24             	mov    %eax,(%esp)
80105e19:	e8 56 ba ff ff       	call   80101874 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105e1e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e23:	75 15                	jne    80105e3a <create+0x9f>
80105e25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e28:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e2c:	66 83 f8 02          	cmp    $0x2,%ax
80105e30:	75 08                	jne    80105e3a <create+0x9f>
      return ip;
80105e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e35:	e9 1f 01 00 00       	jmp    80105f59 <create+0x1be>
    iunlockput(ip);
80105e3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e3d:	89 04 24             	mov    %eax,(%esp)
80105e40:	e8 b3 bc ff ff       	call   80101af8 <iunlockput>
    return 0;
80105e45:	b8 00 00 00 00       	mov    $0x0,%eax
80105e4a:	e9 0a 01 00 00       	jmp    80105f59 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e4f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e56:	8b 00                	mov    (%eax),%eax
80105e58:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e5c:	89 04 24             	mov    %eax,(%esp)
80105e5f:	e8 77 b7 ff ff       	call   801015db <ialloc>
80105e64:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e6b:	75 0c                	jne    80105e79 <create+0xde>
    panic("create: ialloc");
80105e6d:	c7 04 24 0f 8b 10 80 	movl   $0x80108b0f,(%esp)
80105e74:	e8 c4 a6 ff ff       	call   8010053d <panic>

  ilock(ip);
80105e79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7c:	89 04 24             	mov    %eax,(%esp)
80105e7f:	e8 f0 b9 ff ff       	call   80101874 <ilock>
  ip->major = major;
80105e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e87:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e8b:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105e8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e92:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e96:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9d:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea6:	89 04 24             	mov    %eax,(%esp)
80105ea9:	e8 0a b8 ff ff       	call   801016b8 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105eae:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105eb3:	75 6a                	jne    80105f1f <create+0x184>
    dp->nlink++;  // for ".."
80105eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ebc:	8d 50 01             	lea    0x1(%eax),%edx
80105ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec2:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec9:	89 04 24             	mov    %eax,(%esp)
80105ecc:	e8 e7 b7 ff ff       	call   801016b8 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ed1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed4:	8b 40 04             	mov    0x4(%eax),%eax
80105ed7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105edb:	c7 44 24 04 e9 8a 10 	movl   $0x80108ae9,0x4(%esp)
80105ee2:	80 
80105ee3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee6:	89 04 24             	mov    %eax,(%esp)
80105ee9:	e8 67 c2 ff ff       	call   80102155 <dirlink>
80105eee:	85 c0                	test   %eax,%eax
80105ef0:	78 21                	js     80105f13 <create+0x178>
80105ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef5:	8b 40 04             	mov    0x4(%eax),%eax
80105ef8:	89 44 24 08          	mov    %eax,0x8(%esp)
80105efc:	c7 44 24 04 eb 8a 10 	movl   $0x80108aeb,0x4(%esp)
80105f03:	80 
80105f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f07:	89 04 24             	mov    %eax,(%esp)
80105f0a:	e8 46 c2 ff ff       	call   80102155 <dirlink>
80105f0f:	85 c0                	test   %eax,%eax
80105f11:	79 0c                	jns    80105f1f <create+0x184>
      panic("create dots");
80105f13:	c7 04 24 1e 8b 10 80 	movl   $0x80108b1e,(%esp)
80105f1a:	e8 1e a6 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f22:	8b 40 04             	mov    0x4(%eax),%eax
80105f25:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f29:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f33:	89 04 24             	mov    %eax,(%esp)
80105f36:	e8 1a c2 ff ff       	call   80102155 <dirlink>
80105f3b:	85 c0                	test   %eax,%eax
80105f3d:	79 0c                	jns    80105f4b <create+0x1b0>
    panic("create: dirlink");
80105f3f:	c7 04 24 2a 8b 10 80 	movl   $0x80108b2a,(%esp)
80105f46:	e8 f2 a5 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80105f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4e:	89 04 24             	mov    %eax,(%esp)
80105f51:	e8 a2 bb ff ff       	call   80101af8 <iunlockput>

  return ip;
80105f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f59:	c9                   	leave  
80105f5a:	c3                   	ret    

80105f5b <sys_open>:

int
sys_open(void)
{
80105f5b:	55                   	push   %ebp
80105f5c:	89 e5                	mov    %esp,%ebp
80105f5e:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f61:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f64:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f6f:	e8 da f6 ff ff       	call   8010564e <argstr>
80105f74:	85 c0                	test   %eax,%eax
80105f76:	78 17                	js     80105f8f <sys_open+0x34>
80105f78:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f7f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f86:	e8 33 f6 ff ff       	call   801055be <argint>
80105f8b:	85 c0                	test   %eax,%eax
80105f8d:	79 0a                	jns    80105f99 <sys_open+0x3e>
    return -1;
80105f8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f94:	e9 5a 01 00 00       	jmp    801060f3 <sys_open+0x198>

  begin_op();
80105f99:	e8 c3 d4 ff ff       	call   80103461 <begin_op>

  if(omode & O_CREATE){
80105f9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fa1:	25 00 02 00 00       	and    $0x200,%eax
80105fa6:	85 c0                	test   %eax,%eax
80105fa8:	74 3b                	je     80105fe5 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105faa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105fb4:	00 
80105fb5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105fbc:	00 
80105fbd:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105fc4:	00 
80105fc5:	89 04 24             	mov    %eax,(%esp)
80105fc8:	e8 ce fd ff ff       	call   80105d9b <create>
80105fcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105fd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fd4:	75 6b                	jne    80106041 <sys_open+0xe6>
      end_op();
80105fd6:	e8 07 d5 ff ff       	call   801034e2 <end_op>
      return -1;
80105fdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fe0:	e9 0e 01 00 00       	jmp    801060f3 <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
80105fe5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fe8:	89 04 24             	mov    %eax,(%esp)
80105feb:	e8 26 c4 ff ff       	call   80102416 <namei>
80105ff0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ff3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ff7:	75 0f                	jne    80106008 <sys_open+0xad>
      end_op();
80105ff9:	e8 e4 d4 ff ff       	call   801034e2 <end_op>
      return -1;
80105ffe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106003:	e9 eb 00 00 00       	jmp    801060f3 <sys_open+0x198>
    }
    ilock(ip);
80106008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010600b:	89 04 24             	mov    %eax,(%esp)
8010600e:	e8 61 b8 ff ff       	call   80101874 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106016:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010601a:	66 83 f8 01          	cmp    $0x1,%ax
8010601e:	75 21                	jne    80106041 <sys_open+0xe6>
80106020:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106023:	85 c0                	test   %eax,%eax
80106025:	74 1a                	je     80106041 <sys_open+0xe6>
      iunlockput(ip);
80106027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602a:	89 04 24             	mov    %eax,(%esp)
8010602d:	e8 c6 ba ff ff       	call   80101af8 <iunlockput>
      end_op();
80106032:	e8 ab d4 ff ff       	call   801034e2 <end_op>
      return -1;
80106037:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603c:	e9 b2 00 00 00       	jmp    801060f3 <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106041:	e8 e2 ae ff ff       	call   80100f28 <filealloc>
80106046:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106049:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010604d:	74 14                	je     80106063 <sys_open+0x108>
8010604f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106052:	89 04 24             	mov    %eax,(%esp)
80106055:	e8 2f f7 ff ff       	call   80105789 <fdalloc>
8010605a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010605d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106061:	79 28                	jns    8010608b <sys_open+0x130>
    if(f)
80106063:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106067:	74 0b                	je     80106074 <sys_open+0x119>
      fileclose(f);
80106069:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606c:	89 04 24             	mov    %eax,(%esp)
8010606f:	e8 5c af ff ff       	call   80100fd0 <fileclose>
    iunlockput(ip);
80106074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106077:	89 04 24             	mov    %eax,(%esp)
8010607a:	e8 79 ba ff ff       	call   80101af8 <iunlockput>
    end_op();
8010607f:	e8 5e d4 ff ff       	call   801034e2 <end_op>
    return -1;
80106084:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106089:	eb 68                	jmp    801060f3 <sys_open+0x198>
  }
  iunlock(ip);
8010608b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608e:	89 04 24             	mov    %eax,(%esp)
80106091:	e8 2c b9 ff ff       	call   801019c2 <iunlock>
  end_op();
80106096:	e8 47 d4 ff ff       	call   801034e2 <end_op>

  f->type = FD_INODE;
8010609b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010609e:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060aa:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060ba:	83 e0 01             	and    $0x1,%eax
801060bd:	85 c0                	test   %eax,%eax
801060bf:	0f 94 c2             	sete   %dl
801060c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c5:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060cb:	83 e0 01             	and    $0x1,%eax
801060ce:	84 c0                	test   %al,%al
801060d0:	75 0a                	jne    801060dc <sys_open+0x181>
801060d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060d5:	83 e0 02             	and    $0x2,%eax
801060d8:	85 c0                	test   %eax,%eax
801060da:	74 07                	je     801060e3 <sys_open+0x188>
801060dc:	b8 01 00 00 00       	mov    $0x1,%eax
801060e1:	eb 05                	jmp    801060e8 <sys_open+0x18d>
801060e3:	b8 00 00 00 00       	mov    $0x0,%eax
801060e8:	89 c2                	mov    %eax,%edx
801060ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ed:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801060f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801060f3:	c9                   	leave  
801060f4:	c3                   	ret    

801060f5 <sys_mkdir>:

int
sys_mkdir(void)
{
801060f5:	55                   	push   %ebp
801060f6:	89 e5                	mov    %esp,%ebp
801060f8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060fb:	e8 61 d3 ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106100:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106103:	89 44 24 04          	mov    %eax,0x4(%esp)
80106107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010610e:	e8 3b f5 ff ff       	call   8010564e <argstr>
80106113:	85 c0                	test   %eax,%eax
80106115:	78 2c                	js     80106143 <sys_mkdir+0x4e>
80106117:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106121:	00 
80106122:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106129:	00 
8010612a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106131:	00 
80106132:	89 04 24             	mov    %eax,(%esp)
80106135:	e8 61 fc ff ff       	call   80105d9b <create>
8010613a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010613d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106141:	75 0c                	jne    8010614f <sys_mkdir+0x5a>
    end_op();
80106143:	e8 9a d3 ff ff       	call   801034e2 <end_op>
    return -1;
80106148:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614d:	eb 15                	jmp    80106164 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
8010614f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106152:	89 04 24             	mov    %eax,(%esp)
80106155:	e8 9e b9 ff ff       	call   80101af8 <iunlockput>
  end_op();
8010615a:	e8 83 d3 ff ff       	call   801034e2 <end_op>
  return 0;
8010615f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106164:	c9                   	leave  
80106165:	c3                   	ret    

80106166 <sys_mknod>:

int
sys_mknod(void)
{
80106166:	55                   	push   %ebp
80106167:	89 e5                	mov    %esp,%ebp
80106169:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010616c:	e8 f0 d2 ff ff       	call   80103461 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106171:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106174:	89 44 24 04          	mov    %eax,0x4(%esp)
80106178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010617f:	e8 ca f4 ff ff       	call   8010564e <argstr>
80106184:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106187:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010618b:	78 5e                	js     801061eb <sys_mknod+0x85>
     argint(1, &major) < 0 ||
8010618d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106190:	89 44 24 04          	mov    %eax,0x4(%esp)
80106194:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010619b:	e8 1e f4 ff ff       	call   801055be <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801061a0:	85 c0                	test   %eax,%eax
801061a2:	78 47                	js     801061eb <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ab:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801061b2:	e8 07 f4 ff ff       	call   801055be <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801061b7:	85 c0                	test   %eax,%eax
801061b9:	78 30                	js     801061eb <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801061bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061be:	0f bf c8             	movswl %ax,%ecx
801061c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061c4:	0f bf d0             	movswl %ax,%edx
801061c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061ca:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801061ce:	89 54 24 08          	mov    %edx,0x8(%esp)
801061d2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801061d9:	00 
801061da:	89 04 24             	mov    %eax,(%esp)
801061dd:	e8 b9 fb ff ff       	call   80105d9b <create>
801061e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061e9:	75 0c                	jne    801061f7 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801061eb:	e8 f2 d2 ff ff       	call   801034e2 <end_op>
    return -1;
801061f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f5:	eb 15                	jmp    8010620c <sys_mknod+0xa6>
  }
  iunlockput(ip);
801061f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061fa:	89 04 24             	mov    %eax,(%esp)
801061fd:	e8 f6 b8 ff ff       	call   80101af8 <iunlockput>
  end_op();
80106202:	e8 db d2 ff ff       	call   801034e2 <end_op>
  return 0;
80106207:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010620c:	c9                   	leave  
8010620d:	c3                   	ret    

8010620e <sys_chdir>:

int
sys_chdir(void)
{
8010620e:	55                   	push   %ebp
8010620f:	89 e5                	mov    %esp,%ebp
80106211:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106214:	e8 48 d2 ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106219:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010621c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106220:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106227:	e8 22 f4 ff ff       	call   8010564e <argstr>
8010622c:	85 c0                	test   %eax,%eax
8010622e:	78 14                	js     80106244 <sys_chdir+0x36>
80106230:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106233:	89 04 24             	mov    %eax,(%esp)
80106236:	e8 db c1 ff ff       	call   80102416 <namei>
8010623b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010623e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106242:	75 0c                	jne    80106250 <sys_chdir+0x42>
    end_op();
80106244:	e8 99 d2 ff ff       	call   801034e2 <end_op>
    return -1;
80106249:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010624e:	eb 61                	jmp    801062b1 <sys_chdir+0xa3>
  }
  ilock(ip);
80106250:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106253:	89 04 24             	mov    %eax,(%esp)
80106256:	e8 19 b6 ff ff       	call   80101874 <ilock>
  if(ip->type != T_DIR){
8010625b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106262:	66 83 f8 01          	cmp    $0x1,%ax
80106266:	74 17                	je     8010627f <sys_chdir+0x71>
    iunlockput(ip);
80106268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626b:	89 04 24             	mov    %eax,(%esp)
8010626e:	e8 85 b8 ff ff       	call   80101af8 <iunlockput>
    end_op();
80106273:	e8 6a d2 ff ff       	call   801034e2 <end_op>
    return -1;
80106278:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627d:	eb 32                	jmp    801062b1 <sys_chdir+0xa3>
  }
  iunlock(ip);
8010627f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106282:	89 04 24             	mov    %eax,(%esp)
80106285:	e8 38 b7 ff ff       	call   801019c2 <iunlock>
  iput(proc->cwd);
8010628a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106290:	8b 40 68             	mov    0x68(%eax),%eax
80106293:	89 04 24             	mov    %eax,(%esp)
80106296:	e8 8c b7 ff ff       	call   80101a27 <iput>
  end_op();
8010629b:	e8 42 d2 ff ff       	call   801034e2 <end_op>
  proc->cwd = ip;
801062a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062a9:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062b1:	c9                   	leave  
801062b2:	c3                   	ret    

801062b3 <sys_exec>:

int
sys_exec(void)
{
801062b3:	55                   	push   %ebp
801062b4:	89 e5                	mov    %esp,%ebp
801062b6:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062ca:	e8 7f f3 ff ff       	call   8010564e <argstr>
801062cf:	85 c0                	test   %eax,%eax
801062d1:	78 1a                	js     801062ed <sys_exec+0x3a>
801062d3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801062dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062e4:	e8 d5 f2 ff ff       	call   801055be <argint>
801062e9:	85 c0                	test   %eax,%eax
801062eb:	79 0a                	jns    801062f7 <sys_exec+0x44>
    return -1;
801062ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f2:	e9 cc 00 00 00       	jmp    801063c3 <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
801062f7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801062fe:	00 
801062ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106306:	00 
80106307:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010630d:	89 04 24             	mov    %eax,(%esp)
80106310:	e8 4d ef ff ff       	call   80105262 <memset>
  for(i=0;; i++){
80106315:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010631c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631f:	83 f8 1f             	cmp    $0x1f,%eax
80106322:	76 0a                	jbe    8010632e <sys_exec+0x7b>
      return -1;
80106324:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106329:	e9 95 00 00 00       	jmp    801063c3 <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010632e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106331:	c1 e0 02             	shl    $0x2,%eax
80106334:	89 c2                	mov    %eax,%edx
80106336:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010633c:	01 c2                	add    %eax,%edx
8010633e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106344:	89 44 24 04          	mov    %eax,0x4(%esp)
80106348:	89 14 24             	mov    %edx,(%esp)
8010634b:	e8 d0 f1 ff ff       	call   80105520 <fetchint>
80106350:	85 c0                	test   %eax,%eax
80106352:	79 07                	jns    8010635b <sys_exec+0xa8>
      return -1;
80106354:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106359:	eb 68                	jmp    801063c3 <sys_exec+0x110>
    if(uarg == 0){
8010635b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106361:	85 c0                	test   %eax,%eax
80106363:	75 26                	jne    8010638b <sys_exec+0xd8>
      argv[i] = 0;
80106365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106368:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010636f:	00 00 00 00 
      break;
80106373:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106374:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106377:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010637d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106381:	89 04 24             	mov    %eax,(%esp)
80106384:	e8 73 a7 ff ff       	call   80100afc <exec>
80106389:	eb 38                	jmp    801063c3 <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010638b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010638e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106395:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010639b:	01 c2                	add    %eax,%edx
8010639d:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063a3:	89 54 24 04          	mov    %edx,0x4(%esp)
801063a7:	89 04 24             	mov    %eax,(%esp)
801063aa:	e8 ab f1 ff ff       	call   8010555a <fetchstr>
801063af:	85 c0                	test   %eax,%eax
801063b1:	79 07                	jns    801063ba <sys_exec+0x107>
      return -1;
801063b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b8:	eb 09                	jmp    801063c3 <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801063ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801063be:	e9 59 ff ff ff       	jmp    8010631c <sys_exec+0x69>
  return exec(path, argv);
}
801063c3:	c9                   	leave  
801063c4:	c3                   	ret    

801063c5 <sys_pipe>:

int
sys_pipe(void)
{
801063c5:	55                   	push   %ebp
801063c6:	89 e5                	mov    %esp,%ebp
801063c8:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063cb:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801063d2:	00 
801063d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801063da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063e1:	e8 06 f2 ff ff       	call   801055ec <argptr>
801063e6:	85 c0                	test   %eax,%eax
801063e8:	79 0a                	jns    801063f4 <sys_pipe+0x2f>
    return -1;
801063ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ef:	e9 9b 00 00 00       	jmp    8010648f <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801063f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801063fb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063fe:	89 04 24             	mov    %eax,(%esp)
80106401:	e8 8a db ff ff       	call   80103f90 <pipealloc>
80106406:	85 c0                	test   %eax,%eax
80106408:	79 07                	jns    80106411 <sys_pipe+0x4c>
    return -1;
8010640a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640f:	eb 7e                	jmp    8010648f <sys_pipe+0xca>
  fd0 = -1;
80106411:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106418:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010641b:	89 04 24             	mov    %eax,(%esp)
8010641e:	e8 66 f3 ff ff       	call   80105789 <fdalloc>
80106423:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106426:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010642a:	78 14                	js     80106440 <sys_pipe+0x7b>
8010642c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010642f:	89 04 24             	mov    %eax,(%esp)
80106432:	e8 52 f3 ff ff       	call   80105789 <fdalloc>
80106437:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010643a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010643e:	79 37                	jns    80106477 <sys_pipe+0xb2>
    if(fd0 >= 0)
80106440:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106444:	78 14                	js     8010645a <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106446:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010644c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010644f:	83 c2 08             	add    $0x8,%edx
80106452:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106459:	00 
    fileclose(rf);
8010645a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010645d:	89 04 24             	mov    %eax,(%esp)
80106460:	e8 6b ab ff ff       	call   80100fd0 <fileclose>
    fileclose(wf);
80106465:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106468:	89 04 24             	mov    %eax,(%esp)
8010646b:	e8 60 ab ff ff       	call   80100fd0 <fileclose>
    return -1;
80106470:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106475:	eb 18                	jmp    8010648f <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106477:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010647a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010647d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010647f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106482:	8d 50 04             	lea    0x4(%eax),%edx
80106485:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106488:	89 02                	mov    %eax,(%edx)
  return 0;
8010648a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010648f:	c9                   	leave  
80106490:	c3                   	ret    
80106491:	00 00                	add    %al,(%eax)
	...

80106494 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106494:	55                   	push   %ebp
80106495:	89 e5                	mov    %esp,%ebp
80106497:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010649a:	e8 a4 e1 ff ff       	call   80104643 <fork>
}
8010649f:	c9                   	leave  
801064a0:	c3                   	ret    

801064a1 <sys_exit>:

int
sys_exit(void)
{
801064a1:	55                   	push   %ebp
801064a2:	89 e5                	mov    %esp,%ebp
801064a4:	83 ec 28             	sub    $0x28,%esp
	int status;
	if(argint(0, &status) < 0)
801064a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064b5:	e8 04 f1 ff ff       	call   801055be <argint>
801064ba:	85 c0                	test   %eax,%eax
801064bc:	79 07                	jns    801064c5 <sys_exit+0x24>
	    return -1;
801064be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064c3:	eb 10                	jmp    801064d5 <sys_exit+0x34>

	exit(status);
801064c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c8:	89 04 24             	mov    %eax,(%esp)
801064cb:	e8 ee e2 ff ff       	call   801047be <exit>
	return 0;  // not reached
801064d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064d5:	c9                   	leave  
801064d6:	c3                   	ret    

801064d7 <sys_wait>:

int
sys_wait(void)
{
801064d7:	55                   	push   %ebp
801064d8:	89 e5                	mov    %esp,%ebp
801064da:	83 ec 28             	sub    $0x28,%esp
	int* status;
	//take argument from environment
	if(argptr(0,(char**)&status, sizeof(int)) <0){ //error check
801064dd:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801064e4:	00 
801064e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801064ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064f3:	e8 f4 f0 ff ff       	call   801055ec <argptr>
801064f8:	85 c0                	test   %eax,%eax
801064fa:	79 07                	jns    80106503 <sys_wait+0x2c>
		return -1;
801064fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106501:	eb 0b                	jmp    8010650e <sys_wait+0x37>
	}
	return wait(status);
80106503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106506:	89 04 24             	mov    %eax,(%esp)
80106509:	e8 de e3 ff ff       	call   801048ec <wait>
}
8010650e:	c9                   	leave  
8010650f:	c3                   	ret    

80106510 <sys_waitpid>:

int
sys_waitpid(void)
{
80106510:	55                   	push   %ebp
80106511:	89 e5                	mov    %esp,%ebp
80106513:	83 ec 28             	sub    $0x28,%esp
	int pid;
	int *status;
	int options;

	if (	(argint(0, &pid) < 0) ||
80106516:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106519:	89 44 24 04          	mov    %eax,0x4(%esp)
8010651d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106524:	e8 95 f0 ff ff       	call   801055be <argint>
80106529:	85 c0                	test   %eax,%eax
8010652b:	78 36                	js     80106563 <sys_waitpid+0x53>
			(argptr(1,(char**)&status, sizeof(int)) < 0) ||
8010652d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106534:	00 
80106535:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106538:	89 44 24 04          	mov    %eax,0x4(%esp)
8010653c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106543:	e8 a4 f0 ff ff       	call   801055ec <argptr>
{
	int pid;
	int *status;
	int options;

	if (	(argint(0, &pid) < 0) ||
80106548:	85 c0                	test   %eax,%eax
8010654a:	78 17                	js     80106563 <sys_waitpid+0x53>
			(argptr(1,(char**)&status, sizeof(int)) < 0) ||
			(argint(2, &options) < 0) ){
8010654c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010654f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106553:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010655a:	e8 5f f0 ff ff       	call   801055be <argint>
	int pid;
	int *status;
	int options;

	if (	(argint(0, &pid) < 0) ||
			(argptr(1,(char**)&status, sizeof(int)) < 0) ||
8010655f:	85 c0                	test   %eax,%eax
80106561:	79 07                	jns    8010656a <sys_waitpid+0x5a>
			(argint(2, &options) < 0) ){

		return -1;
80106563:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106568:	eb 19                	jmp    80106583 <sys_waitpid+0x73>
	}

	return waitpid(pid, status, options);
8010656a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010656d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106573:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106577:	89 54 24 04          	mov    %edx,0x4(%esp)
8010657b:	89 04 24             	mov    %eax,(%esp)
8010657e:	e8 8d e4 ff ff       	call   80104a10 <waitpid>
}
80106583:	c9                   	leave  
80106584:	c3                   	ret    

80106585 <sys_kill>:

int
sys_kill(void)
{
80106585:	55                   	push   %ebp
80106586:	89 e5                	mov    %esp,%ebp
80106588:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010658b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010658e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106592:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106599:	e8 20 f0 ff ff       	call   801055be <argint>
8010659e:	85 c0                	test   %eax,%eax
801065a0:	79 07                	jns    801065a9 <sys_kill+0x24>
    return -1;
801065a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065a7:	eb 0b                	jmp    801065b4 <sys_kill+0x2f>
  return kill(pid);
801065a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ac:	89 04 24             	mov    %eax,(%esp)
801065af:	e8 86 e8 ff ff       	call   80104e3a <kill>
}
801065b4:	c9                   	leave  
801065b5:	c3                   	ret    

801065b6 <sys_getpid>:

int
sys_getpid(void)
{
801065b6:	55                   	push   %ebp
801065b7:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801065b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065bf:	8b 40 10             	mov    0x10(%eax),%eax
}
801065c2:	5d                   	pop    %ebp
801065c3:	c3                   	ret    

801065c4 <sys_sbrk>:

int
sys_sbrk(void)
{
801065c4:	55                   	push   %ebp
801065c5:	89 e5                	mov    %esp,%ebp
801065c7:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801065ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801065d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065d8:	e8 e1 ef ff ff       	call   801055be <argint>
801065dd:	85 c0                	test   %eax,%eax
801065df:	79 07                	jns    801065e8 <sys_sbrk+0x24>
    return -1;
801065e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e6:	eb 24                	jmp    8010660c <sys_sbrk+0x48>
  addr = proc->sz;
801065e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065ee:	8b 00                	mov    (%eax),%eax
801065f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801065f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f6:	89 04 24             	mov    %eax,(%esp)
801065f9:	e8 a0 df ff ff       	call   8010459e <growproc>
801065fe:	85 c0                	test   %eax,%eax
80106600:	79 07                	jns    80106609 <sys_sbrk+0x45>
    return -1;
80106602:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106607:	eb 03                	jmp    8010660c <sys_sbrk+0x48>
  return addr;
80106609:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010660c:	c9                   	leave  
8010660d:	c3                   	ret    

8010660e <sys_sleep>:

int
sys_sleep(void)
{
8010660e:	55                   	push   %ebp
8010660f:	89 e5                	mov    %esp,%ebp
80106611:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106614:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106617:	89 44 24 04          	mov    %eax,0x4(%esp)
8010661b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106622:	e8 97 ef ff ff       	call   801055be <argint>
80106627:	85 c0                	test   %eax,%eax
80106629:	79 07                	jns    80106632 <sys_sleep+0x24>
    return -1;
8010662b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106630:	eb 6c                	jmp    8010669e <sys_sleep+0x90>
  acquire(&tickslock);
80106632:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106639:	e8 d5 e9 ff ff       	call   80105013 <acquire>
  ticks0 = ticks;
8010663e:	a1 e0 51 11 80       	mov    0x801151e0,%eax
80106643:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106646:	eb 34                	jmp    8010667c <sys_sleep+0x6e>
    if(proc->killed){
80106648:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010664e:	8b 40 24             	mov    0x24(%eax),%eax
80106651:	85 c0                	test   %eax,%eax
80106653:	74 13                	je     80106668 <sys_sleep+0x5a>
      release(&tickslock);
80106655:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
8010665c:	e8 14 ea ff ff       	call   80105075 <release>
      return -1;
80106661:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106666:	eb 36                	jmp    8010669e <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106668:	c7 44 24 04 a0 49 11 	movl   $0x801149a0,0x4(%esp)
8010666f:	80 
80106670:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
80106677:	e8 ba e6 ff ff       	call   80104d36 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010667c:	a1 e0 51 11 80       	mov    0x801151e0,%eax
80106681:	89 c2                	mov    %eax,%edx
80106683:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106686:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106689:	39 c2                	cmp    %eax,%edx
8010668b:	72 bb                	jb     80106648 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
8010668d:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106694:	e8 dc e9 ff ff       	call   80105075 <release>
  return 0;
80106699:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010669e:	c9                   	leave  
8010669f:	c3                   	ret    

801066a0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801066a0:	55                   	push   %ebp
801066a1:	89 e5                	mov    %esp,%ebp
801066a3:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801066a6:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801066ad:	e8 61 e9 ff ff       	call   80105013 <acquire>
  xticks = ticks;
801066b2:	a1 e0 51 11 80       	mov    0x801151e0,%eax
801066b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801066ba:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801066c1:	e8 af e9 ff ff       	call   80105075 <release>
  return xticks;
801066c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066c9:	c9                   	leave  
801066ca:	c3                   	ret    
	...

801066cc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801066cc:	55                   	push   %ebp
801066cd:	89 e5                	mov    %esp,%ebp
801066cf:	83 ec 08             	sub    $0x8,%esp
801066d2:	8b 55 08             	mov    0x8(%ebp),%edx
801066d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801066d8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801066dc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066df:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066e3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066e7:	ee                   	out    %al,(%dx)
}
801066e8:	c9                   	leave  
801066e9:	c3                   	ret    

801066ea <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801066ea:	55                   	push   %ebp
801066eb:	89 e5                	mov    %esp,%ebp
801066ed:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801066f0:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801066f7:	00 
801066f8:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801066ff:	e8 c8 ff ff ff       	call   801066cc <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106704:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
8010670b:	00 
8010670c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106713:	e8 b4 ff ff ff       	call   801066cc <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106718:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010671f:	00 
80106720:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106727:	e8 a0 ff ff ff       	call   801066cc <outb>
  picenable(IRQ_TIMER);
8010672c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106733:	e8 e1 d6 ff ff       	call   80103e19 <picenable>
}
80106738:	c9                   	leave  
80106739:	c3                   	ret    
	...

8010673c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010673c:	1e                   	push   %ds
  pushl %es
8010673d:	06                   	push   %es
  pushl %fs
8010673e:	0f a0                	push   %fs
  pushl %gs
80106740:	0f a8                	push   %gs
  pushal
80106742:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106743:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106747:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106749:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010674b:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010674f:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106751:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106753:	54                   	push   %esp
  call trap
80106754:	e8 de 01 00 00       	call   80106937 <trap>
  addl $4, %esp
80106759:	83 c4 04             	add    $0x4,%esp

8010675c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010675c:	61                   	popa   
  popl %gs
8010675d:	0f a9                	pop    %gs
  popl %fs
8010675f:	0f a1                	pop    %fs
  popl %es
80106761:	07                   	pop    %es
  popl %ds
80106762:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106763:	83 c4 08             	add    $0x8,%esp
  iret
80106766:	cf                   	iret   
	...

80106768 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106768:	55                   	push   %ebp
80106769:	89 e5                	mov    %esp,%ebp
8010676b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010676e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106771:	83 e8 01             	sub    $0x1,%eax
80106774:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106778:	8b 45 08             	mov    0x8(%ebp),%eax
8010677b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010677f:	8b 45 08             	mov    0x8(%ebp),%eax
80106782:	c1 e8 10             	shr    $0x10,%eax
80106785:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106789:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010678c:	0f 01 18             	lidtl  (%eax)
}
8010678f:	c9                   	leave  
80106790:	c3                   	ret    

80106791 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106791:	55                   	push   %ebp
80106792:	89 e5                	mov    %esp,%ebp
80106794:	53                   	push   %ebx
80106795:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106798:	0f 20 d3             	mov    %cr2,%ebx
8010679b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
8010679e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801067a1:	83 c4 10             	add    $0x10,%esp
801067a4:	5b                   	pop    %ebx
801067a5:	5d                   	pop    %ebp
801067a6:	c3                   	ret    

801067a7 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067a7:	55                   	push   %ebp
801067a8:	89 e5                	mov    %esp,%ebp
801067aa:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801067ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067b4:	e9 c3 00 00 00       	jmp    8010687c <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801067b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bc:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
801067c3:	89 c2                	mov    %eax,%edx
801067c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c8:	66 89 14 c5 e0 49 11 	mov    %dx,-0x7feeb620(,%eax,8)
801067cf:	80 
801067d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d3:	66 c7 04 c5 e2 49 11 	movw   $0x8,-0x7feeb61e(,%eax,8)
801067da:	80 08 00 
801067dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e0:	0f b6 14 c5 e4 49 11 	movzbl -0x7feeb61c(,%eax,8),%edx
801067e7:	80 
801067e8:	83 e2 e0             	and    $0xffffffe0,%edx
801067eb:	88 14 c5 e4 49 11 80 	mov    %dl,-0x7feeb61c(,%eax,8)
801067f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f5:	0f b6 14 c5 e4 49 11 	movzbl -0x7feeb61c(,%eax,8),%edx
801067fc:	80 
801067fd:	83 e2 1f             	and    $0x1f,%edx
80106800:	88 14 c5 e4 49 11 80 	mov    %dl,-0x7feeb61c(,%eax,8)
80106807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680a:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
80106811:	80 
80106812:	83 e2 f0             	and    $0xfffffff0,%edx
80106815:	83 ca 0e             	or     $0xe,%edx
80106818:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
8010681f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106822:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
80106829:	80 
8010682a:	83 e2 ef             	and    $0xffffffef,%edx
8010682d:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
80106834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106837:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
8010683e:	80 
8010683f:	83 e2 9f             	and    $0xffffff9f,%edx
80106842:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
80106849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684c:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
80106853:	80 
80106854:	83 ca 80             	or     $0xffffff80,%edx
80106857:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
8010685e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106861:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106868:	c1 e8 10             	shr    $0x10,%eax
8010686b:	89 c2                	mov    %eax,%edx
8010686d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106870:	66 89 14 c5 e6 49 11 	mov    %dx,-0x7feeb61a(,%eax,8)
80106877:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106878:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010687c:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106883:	0f 8e 30 ff ff ff    	jle    801067b9 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106889:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
8010688e:	66 a3 e0 4b 11 80    	mov    %ax,0x80114be0
80106894:	66 c7 05 e2 4b 11 80 	movw   $0x8,0x80114be2
8010689b:	08 00 
8010689d:	0f b6 05 e4 4b 11 80 	movzbl 0x80114be4,%eax
801068a4:	83 e0 e0             	and    $0xffffffe0,%eax
801068a7:	a2 e4 4b 11 80       	mov    %al,0x80114be4
801068ac:	0f b6 05 e4 4b 11 80 	movzbl 0x80114be4,%eax
801068b3:	83 e0 1f             	and    $0x1f,%eax
801068b6:	a2 e4 4b 11 80       	mov    %al,0x80114be4
801068bb:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801068c2:	83 c8 0f             	or     $0xf,%eax
801068c5:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801068ca:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801068d1:	83 e0 ef             	and    $0xffffffef,%eax
801068d4:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801068d9:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801068e0:	83 c8 60             	or     $0x60,%eax
801068e3:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801068e8:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801068ef:	83 c8 80             	or     $0xffffff80,%eax
801068f2:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801068f7:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
801068fc:	c1 e8 10             	shr    $0x10,%eax
801068ff:	66 a3 e6 4b 11 80    	mov    %ax,0x80114be6
  
  initlock(&tickslock, "time");
80106905:	c7 44 24 04 3c 8b 10 	movl   $0x80108b3c,0x4(%esp)
8010690c:	80 
8010690d:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106914:	e8 d9 e6 ff ff       	call   80104ff2 <initlock>
}
80106919:	c9                   	leave  
8010691a:	c3                   	ret    

8010691b <idtinit>:

void
idtinit(void)
{
8010691b:	55                   	push   %ebp
8010691c:	89 e5                	mov    %esp,%ebp
8010691e:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106921:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106928:	00 
80106929:	c7 04 24 e0 49 11 80 	movl   $0x801149e0,(%esp)
80106930:	e8 33 fe ff ff       	call   80106768 <lidt>
}
80106935:	c9                   	leave  
80106936:	c3                   	ret    

80106937 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106937:	55                   	push   %ebp
80106938:	89 e5                	mov    %esp,%ebp
8010693a:	57                   	push   %edi
8010693b:	56                   	push   %esi
8010693c:	53                   	push   %ebx
8010693d:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106940:	8b 45 08             	mov    0x8(%ebp),%eax
80106943:	8b 40 30             	mov    0x30(%eax),%eax
80106946:	83 f8 40             	cmp    $0x40,%eax
80106949:	75 4c                	jne    80106997 <trap+0x60>
    if(proc->killed)
8010694b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106951:	8b 40 24             	mov    0x24(%eax),%eax
80106954:	85 c0                	test   %eax,%eax
80106956:	74 0c                	je     80106964 <trap+0x2d>
      exit(EXIT_STATUS_DEFAULT);
80106958:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010695f:	e8 5a de ff ff       	call   801047be <exit>
    proc->tf = tf;
80106964:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010696a:	8b 55 08             	mov    0x8(%ebp),%edx
8010696d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106970:	e8 10 ed ff ff       	call   80105685 <syscall>
    if(proc->killed)
80106975:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010697b:	8b 40 24             	mov    0x24(%eax),%eax
8010697e:	85 c0                	test   %eax,%eax
80106980:	0f 84 49 02 00 00    	je     80106bcf <trap+0x298>
      exit(EXIT_STATUS_DEFAULT);
80106986:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010698d:	e8 2c de ff ff       	call   801047be <exit>
    return;
80106992:	e9 38 02 00 00       	jmp    80106bcf <trap+0x298>
  }

  switch(tf->trapno){
80106997:	8b 45 08             	mov    0x8(%ebp),%eax
8010699a:	8b 40 30             	mov    0x30(%eax),%eax
8010699d:	83 e8 20             	sub    $0x20,%eax
801069a0:	83 f8 1f             	cmp    $0x1f,%eax
801069a3:	0f 87 bc 00 00 00    	ja     80106a65 <trap+0x12e>
801069a9:	8b 04 85 e4 8b 10 80 	mov    -0x7fef741c(,%eax,4),%eax
801069b0:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801069b2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069b8:	0f b6 00             	movzbl (%eax),%eax
801069bb:	84 c0                	test   %al,%al
801069bd:	75 31                	jne    801069f0 <trap+0xb9>
      acquire(&tickslock);
801069bf:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801069c6:	e8 48 e6 ff ff       	call   80105013 <acquire>
      ticks++;
801069cb:	a1 e0 51 11 80       	mov    0x801151e0,%eax
801069d0:	83 c0 01             	add    $0x1,%eax
801069d3:	a3 e0 51 11 80       	mov    %eax,0x801151e0
      wakeup(&ticks);
801069d8:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
801069df:	e8 2b e4 ff ff       	call   80104e0f <wakeup>
      release(&tickslock);
801069e4:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801069eb:	e8 85 e6 ff ff       	call   80105075 <release>
    }
    lapiceoi();
801069f0:	e8 2a c5 ff ff       	call   80102f1f <lapiceoi>
    break;
801069f5:	e9 41 01 00 00       	jmp    80106b3b <trap+0x204>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801069fa:	e8 fe bc ff ff       	call   801026fd <ideintr>
    lapiceoi();
801069ff:	e8 1b c5 ff ff       	call   80102f1f <lapiceoi>
    break;
80106a04:	e9 32 01 00 00       	jmp    80106b3b <trap+0x204>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a09:	e8 c5 c2 ff ff       	call   80102cd3 <kbdintr>
    lapiceoi();
80106a0e:	e8 0c c5 ff ff       	call   80102f1f <lapiceoi>
    break;
80106a13:	e9 23 01 00 00       	jmp    80106b3b <trap+0x204>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a18:	e8 b7 03 00 00       	call   80106dd4 <uartintr>
    lapiceoi();
80106a1d:	e8 fd c4 ff ff       	call   80102f1f <lapiceoi>
    break;
80106a22:	e9 14 01 00 00       	jmp    80106b3b <trap+0x204>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106a27:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a2a:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a30:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a34:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106a37:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a3d:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a40:	0f b6 c0             	movzbl %al,%eax
80106a43:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a47:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a4f:	c7 04 24 44 8b 10 80 	movl   $0x80108b44,(%esp)
80106a56:	e8 46 99 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106a5b:	e8 bf c4 ff ff       	call   80102f1f <lapiceoi>
    break;
80106a60:	e9 d6 00 00 00       	jmp    80106b3b <trap+0x204>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106a65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a6b:	85 c0                	test   %eax,%eax
80106a6d:	74 11                	je     80106a80 <trap+0x149>
80106a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80106a72:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a76:	0f b7 c0             	movzwl %ax,%eax
80106a79:	83 e0 03             	and    $0x3,%eax
80106a7c:	85 c0                	test   %eax,%eax
80106a7e:	75 46                	jne    80106ac6 <trap+0x18f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a80:	e8 0c fd ff ff       	call   80106791 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106a85:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a88:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106a8b:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106a92:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a95:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106a98:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a9b:	8b 52 30             	mov    0x30(%edx),%edx
80106a9e:	89 44 24 10          	mov    %eax,0x10(%esp)
80106aa2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106aa6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106aaa:	89 54 24 04          	mov    %edx,0x4(%esp)
80106aae:	c7 04 24 68 8b 10 80 	movl   $0x80108b68,(%esp)
80106ab5:	e8 e7 98 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106aba:	c7 04 24 9a 8b 10 80 	movl   $0x80108b9a,(%esp)
80106ac1:	e8 77 9a ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ac6:	e8 c6 fc ff ff       	call   80106791 <rcr2>
80106acb:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106acd:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ad0:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106ad3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ad9:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106adc:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106adf:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ae2:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106ae5:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ae8:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106aeb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106af1:	83 c0 6c             	add    $0x6c,%eax
80106af4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106af7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106afd:	8b 40 10             	mov    0x10(%eax),%eax
80106b00:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106b04:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106b08:	89 74 24 14          	mov    %esi,0x14(%esp)
80106b0c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b10:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106b17:	89 54 24 08          	mov    %edx,0x8(%esp)
80106b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b1f:	c7 04 24 a0 8b 10 80 	movl   $0x80108ba0,(%esp)
80106b26:	e8 76 98 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106b2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b31:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106b38:	eb 01                	jmp    80106b3b <trap+0x204>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106b3a:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b3b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b41:	85 c0                	test   %eax,%eax
80106b43:	74 2b                	je     80106b70 <trap+0x239>
80106b45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b4b:	8b 40 24             	mov    0x24(%eax),%eax
80106b4e:	85 c0                	test   %eax,%eax
80106b50:	74 1e                	je     80106b70 <trap+0x239>
80106b52:	8b 45 08             	mov    0x8(%ebp),%eax
80106b55:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b59:	0f b7 c0             	movzwl %ax,%eax
80106b5c:	83 e0 03             	and    $0x3,%eax
80106b5f:	83 f8 03             	cmp    $0x3,%eax
80106b62:	75 0c                	jne    80106b70 <trap+0x239>
    exit(EXIT_STATUS_DEFAULT);
80106b64:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106b6b:	e8 4e dc ff ff       	call   801047be <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106b70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b76:	85 c0                	test   %eax,%eax
80106b78:	74 1e                	je     80106b98 <trap+0x261>
80106b7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b80:	8b 40 0c             	mov    0xc(%eax),%eax
80106b83:	83 f8 04             	cmp    $0x4,%eax
80106b86:	75 10                	jne    80106b98 <trap+0x261>
80106b88:	8b 45 08             	mov    0x8(%ebp),%eax
80106b8b:	8b 40 30             	mov    0x30(%eax),%eax
80106b8e:	83 f8 20             	cmp    $0x20,%eax
80106b91:	75 05                	jne    80106b98 <trap+0x261>
    yield();
80106b93:	e8 40 e1 ff ff       	call   80104cd8 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b9e:	85 c0                	test   %eax,%eax
80106ba0:	74 2e                	je     80106bd0 <trap+0x299>
80106ba2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ba8:	8b 40 24             	mov    0x24(%eax),%eax
80106bab:	85 c0                	test   %eax,%eax
80106bad:	74 21                	je     80106bd0 <trap+0x299>
80106baf:	8b 45 08             	mov    0x8(%ebp),%eax
80106bb2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bb6:	0f b7 c0             	movzwl %ax,%eax
80106bb9:	83 e0 03             	and    $0x3,%eax
80106bbc:	83 f8 03             	cmp    $0x3,%eax
80106bbf:	75 0f                	jne    80106bd0 <trap+0x299>
    exit(EXIT_STATUS_DEFAULT);
80106bc1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106bc8:	e8 f1 db ff ff       	call   801047be <exit>
80106bcd:	eb 01                	jmp    80106bd0 <trap+0x299>
      exit(EXIT_STATUS_DEFAULT);
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit(EXIT_STATUS_DEFAULT);
    return;
80106bcf:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit(EXIT_STATUS_DEFAULT);
}
80106bd0:	83 c4 3c             	add    $0x3c,%esp
80106bd3:	5b                   	pop    %ebx
80106bd4:	5e                   	pop    %esi
80106bd5:	5f                   	pop    %edi
80106bd6:	5d                   	pop    %ebp
80106bd7:	c3                   	ret    

80106bd8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106bd8:	55                   	push   %ebp
80106bd9:	89 e5                	mov    %esp,%ebp
80106bdb:	53                   	push   %ebx
80106bdc:	83 ec 14             	sub    $0x14,%esp
80106bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80106be2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106be6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106bea:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106bee:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106bf2:	ec                   	in     (%dx),%al
80106bf3:	89 c3                	mov    %eax,%ebx
80106bf5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106bf8:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106bfc:	83 c4 14             	add    $0x14,%esp
80106bff:	5b                   	pop    %ebx
80106c00:	5d                   	pop    %ebp
80106c01:	c3                   	ret    

80106c02 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c02:	55                   	push   %ebp
80106c03:	89 e5                	mov    %esp,%ebp
80106c05:	83 ec 08             	sub    $0x8,%esp
80106c08:	8b 55 08             	mov    0x8(%ebp),%edx
80106c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c0e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c12:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c15:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c19:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c1d:	ee                   	out    %al,(%dx)
}
80106c1e:	c9                   	leave  
80106c1f:	c3                   	ret    

80106c20 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c20:	55                   	push   %ebp
80106c21:	89 e5                	mov    %esp,%ebp
80106c23:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c2d:	00 
80106c2e:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c35:	e8 c8 ff ff ff       	call   80106c02 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c3a:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106c41:	00 
80106c42:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c49:	e8 b4 ff ff ff       	call   80106c02 <outb>
  outb(COM1+0, 115200/9600);
80106c4e:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106c55:	00 
80106c56:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c5d:	e8 a0 ff ff ff       	call   80106c02 <outb>
  outb(COM1+1, 0);
80106c62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c69:	00 
80106c6a:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c71:	e8 8c ff ff ff       	call   80106c02 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c76:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106c7d:	00 
80106c7e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c85:	e8 78 ff ff ff       	call   80106c02 <outb>
  outb(COM1+4, 0);
80106c8a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c91:	00 
80106c92:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106c99:	e8 64 ff ff ff       	call   80106c02 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106c9e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106ca5:	00 
80106ca6:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106cad:	e8 50 ff ff ff       	call   80106c02 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106cb2:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106cb9:	e8 1a ff ff ff       	call   80106bd8 <inb>
80106cbe:	3c ff                	cmp    $0xff,%al
80106cc0:	74 6c                	je     80106d2e <uartinit+0x10e>
    return;
  uart = 1;
80106cc2:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106cc9:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106ccc:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106cd3:	e8 00 ff ff ff       	call   80106bd8 <inb>
  inb(COM1+0);
80106cd8:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cdf:	e8 f4 fe ff ff       	call   80106bd8 <inb>
  picenable(IRQ_COM1);
80106ce4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106ceb:	e8 29 d1 ff ff       	call   80103e19 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106cf0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106cf7:	00 
80106cf8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106cff:	e8 7e bc ff ff       	call   80102982 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d04:	c7 45 f4 64 8c 10 80 	movl   $0x80108c64,-0xc(%ebp)
80106d0b:	eb 15                	jmp    80106d22 <uartinit+0x102>
    uartputc(*p);
80106d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d10:	0f b6 00             	movzbl (%eax),%eax
80106d13:	0f be c0             	movsbl %al,%eax
80106d16:	89 04 24             	mov    %eax,(%esp)
80106d19:	e8 13 00 00 00       	call   80106d31 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d1e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d25:	0f b6 00             	movzbl (%eax),%eax
80106d28:	84 c0                	test   %al,%al
80106d2a:	75 e1                	jne    80106d0d <uartinit+0xed>
80106d2c:	eb 01                	jmp    80106d2f <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106d2e:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106d2f:	c9                   	leave  
80106d30:	c3                   	ret    

80106d31 <uartputc>:

void
uartputc(int c)
{
80106d31:	55                   	push   %ebp
80106d32:	89 e5                	mov    %esp,%ebp
80106d34:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106d37:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106d3c:	85 c0                	test   %eax,%eax
80106d3e:	74 4d                	je     80106d8d <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d40:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d47:	eb 10                	jmp    80106d59 <uartputc+0x28>
    microdelay(10);
80106d49:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106d50:	e8 ef c1 ff ff       	call   80102f44 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d55:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d59:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d5d:	7f 16                	jg     80106d75 <uartputc+0x44>
80106d5f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d66:	e8 6d fe ff ff       	call   80106bd8 <inb>
80106d6b:	0f b6 c0             	movzbl %al,%eax
80106d6e:	83 e0 20             	and    $0x20,%eax
80106d71:	85 c0                	test   %eax,%eax
80106d73:	74 d4                	je     80106d49 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106d75:	8b 45 08             	mov    0x8(%ebp),%eax
80106d78:	0f b6 c0             	movzbl %al,%eax
80106d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d7f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d86:	e8 77 fe ff ff       	call   80106c02 <outb>
80106d8b:	eb 01                	jmp    80106d8e <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106d8d:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106d8e:	c9                   	leave  
80106d8f:	c3                   	ret    

80106d90 <uartgetc>:

static int
uartgetc(void)
{
80106d90:	55                   	push   %ebp
80106d91:	89 e5                	mov    %esp,%ebp
80106d93:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106d96:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106d9b:	85 c0                	test   %eax,%eax
80106d9d:	75 07                	jne    80106da6 <uartgetc+0x16>
    return -1;
80106d9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106da4:	eb 2c                	jmp    80106dd2 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106da6:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106dad:	e8 26 fe ff ff       	call   80106bd8 <inb>
80106db2:	0f b6 c0             	movzbl %al,%eax
80106db5:	83 e0 01             	and    $0x1,%eax
80106db8:	85 c0                	test   %eax,%eax
80106dba:	75 07                	jne    80106dc3 <uartgetc+0x33>
    return -1;
80106dbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dc1:	eb 0f                	jmp    80106dd2 <uartgetc+0x42>
  return inb(COM1+0);
80106dc3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106dca:	e8 09 fe ff ff       	call   80106bd8 <inb>
80106dcf:	0f b6 c0             	movzbl %al,%eax
}
80106dd2:	c9                   	leave  
80106dd3:	c3                   	ret    

80106dd4 <uartintr>:

void
uartintr(void)
{
80106dd4:	55                   	push   %ebp
80106dd5:	89 e5                	mov    %esp,%ebp
80106dd7:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106dda:	c7 04 24 90 6d 10 80 	movl   $0x80106d90,(%esp)
80106de1:	e8 c7 99 ff ff       	call   801007ad <consoleintr>
}
80106de6:	c9                   	leave  
80106de7:	c3                   	ret    

80106de8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106de8:	6a 00                	push   $0x0
  pushl $0
80106dea:	6a 00                	push   $0x0
  jmp alltraps
80106dec:	e9 4b f9 ff ff       	jmp    8010673c <alltraps>

80106df1 <vector1>:
.globl vector1
vector1:
  pushl $0
80106df1:	6a 00                	push   $0x0
  pushl $1
80106df3:	6a 01                	push   $0x1
  jmp alltraps
80106df5:	e9 42 f9 ff ff       	jmp    8010673c <alltraps>

80106dfa <vector2>:
.globl vector2
vector2:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $2
80106dfc:	6a 02                	push   $0x2
  jmp alltraps
80106dfe:	e9 39 f9 ff ff       	jmp    8010673c <alltraps>

80106e03 <vector3>:
.globl vector3
vector3:
  pushl $0
80106e03:	6a 00                	push   $0x0
  pushl $3
80106e05:	6a 03                	push   $0x3
  jmp alltraps
80106e07:	e9 30 f9 ff ff       	jmp    8010673c <alltraps>

80106e0c <vector4>:
.globl vector4
vector4:
  pushl $0
80106e0c:	6a 00                	push   $0x0
  pushl $4
80106e0e:	6a 04                	push   $0x4
  jmp alltraps
80106e10:	e9 27 f9 ff ff       	jmp    8010673c <alltraps>

80106e15 <vector5>:
.globl vector5
vector5:
  pushl $0
80106e15:	6a 00                	push   $0x0
  pushl $5
80106e17:	6a 05                	push   $0x5
  jmp alltraps
80106e19:	e9 1e f9 ff ff       	jmp    8010673c <alltraps>

80106e1e <vector6>:
.globl vector6
vector6:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $6
80106e20:	6a 06                	push   $0x6
  jmp alltraps
80106e22:	e9 15 f9 ff ff       	jmp    8010673c <alltraps>

80106e27 <vector7>:
.globl vector7
vector7:
  pushl $0
80106e27:	6a 00                	push   $0x0
  pushl $7
80106e29:	6a 07                	push   $0x7
  jmp alltraps
80106e2b:	e9 0c f9 ff ff       	jmp    8010673c <alltraps>

80106e30 <vector8>:
.globl vector8
vector8:
  pushl $8
80106e30:	6a 08                	push   $0x8
  jmp alltraps
80106e32:	e9 05 f9 ff ff       	jmp    8010673c <alltraps>

80106e37 <vector9>:
.globl vector9
vector9:
  pushl $0
80106e37:	6a 00                	push   $0x0
  pushl $9
80106e39:	6a 09                	push   $0x9
  jmp alltraps
80106e3b:	e9 fc f8 ff ff       	jmp    8010673c <alltraps>

80106e40 <vector10>:
.globl vector10
vector10:
  pushl $10
80106e40:	6a 0a                	push   $0xa
  jmp alltraps
80106e42:	e9 f5 f8 ff ff       	jmp    8010673c <alltraps>

80106e47 <vector11>:
.globl vector11
vector11:
  pushl $11
80106e47:	6a 0b                	push   $0xb
  jmp alltraps
80106e49:	e9 ee f8 ff ff       	jmp    8010673c <alltraps>

80106e4e <vector12>:
.globl vector12
vector12:
  pushl $12
80106e4e:	6a 0c                	push   $0xc
  jmp alltraps
80106e50:	e9 e7 f8 ff ff       	jmp    8010673c <alltraps>

80106e55 <vector13>:
.globl vector13
vector13:
  pushl $13
80106e55:	6a 0d                	push   $0xd
  jmp alltraps
80106e57:	e9 e0 f8 ff ff       	jmp    8010673c <alltraps>

80106e5c <vector14>:
.globl vector14
vector14:
  pushl $14
80106e5c:	6a 0e                	push   $0xe
  jmp alltraps
80106e5e:	e9 d9 f8 ff ff       	jmp    8010673c <alltraps>

80106e63 <vector15>:
.globl vector15
vector15:
  pushl $0
80106e63:	6a 00                	push   $0x0
  pushl $15
80106e65:	6a 0f                	push   $0xf
  jmp alltraps
80106e67:	e9 d0 f8 ff ff       	jmp    8010673c <alltraps>

80106e6c <vector16>:
.globl vector16
vector16:
  pushl $0
80106e6c:	6a 00                	push   $0x0
  pushl $16
80106e6e:	6a 10                	push   $0x10
  jmp alltraps
80106e70:	e9 c7 f8 ff ff       	jmp    8010673c <alltraps>

80106e75 <vector17>:
.globl vector17
vector17:
  pushl $17
80106e75:	6a 11                	push   $0x11
  jmp alltraps
80106e77:	e9 c0 f8 ff ff       	jmp    8010673c <alltraps>

80106e7c <vector18>:
.globl vector18
vector18:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $18
80106e7e:	6a 12                	push   $0x12
  jmp alltraps
80106e80:	e9 b7 f8 ff ff       	jmp    8010673c <alltraps>

80106e85 <vector19>:
.globl vector19
vector19:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $19
80106e87:	6a 13                	push   $0x13
  jmp alltraps
80106e89:	e9 ae f8 ff ff       	jmp    8010673c <alltraps>

80106e8e <vector20>:
.globl vector20
vector20:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $20
80106e90:	6a 14                	push   $0x14
  jmp alltraps
80106e92:	e9 a5 f8 ff ff       	jmp    8010673c <alltraps>

80106e97 <vector21>:
.globl vector21
vector21:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $21
80106e99:	6a 15                	push   $0x15
  jmp alltraps
80106e9b:	e9 9c f8 ff ff       	jmp    8010673c <alltraps>

80106ea0 <vector22>:
.globl vector22
vector22:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $22
80106ea2:	6a 16                	push   $0x16
  jmp alltraps
80106ea4:	e9 93 f8 ff ff       	jmp    8010673c <alltraps>

80106ea9 <vector23>:
.globl vector23
vector23:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $23
80106eab:	6a 17                	push   $0x17
  jmp alltraps
80106ead:	e9 8a f8 ff ff       	jmp    8010673c <alltraps>

80106eb2 <vector24>:
.globl vector24
vector24:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $24
80106eb4:	6a 18                	push   $0x18
  jmp alltraps
80106eb6:	e9 81 f8 ff ff       	jmp    8010673c <alltraps>

80106ebb <vector25>:
.globl vector25
vector25:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $25
80106ebd:	6a 19                	push   $0x19
  jmp alltraps
80106ebf:	e9 78 f8 ff ff       	jmp    8010673c <alltraps>

80106ec4 <vector26>:
.globl vector26
vector26:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $26
80106ec6:	6a 1a                	push   $0x1a
  jmp alltraps
80106ec8:	e9 6f f8 ff ff       	jmp    8010673c <alltraps>

80106ecd <vector27>:
.globl vector27
vector27:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $27
80106ecf:	6a 1b                	push   $0x1b
  jmp alltraps
80106ed1:	e9 66 f8 ff ff       	jmp    8010673c <alltraps>

80106ed6 <vector28>:
.globl vector28
vector28:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $28
80106ed8:	6a 1c                	push   $0x1c
  jmp alltraps
80106eda:	e9 5d f8 ff ff       	jmp    8010673c <alltraps>

80106edf <vector29>:
.globl vector29
vector29:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $29
80106ee1:	6a 1d                	push   $0x1d
  jmp alltraps
80106ee3:	e9 54 f8 ff ff       	jmp    8010673c <alltraps>

80106ee8 <vector30>:
.globl vector30
vector30:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $30
80106eea:	6a 1e                	push   $0x1e
  jmp alltraps
80106eec:	e9 4b f8 ff ff       	jmp    8010673c <alltraps>

80106ef1 <vector31>:
.globl vector31
vector31:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $31
80106ef3:	6a 1f                	push   $0x1f
  jmp alltraps
80106ef5:	e9 42 f8 ff ff       	jmp    8010673c <alltraps>

80106efa <vector32>:
.globl vector32
vector32:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $32
80106efc:	6a 20                	push   $0x20
  jmp alltraps
80106efe:	e9 39 f8 ff ff       	jmp    8010673c <alltraps>

80106f03 <vector33>:
.globl vector33
vector33:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $33
80106f05:	6a 21                	push   $0x21
  jmp alltraps
80106f07:	e9 30 f8 ff ff       	jmp    8010673c <alltraps>

80106f0c <vector34>:
.globl vector34
vector34:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $34
80106f0e:	6a 22                	push   $0x22
  jmp alltraps
80106f10:	e9 27 f8 ff ff       	jmp    8010673c <alltraps>

80106f15 <vector35>:
.globl vector35
vector35:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $35
80106f17:	6a 23                	push   $0x23
  jmp alltraps
80106f19:	e9 1e f8 ff ff       	jmp    8010673c <alltraps>

80106f1e <vector36>:
.globl vector36
vector36:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $36
80106f20:	6a 24                	push   $0x24
  jmp alltraps
80106f22:	e9 15 f8 ff ff       	jmp    8010673c <alltraps>

80106f27 <vector37>:
.globl vector37
vector37:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $37
80106f29:	6a 25                	push   $0x25
  jmp alltraps
80106f2b:	e9 0c f8 ff ff       	jmp    8010673c <alltraps>

80106f30 <vector38>:
.globl vector38
vector38:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $38
80106f32:	6a 26                	push   $0x26
  jmp alltraps
80106f34:	e9 03 f8 ff ff       	jmp    8010673c <alltraps>

80106f39 <vector39>:
.globl vector39
vector39:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $39
80106f3b:	6a 27                	push   $0x27
  jmp alltraps
80106f3d:	e9 fa f7 ff ff       	jmp    8010673c <alltraps>

80106f42 <vector40>:
.globl vector40
vector40:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $40
80106f44:	6a 28                	push   $0x28
  jmp alltraps
80106f46:	e9 f1 f7 ff ff       	jmp    8010673c <alltraps>

80106f4b <vector41>:
.globl vector41
vector41:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $41
80106f4d:	6a 29                	push   $0x29
  jmp alltraps
80106f4f:	e9 e8 f7 ff ff       	jmp    8010673c <alltraps>

80106f54 <vector42>:
.globl vector42
vector42:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $42
80106f56:	6a 2a                	push   $0x2a
  jmp alltraps
80106f58:	e9 df f7 ff ff       	jmp    8010673c <alltraps>

80106f5d <vector43>:
.globl vector43
vector43:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $43
80106f5f:	6a 2b                	push   $0x2b
  jmp alltraps
80106f61:	e9 d6 f7 ff ff       	jmp    8010673c <alltraps>

80106f66 <vector44>:
.globl vector44
vector44:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $44
80106f68:	6a 2c                	push   $0x2c
  jmp alltraps
80106f6a:	e9 cd f7 ff ff       	jmp    8010673c <alltraps>

80106f6f <vector45>:
.globl vector45
vector45:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $45
80106f71:	6a 2d                	push   $0x2d
  jmp alltraps
80106f73:	e9 c4 f7 ff ff       	jmp    8010673c <alltraps>

80106f78 <vector46>:
.globl vector46
vector46:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $46
80106f7a:	6a 2e                	push   $0x2e
  jmp alltraps
80106f7c:	e9 bb f7 ff ff       	jmp    8010673c <alltraps>

80106f81 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $47
80106f83:	6a 2f                	push   $0x2f
  jmp alltraps
80106f85:	e9 b2 f7 ff ff       	jmp    8010673c <alltraps>

80106f8a <vector48>:
.globl vector48
vector48:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $48
80106f8c:	6a 30                	push   $0x30
  jmp alltraps
80106f8e:	e9 a9 f7 ff ff       	jmp    8010673c <alltraps>

80106f93 <vector49>:
.globl vector49
vector49:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $49
80106f95:	6a 31                	push   $0x31
  jmp alltraps
80106f97:	e9 a0 f7 ff ff       	jmp    8010673c <alltraps>

80106f9c <vector50>:
.globl vector50
vector50:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $50
80106f9e:	6a 32                	push   $0x32
  jmp alltraps
80106fa0:	e9 97 f7 ff ff       	jmp    8010673c <alltraps>

80106fa5 <vector51>:
.globl vector51
vector51:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $51
80106fa7:	6a 33                	push   $0x33
  jmp alltraps
80106fa9:	e9 8e f7 ff ff       	jmp    8010673c <alltraps>

80106fae <vector52>:
.globl vector52
vector52:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $52
80106fb0:	6a 34                	push   $0x34
  jmp alltraps
80106fb2:	e9 85 f7 ff ff       	jmp    8010673c <alltraps>

80106fb7 <vector53>:
.globl vector53
vector53:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $53
80106fb9:	6a 35                	push   $0x35
  jmp alltraps
80106fbb:	e9 7c f7 ff ff       	jmp    8010673c <alltraps>

80106fc0 <vector54>:
.globl vector54
vector54:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $54
80106fc2:	6a 36                	push   $0x36
  jmp alltraps
80106fc4:	e9 73 f7 ff ff       	jmp    8010673c <alltraps>

80106fc9 <vector55>:
.globl vector55
vector55:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $55
80106fcb:	6a 37                	push   $0x37
  jmp alltraps
80106fcd:	e9 6a f7 ff ff       	jmp    8010673c <alltraps>

80106fd2 <vector56>:
.globl vector56
vector56:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $56
80106fd4:	6a 38                	push   $0x38
  jmp alltraps
80106fd6:	e9 61 f7 ff ff       	jmp    8010673c <alltraps>

80106fdb <vector57>:
.globl vector57
vector57:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $57
80106fdd:	6a 39                	push   $0x39
  jmp alltraps
80106fdf:	e9 58 f7 ff ff       	jmp    8010673c <alltraps>

80106fe4 <vector58>:
.globl vector58
vector58:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $58
80106fe6:	6a 3a                	push   $0x3a
  jmp alltraps
80106fe8:	e9 4f f7 ff ff       	jmp    8010673c <alltraps>

80106fed <vector59>:
.globl vector59
vector59:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $59
80106fef:	6a 3b                	push   $0x3b
  jmp alltraps
80106ff1:	e9 46 f7 ff ff       	jmp    8010673c <alltraps>

80106ff6 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $60
80106ff8:	6a 3c                	push   $0x3c
  jmp alltraps
80106ffa:	e9 3d f7 ff ff       	jmp    8010673c <alltraps>

80106fff <vector61>:
.globl vector61
vector61:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $61
80107001:	6a 3d                	push   $0x3d
  jmp alltraps
80107003:	e9 34 f7 ff ff       	jmp    8010673c <alltraps>

80107008 <vector62>:
.globl vector62
vector62:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $62
8010700a:	6a 3e                	push   $0x3e
  jmp alltraps
8010700c:	e9 2b f7 ff ff       	jmp    8010673c <alltraps>

80107011 <vector63>:
.globl vector63
vector63:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $63
80107013:	6a 3f                	push   $0x3f
  jmp alltraps
80107015:	e9 22 f7 ff ff       	jmp    8010673c <alltraps>

8010701a <vector64>:
.globl vector64
vector64:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $64
8010701c:	6a 40                	push   $0x40
  jmp alltraps
8010701e:	e9 19 f7 ff ff       	jmp    8010673c <alltraps>

80107023 <vector65>:
.globl vector65
vector65:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $65
80107025:	6a 41                	push   $0x41
  jmp alltraps
80107027:	e9 10 f7 ff ff       	jmp    8010673c <alltraps>

8010702c <vector66>:
.globl vector66
vector66:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $66
8010702e:	6a 42                	push   $0x42
  jmp alltraps
80107030:	e9 07 f7 ff ff       	jmp    8010673c <alltraps>

80107035 <vector67>:
.globl vector67
vector67:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $67
80107037:	6a 43                	push   $0x43
  jmp alltraps
80107039:	e9 fe f6 ff ff       	jmp    8010673c <alltraps>

8010703e <vector68>:
.globl vector68
vector68:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $68
80107040:	6a 44                	push   $0x44
  jmp alltraps
80107042:	e9 f5 f6 ff ff       	jmp    8010673c <alltraps>

80107047 <vector69>:
.globl vector69
vector69:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $69
80107049:	6a 45                	push   $0x45
  jmp alltraps
8010704b:	e9 ec f6 ff ff       	jmp    8010673c <alltraps>

80107050 <vector70>:
.globl vector70
vector70:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $70
80107052:	6a 46                	push   $0x46
  jmp alltraps
80107054:	e9 e3 f6 ff ff       	jmp    8010673c <alltraps>

80107059 <vector71>:
.globl vector71
vector71:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $71
8010705b:	6a 47                	push   $0x47
  jmp alltraps
8010705d:	e9 da f6 ff ff       	jmp    8010673c <alltraps>

80107062 <vector72>:
.globl vector72
vector72:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $72
80107064:	6a 48                	push   $0x48
  jmp alltraps
80107066:	e9 d1 f6 ff ff       	jmp    8010673c <alltraps>

8010706b <vector73>:
.globl vector73
vector73:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $73
8010706d:	6a 49                	push   $0x49
  jmp alltraps
8010706f:	e9 c8 f6 ff ff       	jmp    8010673c <alltraps>

80107074 <vector74>:
.globl vector74
vector74:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $74
80107076:	6a 4a                	push   $0x4a
  jmp alltraps
80107078:	e9 bf f6 ff ff       	jmp    8010673c <alltraps>

8010707d <vector75>:
.globl vector75
vector75:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $75
8010707f:	6a 4b                	push   $0x4b
  jmp alltraps
80107081:	e9 b6 f6 ff ff       	jmp    8010673c <alltraps>

80107086 <vector76>:
.globl vector76
vector76:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $76
80107088:	6a 4c                	push   $0x4c
  jmp alltraps
8010708a:	e9 ad f6 ff ff       	jmp    8010673c <alltraps>

8010708f <vector77>:
.globl vector77
vector77:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $77
80107091:	6a 4d                	push   $0x4d
  jmp alltraps
80107093:	e9 a4 f6 ff ff       	jmp    8010673c <alltraps>

80107098 <vector78>:
.globl vector78
vector78:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $78
8010709a:	6a 4e                	push   $0x4e
  jmp alltraps
8010709c:	e9 9b f6 ff ff       	jmp    8010673c <alltraps>

801070a1 <vector79>:
.globl vector79
vector79:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $79
801070a3:	6a 4f                	push   $0x4f
  jmp alltraps
801070a5:	e9 92 f6 ff ff       	jmp    8010673c <alltraps>

801070aa <vector80>:
.globl vector80
vector80:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $80
801070ac:	6a 50                	push   $0x50
  jmp alltraps
801070ae:	e9 89 f6 ff ff       	jmp    8010673c <alltraps>

801070b3 <vector81>:
.globl vector81
vector81:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $81
801070b5:	6a 51                	push   $0x51
  jmp alltraps
801070b7:	e9 80 f6 ff ff       	jmp    8010673c <alltraps>

801070bc <vector82>:
.globl vector82
vector82:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $82
801070be:	6a 52                	push   $0x52
  jmp alltraps
801070c0:	e9 77 f6 ff ff       	jmp    8010673c <alltraps>

801070c5 <vector83>:
.globl vector83
vector83:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $83
801070c7:	6a 53                	push   $0x53
  jmp alltraps
801070c9:	e9 6e f6 ff ff       	jmp    8010673c <alltraps>

801070ce <vector84>:
.globl vector84
vector84:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $84
801070d0:	6a 54                	push   $0x54
  jmp alltraps
801070d2:	e9 65 f6 ff ff       	jmp    8010673c <alltraps>

801070d7 <vector85>:
.globl vector85
vector85:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $85
801070d9:	6a 55                	push   $0x55
  jmp alltraps
801070db:	e9 5c f6 ff ff       	jmp    8010673c <alltraps>

801070e0 <vector86>:
.globl vector86
vector86:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $86
801070e2:	6a 56                	push   $0x56
  jmp alltraps
801070e4:	e9 53 f6 ff ff       	jmp    8010673c <alltraps>

801070e9 <vector87>:
.globl vector87
vector87:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $87
801070eb:	6a 57                	push   $0x57
  jmp alltraps
801070ed:	e9 4a f6 ff ff       	jmp    8010673c <alltraps>

801070f2 <vector88>:
.globl vector88
vector88:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $88
801070f4:	6a 58                	push   $0x58
  jmp alltraps
801070f6:	e9 41 f6 ff ff       	jmp    8010673c <alltraps>

801070fb <vector89>:
.globl vector89
vector89:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $89
801070fd:	6a 59                	push   $0x59
  jmp alltraps
801070ff:	e9 38 f6 ff ff       	jmp    8010673c <alltraps>

80107104 <vector90>:
.globl vector90
vector90:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $90
80107106:	6a 5a                	push   $0x5a
  jmp alltraps
80107108:	e9 2f f6 ff ff       	jmp    8010673c <alltraps>

8010710d <vector91>:
.globl vector91
vector91:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $91
8010710f:	6a 5b                	push   $0x5b
  jmp alltraps
80107111:	e9 26 f6 ff ff       	jmp    8010673c <alltraps>

80107116 <vector92>:
.globl vector92
vector92:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $92
80107118:	6a 5c                	push   $0x5c
  jmp alltraps
8010711a:	e9 1d f6 ff ff       	jmp    8010673c <alltraps>

8010711f <vector93>:
.globl vector93
vector93:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $93
80107121:	6a 5d                	push   $0x5d
  jmp alltraps
80107123:	e9 14 f6 ff ff       	jmp    8010673c <alltraps>

80107128 <vector94>:
.globl vector94
vector94:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $94
8010712a:	6a 5e                	push   $0x5e
  jmp alltraps
8010712c:	e9 0b f6 ff ff       	jmp    8010673c <alltraps>

80107131 <vector95>:
.globl vector95
vector95:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $95
80107133:	6a 5f                	push   $0x5f
  jmp alltraps
80107135:	e9 02 f6 ff ff       	jmp    8010673c <alltraps>

8010713a <vector96>:
.globl vector96
vector96:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $96
8010713c:	6a 60                	push   $0x60
  jmp alltraps
8010713e:	e9 f9 f5 ff ff       	jmp    8010673c <alltraps>

80107143 <vector97>:
.globl vector97
vector97:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $97
80107145:	6a 61                	push   $0x61
  jmp alltraps
80107147:	e9 f0 f5 ff ff       	jmp    8010673c <alltraps>

8010714c <vector98>:
.globl vector98
vector98:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $98
8010714e:	6a 62                	push   $0x62
  jmp alltraps
80107150:	e9 e7 f5 ff ff       	jmp    8010673c <alltraps>

80107155 <vector99>:
.globl vector99
vector99:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $99
80107157:	6a 63                	push   $0x63
  jmp alltraps
80107159:	e9 de f5 ff ff       	jmp    8010673c <alltraps>

8010715e <vector100>:
.globl vector100
vector100:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $100
80107160:	6a 64                	push   $0x64
  jmp alltraps
80107162:	e9 d5 f5 ff ff       	jmp    8010673c <alltraps>

80107167 <vector101>:
.globl vector101
vector101:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $101
80107169:	6a 65                	push   $0x65
  jmp alltraps
8010716b:	e9 cc f5 ff ff       	jmp    8010673c <alltraps>

80107170 <vector102>:
.globl vector102
vector102:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $102
80107172:	6a 66                	push   $0x66
  jmp alltraps
80107174:	e9 c3 f5 ff ff       	jmp    8010673c <alltraps>

80107179 <vector103>:
.globl vector103
vector103:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $103
8010717b:	6a 67                	push   $0x67
  jmp alltraps
8010717d:	e9 ba f5 ff ff       	jmp    8010673c <alltraps>

80107182 <vector104>:
.globl vector104
vector104:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $104
80107184:	6a 68                	push   $0x68
  jmp alltraps
80107186:	e9 b1 f5 ff ff       	jmp    8010673c <alltraps>

8010718b <vector105>:
.globl vector105
vector105:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $105
8010718d:	6a 69                	push   $0x69
  jmp alltraps
8010718f:	e9 a8 f5 ff ff       	jmp    8010673c <alltraps>

80107194 <vector106>:
.globl vector106
vector106:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $106
80107196:	6a 6a                	push   $0x6a
  jmp alltraps
80107198:	e9 9f f5 ff ff       	jmp    8010673c <alltraps>

8010719d <vector107>:
.globl vector107
vector107:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $107
8010719f:	6a 6b                	push   $0x6b
  jmp alltraps
801071a1:	e9 96 f5 ff ff       	jmp    8010673c <alltraps>

801071a6 <vector108>:
.globl vector108
vector108:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $108
801071a8:	6a 6c                	push   $0x6c
  jmp alltraps
801071aa:	e9 8d f5 ff ff       	jmp    8010673c <alltraps>

801071af <vector109>:
.globl vector109
vector109:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $109
801071b1:	6a 6d                	push   $0x6d
  jmp alltraps
801071b3:	e9 84 f5 ff ff       	jmp    8010673c <alltraps>

801071b8 <vector110>:
.globl vector110
vector110:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $110
801071ba:	6a 6e                	push   $0x6e
  jmp alltraps
801071bc:	e9 7b f5 ff ff       	jmp    8010673c <alltraps>

801071c1 <vector111>:
.globl vector111
vector111:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $111
801071c3:	6a 6f                	push   $0x6f
  jmp alltraps
801071c5:	e9 72 f5 ff ff       	jmp    8010673c <alltraps>

801071ca <vector112>:
.globl vector112
vector112:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $112
801071cc:	6a 70                	push   $0x70
  jmp alltraps
801071ce:	e9 69 f5 ff ff       	jmp    8010673c <alltraps>

801071d3 <vector113>:
.globl vector113
vector113:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $113
801071d5:	6a 71                	push   $0x71
  jmp alltraps
801071d7:	e9 60 f5 ff ff       	jmp    8010673c <alltraps>

801071dc <vector114>:
.globl vector114
vector114:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $114
801071de:	6a 72                	push   $0x72
  jmp alltraps
801071e0:	e9 57 f5 ff ff       	jmp    8010673c <alltraps>

801071e5 <vector115>:
.globl vector115
vector115:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $115
801071e7:	6a 73                	push   $0x73
  jmp alltraps
801071e9:	e9 4e f5 ff ff       	jmp    8010673c <alltraps>

801071ee <vector116>:
.globl vector116
vector116:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $116
801071f0:	6a 74                	push   $0x74
  jmp alltraps
801071f2:	e9 45 f5 ff ff       	jmp    8010673c <alltraps>

801071f7 <vector117>:
.globl vector117
vector117:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $117
801071f9:	6a 75                	push   $0x75
  jmp alltraps
801071fb:	e9 3c f5 ff ff       	jmp    8010673c <alltraps>

80107200 <vector118>:
.globl vector118
vector118:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $118
80107202:	6a 76                	push   $0x76
  jmp alltraps
80107204:	e9 33 f5 ff ff       	jmp    8010673c <alltraps>

80107209 <vector119>:
.globl vector119
vector119:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $119
8010720b:	6a 77                	push   $0x77
  jmp alltraps
8010720d:	e9 2a f5 ff ff       	jmp    8010673c <alltraps>

80107212 <vector120>:
.globl vector120
vector120:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $120
80107214:	6a 78                	push   $0x78
  jmp alltraps
80107216:	e9 21 f5 ff ff       	jmp    8010673c <alltraps>

8010721b <vector121>:
.globl vector121
vector121:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $121
8010721d:	6a 79                	push   $0x79
  jmp alltraps
8010721f:	e9 18 f5 ff ff       	jmp    8010673c <alltraps>

80107224 <vector122>:
.globl vector122
vector122:
  pushl $0
80107224:	6a 00                	push   $0x0
  pushl $122
80107226:	6a 7a                	push   $0x7a
  jmp alltraps
80107228:	e9 0f f5 ff ff       	jmp    8010673c <alltraps>

8010722d <vector123>:
.globl vector123
vector123:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $123
8010722f:	6a 7b                	push   $0x7b
  jmp alltraps
80107231:	e9 06 f5 ff ff       	jmp    8010673c <alltraps>

80107236 <vector124>:
.globl vector124
vector124:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $124
80107238:	6a 7c                	push   $0x7c
  jmp alltraps
8010723a:	e9 fd f4 ff ff       	jmp    8010673c <alltraps>

8010723f <vector125>:
.globl vector125
vector125:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $125
80107241:	6a 7d                	push   $0x7d
  jmp alltraps
80107243:	e9 f4 f4 ff ff       	jmp    8010673c <alltraps>

80107248 <vector126>:
.globl vector126
vector126:
  pushl $0
80107248:	6a 00                	push   $0x0
  pushl $126
8010724a:	6a 7e                	push   $0x7e
  jmp alltraps
8010724c:	e9 eb f4 ff ff       	jmp    8010673c <alltraps>

80107251 <vector127>:
.globl vector127
vector127:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $127
80107253:	6a 7f                	push   $0x7f
  jmp alltraps
80107255:	e9 e2 f4 ff ff       	jmp    8010673c <alltraps>

8010725a <vector128>:
.globl vector128
vector128:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $128
8010725c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107261:	e9 d6 f4 ff ff       	jmp    8010673c <alltraps>

80107266 <vector129>:
.globl vector129
vector129:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $129
80107268:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010726d:	e9 ca f4 ff ff       	jmp    8010673c <alltraps>

80107272 <vector130>:
.globl vector130
vector130:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $130
80107274:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107279:	e9 be f4 ff ff       	jmp    8010673c <alltraps>

8010727e <vector131>:
.globl vector131
vector131:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $131
80107280:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107285:	e9 b2 f4 ff ff       	jmp    8010673c <alltraps>

8010728a <vector132>:
.globl vector132
vector132:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $132
8010728c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107291:	e9 a6 f4 ff ff       	jmp    8010673c <alltraps>

80107296 <vector133>:
.globl vector133
vector133:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $133
80107298:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010729d:	e9 9a f4 ff ff       	jmp    8010673c <alltraps>

801072a2 <vector134>:
.globl vector134
vector134:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $134
801072a4:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801072a9:	e9 8e f4 ff ff       	jmp    8010673c <alltraps>

801072ae <vector135>:
.globl vector135
vector135:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $135
801072b0:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801072b5:	e9 82 f4 ff ff       	jmp    8010673c <alltraps>

801072ba <vector136>:
.globl vector136
vector136:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $136
801072bc:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801072c1:	e9 76 f4 ff ff       	jmp    8010673c <alltraps>

801072c6 <vector137>:
.globl vector137
vector137:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $137
801072c8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801072cd:	e9 6a f4 ff ff       	jmp    8010673c <alltraps>

801072d2 <vector138>:
.globl vector138
vector138:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $138
801072d4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801072d9:	e9 5e f4 ff ff       	jmp    8010673c <alltraps>

801072de <vector139>:
.globl vector139
vector139:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $139
801072e0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801072e5:	e9 52 f4 ff ff       	jmp    8010673c <alltraps>

801072ea <vector140>:
.globl vector140
vector140:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $140
801072ec:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801072f1:	e9 46 f4 ff ff       	jmp    8010673c <alltraps>

801072f6 <vector141>:
.globl vector141
vector141:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $141
801072f8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801072fd:	e9 3a f4 ff ff       	jmp    8010673c <alltraps>

80107302 <vector142>:
.globl vector142
vector142:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $142
80107304:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107309:	e9 2e f4 ff ff       	jmp    8010673c <alltraps>

8010730e <vector143>:
.globl vector143
vector143:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $143
80107310:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107315:	e9 22 f4 ff ff       	jmp    8010673c <alltraps>

8010731a <vector144>:
.globl vector144
vector144:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $144
8010731c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107321:	e9 16 f4 ff ff       	jmp    8010673c <alltraps>

80107326 <vector145>:
.globl vector145
vector145:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $145
80107328:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010732d:	e9 0a f4 ff ff       	jmp    8010673c <alltraps>

80107332 <vector146>:
.globl vector146
vector146:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $146
80107334:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107339:	e9 fe f3 ff ff       	jmp    8010673c <alltraps>

8010733e <vector147>:
.globl vector147
vector147:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $147
80107340:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107345:	e9 f2 f3 ff ff       	jmp    8010673c <alltraps>

8010734a <vector148>:
.globl vector148
vector148:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $148
8010734c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107351:	e9 e6 f3 ff ff       	jmp    8010673c <alltraps>

80107356 <vector149>:
.globl vector149
vector149:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $149
80107358:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010735d:	e9 da f3 ff ff       	jmp    8010673c <alltraps>

80107362 <vector150>:
.globl vector150
vector150:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $150
80107364:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107369:	e9 ce f3 ff ff       	jmp    8010673c <alltraps>

8010736e <vector151>:
.globl vector151
vector151:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $151
80107370:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107375:	e9 c2 f3 ff ff       	jmp    8010673c <alltraps>

8010737a <vector152>:
.globl vector152
vector152:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $152
8010737c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107381:	e9 b6 f3 ff ff       	jmp    8010673c <alltraps>

80107386 <vector153>:
.globl vector153
vector153:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $153
80107388:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010738d:	e9 aa f3 ff ff       	jmp    8010673c <alltraps>

80107392 <vector154>:
.globl vector154
vector154:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $154
80107394:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107399:	e9 9e f3 ff ff       	jmp    8010673c <alltraps>

8010739e <vector155>:
.globl vector155
vector155:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $155
801073a0:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801073a5:	e9 92 f3 ff ff       	jmp    8010673c <alltraps>

801073aa <vector156>:
.globl vector156
vector156:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $156
801073ac:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801073b1:	e9 86 f3 ff ff       	jmp    8010673c <alltraps>

801073b6 <vector157>:
.globl vector157
vector157:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $157
801073b8:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801073bd:	e9 7a f3 ff ff       	jmp    8010673c <alltraps>

801073c2 <vector158>:
.globl vector158
vector158:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $158
801073c4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801073c9:	e9 6e f3 ff ff       	jmp    8010673c <alltraps>

801073ce <vector159>:
.globl vector159
vector159:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $159
801073d0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801073d5:	e9 62 f3 ff ff       	jmp    8010673c <alltraps>

801073da <vector160>:
.globl vector160
vector160:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $160
801073dc:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801073e1:	e9 56 f3 ff ff       	jmp    8010673c <alltraps>

801073e6 <vector161>:
.globl vector161
vector161:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $161
801073e8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801073ed:	e9 4a f3 ff ff       	jmp    8010673c <alltraps>

801073f2 <vector162>:
.globl vector162
vector162:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $162
801073f4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801073f9:	e9 3e f3 ff ff       	jmp    8010673c <alltraps>

801073fe <vector163>:
.globl vector163
vector163:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $163
80107400:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107405:	e9 32 f3 ff ff       	jmp    8010673c <alltraps>

8010740a <vector164>:
.globl vector164
vector164:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $164
8010740c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107411:	e9 26 f3 ff ff       	jmp    8010673c <alltraps>

80107416 <vector165>:
.globl vector165
vector165:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $165
80107418:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
8010741d:	e9 1a f3 ff ff       	jmp    8010673c <alltraps>

80107422 <vector166>:
.globl vector166
vector166:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $166
80107424:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107429:	e9 0e f3 ff ff       	jmp    8010673c <alltraps>

8010742e <vector167>:
.globl vector167
vector167:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $167
80107430:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107435:	e9 02 f3 ff ff       	jmp    8010673c <alltraps>

8010743a <vector168>:
.globl vector168
vector168:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $168
8010743c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107441:	e9 f6 f2 ff ff       	jmp    8010673c <alltraps>

80107446 <vector169>:
.globl vector169
vector169:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $169
80107448:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010744d:	e9 ea f2 ff ff       	jmp    8010673c <alltraps>

80107452 <vector170>:
.globl vector170
vector170:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $170
80107454:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107459:	e9 de f2 ff ff       	jmp    8010673c <alltraps>

8010745e <vector171>:
.globl vector171
vector171:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $171
80107460:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107465:	e9 d2 f2 ff ff       	jmp    8010673c <alltraps>

8010746a <vector172>:
.globl vector172
vector172:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $172
8010746c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107471:	e9 c6 f2 ff ff       	jmp    8010673c <alltraps>

80107476 <vector173>:
.globl vector173
vector173:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $173
80107478:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010747d:	e9 ba f2 ff ff       	jmp    8010673c <alltraps>

80107482 <vector174>:
.globl vector174
vector174:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $174
80107484:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107489:	e9 ae f2 ff ff       	jmp    8010673c <alltraps>

8010748e <vector175>:
.globl vector175
vector175:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $175
80107490:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107495:	e9 a2 f2 ff ff       	jmp    8010673c <alltraps>

8010749a <vector176>:
.globl vector176
vector176:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $176
8010749c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801074a1:	e9 96 f2 ff ff       	jmp    8010673c <alltraps>

801074a6 <vector177>:
.globl vector177
vector177:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $177
801074a8:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801074ad:	e9 8a f2 ff ff       	jmp    8010673c <alltraps>

801074b2 <vector178>:
.globl vector178
vector178:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $178
801074b4:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801074b9:	e9 7e f2 ff ff       	jmp    8010673c <alltraps>

801074be <vector179>:
.globl vector179
vector179:
  pushl $0
801074be:	6a 00                	push   $0x0
  pushl $179
801074c0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801074c5:	e9 72 f2 ff ff       	jmp    8010673c <alltraps>

801074ca <vector180>:
.globl vector180
vector180:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $180
801074cc:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801074d1:	e9 66 f2 ff ff       	jmp    8010673c <alltraps>

801074d6 <vector181>:
.globl vector181
vector181:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $181
801074d8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801074dd:	e9 5a f2 ff ff       	jmp    8010673c <alltraps>

801074e2 <vector182>:
.globl vector182
vector182:
  pushl $0
801074e2:	6a 00                	push   $0x0
  pushl $182
801074e4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801074e9:	e9 4e f2 ff ff       	jmp    8010673c <alltraps>

801074ee <vector183>:
.globl vector183
vector183:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $183
801074f0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801074f5:	e9 42 f2 ff ff       	jmp    8010673c <alltraps>

801074fa <vector184>:
.globl vector184
vector184:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $184
801074fc:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107501:	e9 36 f2 ff ff       	jmp    8010673c <alltraps>

80107506 <vector185>:
.globl vector185
vector185:
  pushl $0
80107506:	6a 00                	push   $0x0
  pushl $185
80107508:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010750d:	e9 2a f2 ff ff       	jmp    8010673c <alltraps>

80107512 <vector186>:
.globl vector186
vector186:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $186
80107514:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107519:	e9 1e f2 ff ff       	jmp    8010673c <alltraps>

8010751e <vector187>:
.globl vector187
vector187:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $187
80107520:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107525:	e9 12 f2 ff ff       	jmp    8010673c <alltraps>

8010752a <vector188>:
.globl vector188
vector188:
  pushl $0
8010752a:	6a 00                	push   $0x0
  pushl $188
8010752c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107531:	e9 06 f2 ff ff       	jmp    8010673c <alltraps>

80107536 <vector189>:
.globl vector189
vector189:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $189
80107538:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010753d:	e9 fa f1 ff ff       	jmp    8010673c <alltraps>

80107542 <vector190>:
.globl vector190
vector190:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $190
80107544:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107549:	e9 ee f1 ff ff       	jmp    8010673c <alltraps>

8010754e <vector191>:
.globl vector191
vector191:
  pushl $0
8010754e:	6a 00                	push   $0x0
  pushl $191
80107550:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107555:	e9 e2 f1 ff ff       	jmp    8010673c <alltraps>

8010755a <vector192>:
.globl vector192
vector192:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $192
8010755c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107561:	e9 d6 f1 ff ff       	jmp    8010673c <alltraps>

80107566 <vector193>:
.globl vector193
vector193:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $193
80107568:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010756d:	e9 ca f1 ff ff       	jmp    8010673c <alltraps>

80107572 <vector194>:
.globl vector194
vector194:
  pushl $0
80107572:	6a 00                	push   $0x0
  pushl $194
80107574:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107579:	e9 be f1 ff ff       	jmp    8010673c <alltraps>

8010757e <vector195>:
.globl vector195
vector195:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $195
80107580:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107585:	e9 b2 f1 ff ff       	jmp    8010673c <alltraps>

8010758a <vector196>:
.globl vector196
vector196:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $196
8010758c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107591:	e9 a6 f1 ff ff       	jmp    8010673c <alltraps>

80107596 <vector197>:
.globl vector197
vector197:
  pushl $0
80107596:	6a 00                	push   $0x0
  pushl $197
80107598:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010759d:	e9 9a f1 ff ff       	jmp    8010673c <alltraps>

801075a2 <vector198>:
.globl vector198
vector198:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $198
801075a4:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801075a9:	e9 8e f1 ff ff       	jmp    8010673c <alltraps>

801075ae <vector199>:
.globl vector199
vector199:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $199
801075b0:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801075b5:	e9 82 f1 ff ff       	jmp    8010673c <alltraps>

801075ba <vector200>:
.globl vector200
vector200:
  pushl $0
801075ba:	6a 00                	push   $0x0
  pushl $200
801075bc:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801075c1:	e9 76 f1 ff ff       	jmp    8010673c <alltraps>

801075c6 <vector201>:
.globl vector201
vector201:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $201
801075c8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801075cd:	e9 6a f1 ff ff       	jmp    8010673c <alltraps>

801075d2 <vector202>:
.globl vector202
vector202:
  pushl $0
801075d2:	6a 00                	push   $0x0
  pushl $202
801075d4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801075d9:	e9 5e f1 ff ff       	jmp    8010673c <alltraps>

801075de <vector203>:
.globl vector203
vector203:
  pushl $0
801075de:	6a 00                	push   $0x0
  pushl $203
801075e0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801075e5:	e9 52 f1 ff ff       	jmp    8010673c <alltraps>

801075ea <vector204>:
.globl vector204
vector204:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $204
801075ec:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801075f1:	e9 46 f1 ff ff       	jmp    8010673c <alltraps>

801075f6 <vector205>:
.globl vector205
vector205:
  pushl $0
801075f6:	6a 00                	push   $0x0
  pushl $205
801075f8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801075fd:	e9 3a f1 ff ff       	jmp    8010673c <alltraps>

80107602 <vector206>:
.globl vector206
vector206:
  pushl $0
80107602:	6a 00                	push   $0x0
  pushl $206
80107604:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107609:	e9 2e f1 ff ff       	jmp    8010673c <alltraps>

8010760e <vector207>:
.globl vector207
vector207:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $207
80107610:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107615:	e9 22 f1 ff ff       	jmp    8010673c <alltraps>

8010761a <vector208>:
.globl vector208
vector208:
  pushl $0
8010761a:	6a 00                	push   $0x0
  pushl $208
8010761c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107621:	e9 16 f1 ff ff       	jmp    8010673c <alltraps>

80107626 <vector209>:
.globl vector209
vector209:
  pushl $0
80107626:	6a 00                	push   $0x0
  pushl $209
80107628:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010762d:	e9 0a f1 ff ff       	jmp    8010673c <alltraps>

80107632 <vector210>:
.globl vector210
vector210:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $210
80107634:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107639:	e9 fe f0 ff ff       	jmp    8010673c <alltraps>

8010763e <vector211>:
.globl vector211
vector211:
  pushl $0
8010763e:	6a 00                	push   $0x0
  pushl $211
80107640:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107645:	e9 f2 f0 ff ff       	jmp    8010673c <alltraps>

8010764a <vector212>:
.globl vector212
vector212:
  pushl $0
8010764a:	6a 00                	push   $0x0
  pushl $212
8010764c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107651:	e9 e6 f0 ff ff       	jmp    8010673c <alltraps>

80107656 <vector213>:
.globl vector213
vector213:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $213
80107658:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010765d:	e9 da f0 ff ff       	jmp    8010673c <alltraps>

80107662 <vector214>:
.globl vector214
vector214:
  pushl $0
80107662:	6a 00                	push   $0x0
  pushl $214
80107664:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107669:	e9 ce f0 ff ff       	jmp    8010673c <alltraps>

8010766e <vector215>:
.globl vector215
vector215:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $215
80107670:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107675:	e9 c2 f0 ff ff       	jmp    8010673c <alltraps>

8010767a <vector216>:
.globl vector216
vector216:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $216
8010767c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107681:	e9 b6 f0 ff ff       	jmp    8010673c <alltraps>

80107686 <vector217>:
.globl vector217
vector217:
  pushl $0
80107686:	6a 00                	push   $0x0
  pushl $217
80107688:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010768d:	e9 aa f0 ff ff       	jmp    8010673c <alltraps>

80107692 <vector218>:
.globl vector218
vector218:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $218
80107694:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107699:	e9 9e f0 ff ff       	jmp    8010673c <alltraps>

8010769e <vector219>:
.globl vector219
vector219:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $219
801076a0:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801076a5:	e9 92 f0 ff ff       	jmp    8010673c <alltraps>

801076aa <vector220>:
.globl vector220
vector220:
  pushl $0
801076aa:	6a 00                	push   $0x0
  pushl $220
801076ac:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801076b1:	e9 86 f0 ff ff       	jmp    8010673c <alltraps>

801076b6 <vector221>:
.globl vector221
vector221:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $221
801076b8:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801076bd:	e9 7a f0 ff ff       	jmp    8010673c <alltraps>

801076c2 <vector222>:
.globl vector222
vector222:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $222
801076c4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801076c9:	e9 6e f0 ff ff       	jmp    8010673c <alltraps>

801076ce <vector223>:
.globl vector223
vector223:
  pushl $0
801076ce:	6a 00                	push   $0x0
  pushl $223
801076d0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801076d5:	e9 62 f0 ff ff       	jmp    8010673c <alltraps>

801076da <vector224>:
.globl vector224
vector224:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $224
801076dc:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801076e1:	e9 56 f0 ff ff       	jmp    8010673c <alltraps>

801076e6 <vector225>:
.globl vector225
vector225:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $225
801076e8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801076ed:	e9 4a f0 ff ff       	jmp    8010673c <alltraps>

801076f2 <vector226>:
.globl vector226
vector226:
  pushl $0
801076f2:	6a 00                	push   $0x0
  pushl $226
801076f4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801076f9:	e9 3e f0 ff ff       	jmp    8010673c <alltraps>

801076fe <vector227>:
.globl vector227
vector227:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $227
80107700:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107705:	e9 32 f0 ff ff       	jmp    8010673c <alltraps>

8010770a <vector228>:
.globl vector228
vector228:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $228
8010770c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107711:	e9 26 f0 ff ff       	jmp    8010673c <alltraps>

80107716 <vector229>:
.globl vector229
vector229:
  pushl $0
80107716:	6a 00                	push   $0x0
  pushl $229
80107718:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010771d:	e9 1a f0 ff ff       	jmp    8010673c <alltraps>

80107722 <vector230>:
.globl vector230
vector230:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $230
80107724:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107729:	e9 0e f0 ff ff       	jmp    8010673c <alltraps>

8010772e <vector231>:
.globl vector231
vector231:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $231
80107730:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107735:	e9 02 f0 ff ff       	jmp    8010673c <alltraps>

8010773a <vector232>:
.globl vector232
vector232:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $232
8010773c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107741:	e9 f6 ef ff ff       	jmp    8010673c <alltraps>

80107746 <vector233>:
.globl vector233
vector233:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $233
80107748:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010774d:	e9 ea ef ff ff       	jmp    8010673c <alltraps>

80107752 <vector234>:
.globl vector234
vector234:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $234
80107754:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107759:	e9 de ef ff ff       	jmp    8010673c <alltraps>

8010775e <vector235>:
.globl vector235
vector235:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $235
80107760:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107765:	e9 d2 ef ff ff       	jmp    8010673c <alltraps>

8010776a <vector236>:
.globl vector236
vector236:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $236
8010776c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107771:	e9 c6 ef ff ff       	jmp    8010673c <alltraps>

80107776 <vector237>:
.globl vector237
vector237:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $237
80107778:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010777d:	e9 ba ef ff ff       	jmp    8010673c <alltraps>

80107782 <vector238>:
.globl vector238
vector238:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $238
80107784:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107789:	e9 ae ef ff ff       	jmp    8010673c <alltraps>

8010778e <vector239>:
.globl vector239
vector239:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $239
80107790:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107795:	e9 a2 ef ff ff       	jmp    8010673c <alltraps>

8010779a <vector240>:
.globl vector240
vector240:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $240
8010779c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801077a1:	e9 96 ef ff ff       	jmp    8010673c <alltraps>

801077a6 <vector241>:
.globl vector241
vector241:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $241
801077a8:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801077ad:	e9 8a ef ff ff       	jmp    8010673c <alltraps>

801077b2 <vector242>:
.globl vector242
vector242:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $242
801077b4:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801077b9:	e9 7e ef ff ff       	jmp    8010673c <alltraps>

801077be <vector243>:
.globl vector243
vector243:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $243
801077c0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801077c5:	e9 72 ef ff ff       	jmp    8010673c <alltraps>

801077ca <vector244>:
.globl vector244
vector244:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $244
801077cc:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801077d1:	e9 66 ef ff ff       	jmp    8010673c <alltraps>

801077d6 <vector245>:
.globl vector245
vector245:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $245
801077d8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801077dd:	e9 5a ef ff ff       	jmp    8010673c <alltraps>

801077e2 <vector246>:
.globl vector246
vector246:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $246
801077e4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801077e9:	e9 4e ef ff ff       	jmp    8010673c <alltraps>

801077ee <vector247>:
.globl vector247
vector247:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $247
801077f0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801077f5:	e9 42 ef ff ff       	jmp    8010673c <alltraps>

801077fa <vector248>:
.globl vector248
vector248:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $248
801077fc:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107801:	e9 36 ef ff ff       	jmp    8010673c <alltraps>

80107806 <vector249>:
.globl vector249
vector249:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $249
80107808:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010780d:	e9 2a ef ff ff       	jmp    8010673c <alltraps>

80107812 <vector250>:
.globl vector250
vector250:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $250
80107814:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107819:	e9 1e ef ff ff       	jmp    8010673c <alltraps>

8010781e <vector251>:
.globl vector251
vector251:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $251
80107820:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107825:	e9 12 ef ff ff       	jmp    8010673c <alltraps>

8010782a <vector252>:
.globl vector252
vector252:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $252
8010782c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107831:	e9 06 ef ff ff       	jmp    8010673c <alltraps>

80107836 <vector253>:
.globl vector253
vector253:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $253
80107838:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010783d:	e9 fa ee ff ff       	jmp    8010673c <alltraps>

80107842 <vector254>:
.globl vector254
vector254:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $254
80107844:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107849:	e9 ee ee ff ff       	jmp    8010673c <alltraps>

8010784e <vector255>:
.globl vector255
vector255:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $255
80107850:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107855:	e9 e2 ee ff ff       	jmp    8010673c <alltraps>
	...

8010785c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010785c:	55                   	push   %ebp
8010785d:	89 e5                	mov    %esp,%ebp
8010785f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107862:	8b 45 0c             	mov    0xc(%ebp),%eax
80107865:	83 e8 01             	sub    $0x1,%eax
80107868:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010786c:	8b 45 08             	mov    0x8(%ebp),%eax
8010786f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107873:	8b 45 08             	mov    0x8(%ebp),%eax
80107876:	c1 e8 10             	shr    $0x10,%eax
80107879:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010787d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107880:	0f 01 10             	lgdtl  (%eax)
}
80107883:	c9                   	leave  
80107884:	c3                   	ret    

80107885 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107885:	55                   	push   %ebp
80107886:	89 e5                	mov    %esp,%ebp
80107888:	83 ec 04             	sub    $0x4,%esp
8010788b:	8b 45 08             	mov    0x8(%ebp),%eax
8010788e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107892:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107896:	0f 00 d8             	ltr    %ax
}
80107899:	c9                   	leave  
8010789a:	c3                   	ret    

8010789b <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
8010789b:	55                   	push   %ebp
8010789c:	89 e5                	mov    %esp,%ebp
8010789e:	83 ec 04             	sub    $0x4,%esp
801078a1:	8b 45 08             	mov    0x8(%ebp),%eax
801078a4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801078a8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078ac:	8e e8                	mov    %eax,%gs
}
801078ae:	c9                   	leave  
801078af:	c3                   	ret    

801078b0 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801078b0:	55                   	push   %ebp
801078b1:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801078b3:	8b 45 08             	mov    0x8(%ebp),%eax
801078b6:	0f 22 d8             	mov    %eax,%cr3
}
801078b9:	5d                   	pop    %ebp
801078ba:	c3                   	ret    

801078bb <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801078bb:	55                   	push   %ebp
801078bc:	89 e5                	mov    %esp,%ebp
801078be:	8b 45 08             	mov    0x8(%ebp),%eax
801078c1:	05 00 00 00 80       	add    $0x80000000,%eax
801078c6:	5d                   	pop    %ebp
801078c7:	c3                   	ret    

801078c8 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801078c8:	55                   	push   %ebp
801078c9:	89 e5                	mov    %esp,%ebp
801078cb:	8b 45 08             	mov    0x8(%ebp),%eax
801078ce:	05 00 00 00 80       	add    $0x80000000,%eax
801078d3:	5d                   	pop    %ebp
801078d4:	c3                   	ret    

801078d5 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801078d5:	55                   	push   %ebp
801078d6:	89 e5                	mov    %esp,%ebp
801078d8:	53                   	push   %ebx
801078d9:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801078dc:	e8 e2 b5 ff ff       	call   80102ec3 <cpunum>
801078e1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801078e7:	05 60 23 11 80       	add    $0x80112360,%eax
801078ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801078ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801078f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078fb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107904:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010790f:	83 e2 f0             	and    $0xfffffff0,%edx
80107912:	83 ca 0a             	or     $0xa,%edx
80107915:	88 50 7d             	mov    %dl,0x7d(%eax)
80107918:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791b:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010791f:	83 ca 10             	or     $0x10,%edx
80107922:	88 50 7d             	mov    %dl,0x7d(%eax)
80107925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107928:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010792c:	83 e2 9f             	and    $0xffffff9f,%edx
8010792f:	88 50 7d             	mov    %dl,0x7d(%eax)
80107932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107935:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107939:	83 ca 80             	or     $0xffffff80,%edx
8010793c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010793f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107942:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107946:	83 ca 0f             	or     $0xf,%edx
80107949:	88 50 7e             	mov    %dl,0x7e(%eax)
8010794c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107953:	83 e2 ef             	and    $0xffffffef,%edx
80107956:	88 50 7e             	mov    %dl,0x7e(%eax)
80107959:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107960:	83 e2 df             	and    $0xffffffdf,%edx
80107963:	88 50 7e             	mov    %dl,0x7e(%eax)
80107966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107969:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010796d:	83 ca 40             	or     $0x40,%edx
80107970:	88 50 7e             	mov    %dl,0x7e(%eax)
80107973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107976:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010797a:	83 ca 80             	or     $0xffffff80,%edx
8010797d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107983:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107991:	ff ff 
80107993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107996:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010799d:	00 00 
8010799f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a2:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801079a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ac:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079b3:	83 e2 f0             	and    $0xfffffff0,%edx
801079b6:	83 ca 02             	or     $0x2,%edx
801079b9:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c2:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079c9:	83 ca 10             	or     $0x10,%edx
801079cc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079dc:	83 e2 9f             	and    $0xffffff9f,%edx
801079df:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079ef:	83 ca 80             	or     $0xffffff80,%edx
801079f2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079fb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a02:	83 ca 0f             	or     $0xf,%edx
80107a05:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0e:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a15:	83 e2 ef             	and    $0xffffffef,%edx
80107a18:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a21:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a28:	83 e2 df             	and    $0xffffffdf,%edx
80107a2b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a34:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a3b:	83 ca 40             	or     $0x40,%edx
80107a3e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a47:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a4e:	83 ca 80             	or     $0xffffff80,%edx
80107a51:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a64:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a6b:	ff ff 
80107a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a70:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a77:	00 00 
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a86:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107a8d:	83 e2 f0             	and    $0xfffffff0,%edx
80107a90:	83 ca 0a             	or     $0xa,%edx
80107a93:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107aa3:	83 ca 10             	or     $0x10,%edx
80107aa6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aaf:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ab6:	83 ca 60             	or     $0x60,%edx
80107ab9:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac2:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ac9:	83 ca 80             	or     $0xffffff80,%edx
80107acc:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107adc:	83 ca 0f             	or     $0xf,%edx
80107adf:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107aef:	83 e2 ef             	and    $0xffffffef,%edx
80107af2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b02:	83 e2 df             	and    $0xffffffdf,%edx
80107b05:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b15:	83 ca 40             	or     $0x40,%edx
80107b18:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b21:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b28:	83 ca 80             	or     $0xffffff80,%edx
80107b2b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b34:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3e:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107b45:	ff ff 
80107b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4a:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107b51:	00 00 
80107b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b56:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b60:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b67:	83 e2 f0             	and    $0xfffffff0,%edx
80107b6a:	83 ca 02             	or     $0x2,%edx
80107b6d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b76:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b7d:	83 ca 10             	or     $0x10,%edx
80107b80:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b89:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b90:	83 ca 60             	or     $0x60,%edx
80107b93:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ba3:	83 ca 80             	or     $0xffffff80,%edx
80107ba6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baf:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bb6:	83 ca 0f             	or     $0xf,%edx
80107bb9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc2:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bc9:	83 e2 ef             	and    $0xffffffef,%edx
80107bcc:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd5:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bdc:	83 e2 df             	and    $0xffffffdf,%edx
80107bdf:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107be5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be8:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bef:	83 ca 40             	or     $0x40,%edx
80107bf2:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfb:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c02:	83 ca 80             	or     $0xffffff80,%edx
80107c05:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0e:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c18:	05 b4 00 00 00       	add    $0xb4,%eax
80107c1d:	89 c3                	mov    %eax,%ebx
80107c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c22:	05 b4 00 00 00       	add    $0xb4,%eax
80107c27:	c1 e8 10             	shr    $0x10,%eax
80107c2a:	89 c1                	mov    %eax,%ecx
80107c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2f:	05 b4 00 00 00       	add    $0xb4,%eax
80107c34:	c1 e8 18             	shr    $0x18,%eax
80107c37:	89 c2                	mov    %eax,%edx
80107c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3c:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107c43:	00 00 
80107c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c48:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c52:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5b:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c62:	83 e1 f0             	and    $0xfffffff0,%ecx
80107c65:	83 c9 02             	or     $0x2,%ecx
80107c68:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c71:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c78:	83 c9 10             	or     $0x10,%ecx
80107c7b:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c84:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c8b:	83 e1 9f             	and    $0xffffff9f,%ecx
80107c8e:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c97:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c9e:	83 c9 80             	or     $0xffffff80,%ecx
80107ca1:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caa:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cb1:	83 e1 f0             	and    $0xfffffff0,%ecx
80107cb4:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbd:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cc4:	83 e1 ef             	and    $0xffffffef,%ecx
80107cc7:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd0:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cd7:	83 e1 df             	and    $0xffffffdf,%ecx
80107cda:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce3:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cea:	83 c9 40             	or     $0x40,%ecx
80107ced:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf6:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cfd:	83 c9 80             	or     $0xffffff80,%ecx
80107d00:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d09:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d12:	83 c0 70             	add    $0x70,%eax
80107d15:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107d1c:	00 
80107d1d:	89 04 24             	mov    %eax,(%esp)
80107d20:	e8 37 fb ff ff       	call   8010785c <lgdt>
  loadgs(SEG_KCPU << 3);
80107d25:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107d2c:	e8 6a fb ff ff       	call   8010789b <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d34:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107d3a:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107d41:	00 00 00 00 
}
80107d45:	83 c4 24             	add    $0x24,%esp
80107d48:	5b                   	pop    %ebx
80107d49:	5d                   	pop    %ebp
80107d4a:	c3                   	ret    

80107d4b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107d4b:	55                   	push   %ebp
80107d4c:	89 e5                	mov    %esp,%ebp
80107d4e:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107d51:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d54:	c1 e8 16             	shr    $0x16,%eax
80107d57:	c1 e0 02             	shl    $0x2,%eax
80107d5a:	03 45 08             	add    0x8(%ebp),%eax
80107d5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107d60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d63:	8b 00                	mov    (%eax),%eax
80107d65:	83 e0 01             	and    $0x1,%eax
80107d68:	84 c0                	test   %al,%al
80107d6a:	74 17                	je     80107d83 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d6f:	8b 00                	mov    (%eax),%eax
80107d71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d76:	89 04 24             	mov    %eax,(%esp)
80107d79:	e8 4a fb ff ff       	call   801078c8 <p2v>
80107d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d81:	eb 4b                	jmp    80107dce <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107d83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107d87:	74 0e                	je     80107d97 <walkpgdir+0x4c>
80107d89:	e8 7d ad ff ff       	call   80102b0b <kalloc>
80107d8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d91:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107d95:	75 07                	jne    80107d9e <walkpgdir+0x53>
      return 0;
80107d97:	b8 00 00 00 00       	mov    $0x0,%eax
80107d9c:	eb 41                	jmp    80107ddf <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107d9e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107da5:	00 
80107da6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107dad:	00 
80107dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db1:	89 04 24             	mov    %eax,(%esp)
80107db4:	e8 a9 d4 ff ff       	call   80105262 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbc:	89 04 24             	mov    %eax,(%esp)
80107dbf:	e8 f7 fa ff ff       	call   801078bb <v2p>
80107dc4:	89 c2                	mov    %eax,%edx
80107dc6:	83 ca 07             	or     $0x7,%edx
80107dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107dcc:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107dce:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dd1:	c1 e8 0c             	shr    $0xc,%eax
80107dd4:	25 ff 03 00 00       	and    $0x3ff,%eax
80107dd9:	c1 e0 02             	shl    $0x2,%eax
80107ddc:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107ddf:	c9                   	leave  
80107de0:	c3                   	ret    

80107de1 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107de1:	55                   	push   %ebp
80107de2:	89 e5                	mov    %esp,%ebp
80107de4:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107de7:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107def:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107df2:	8b 45 0c             	mov    0xc(%ebp),%eax
80107df5:	03 45 10             	add    0x10(%ebp),%eax
80107df8:	83 e8 01             	sub    $0x1,%eax
80107dfb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e00:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e03:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107e0a:	00 
80107e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e12:	8b 45 08             	mov    0x8(%ebp),%eax
80107e15:	89 04 24             	mov    %eax,(%esp)
80107e18:	e8 2e ff ff ff       	call   80107d4b <walkpgdir>
80107e1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e20:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e24:	75 07                	jne    80107e2d <mappages+0x4c>
      return -1;
80107e26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e2b:	eb 46                	jmp    80107e73 <mappages+0x92>
    if(*pte & PTE_P)
80107e2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e30:	8b 00                	mov    (%eax),%eax
80107e32:	83 e0 01             	and    $0x1,%eax
80107e35:	84 c0                	test   %al,%al
80107e37:	74 0c                	je     80107e45 <mappages+0x64>
      panic("remap");
80107e39:	c7 04 24 6c 8c 10 80 	movl   $0x80108c6c,(%esp)
80107e40:	e8 f8 86 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107e45:	8b 45 18             	mov    0x18(%ebp),%eax
80107e48:	0b 45 14             	or     0x14(%ebp),%eax
80107e4b:	89 c2                	mov    %eax,%edx
80107e4d:	83 ca 01             	or     $0x1,%edx
80107e50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e53:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e58:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107e5b:	74 10                	je     80107e6d <mappages+0x8c>
      break;
    a += PGSIZE;
80107e5d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107e64:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107e6b:	eb 96                	jmp    80107e03 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107e6d:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107e6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e73:	c9                   	leave  
80107e74:	c3                   	ret    

80107e75 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107e75:	55                   	push   %ebp
80107e76:	89 e5                	mov    %esp,%ebp
80107e78:	53                   	push   %ebx
80107e79:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107e7c:	e8 8a ac ff ff       	call   80102b0b <kalloc>
80107e81:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e88:	75 0a                	jne    80107e94 <setupkvm+0x1f>
    return 0;
80107e8a:	b8 00 00 00 00       	mov    $0x0,%eax
80107e8f:	e9 98 00 00 00       	jmp    80107f2c <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107e94:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e9b:	00 
80107e9c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ea3:	00 
80107ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ea7:	89 04 24             	mov    %eax,(%esp)
80107eaa:	e8 b3 d3 ff ff       	call   80105262 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107eaf:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107eb6:	e8 0d fa ff ff       	call   801078c8 <p2v>
80107ebb:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107ec0:	76 0c                	jbe    80107ece <setupkvm+0x59>
    panic("PHYSTOP too high");
80107ec2:	c7 04 24 72 8c 10 80 	movl   $0x80108c72,(%esp)
80107ec9:	e8 6f 86 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ece:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107ed5:	eb 49                	jmp    80107f20 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80107ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107eda:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107ee0:	8b 50 04             	mov    0x4(%eax),%edx
80107ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee6:	8b 58 08             	mov    0x8(%eax),%ebx
80107ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eec:	8b 40 04             	mov    0x4(%eax),%eax
80107eef:	29 c3                	sub    %eax,%ebx
80107ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef4:	8b 00                	mov    (%eax),%eax
80107ef6:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107efa:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107efe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107f02:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f09:	89 04 24             	mov    %eax,(%esp)
80107f0c:	e8 d0 fe ff ff       	call   80107de1 <mappages>
80107f11:	85 c0                	test   %eax,%eax
80107f13:	79 07                	jns    80107f1c <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107f15:	b8 00 00 00 00       	mov    $0x0,%eax
80107f1a:	eb 10                	jmp    80107f2c <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f1c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f20:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107f27:	72 ae                	jb     80107ed7 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107f2c:	83 c4 34             	add    $0x34,%esp
80107f2f:	5b                   	pop    %ebx
80107f30:	5d                   	pop    %ebp
80107f31:	c3                   	ret    

80107f32 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107f32:	55                   	push   %ebp
80107f33:	89 e5                	mov    %esp,%ebp
80107f35:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107f38:	e8 38 ff ff ff       	call   80107e75 <setupkvm>
80107f3d:	a3 38 52 11 80       	mov    %eax,0x80115238
  switchkvm();
80107f42:	e8 02 00 00 00       	call   80107f49 <switchkvm>
}
80107f47:	c9                   	leave  
80107f48:	c3                   	ret    

80107f49 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107f49:	55                   	push   %ebp
80107f4a:	89 e5                	mov    %esp,%ebp
80107f4c:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107f4f:	a1 38 52 11 80       	mov    0x80115238,%eax
80107f54:	89 04 24             	mov    %eax,(%esp)
80107f57:	e8 5f f9 ff ff       	call   801078bb <v2p>
80107f5c:	89 04 24             	mov    %eax,(%esp)
80107f5f:	e8 4c f9 ff ff       	call   801078b0 <lcr3>
}
80107f64:	c9                   	leave  
80107f65:	c3                   	ret    

80107f66 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107f66:	55                   	push   %ebp
80107f67:	89 e5                	mov    %esp,%ebp
80107f69:	53                   	push   %ebx
80107f6a:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107f6d:	e8 e9 d1 ff ff       	call   8010515b <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107f72:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f78:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107f7f:	83 c2 08             	add    $0x8,%edx
80107f82:	89 d3                	mov    %edx,%ebx
80107f84:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107f8b:	83 c2 08             	add    $0x8,%edx
80107f8e:	c1 ea 10             	shr    $0x10,%edx
80107f91:	89 d1                	mov    %edx,%ecx
80107f93:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107f9a:	83 c2 08             	add    $0x8,%edx
80107f9d:	c1 ea 18             	shr    $0x18,%edx
80107fa0:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107fa7:	67 00 
80107fa9:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107fb0:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107fb6:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107fbd:	83 e1 f0             	and    $0xfffffff0,%ecx
80107fc0:	83 c9 09             	or     $0x9,%ecx
80107fc3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107fc9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107fd0:	83 c9 10             	or     $0x10,%ecx
80107fd3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107fd9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107fe0:	83 e1 9f             	and    $0xffffff9f,%ecx
80107fe3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107fe9:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ff0:	83 c9 80             	or     $0xffffff80,%ecx
80107ff3:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ff9:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108000:	83 e1 f0             	and    $0xfffffff0,%ecx
80108003:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108009:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108010:	83 e1 ef             	and    $0xffffffef,%ecx
80108013:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108019:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108020:	83 e1 df             	and    $0xffffffdf,%ecx
80108023:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108029:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108030:	83 c9 40             	or     $0x40,%ecx
80108033:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108039:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108040:	83 e1 7f             	and    $0x7f,%ecx
80108043:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108049:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
8010804f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108055:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010805c:	83 e2 ef             	and    $0xffffffef,%edx
8010805f:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108065:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010806b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108071:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108077:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010807e:	8b 52 08             	mov    0x8(%edx),%edx
80108081:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108087:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010808a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80108091:	e8 ef f7 ff ff       	call   80107885 <ltr>
  if(p->pgdir == 0)
80108096:	8b 45 08             	mov    0x8(%ebp),%eax
80108099:	8b 40 04             	mov    0x4(%eax),%eax
8010809c:	85 c0                	test   %eax,%eax
8010809e:	75 0c                	jne    801080ac <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801080a0:	c7 04 24 83 8c 10 80 	movl   $0x80108c83,(%esp)
801080a7:	e8 91 84 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801080ac:	8b 45 08             	mov    0x8(%ebp),%eax
801080af:	8b 40 04             	mov    0x4(%eax),%eax
801080b2:	89 04 24             	mov    %eax,(%esp)
801080b5:	e8 01 f8 ff ff       	call   801078bb <v2p>
801080ba:	89 04 24             	mov    %eax,(%esp)
801080bd:	e8 ee f7 ff ff       	call   801078b0 <lcr3>
  popcli();
801080c2:	e8 dc d0 ff ff       	call   801051a3 <popcli>
}
801080c7:	83 c4 14             	add    $0x14,%esp
801080ca:	5b                   	pop    %ebx
801080cb:	5d                   	pop    %ebp
801080cc:	c3                   	ret    

801080cd <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801080cd:	55                   	push   %ebp
801080ce:	89 e5                	mov    %esp,%ebp
801080d0:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801080d3:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801080da:	76 0c                	jbe    801080e8 <inituvm+0x1b>
    panic("inituvm: more than a page");
801080dc:	c7 04 24 97 8c 10 80 	movl   $0x80108c97,(%esp)
801080e3:	e8 55 84 ff ff       	call   8010053d <panic>
  mem = kalloc();
801080e8:	e8 1e aa ff ff       	call   80102b0b <kalloc>
801080ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801080f0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080f7:	00 
801080f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801080ff:	00 
80108100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108103:	89 04 24             	mov    %eax,(%esp)
80108106:	e8 57 d1 ff ff       	call   80105262 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010810b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810e:	89 04 24             	mov    %eax,(%esp)
80108111:	e8 a5 f7 ff ff       	call   801078bb <v2p>
80108116:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010811d:	00 
8010811e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108122:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108129:	00 
8010812a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108131:	00 
80108132:	8b 45 08             	mov    0x8(%ebp),%eax
80108135:	89 04 24             	mov    %eax,(%esp)
80108138:	e8 a4 fc ff ff       	call   80107de1 <mappages>
  memmove(mem, init, sz);
8010813d:	8b 45 10             	mov    0x10(%ebp),%eax
80108140:	89 44 24 08          	mov    %eax,0x8(%esp)
80108144:	8b 45 0c             	mov    0xc(%ebp),%eax
80108147:	89 44 24 04          	mov    %eax,0x4(%esp)
8010814b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814e:	89 04 24             	mov    %eax,(%esp)
80108151:	e8 df d1 ff ff       	call   80105335 <memmove>
}
80108156:	c9                   	leave  
80108157:	c3                   	ret    

80108158 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108158:	55                   	push   %ebp
80108159:	89 e5                	mov    %esp,%ebp
8010815b:	53                   	push   %ebx
8010815c:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010815f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108162:	25 ff 0f 00 00       	and    $0xfff,%eax
80108167:	85 c0                	test   %eax,%eax
80108169:	74 0c                	je     80108177 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010816b:	c7 04 24 b4 8c 10 80 	movl   $0x80108cb4,(%esp)
80108172:	e8 c6 83 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108177:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010817e:	e9 ad 00 00 00       	jmp    80108230 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108186:	8b 55 0c             	mov    0xc(%ebp),%edx
80108189:	01 d0                	add    %edx,%eax
8010818b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108192:	00 
80108193:	89 44 24 04          	mov    %eax,0x4(%esp)
80108197:	8b 45 08             	mov    0x8(%ebp),%eax
8010819a:	89 04 24             	mov    %eax,(%esp)
8010819d:	e8 a9 fb ff ff       	call   80107d4b <walkpgdir>
801081a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081a5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081a9:	75 0c                	jne    801081b7 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801081ab:	c7 04 24 d7 8c 10 80 	movl   $0x80108cd7,(%esp)
801081b2:	e8 86 83 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801081b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081ba:	8b 00                	mov    (%eax),%eax
801081bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081c1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801081c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c7:	8b 55 18             	mov    0x18(%ebp),%edx
801081ca:	89 d1                	mov    %edx,%ecx
801081cc:	29 c1                	sub    %eax,%ecx
801081ce:	89 c8                	mov    %ecx,%eax
801081d0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801081d5:	77 11                	ja     801081e8 <loaduvm+0x90>
      n = sz - i;
801081d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081da:	8b 55 18             	mov    0x18(%ebp),%edx
801081dd:	89 d1                	mov    %edx,%ecx
801081df:	29 c1                	sub    %eax,%ecx
801081e1:	89 c8                	mov    %ecx,%eax
801081e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081e6:	eb 07                	jmp    801081ef <loaduvm+0x97>
    else
      n = PGSIZE;
801081e8:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801081ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f2:	8b 55 14             	mov    0x14(%ebp),%edx
801081f5:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801081f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801081fb:	89 04 24             	mov    %eax,(%esp)
801081fe:	e8 c5 f6 ff ff       	call   801078c8 <p2v>
80108203:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108206:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010820a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010820e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108212:	8b 45 10             	mov    0x10(%ebp),%eax
80108215:	89 04 24             	mov    %eax,(%esp)
80108218:	e8 4d 9b ff ff       	call   80101d6a <readi>
8010821d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108220:	74 07                	je     80108229 <loaduvm+0xd1>
      return -1;
80108222:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108227:	eb 18                	jmp    80108241 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108229:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108233:	3b 45 18             	cmp    0x18(%ebp),%eax
80108236:	0f 82 47 ff ff ff    	jb     80108183 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010823c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108241:	83 c4 24             	add    $0x24,%esp
80108244:	5b                   	pop    %ebx
80108245:	5d                   	pop    %ebp
80108246:	c3                   	ret    

80108247 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108247:	55                   	push   %ebp
80108248:	89 e5                	mov    %esp,%ebp
8010824a:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
8010824d:	8b 45 10             	mov    0x10(%ebp),%eax
80108250:	85 c0                	test   %eax,%eax
80108252:	79 0a                	jns    8010825e <allocuvm+0x17>
    return 0;
80108254:	b8 00 00 00 00       	mov    $0x0,%eax
80108259:	e9 c1 00 00 00       	jmp    8010831f <allocuvm+0xd8>
  if(newsz < oldsz)
8010825e:	8b 45 10             	mov    0x10(%ebp),%eax
80108261:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108264:	73 08                	jae    8010826e <allocuvm+0x27>
    return oldsz;
80108266:	8b 45 0c             	mov    0xc(%ebp),%eax
80108269:	e9 b1 00 00 00       	jmp    8010831f <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
8010826e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108271:	05 ff 0f 00 00       	add    $0xfff,%eax
80108276:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010827b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
8010827e:	e9 8d 00 00 00       	jmp    80108310 <allocuvm+0xc9>
    mem = kalloc();
80108283:	e8 83 a8 ff ff       	call   80102b0b <kalloc>
80108288:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010828b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010828f:	75 2c                	jne    801082bd <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80108291:	c7 04 24 f5 8c 10 80 	movl   $0x80108cf5,(%esp)
80108298:	e8 04 81 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010829d:	8b 45 0c             	mov    0xc(%ebp),%eax
801082a0:	89 44 24 08          	mov    %eax,0x8(%esp)
801082a4:	8b 45 10             	mov    0x10(%ebp),%eax
801082a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801082ab:	8b 45 08             	mov    0x8(%ebp),%eax
801082ae:	89 04 24             	mov    %eax,(%esp)
801082b1:	e8 6b 00 00 00       	call   80108321 <deallocuvm>
      return 0;
801082b6:	b8 00 00 00 00       	mov    $0x0,%eax
801082bb:	eb 62                	jmp    8010831f <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801082bd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082c4:	00 
801082c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082cc:	00 
801082cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082d0:	89 04 24             	mov    %eax,(%esp)
801082d3:	e8 8a cf ff ff       	call   80105262 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082db:	89 04 24             	mov    %eax,(%esp)
801082de:	e8 d8 f5 ff ff       	call   801078bb <v2p>
801082e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801082e6:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801082ed:	00 
801082ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
801082f2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082f9:	00 
801082fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801082fe:	8b 45 08             	mov    0x8(%ebp),%eax
80108301:	89 04 24             	mov    %eax,(%esp)
80108304:	e8 d8 fa ff ff       	call   80107de1 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108309:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108313:	3b 45 10             	cmp    0x10(%ebp),%eax
80108316:	0f 82 67 ff ff ff    	jb     80108283 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010831c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010831f:	c9                   	leave  
80108320:	c3                   	ret    

80108321 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108321:	55                   	push   %ebp
80108322:	89 e5                	mov    %esp,%ebp
80108324:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108327:	8b 45 10             	mov    0x10(%ebp),%eax
8010832a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010832d:	72 08                	jb     80108337 <deallocuvm+0x16>
    return oldsz;
8010832f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108332:	e9 a4 00 00 00       	jmp    801083db <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108337:	8b 45 10             	mov    0x10(%ebp),%eax
8010833a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010833f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108344:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108347:	e9 80 00 00 00       	jmp    801083cc <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010834c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010834f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108356:	00 
80108357:	89 44 24 04          	mov    %eax,0x4(%esp)
8010835b:	8b 45 08             	mov    0x8(%ebp),%eax
8010835e:	89 04 24             	mov    %eax,(%esp)
80108361:	e8 e5 f9 ff ff       	call   80107d4b <walkpgdir>
80108366:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108369:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010836d:	75 09                	jne    80108378 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
8010836f:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108376:	eb 4d                	jmp    801083c5 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108378:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010837b:	8b 00                	mov    (%eax),%eax
8010837d:	83 e0 01             	and    $0x1,%eax
80108380:	84 c0                	test   %al,%al
80108382:	74 41                	je     801083c5 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80108384:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108387:	8b 00                	mov    (%eax),%eax
80108389:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010838e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108391:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108395:	75 0c                	jne    801083a3 <deallocuvm+0x82>
        panic("kfree");
80108397:	c7 04 24 0d 8d 10 80 	movl   $0x80108d0d,(%esp)
8010839e:	e8 9a 81 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
801083a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a6:	89 04 24             	mov    %eax,(%esp)
801083a9:	e8 1a f5 ff ff       	call   801078c8 <p2v>
801083ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801083b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083b4:	89 04 24             	mov    %eax,(%esp)
801083b7:	e8 b6 a6 ff ff       	call   80102a72 <kfree>
      *pte = 0;
801083bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801083c5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083d2:	0f 82 74 ff ff ff    	jb     8010834c <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801083d8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083db:	c9                   	leave  
801083dc:	c3                   	ret    

801083dd <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801083dd:	55                   	push   %ebp
801083de:	89 e5                	mov    %esp,%ebp
801083e0:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801083e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801083e7:	75 0c                	jne    801083f5 <freevm+0x18>
    panic("freevm: no pgdir");
801083e9:	c7 04 24 13 8d 10 80 	movl   $0x80108d13,(%esp)
801083f0:	e8 48 81 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801083f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083fc:	00 
801083fd:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108404:	80 
80108405:	8b 45 08             	mov    0x8(%ebp),%eax
80108408:	89 04 24             	mov    %eax,(%esp)
8010840b:	e8 11 ff ff ff       	call   80108321 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108410:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108417:	eb 3c                	jmp    80108455 <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841c:	c1 e0 02             	shl    $0x2,%eax
8010841f:	03 45 08             	add    0x8(%ebp),%eax
80108422:	8b 00                	mov    (%eax),%eax
80108424:	83 e0 01             	and    $0x1,%eax
80108427:	84 c0                	test   %al,%al
80108429:	74 26                	je     80108451 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010842b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842e:	c1 e0 02             	shl    $0x2,%eax
80108431:	03 45 08             	add    0x8(%ebp),%eax
80108434:	8b 00                	mov    (%eax),%eax
80108436:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010843b:	89 04 24             	mov    %eax,(%esp)
8010843e:	e8 85 f4 ff ff       	call   801078c8 <p2v>
80108443:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108446:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108449:	89 04 24             	mov    %eax,(%esp)
8010844c:	e8 21 a6 ff ff       	call   80102a72 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108451:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108455:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010845c:	76 bb                	jbe    80108419 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010845e:	8b 45 08             	mov    0x8(%ebp),%eax
80108461:	89 04 24             	mov    %eax,(%esp)
80108464:	e8 09 a6 ff ff       	call   80102a72 <kfree>
}
80108469:	c9                   	leave  
8010846a:	c3                   	ret    

8010846b <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010846b:	55                   	push   %ebp
8010846c:	89 e5                	mov    %esp,%ebp
8010846e:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108471:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108478:	00 
80108479:	8b 45 0c             	mov    0xc(%ebp),%eax
8010847c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108480:	8b 45 08             	mov    0x8(%ebp),%eax
80108483:	89 04 24             	mov    %eax,(%esp)
80108486:	e8 c0 f8 ff ff       	call   80107d4b <walkpgdir>
8010848b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010848e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108492:	75 0c                	jne    801084a0 <clearpteu+0x35>
    panic("clearpteu");
80108494:	c7 04 24 24 8d 10 80 	movl   $0x80108d24,(%esp)
8010849b:	e8 9d 80 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
801084a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a3:	8b 00                	mov    (%eax),%eax
801084a5:	89 c2                	mov    %eax,%edx
801084a7:	83 e2 fb             	and    $0xfffffffb,%edx
801084aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ad:	89 10                	mov    %edx,(%eax)
}
801084af:	c9                   	leave  
801084b0:	c3                   	ret    

801084b1 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801084b1:	55                   	push   %ebp
801084b2:	89 e5                	mov    %esp,%ebp
801084b4:	53                   	push   %ebx
801084b5:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801084b8:	e8 b8 f9 ff ff       	call   80107e75 <setupkvm>
801084bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084c0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084c4:	75 0a                	jne    801084d0 <copyuvm+0x1f>
    return 0;
801084c6:	b8 00 00 00 00       	mov    $0x0,%eax
801084cb:	e9 fd 00 00 00       	jmp    801085cd <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801084d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084d7:	e9 cc 00 00 00       	jmp    801085a8 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801084dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084e6:	00 
801084e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801084eb:	8b 45 08             	mov    0x8(%ebp),%eax
801084ee:	89 04 24             	mov    %eax,(%esp)
801084f1:	e8 55 f8 ff ff       	call   80107d4b <walkpgdir>
801084f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801084f9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084fd:	75 0c                	jne    8010850b <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
801084ff:	c7 04 24 2e 8d 10 80 	movl   $0x80108d2e,(%esp)
80108506:	e8 32 80 ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
8010850b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010850e:	8b 00                	mov    (%eax),%eax
80108510:	83 e0 01             	and    $0x1,%eax
80108513:	85 c0                	test   %eax,%eax
80108515:	75 0c                	jne    80108523 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108517:	c7 04 24 48 8d 10 80 	movl   $0x80108d48,(%esp)
8010851e:	e8 1a 80 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108523:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108526:	8b 00                	mov    (%eax),%eax
80108528:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010852d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108530:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108533:	8b 00                	mov    (%eax),%eax
80108535:	25 ff 0f 00 00       	and    $0xfff,%eax
8010853a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
8010853d:	e8 c9 a5 ff ff       	call   80102b0b <kalloc>
80108542:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108545:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108549:	74 6e                	je     801085b9 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
8010854b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010854e:	89 04 24             	mov    %eax,(%esp)
80108551:	e8 72 f3 ff ff       	call   801078c8 <p2v>
80108556:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010855d:	00 
8010855e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108562:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108565:	89 04 24             	mov    %eax,(%esp)
80108568:	e8 c8 cd ff ff       	call   80105335 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010856d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108570:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108573:	89 04 24             	mov    %eax,(%esp)
80108576:	e8 40 f3 ff ff       	call   801078bb <v2p>
8010857b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010857e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108582:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108586:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010858d:	00 
8010858e:	89 54 24 04          	mov    %edx,0x4(%esp)
80108592:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108595:	89 04 24             	mov    %eax,(%esp)
80108598:	e8 44 f8 ff ff       	call   80107de1 <mappages>
8010859d:	85 c0                	test   %eax,%eax
8010859f:	78 1b                	js     801085bc <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801085a1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ab:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085ae:	0f 82 28 ff ff ff    	jb     801084dc <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801085b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b7:	eb 14                	jmp    801085cd <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801085b9:	90                   	nop
801085ba:	eb 01                	jmp    801085bd <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801085bc:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801085bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085c0:	89 04 24             	mov    %eax,(%esp)
801085c3:	e8 15 fe ff ff       	call   801083dd <freevm>
  return 0;
801085c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085cd:	83 c4 44             	add    $0x44,%esp
801085d0:	5b                   	pop    %ebx
801085d1:	5d                   	pop    %ebp
801085d2:	c3                   	ret    

801085d3 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801085d3:	55                   	push   %ebp
801085d4:	89 e5                	mov    %esp,%ebp
801085d6:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085e0:	00 
801085e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801085e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801085e8:	8b 45 08             	mov    0x8(%ebp),%eax
801085eb:	89 04 24             	mov    %eax,(%esp)
801085ee:	e8 58 f7 ff ff       	call   80107d4b <walkpgdir>
801085f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801085f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f9:	8b 00                	mov    (%eax),%eax
801085fb:	83 e0 01             	and    $0x1,%eax
801085fe:	85 c0                	test   %eax,%eax
80108600:	75 07                	jne    80108609 <uva2ka+0x36>
    return 0;
80108602:	b8 00 00 00 00       	mov    $0x0,%eax
80108607:	eb 25                	jmp    8010862e <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860c:	8b 00                	mov    (%eax),%eax
8010860e:	83 e0 04             	and    $0x4,%eax
80108611:	85 c0                	test   %eax,%eax
80108613:	75 07                	jne    8010861c <uva2ka+0x49>
    return 0;
80108615:	b8 00 00 00 00       	mov    $0x0,%eax
8010861a:	eb 12                	jmp    8010862e <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
8010861c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861f:	8b 00                	mov    (%eax),%eax
80108621:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108626:	89 04 24             	mov    %eax,(%esp)
80108629:	e8 9a f2 ff ff       	call   801078c8 <p2v>
}
8010862e:	c9                   	leave  
8010862f:	c3                   	ret    

80108630 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108630:	55                   	push   %ebp
80108631:	89 e5                	mov    %esp,%ebp
80108633:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108636:	8b 45 10             	mov    0x10(%ebp),%eax
80108639:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010863c:	e9 8b 00 00 00       	jmp    801086cc <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108641:	8b 45 0c             	mov    0xc(%ebp),%eax
80108644:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108649:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010864c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010864f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108653:	8b 45 08             	mov    0x8(%ebp),%eax
80108656:	89 04 24             	mov    %eax,(%esp)
80108659:	e8 75 ff ff ff       	call   801085d3 <uva2ka>
8010865e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108661:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108665:	75 07                	jne    8010866e <copyout+0x3e>
      return -1;
80108667:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010866c:	eb 6d                	jmp    801086db <copyout+0xab>
    n = PGSIZE - (va - va0);
8010866e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108671:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108674:	89 d1                	mov    %edx,%ecx
80108676:	29 c1                	sub    %eax,%ecx
80108678:	89 c8                	mov    %ecx,%eax
8010867a:	05 00 10 00 00       	add    $0x1000,%eax
8010867f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108682:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108685:	3b 45 14             	cmp    0x14(%ebp),%eax
80108688:	76 06                	jbe    80108690 <copyout+0x60>
      n = len;
8010868a:	8b 45 14             	mov    0x14(%ebp),%eax
8010868d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108690:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108693:	8b 55 0c             	mov    0xc(%ebp),%edx
80108696:	89 d1                	mov    %edx,%ecx
80108698:	29 c1                	sub    %eax,%ecx
8010869a:	89 c8                	mov    %ecx,%eax
8010869c:	03 45 e8             	add    -0x18(%ebp),%eax
8010869f:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086a2:	89 54 24 08          	mov    %edx,0x8(%esp)
801086a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086a9:	89 54 24 04          	mov    %edx,0x4(%esp)
801086ad:	89 04 24             	mov    %eax,(%esp)
801086b0:	e8 80 cc ff ff       	call   80105335 <memmove>
    len -= n;
801086b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086b8:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801086bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086be:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801086c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086c4:	05 00 10 00 00       	add    $0x1000,%eax
801086c9:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801086cc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801086d0:	0f 85 6b ff ff ff    	jne    80108641 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801086d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086db:	c9                   	leave  
801086dc:	c3                   	ret    
