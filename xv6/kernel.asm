
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
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
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
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 cb 37 10 80       	mov    $0x801037cb,%eax
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
8010003a:	c7 44 24 04 10 8c 10 	movl   $0x80108c10,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100049:	e8 38 53 00 00       	call   80105386 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 94 15 11 80       	mov    0x80111594,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
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
801000b6:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801000bd:	e8 e5 52 00 00       	call   801053a7 <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 94 15 11 80       	mov    0x80111594,%eax
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
801000fd:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
80100104:	e8 00 53 00 00       	call   80105409 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 d6 10 	movl   $0x8010d680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 9d 4f 00 00       	call   801050c1 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 90 15 11 80       	mov    0x80111590,%eax
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
80100175:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010017c:	e8 88 52 00 00       	call   80105409 <release>
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
8010018f:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 17 8c 10 80 	movl   $0x80108c17,(%esp)
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
801001d3:	e8 44 26 00 00       	call   8010281c <iderw>
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
801001ef:	c7 04 24 28 8c 10 80 	movl   $0x80108c28,(%esp)
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
80100210:	e8 07 26 00 00       	call   8010281c <iderw>
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
80100229:	c7 04 24 2f 8c 10 80 	movl   $0x80108c2f,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
8010023c:	e8 66 51 00 00       	call   801053a7 <acquire>

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
8010025f:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 94 15 11 80       	mov    0x80111594,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 94 15 11 80       	mov    %eax,0x80111594

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
8010029d:	e8 fb 4e 00 00       	call   8010519d <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 d6 10 80 	movl   $0x8010d680,(%esp)
801002a9:	e8 5b 51 00 00       	call   80105409 <release>
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
8010033f:	0f b6 90 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%edx
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
801003a7:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
801003bc:	e8 e6 4f 00 00       	call   801053a7 <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 36 8c 10 80 	movl   $0x80108c36,(%esp)
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
801004af:	c7 45 ec 3f 8c 10 80 	movl   $0x80108c3f,-0x14(%ebp)
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
8010052f:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100536:	e8 ce 4e 00 00       	call   80105409 <release>
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
80100548:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 46 8c 10 80 	movl   $0x80108c46,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 55 8c 10 80 	movl   $0x80108c55,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 c1 4e 00 00       	call   80105458 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 57 8c 10 80 	movl   $0x80108c57,(%esp)
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
801005c1:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
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
8010066d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
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
80100693:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 12 50 00 00       	call   801056c9 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	01 c0                	add    %eax,%eax
801006c5:	8b 15 00 a0 10 80    	mov    0x8010a000,%edx
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 ca                	add    %ecx,%edx
801006d2:	89 44 24 08          	mov    %eax,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 14 24             	mov    %edx,(%esp)
801006e1:	e8 10 4f 00 00       	call   801055f6 <memset>
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
8010073d:	a1 00 a0 10 80       	mov    0x8010a000,%eax
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
80100756:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
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
80100776:	e8 da 6a 00 00       	call   80107255 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 ce 6a 00 00       	call   80107255 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 c2 6a 00 00       	call   80107255 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 b5 6a 00 00       	call   80107255 <uartputc>
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
801007b3:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
801007ba:	e8 e8 4b 00 00       	call   801053a7 <acquire>
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
801007ea:	e8 54 4a 00 00       	call   80105243 <procdump>
      break;
801007ef:	e9 11 01 00 00       	jmp    80100905 <consoleintr+0x158>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 5c 18 11 80       	mov    %eax,0x8011185c
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
80100810:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100816:	a1 58 18 11 80       	mov    0x80111858,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	0f 84 db 00 00 00    	je     801008fe <consoleintr+0x151>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100823:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100828:	83 e8 01             	sub    $0x1,%eax
8010082b:	83 e0 7f             	and    $0x7f,%eax
8010082e:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
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
8010083e:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100844:	a1 58 18 11 80       	mov    0x80111858,%eax
80100849:	39 c2                	cmp    %eax,%edx
8010084b:	0f 84 b0 00 00 00    	je     80100901 <consoleintr+0x154>
        input.e--;
80100851:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100856:	83 e8 01             	sub    $0x1,%eax
80100859:	a3 5c 18 11 80       	mov    %eax,0x8011185c
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
80100879:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
8010087f:	a1 54 18 11 80       	mov    0x80111854,%eax
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
801008a2:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008a7:	89 c1                	mov    %eax,%ecx
801008a9:	83 e1 7f             	and    $0x7f,%ecx
801008ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008af:	88 91 d4 17 11 80    	mov    %dl,-0x7feee82c(%ecx)
801008b5:	83 c0 01             	add    $0x1,%eax
801008b8:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(c);
801008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008c0:	89 04 24             	mov    %eax,(%esp)
801008c3:	e8 88 fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c8:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008cc:	74 18                	je     801008e6 <consoleintr+0x139>
801008ce:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008d2:	74 12                	je     801008e6 <consoleintr+0x139>
801008d4:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008d9:	8b 15 54 18 11 80    	mov    0x80111854,%edx
801008df:	83 ea 80             	sub    $0xffffff80,%edx
801008e2:	39 d0                	cmp    %edx,%eax
801008e4:	75 1e                	jne    80100904 <consoleintr+0x157>
          input.w = input.e;
801008e6:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008eb:	a3 58 18 11 80       	mov    %eax,0x80111858
          wakeup(&input.r);
801008f0:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
801008f7:	e8 a1 48 00 00       	call   8010519d <wakeup>
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
80100917:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
8010091e:	e8 e6 4a 00 00       	call   80105409 <release>
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
80100931:	e8 e8 10 00 00       	call   80101a1e <iunlock>
  target = n;
80100936:	8b 45 10             	mov    0x10(%ebp),%eax
80100939:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010093c:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100943:	e8 5f 4a 00 00       	call   801053a7 <acquire>
  while(n > 0){
80100948:	e9 a8 00 00 00       	jmp    801009f5 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010094d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100953:	8b 40 28             	mov    0x28(%eax),%eax
80100956:	85 c0                	test   %eax,%eax
80100958:	74 21                	je     8010097b <consoleread+0x56>
        release(&input.lock);
8010095a:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100961:	e8 a3 4a 00 00       	call   80105409 <release>
        ilock(ip);
80100966:	8b 45 08             	mov    0x8(%ebp),%eax
80100969:	89 04 24             	mov    %eax,(%esp)
8010096c:	e8 5f 0f 00 00       	call   801018d0 <ilock>
        return -1;
80100971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100976:	e9 a9 00 00 00       	jmp    80100a24 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010097b:	c7 44 24 04 a0 17 11 	movl   $0x801117a0,0x4(%esp)
80100982:	80 
80100983:	c7 04 24 54 18 11 80 	movl   $0x80111854,(%esp)
8010098a:	e8 32 47 00 00       	call   801050c1 <sleep>
8010098f:	eb 01                	jmp    80100992 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100991:	90                   	nop
80100992:	8b 15 54 18 11 80    	mov    0x80111854,%edx
80100998:	a1 58 18 11 80       	mov    0x80111858,%eax
8010099d:	39 c2                	cmp    %eax,%edx
8010099f:	74 ac                	je     8010094d <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009a1:	a1 54 18 11 80       	mov    0x80111854,%eax
801009a6:	89 c2                	mov    %eax,%edx
801009a8:	83 e2 7f             	and    $0x7f,%edx
801009ab:	0f b6 92 d4 17 11 80 	movzbl -0x7feee82c(%edx),%edx
801009b2:	0f be d2             	movsbl %dl,%edx
801009b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801009b8:	83 c0 01             	add    $0x1,%eax
801009bb:	a3 54 18 11 80       	mov    %eax,0x80111854
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
801009ce:	a1 54 18 11 80       	mov    0x80111854,%eax
801009d3:	83 e8 01             	sub    $0x1,%eax
801009d6:	a3 54 18 11 80       	mov    %eax,0x80111854
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
80100a01:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100a08:	e8 fc 49 00 00       	call   80105409 <release>
  ilock(ip);
80100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a10:	89 04 24             	mov    %eax,(%esp)
80100a13:	e8 b8 0e 00 00       	call   801018d0 <ilock>

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
80100a32:	e8 e7 0f 00 00       	call   80101a1e <iunlock>
  acquire(&cons.lock);
80100a37:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a3e:	e8 64 49 00 00       	call   801053a7 <acquire>
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
80100a71:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100a78:	e8 8c 49 00 00       	call   80105409 <release>
  ilock(ip);
80100a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 48 0e 00 00       	call   801018d0 <ilock>

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
80100a93:	c7 44 24 04 5b 8c 10 	movl   $0x80108c5b,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 e0 c5 10 80 	movl   $0x8010c5e0,(%esp)
80100aa2:	e8 df 48 00 00       	call   80105386 <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 63 8c 10 	movl   $0x80108c63,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 a0 17 11 80 	movl   $0x801117a0,(%esp)
80100ab6:	e8 cb 48 00 00       	call   80105386 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100abb:	c7 05 0c 22 11 80 26 	movl   $0x80100a26,0x8011220c
80100ac2:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ac5:	c7 05 08 22 11 80 25 	movl   $0x80100925,0x80112208
80100acc:	09 10 80 
  cons.locking = 1;
80100acf:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100ad6:	00 00 00 

  picenable(IRQ_KBD);
80100ad9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae0:	e8 90 33 00 00       	call   80103e75 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100aec:	00 
80100aed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af4:	e8 e5 1e 00 00       	call   801029de <ioapicenable>
}
80100af9:	c9                   	leave  
80100afa:	c3                   	ret    
	...

80100afc <exec>:
extern void implicit_exit();
extern void implicit_exit_end();

int
exec(char *path, char **argv)
{
80100afc:	55                   	push   %ebp
80100afd:	89 e5                	mov    %esp,%ebp
80100aff:	81 ec 48 01 00 00    	sub    $0x148,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b05:	e8 b3 29 00 00       	call   801034bd <begin_op>
  if((ip = namei(path)) == 0){
80100b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80100b0d:	89 04 24             	mov    %eax,(%esp)
80100b10:	e8 5d 19 00 00       	call   80102472 <namei>
80100b15:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b18:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b1c:	75 0f                	jne    80100b2d <exec+0x31>
    end_op();
80100b1e:	e8 1b 2a 00 00       	call   8010353e <end_op>
    return -1;
80100b23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b28:	e9 36 04 00 00       	jmp    80100f63 <exec+0x467>
  }
  ilock(ip);
80100b2d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b30:	89 04 24             	mov    %eax,(%esp)
80100b33:	e8 98 0d 00 00       	call   801018d0 <ilock>
  pgdir = 0;
80100b38:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b3f:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b46:	00 
80100b47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b4e:	00 
80100b4f:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100b55:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b59:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b5c:	89 04 24             	mov    %eax,(%esp)
80100b5f:	e8 62 12 00 00       	call   80101dc6 <readi>
80100b64:	83 f8 33             	cmp    $0x33,%eax
80100b67:	0f 86 a8 03 00 00    	jbe    80100f15 <exec+0x419>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b6d:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
80100b73:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b78:	0f 85 9a 03 00 00    	jne    80100f18 <exec+0x41c>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100b7e:	e8 16 78 00 00       	call   80108399 <setupkvm>
80100b83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b86:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b8a:	0f 84 8b 03 00 00    	je     80100f1b <exec+0x41f>
    goto bad;

  // Load program into memory.
  sz = 0;
80100b90:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b97:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b9e:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
80100ba4:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ba7:	e9 c5 00 00 00       	jmp    80100c71 <exec+0x175>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100baf:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bb6:	00 
80100bb7:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bbb:	8d 85 e4 fe ff ff    	lea    -0x11c(%ebp),%eax
80100bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bc5:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bc8:	89 04 24             	mov    %eax,(%esp)
80100bcb:	e8 f6 11 00 00       	call   80101dc6 <readi>
80100bd0:	83 f8 20             	cmp    $0x20,%eax
80100bd3:	0f 85 45 03 00 00    	jne    80100f1e <exec+0x422>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100bd9:	8b 85 e4 fe ff ff    	mov    -0x11c(%ebp),%eax
80100bdf:	83 f8 01             	cmp    $0x1,%eax
80100be2:	75 7f                	jne    80100c63 <exec+0x167>
      continue;
    if(ph.memsz < ph.filesz)
80100be4:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100bea:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100bf0:	39 c2                	cmp    %eax,%edx
80100bf2:	0f 82 29 03 00 00    	jb     80100f21 <exec+0x425>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bf8:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100bfe:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c04:	01 d0                	add    %edx,%eax
80100c06:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c11:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c14:	89 04 24             	mov    %eax,(%esp)
80100c17:	e8 4f 7b 00 00       	call   8010876b <allocuvm>
80100c1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c1f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c23:	0f 84 fb 02 00 00    	je     80100f24 <exec+0x428>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c29:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c2f:	8b 95 e8 fe ff ff    	mov    -0x118(%ebp),%edx
80100c35:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c3b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c3f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c43:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c46:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c51:	89 04 24             	mov    %eax,(%esp)
80100c54:	e8 23 7a 00 00       	call   8010867c <loaduvm>
80100c59:	85 c0                	test   %eax,%eax
80100c5b:	0f 88 c6 02 00 00    	js     80100f27 <exec+0x42b>
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
80100c71:	0f b7 85 30 ff ff ff 	movzwl -0xd0(%ebp),%eax
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
80100c8a:	e8 c5 0e 00 00       	call   80101b54 <iunlockput>
  end_op();
80100c8f:	e8 aa 28 00 00       	call   8010353e <end_op>
  ip = 0;
80100c94:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)


  int retFuncSize = implicit_exit_end - implicit_exit;
80100c9b:	ba 0e 8c 10 80       	mov    $0x80108c0e,%edx
80100ca0:	b8 04 8c 10 80       	mov    $0x80108c04,%eax
80100ca5:	89 d1                	mov    %edx,%ecx
80100ca7:	29 c1                	sub    %eax,%ecx
80100ca9:	89 c8                	mov    %ecx,%eax
80100cab:	89 45 d0             	mov    %eax,-0x30(%ebp)
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cae:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb1:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cb6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cbb:	89 45 e0             	mov    %eax,-0x20(%ebp)

  if((sz = allocuvm(pgdir, sz, sz + (2*PGSIZE + retFuncSize))) == 0)
80100cbe:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100cc1:	03 45 e0             	add    -0x20(%ebp),%eax
80100cc4:	05 00 20 00 00       	add    $0x2000,%eax
80100cc9:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ccd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cd7:	89 04 24             	mov    %eax,(%esp)
80100cda:	e8 8c 7a 00 00       	call   8010876b <allocuvm>
80100cdf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce6:	0f 84 3e 02 00 00    	je     80100f2a <exec+0x42e>
    goto bad;
  clearpteu(pgdir, (char*)(sz - (2*PGSIZE + retFuncSize)));
80100cec:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100cef:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100cf2:	89 d1                	mov    %edx,%ecx
80100cf4:	29 c1                	sub    %eax,%ecx
80100cf6:	89 c8                	mov    %ecx,%eax
80100cf8:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d01:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d04:	89 04 24             	mov    %eax,(%esp)
80100d07:	e8 83 7c 00 00       	call   8010898f <clearpteu>


  sp = sz - retFuncSize;
80100d0c:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d0f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100d12:	89 d1                	mov    %edx,%ecx
80100d14:	29 c1                	sub    %eax,%ecx
80100d16:	89 c8                	mov    %ecx,%eax
80100d18:	89 45 dc             	mov    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, implicit_exit, retFuncSize) < 0)
80100d1b:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100d1e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100d22:	c7 44 24 08 04 8c 10 	movl   $0x80108c04,0x8(%esp)
80100d29:	80 
80100d2a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d31:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d34:	89 04 24             	mov    %eax,(%esp)
80100d37:	e8 18 7e 00 00       	call   80108b54 <copyout>
80100d3c:	85 c0                	test   %eax,%eax
80100d3e:	0f 88 e9 01 00 00    	js     80100f2d <exec+0x431>
    goto bad;

  uint userRetFuncAddress = sp;
80100d44:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d47:	89 45 cc             	mov    %eax,-0x34(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d4a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d51:	e9 81 00 00 00       	jmp    80100dd7 <exec+0x2db>
    if(argc >= MAXARG)
80100d56:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d5a:	0f 87 d0 01 00 00    	ja     80100f30 <exec+0x434>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d63:	c1 e0 02             	shl    $0x2,%eax
80100d66:	03 45 0c             	add    0xc(%ebp),%eax
80100d69:	8b 00                	mov    (%eax),%eax
80100d6b:	89 04 24             	mov    %eax,(%esp)
80100d6e:	e8 01 4b 00 00       	call   80105874 <strlen>
80100d73:	f7 d0                	not    %eax
80100d75:	03 45 dc             	add    -0x24(%ebp),%eax
80100d78:	83 e0 fc             	and    $0xfffffffc,%eax
80100d7b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d81:	c1 e0 02             	shl    $0x2,%eax
80100d84:	03 45 0c             	add    0xc(%ebp),%eax
80100d87:	8b 00                	mov    (%eax),%eax
80100d89:	89 04 24             	mov    %eax,(%esp)
80100d8c:	e8 e3 4a 00 00       	call   80105874 <strlen>
80100d91:	83 c0 01             	add    $0x1,%eax
80100d94:	89 c2                	mov    %eax,%edx
80100d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d99:	c1 e0 02             	shl    $0x2,%eax
80100d9c:	03 45 0c             	add    0xc(%ebp),%eax
80100d9f:	8b 00                	mov    (%eax),%eax
80100da1:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100da5:	89 44 24 08          	mov    %eax,0x8(%esp)
80100da9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dac:	89 44 24 04          	mov    %eax,0x4(%esp)
80100db0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100db3:	89 04 24             	mov    %eax,(%esp)
80100db6:	e8 99 7d 00 00       	call   80108b54 <copyout>
80100dbb:	85 c0                	test   %eax,%eax
80100dbd:	0f 88 70 01 00 00    	js     80100f33 <exec+0x437>
      goto bad;
    ustack[3+argc] = sp;
80100dc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc6:	8d 50 03             	lea    0x3(%eax),%edx
80100dc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dcc:	89 84 95 38 ff ff ff 	mov    %eax,-0xc8(%ebp,%edx,4)
    goto bad;

  uint userRetFuncAddress = sp;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dd3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dda:	c1 e0 02             	shl    $0x2,%eax
80100ddd:	03 45 0c             	add    0xc(%ebp),%eax
80100de0:	8b 00                	mov    (%eax),%eax
80100de2:	85 c0                	test   %eax,%eax
80100de4:	0f 85 6c ff ff ff    	jne    80100d56 <exec+0x25a>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ded:	83 c0 03             	add    $0x3,%eax
80100df0:	c7 84 85 38 ff ff ff 	movl   $0x0,-0xc8(%ebp,%eax,4)
80100df7:	00 00 00 00 



  ustack[0] = userRetFuncAddress;  // fake return PC
80100dfb:	8b 45 cc             	mov    -0x34(%ebp),%eax
80100dfe:	89 85 38 ff ff ff    	mov    %eax,-0xc8(%ebp)
  ustack[1] = argc;
80100e04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e07:	89 85 3c ff ff ff    	mov    %eax,-0xc4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e10:	83 c0 01             	add    $0x1,%eax
80100e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e1a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e1d:	29 d0                	sub    %edx,%eax
80100e1f:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)

  sp -= (3+argc+1) * 4;
80100e25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e28:	83 c0 04             	add    $0x4,%eax
80100e2b:	c1 e0 02             	shl    $0x2,%eax
80100e2e:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e34:	83 c0 04             	add    $0x4,%eax
80100e37:	c1 e0 02             	shl    $0x2,%eax
80100e3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100e3e:	8d 85 38 ff ff ff    	lea    -0xc8(%ebp),%eax
80100e44:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e48:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e4f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e52:	89 04 24             	mov    %eax,(%esp)
80100e55:	e8 fa 7c 00 00       	call   80108b54 <copyout>
80100e5a:	85 c0                	test   %eax,%eax
80100e5c:	0f 88 d4 00 00 00    	js     80100f36 <exec+0x43a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e62:	8b 45 08             	mov    0x8(%ebp),%eax
80100e65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e6e:	eb 17                	jmp    80100e87 <exec+0x38b>
    if(*s == '/')
80100e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e73:	0f b6 00             	movzbl (%eax),%eax
80100e76:	3c 2f                	cmp    $0x2f,%al
80100e78:	75 09                	jne    80100e83 <exec+0x387>
      last = s+1;
80100e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7d:	83 c0 01             	add    $0x1,%eax
80100e80:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e83:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e8a:	0f b6 00             	movzbl (%eax),%eax
80100e8d:	84 c0                	test   %al,%al
80100e8f:	75 df                	jne    80100e70 <exec+0x374>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e97:	8d 50 70             	lea    0x70(%eax),%edx
80100e9a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100ea1:	00 
80100ea2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100ea5:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ea9:	89 14 24             	mov    %edx,(%esp)
80100eac:	e8 75 49 00 00       	call   80105826 <safestrcpy>
//  cprintf("\n[debug] [%s] executing '%s' \n", TAG, last);
  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100eb1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb7:	8b 40 04             	mov    0x4(%eax),%eax
80100eba:	89 45 c8             	mov    %eax,-0x38(%ebp)
  proc->pgdir = pgdir;
80100ebd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ec6:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ec9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ecf:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ed2:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100ed4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eda:	8b 40 1c             	mov    0x1c(%eax),%eax
80100edd:	8b 95 1c ff ff ff    	mov    -0xe4(%ebp),%edx
80100ee3:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ee6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eec:	8b 40 1c             	mov    0x1c(%eax),%eax
80100eef:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ef2:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ef5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100efb:	89 04 24             	mov    %eax,(%esp)
80100efe:	e8 87 75 00 00       	call   8010848a <switchuvm>
  freevm(oldpgdir);
80100f03:	8b 45 c8             	mov    -0x38(%ebp),%eax
80100f06:	89 04 24             	mov    %eax,(%esp)
80100f09:	e8 f3 79 00 00       	call   80108901 <freevm>
  return 0;
80100f0e:	b8 00 00 00 00       	mov    $0x0,%eax
80100f13:	eb 4e                	jmp    80100f63 <exec+0x467>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f15:	90                   	nop
80100f16:	eb 1f                	jmp    80100f37 <exec+0x43b>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f18:	90                   	nop
80100f19:	eb 1c                	jmp    80100f37 <exec+0x43b>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f1b:	90                   	nop
80100f1c:	eb 19                	jmp    80100f37 <exec+0x43b>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f1e:	90                   	nop
80100f1f:	eb 16                	jmp    80100f37 <exec+0x43b>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f21:	90                   	nop
80100f22:	eb 13                	jmp    80100f37 <exec+0x43b>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f24:	90                   	nop
80100f25:	eb 10                	jmp    80100f37 <exec+0x43b>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f27:	90                   	nop
80100f28:	eb 0d                	jmp    80100f37 <exec+0x43b>
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);

  if((sz = allocuvm(pgdir, sz, sz + (2*PGSIZE + retFuncSize))) == 0)
    goto bad;
80100f2a:	90                   	nop
80100f2b:	eb 0a                	jmp    80100f37 <exec+0x43b>
  clearpteu(pgdir, (char*)(sz - (2*PGSIZE + retFuncSize)));


  sp = sz - retFuncSize;
  if(copyout(pgdir, sp, implicit_exit, retFuncSize) < 0)
    goto bad;
80100f2d:	90                   	nop
80100f2e:	eb 07                	jmp    80100f37 <exec+0x43b>
  uint userRetFuncAddress = sp;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f30:	90                   	nop
80100f31:	eb 04                	jmp    80100f37 <exec+0x43b>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f33:	90                   	nop
80100f34:	eb 01                	jmp    80100f37 <exec+0x43b>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f36:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f37:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f3b:	74 0b                	je     80100f48 <exec+0x44c>
    freevm(pgdir);
80100f3d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f40:	89 04 24             	mov    %eax,(%esp)
80100f43:	e8 b9 79 00 00       	call   80108901 <freevm>
  if(ip){
80100f48:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f4c:	74 10                	je     80100f5e <exec+0x462>
    iunlockput(ip);
80100f4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f51:	89 04 24             	mov    %eax,(%esp)
80100f54:	e8 fb 0b 00 00       	call   80101b54 <iunlockput>
    end_op();
80100f59:	e8 e0 25 00 00       	call   8010353e <end_op>
  }
  return -1;
80100f5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f63:	c9                   	leave  
80100f64:	c3                   	ret    
80100f65:	00 00                	add    %al,(%eax)
	...

80100f68 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f68:	55                   	push   %ebp
80100f69:	89 e5                	mov    %esp,%ebp
80100f6b:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f6e:	c7 44 24 04 69 8c 10 	movl   $0x80108c69,0x4(%esp)
80100f75:	80 
80100f76:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f7d:	e8 04 44 00 00       	call   80105386 <initlock>
}
80100f82:	c9                   	leave  
80100f83:	c3                   	ret    

80100f84 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f84:	55                   	push   %ebp
80100f85:	89 e5                	mov    %esp,%ebp
80100f87:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f8a:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100f91:	e8 11 44 00 00       	call   801053a7 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f96:	c7 45 f4 94 18 11 80 	movl   $0x80111894,-0xc(%ebp)
80100f9d:	eb 29                	jmp    80100fc8 <filealloc+0x44>
    if(f->ref == 0){
80100f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa2:	8b 40 04             	mov    0x4(%eax),%eax
80100fa5:	85 c0                	test   %eax,%eax
80100fa7:	75 1b                	jne    80100fc4 <filealloc+0x40>
      f->ref = 1;
80100fa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fac:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fb3:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fba:	e8 4a 44 00 00       	call   80105409 <release>
      return f;
80100fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc2:	eb 1e                	jmp    80100fe2 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fc4:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fc8:	81 7d f4 f4 21 11 80 	cmpl   $0x801121f4,-0xc(%ebp)
80100fcf:	72 ce                	jb     80100f9f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fd1:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100fd8:	e8 2c 44 00 00       	call   80105409 <release>
  return 0;
80100fdd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fe2:	c9                   	leave  
80100fe3:	c3                   	ret    

80100fe4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fe4:	55                   	push   %ebp
80100fe5:	89 e5                	mov    %esp,%ebp
80100fe7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fea:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80100ff1:	e8 b1 43 00 00       	call   801053a7 <acquire>
  if(f->ref < 1)
80100ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff9:	8b 40 04             	mov    0x4(%eax),%eax
80100ffc:	85 c0                	test   %eax,%eax
80100ffe:	7f 0c                	jg     8010100c <filedup+0x28>
    panic("filedup");
80101000:	c7 04 24 70 8c 10 80 	movl   $0x80108c70,(%esp)
80101007:	e8 31 f5 ff ff       	call   8010053d <panic>
  f->ref++;
8010100c:	8b 45 08             	mov    0x8(%ebp),%eax
8010100f:	8b 40 04             	mov    0x4(%eax),%eax
80101012:	8d 50 01             	lea    0x1(%eax),%edx
80101015:	8b 45 08             	mov    0x8(%ebp),%eax
80101018:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010101b:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80101022:	e8 e2 43 00 00       	call   80105409 <release>
  return f;
80101027:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010102a:	c9                   	leave  
8010102b:	c3                   	ret    

8010102c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010102c:	55                   	push   %ebp
8010102d:	89 e5                	mov    %esp,%ebp
8010102f:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80101032:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80101039:	e8 69 43 00 00       	call   801053a7 <acquire>
  if(f->ref < 1)
8010103e:	8b 45 08             	mov    0x8(%ebp),%eax
80101041:	8b 40 04             	mov    0x4(%eax),%eax
80101044:	85 c0                	test   %eax,%eax
80101046:	7f 0c                	jg     80101054 <fileclose+0x28>
    panic("fileclose");
80101048:	c7 04 24 78 8c 10 80 	movl   $0x80108c78,(%esp)
8010104f:	e8 e9 f4 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101054:	8b 45 08             	mov    0x8(%ebp),%eax
80101057:	8b 40 04             	mov    0x4(%eax),%eax
8010105a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010105d:	8b 45 08             	mov    0x8(%ebp),%eax
80101060:	89 50 04             	mov    %edx,0x4(%eax)
80101063:	8b 45 08             	mov    0x8(%ebp),%eax
80101066:	8b 40 04             	mov    0x4(%eax),%eax
80101069:	85 c0                	test   %eax,%eax
8010106b:	7e 11                	jle    8010107e <fileclose+0x52>
    release(&ftable.lock);
8010106d:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
80101074:	e8 90 43 00 00       	call   80105409 <release>
    return;
80101079:	e9 82 00 00 00       	jmp    80101100 <fileclose+0xd4>
  }
  ff = *f;
8010107e:	8b 45 08             	mov    0x8(%ebp),%eax
80101081:	8b 10                	mov    (%eax),%edx
80101083:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101086:	8b 50 04             	mov    0x4(%eax),%edx
80101089:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010108c:	8b 50 08             	mov    0x8(%eax),%edx
8010108f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101092:	8b 50 0c             	mov    0xc(%eax),%edx
80101095:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101098:	8b 50 10             	mov    0x10(%eax),%edx
8010109b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010109e:	8b 40 14             	mov    0x14(%eax),%eax
801010a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010a4:	8b 45 08             	mov    0x8(%ebp),%eax
801010a7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010b7:	c7 04 24 60 18 11 80 	movl   $0x80111860,(%esp)
801010be:	e8 46 43 00 00       	call   80105409 <release>
  
  if(ff.type == FD_PIPE)
801010c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010c6:	83 f8 01             	cmp    $0x1,%eax
801010c9:	75 18                	jne    801010e3 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
801010cb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010cf:	0f be d0             	movsbl %al,%edx
801010d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801010d9:	89 04 24             	mov    %eax,(%esp)
801010dc:	e8 4e 30 00 00       	call   8010412f <pipeclose>
801010e1:	eb 1d                	jmp    80101100 <fileclose+0xd4>
  else if(ff.type == FD_INODE){
801010e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010e6:	83 f8 02             	cmp    $0x2,%eax
801010e9:	75 15                	jne    80101100 <fileclose+0xd4>
    begin_op();
801010eb:	e8 cd 23 00 00       	call   801034bd <begin_op>
    iput(ff.ip);
801010f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010f3:	89 04 24             	mov    %eax,(%esp)
801010f6:	e8 88 09 00 00       	call   80101a83 <iput>
    end_op();
801010fb:	e8 3e 24 00 00       	call   8010353e <end_op>
  }
}
80101100:	c9                   	leave  
80101101:	c3                   	ret    

80101102 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101102:	55                   	push   %ebp
80101103:	89 e5                	mov    %esp,%ebp
80101105:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101108:	8b 45 08             	mov    0x8(%ebp),%eax
8010110b:	8b 00                	mov    (%eax),%eax
8010110d:	83 f8 02             	cmp    $0x2,%eax
80101110:	75 38                	jne    8010114a <filestat+0x48>
    ilock(f->ip);
80101112:	8b 45 08             	mov    0x8(%ebp),%eax
80101115:	8b 40 10             	mov    0x10(%eax),%eax
80101118:	89 04 24             	mov    %eax,(%esp)
8010111b:	e8 b0 07 00 00       	call   801018d0 <ilock>
    stati(f->ip, st);
80101120:	8b 45 08             	mov    0x8(%ebp),%eax
80101123:	8b 40 10             	mov    0x10(%eax),%eax
80101126:	8b 55 0c             	mov    0xc(%ebp),%edx
80101129:	89 54 24 04          	mov    %edx,0x4(%esp)
8010112d:	89 04 24             	mov    %eax,(%esp)
80101130:	e8 4c 0c 00 00       	call   80101d81 <stati>
    iunlock(f->ip);
80101135:	8b 45 08             	mov    0x8(%ebp),%eax
80101138:	8b 40 10             	mov    0x10(%eax),%eax
8010113b:	89 04 24             	mov    %eax,(%esp)
8010113e:	e8 db 08 00 00       	call   80101a1e <iunlock>
    return 0;
80101143:	b8 00 00 00 00       	mov    $0x0,%eax
80101148:	eb 05                	jmp    8010114f <filestat+0x4d>
  }
  return -1;
8010114a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010114f:	c9                   	leave  
80101150:	c3                   	ret    

80101151 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101151:	55                   	push   %ebp
80101152:	89 e5                	mov    %esp,%ebp
80101154:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101157:	8b 45 08             	mov    0x8(%ebp),%eax
8010115a:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010115e:	84 c0                	test   %al,%al
80101160:	75 0a                	jne    8010116c <fileread+0x1b>
    return -1;
80101162:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101167:	e9 9f 00 00 00       	jmp    8010120b <fileread+0xba>
  if(f->type == FD_PIPE)
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	8b 00                	mov    (%eax),%eax
80101171:	83 f8 01             	cmp    $0x1,%eax
80101174:	75 1e                	jne    80101194 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101176:	8b 45 08             	mov    0x8(%ebp),%eax
80101179:	8b 40 0c             	mov    0xc(%eax),%eax
8010117c:	8b 55 10             	mov    0x10(%ebp),%edx
8010117f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101183:	8b 55 0c             	mov    0xc(%ebp),%edx
80101186:	89 54 24 04          	mov    %edx,0x4(%esp)
8010118a:	89 04 24             	mov    %eax,(%esp)
8010118d:	e8 1f 31 00 00       	call   801042b1 <piperead>
80101192:	eb 77                	jmp    8010120b <fileread+0xba>
  if(f->type == FD_INODE){
80101194:	8b 45 08             	mov    0x8(%ebp),%eax
80101197:	8b 00                	mov    (%eax),%eax
80101199:	83 f8 02             	cmp    $0x2,%eax
8010119c:	75 61                	jne    801011ff <fileread+0xae>
    ilock(f->ip);
8010119e:	8b 45 08             	mov    0x8(%ebp),%eax
801011a1:	8b 40 10             	mov    0x10(%eax),%eax
801011a4:	89 04 24             	mov    %eax,(%esp)
801011a7:	e8 24 07 00 00       	call   801018d0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011af:	8b 45 08             	mov    0x8(%ebp),%eax
801011b2:	8b 50 14             	mov    0x14(%eax),%edx
801011b5:	8b 45 08             	mov    0x8(%ebp),%eax
801011b8:	8b 40 10             	mov    0x10(%eax),%eax
801011bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801011bf:	89 54 24 08          	mov    %edx,0x8(%esp)
801011c3:	8b 55 0c             	mov    0xc(%ebp),%edx
801011c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801011ca:	89 04 24             	mov    %eax,(%esp)
801011cd:	e8 f4 0b 00 00       	call   80101dc6 <readi>
801011d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011d9:	7e 11                	jle    801011ec <fileread+0x9b>
      f->off += r;
801011db:	8b 45 08             	mov    0x8(%ebp),%eax
801011de:	8b 50 14             	mov    0x14(%eax),%edx
801011e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011e4:	01 c2                	add    %eax,%edx
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011ec:	8b 45 08             	mov    0x8(%ebp),%eax
801011ef:	8b 40 10             	mov    0x10(%eax),%eax
801011f2:	89 04 24             	mov    %eax,(%esp)
801011f5:	e8 24 08 00 00       	call   80101a1e <iunlock>
    return r;
801011fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011fd:	eb 0c                	jmp    8010120b <fileread+0xba>
  }
  panic("fileread");
801011ff:	c7 04 24 82 8c 10 80 	movl   $0x80108c82,(%esp)
80101206:	e8 32 f3 ff ff       	call   8010053d <panic>
}
8010120b:	c9                   	leave  
8010120c:	c3                   	ret    

8010120d <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010120d:	55                   	push   %ebp
8010120e:	89 e5                	mov    %esp,%ebp
80101210:	53                   	push   %ebx
80101211:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101214:	8b 45 08             	mov    0x8(%ebp),%eax
80101217:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010121b:	84 c0                	test   %al,%al
8010121d:	75 0a                	jne    80101229 <filewrite+0x1c>
    return -1;
8010121f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101224:	e9 23 01 00 00       	jmp    8010134c <filewrite+0x13f>
  if(f->type == FD_PIPE)
80101229:	8b 45 08             	mov    0x8(%ebp),%eax
8010122c:	8b 00                	mov    (%eax),%eax
8010122e:	83 f8 01             	cmp    $0x1,%eax
80101231:	75 21                	jne    80101254 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
80101233:	8b 45 08             	mov    0x8(%ebp),%eax
80101236:	8b 40 0c             	mov    0xc(%eax),%eax
80101239:	8b 55 10             	mov    0x10(%ebp),%edx
8010123c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101240:	8b 55 0c             	mov    0xc(%ebp),%edx
80101243:	89 54 24 04          	mov    %edx,0x4(%esp)
80101247:	89 04 24             	mov    %eax,(%esp)
8010124a:	e8 72 2f 00 00       	call   801041c1 <pipewrite>
8010124f:	e9 f8 00 00 00       	jmp    8010134c <filewrite+0x13f>
  if(f->type == FD_INODE){
80101254:	8b 45 08             	mov    0x8(%ebp),%eax
80101257:	8b 00                	mov    (%eax),%eax
80101259:	83 f8 02             	cmp    $0x2,%eax
8010125c:	0f 85 de 00 00 00    	jne    80101340 <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101262:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101269:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101270:	e9 a8 00 00 00       	jmp    8010131d <filewrite+0x110>
      int n1 = n - i;
80101275:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101278:	8b 55 10             	mov    0x10(%ebp),%edx
8010127b:	89 d1                	mov    %edx,%ecx
8010127d:	29 c1                	sub    %eax,%ecx
8010127f:	89 c8                	mov    %ecx,%eax
80101281:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101284:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101287:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010128a:	7e 06                	jle    80101292 <filewrite+0x85>
        n1 = max;
8010128c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010128f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101292:	e8 26 22 00 00       	call   801034bd <begin_op>
      ilock(f->ip);
80101297:	8b 45 08             	mov    0x8(%ebp),%eax
8010129a:	8b 40 10             	mov    0x10(%eax),%eax
8010129d:	89 04 24             	mov    %eax,(%esp)
801012a0:	e8 2b 06 00 00       	call   801018d0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012a5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
801012a8:	8b 45 08             	mov    0x8(%ebp),%eax
801012ab:	8b 48 14             	mov    0x14(%eax),%ecx
801012ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b1:	89 c2                	mov    %eax,%edx
801012b3:	03 55 0c             	add    0xc(%ebp),%edx
801012b6:	8b 45 08             	mov    0x8(%ebp),%eax
801012b9:	8b 40 10             	mov    0x10(%eax),%eax
801012bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801012c0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801012c4:	89 54 24 04          	mov    %edx,0x4(%esp)
801012c8:	89 04 24             	mov    %eax,(%esp)
801012cb:	e8 61 0c 00 00       	call   80101f31 <writei>
801012d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012d3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012d7:	7e 11                	jle    801012ea <filewrite+0xdd>
        f->off += r;
801012d9:	8b 45 08             	mov    0x8(%ebp),%eax
801012dc:	8b 50 14             	mov    0x14(%eax),%edx
801012df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012e2:	01 c2                	add    %eax,%edx
801012e4:	8b 45 08             	mov    0x8(%ebp),%eax
801012e7:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012ea:	8b 45 08             	mov    0x8(%ebp),%eax
801012ed:	8b 40 10             	mov    0x10(%eax),%eax
801012f0:	89 04 24             	mov    %eax,(%esp)
801012f3:	e8 26 07 00 00       	call   80101a1e <iunlock>
      end_op();
801012f8:	e8 41 22 00 00       	call   8010353e <end_op>

      if(r < 0)
801012fd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101301:	78 28                	js     8010132b <filewrite+0x11e>
        break;
      if(r != n1)
80101303:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101306:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101309:	74 0c                	je     80101317 <filewrite+0x10a>
        panic("short filewrite");
8010130b:	c7 04 24 8b 8c 10 80 	movl   $0x80108c8b,(%esp)
80101312:	e8 26 f2 ff ff       	call   8010053d <panic>
      i += r;
80101317:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010131a:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010131d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101320:	3b 45 10             	cmp    0x10(%ebp),%eax
80101323:	0f 8c 4c ff ff ff    	jl     80101275 <filewrite+0x68>
80101329:	eb 01                	jmp    8010132c <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010132b:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010132c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101332:	75 05                	jne    80101339 <filewrite+0x12c>
80101334:	8b 45 10             	mov    0x10(%ebp),%eax
80101337:	eb 05                	jmp    8010133e <filewrite+0x131>
80101339:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010133e:	eb 0c                	jmp    8010134c <filewrite+0x13f>
  }
  panic("filewrite");
80101340:	c7 04 24 9b 8c 10 80 	movl   $0x80108c9b,(%esp)
80101347:	e8 f1 f1 ff ff       	call   8010053d <panic>
}
8010134c:	83 c4 24             	add    $0x24,%esp
8010134f:	5b                   	pop    %ebx
80101350:	5d                   	pop    %ebp
80101351:	c3                   	ret    
	...

80101354 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101354:	55                   	push   %ebp
80101355:	89 e5                	mov    %esp,%ebp
80101357:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010135a:	8b 45 08             	mov    0x8(%ebp),%eax
8010135d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101364:	00 
80101365:	89 04 24             	mov    %eax,(%esp)
80101368:	e8 39 ee ff ff       	call   801001a6 <bread>
8010136d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101373:	83 c0 18             	add    $0x18,%eax
80101376:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010137d:	00 
8010137e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101382:	8b 45 0c             	mov    0xc(%ebp),%eax
80101385:	89 04 24             	mov    %eax,(%esp)
80101388:	e8 3c 43 00 00       	call   801056c9 <memmove>
  brelse(bp);
8010138d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101390:	89 04 24             	mov    %eax,(%esp)
80101393:	e8 7f ee ff ff       	call   80100217 <brelse>
}
80101398:	c9                   	leave  
80101399:	c3                   	ret    

8010139a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010139a:	55                   	push   %ebp
8010139b:	89 e5                	mov    %esp,%ebp
8010139d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801013a3:	8b 45 08             	mov    0x8(%ebp),%eax
801013a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801013aa:	89 04 24             	mov    %eax,(%esp)
801013ad:	e8 f4 ed ff ff       	call   801001a6 <bread>
801013b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b8:	83 c0 18             	add    $0x18,%eax
801013bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801013c2:	00 
801013c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801013ca:	00 
801013cb:	89 04 24             	mov    %eax,(%esp)
801013ce:	e8 23 42 00 00       	call   801055f6 <memset>
  log_write(bp);
801013d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d6:	89 04 24             	mov    %eax,(%esp)
801013d9:	e8 e4 22 00 00       	call   801036c2 <log_write>
  brelse(bp);
801013de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e1:	89 04 24             	mov    %eax,(%esp)
801013e4:	e8 2e ee ff ff       	call   80100217 <brelse>
}
801013e9:	c9                   	leave  
801013ea:	c3                   	ret    

801013eb <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013eb:	55                   	push   %ebp
801013ec:	89 e5                	mov    %esp,%ebp
801013ee:	53                   	push   %ebx
801013ef:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801013f2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013f9:	8b 45 08             	mov    0x8(%ebp),%eax
801013fc:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013ff:	89 54 24 04          	mov    %edx,0x4(%esp)
80101403:	89 04 24             	mov    %eax,(%esp)
80101406:	e8 49 ff ff ff       	call   80101354 <readsb>
  for(b = 0; b < sb.size; b += BPB){
8010140b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101412:	e9 11 01 00 00       	jmp    80101528 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101420:	85 c0                	test   %eax,%eax
80101422:	0f 48 c2             	cmovs  %edx,%eax
80101425:	c1 f8 0c             	sar    $0xc,%eax
80101428:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010142b:	c1 ea 03             	shr    $0x3,%edx
8010142e:	01 d0                	add    %edx,%eax
80101430:	83 c0 03             	add    $0x3,%eax
80101433:	89 44 24 04          	mov    %eax,0x4(%esp)
80101437:	8b 45 08             	mov    0x8(%ebp),%eax
8010143a:	89 04 24             	mov    %eax,(%esp)
8010143d:	e8 64 ed ff ff       	call   801001a6 <bread>
80101442:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101445:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010144c:	e9 a7 00 00 00       	jmp    801014f8 <balloc+0x10d>
      m = 1 << (bi % 8);
80101451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101454:	89 c2                	mov    %eax,%edx
80101456:	c1 fa 1f             	sar    $0x1f,%edx
80101459:	c1 ea 1d             	shr    $0x1d,%edx
8010145c:	01 d0                	add    %edx,%eax
8010145e:	83 e0 07             	and    $0x7,%eax
80101461:	29 d0                	sub    %edx,%eax
80101463:	ba 01 00 00 00       	mov    $0x1,%edx
80101468:	89 d3                	mov    %edx,%ebx
8010146a:	89 c1                	mov    %eax,%ecx
8010146c:	d3 e3                	shl    %cl,%ebx
8010146e:	89 d8                	mov    %ebx,%eax
80101470:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101473:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101476:	8d 50 07             	lea    0x7(%eax),%edx
80101479:	85 c0                	test   %eax,%eax
8010147b:	0f 48 c2             	cmovs  %edx,%eax
8010147e:	c1 f8 03             	sar    $0x3,%eax
80101481:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101484:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101489:	0f b6 c0             	movzbl %al,%eax
8010148c:	23 45 e8             	and    -0x18(%ebp),%eax
8010148f:	85 c0                	test   %eax,%eax
80101491:	75 61                	jne    801014f4 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
80101493:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101496:	8d 50 07             	lea    0x7(%eax),%edx
80101499:	85 c0                	test   %eax,%eax
8010149b:	0f 48 c2             	cmovs  %edx,%eax
8010149e:	c1 f8 03             	sar    $0x3,%eax
801014a1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014a4:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014a9:	89 d1                	mov    %edx,%ecx
801014ab:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014ae:	09 ca                	or     %ecx,%edx
801014b0:	89 d1                	mov    %edx,%ecx
801014b2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014b5:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014bc:	89 04 24             	mov    %eax,(%esp)
801014bf:	e8 fe 21 00 00       	call   801036c2 <log_write>
        brelse(bp);
801014c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c7:	89 04 24             	mov    %eax,(%esp)
801014ca:	e8 48 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
801014cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d5:	01 c2                	add    %eax,%edx
801014d7:	8b 45 08             	mov    0x8(%ebp),%eax
801014da:	89 54 24 04          	mov    %edx,0x4(%esp)
801014de:	89 04 24             	mov    %eax,(%esp)
801014e1:	e8 b4 fe ff ff       	call   8010139a <bzero>
        return b + bi;
801014e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ec:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801014ee:	83 c4 34             	add    $0x34,%esp
801014f1:	5b                   	pop    %ebx
801014f2:	5d                   	pop    %ebp
801014f3:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014f4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014f8:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014ff:	7f 15                	jg     80101516 <balloc+0x12b>
80101501:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101504:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101507:	01 d0                	add    %edx,%eax
80101509:	89 c2                	mov    %eax,%edx
8010150b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010150e:	39 c2                	cmp    %eax,%edx
80101510:	0f 82 3b ff ff ff    	jb     80101451 <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101516:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101519:	89 04 24             	mov    %eax,(%esp)
8010151c:	e8 f6 ec ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101521:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101528:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010152b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010152e:	39 c2                	cmp    %eax,%edx
80101530:	0f 82 e1 fe ff ff    	jb     80101417 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101536:	c7 04 24 a5 8c 10 80 	movl   $0x80108ca5,(%esp)
8010153d:	e8 fb ef ff ff       	call   8010053d <panic>

80101542 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101542:	55                   	push   %ebp
80101543:	89 e5                	mov    %esp,%ebp
80101545:	53                   	push   %ebx
80101546:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101549:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010154c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101550:	8b 45 08             	mov    0x8(%ebp),%eax
80101553:	89 04 24             	mov    %eax,(%esp)
80101556:	e8 f9 fd ff ff       	call   80101354 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
8010155b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010155e:	89 c2                	mov    %eax,%edx
80101560:	c1 ea 0c             	shr    $0xc,%edx
80101563:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101566:	c1 e8 03             	shr    $0x3,%eax
80101569:	01 d0                	add    %edx,%eax
8010156b:	8d 50 03             	lea    0x3(%eax),%edx
8010156e:	8b 45 08             	mov    0x8(%ebp),%eax
80101571:	89 54 24 04          	mov    %edx,0x4(%esp)
80101575:	89 04 24             	mov    %eax,(%esp)
80101578:	e8 29 ec ff ff       	call   801001a6 <bread>
8010157d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101580:	8b 45 0c             	mov    0xc(%ebp),%eax
80101583:	25 ff 0f 00 00       	and    $0xfff,%eax
80101588:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010158b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010158e:	89 c2                	mov    %eax,%edx
80101590:	c1 fa 1f             	sar    $0x1f,%edx
80101593:	c1 ea 1d             	shr    $0x1d,%edx
80101596:	01 d0                	add    %edx,%eax
80101598:	83 e0 07             	and    $0x7,%eax
8010159b:	29 d0                	sub    %edx,%eax
8010159d:	ba 01 00 00 00       	mov    $0x1,%edx
801015a2:	89 d3                	mov    %edx,%ebx
801015a4:	89 c1                	mov    %eax,%ecx
801015a6:	d3 e3                	shl    %cl,%ebx
801015a8:	89 d8                	mov    %ebx,%eax
801015aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b0:	8d 50 07             	lea    0x7(%eax),%edx
801015b3:	85 c0                	test   %eax,%eax
801015b5:	0f 48 c2             	cmovs  %edx,%eax
801015b8:	c1 f8 03             	sar    $0x3,%eax
801015bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015be:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
801015c3:	0f b6 c0             	movzbl %al,%eax
801015c6:	23 45 ec             	and    -0x14(%ebp),%eax
801015c9:	85 c0                	test   %eax,%eax
801015cb:	75 0c                	jne    801015d9 <bfree+0x97>
    panic("freeing free block");
801015cd:	c7 04 24 bb 8c 10 80 	movl   $0x80108cbb,(%esp)
801015d4:	e8 64 ef ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
801015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015dc:	8d 50 07             	lea    0x7(%eax),%edx
801015df:	85 c0                	test   %eax,%eax
801015e1:	0f 48 c2             	cmovs  %edx,%eax
801015e4:	c1 f8 03             	sar    $0x3,%eax
801015e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ea:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015ef:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801015f2:	f7 d1                	not    %ecx
801015f4:	21 ca                	and    %ecx,%edx
801015f6:	89 d1                	mov    %edx,%ecx
801015f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015fb:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101602:	89 04 24             	mov    %eax,(%esp)
80101605:	e8 b8 20 00 00       	call   801036c2 <log_write>
  brelse(bp);
8010160a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010160d:	89 04 24             	mov    %eax,(%esp)
80101610:	e8 02 ec ff ff       	call   80100217 <brelse>
}
80101615:	83 c4 34             	add    $0x34,%esp
80101618:	5b                   	pop    %ebx
80101619:	5d                   	pop    %ebp
8010161a:	c3                   	ret    

8010161b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
8010161b:	55                   	push   %ebp
8010161c:	89 e5                	mov    %esp,%ebp
8010161e:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101621:	c7 44 24 04 ce 8c 10 	movl   $0x80108cce,0x4(%esp)
80101628:	80 
80101629:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101630:	e8 51 3d 00 00       	call   80105386 <initlock>
}
80101635:	c9                   	leave  
80101636:	c3                   	ret    

80101637 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101637:	55                   	push   %ebp
80101638:	89 e5                	mov    %esp,%ebp
8010163a:	83 ec 48             	sub    $0x48,%esp
8010163d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101640:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101644:	8b 45 08             	mov    0x8(%ebp),%eax
80101647:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010164a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010164e:	89 04 24             	mov    %eax,(%esp)
80101651:	e8 fe fc ff ff       	call   80101354 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101656:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010165d:	e9 98 00 00 00       	jmp    801016fa <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
80101662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101665:	c1 e8 03             	shr    $0x3,%eax
80101668:	83 c0 02             	add    $0x2,%eax
8010166b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010166f:	8b 45 08             	mov    0x8(%ebp),%eax
80101672:	89 04 24             	mov    %eax,(%esp)
80101675:	e8 2c eb ff ff       	call   801001a6 <bread>
8010167a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101680:	8d 50 18             	lea    0x18(%eax),%edx
80101683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101686:	83 e0 07             	and    $0x7,%eax
80101689:	c1 e0 06             	shl    $0x6,%eax
8010168c:	01 d0                	add    %edx,%eax
8010168e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101691:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101694:	0f b7 00             	movzwl (%eax),%eax
80101697:	66 85 c0             	test   %ax,%ax
8010169a:	75 4f                	jne    801016eb <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
8010169c:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801016a3:	00 
801016a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801016ab:	00 
801016ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016af:	89 04 24             	mov    %eax,(%esp)
801016b2:	e8 3f 3f 00 00       	call   801055f6 <memset>
      dip->type = type;
801016b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016ba:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801016be:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016c4:	89 04 24             	mov    %eax,(%esp)
801016c7:	e8 f6 1f 00 00       	call   801036c2 <log_write>
      brelse(bp);
801016cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016cf:	89 04 24             	mov    %eax,(%esp)
801016d2:	e8 40 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
801016d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016da:	89 44 24 04          	mov    %eax,0x4(%esp)
801016de:	8b 45 08             	mov    0x8(%ebp),%eax
801016e1:	89 04 24             	mov    %eax,(%esp)
801016e4:	e8 e3 00 00 00       	call   801017cc <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
801016e9:	c9                   	leave  
801016ea:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801016eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ee:	89 04 24             	mov    %eax,(%esp)
801016f1:	e8 21 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801016f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101700:	39 c2                	cmp    %eax,%edx
80101702:	0f 82 5a ff ff ff    	jb     80101662 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101708:	c7 04 24 d5 8c 10 80 	movl   $0x80108cd5,(%esp)
8010170f:	e8 29 ee ff ff       	call   8010053d <panic>

80101714 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101714:	55                   	push   %ebp
80101715:	89 e5                	mov    %esp,%ebp
80101717:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010171a:	8b 45 08             	mov    0x8(%ebp),%eax
8010171d:	8b 40 04             	mov    0x4(%eax),%eax
80101720:	c1 e8 03             	shr    $0x3,%eax
80101723:	8d 50 02             	lea    0x2(%eax),%edx
80101726:	8b 45 08             	mov    0x8(%ebp),%eax
80101729:	8b 00                	mov    (%eax),%eax
8010172b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010172f:	89 04 24             	mov    %eax,(%esp)
80101732:	e8 6f ea ff ff       	call   801001a6 <bread>
80101737:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010173a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010173d:	8d 50 18             	lea    0x18(%eax),%edx
80101740:	8b 45 08             	mov    0x8(%ebp),%eax
80101743:	8b 40 04             	mov    0x4(%eax),%eax
80101746:	83 e0 07             	and    $0x7,%eax
80101749:	c1 e0 06             	shl    $0x6,%eax
8010174c:	01 d0                	add    %edx,%eax
8010174e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101751:	8b 45 08             	mov    0x8(%ebp),%eax
80101754:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101758:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010175b:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010175e:	8b 45 08             	mov    0x8(%ebp),%eax
80101761:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101765:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101768:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010176c:	8b 45 08             	mov    0x8(%ebp),%eax
8010176f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101773:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101776:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010177a:	8b 45 08             	mov    0x8(%ebp),%eax
8010177d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101781:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101784:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101788:	8b 45 08             	mov    0x8(%ebp),%eax
8010178b:	8b 50 18             	mov    0x18(%eax),%edx
8010178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101791:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101794:	8b 45 08             	mov    0x8(%ebp),%eax
80101797:	8d 50 1c             	lea    0x1c(%eax),%edx
8010179a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010179d:	83 c0 0c             	add    $0xc,%eax
801017a0:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801017a7:	00 
801017a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801017ac:	89 04 24             	mov    %eax,(%esp)
801017af:	e8 15 3f 00 00       	call   801056c9 <memmove>
  log_write(bp);
801017b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b7:	89 04 24             	mov    %eax,(%esp)
801017ba:	e8 03 1f 00 00       	call   801036c2 <log_write>
  brelse(bp);
801017bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c2:	89 04 24             	mov    %eax,(%esp)
801017c5:	e8 4d ea ff ff       	call   80100217 <brelse>
}
801017ca:	c9                   	leave  
801017cb:	c3                   	ret    

801017cc <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017cc:	55                   	push   %ebp
801017cd:	89 e5                	mov    %esp,%ebp
801017cf:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017d2:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801017d9:	e8 c9 3b 00 00       	call   801053a7 <acquire>

  // Is the inode already cached?
  empty = 0;
801017de:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017e5:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
801017ec:	eb 59                	jmp    80101847 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f1:	8b 40 08             	mov    0x8(%eax),%eax
801017f4:	85 c0                	test   %eax,%eax
801017f6:	7e 35                	jle    8010182d <iget+0x61>
801017f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fb:	8b 00                	mov    (%eax),%eax
801017fd:	3b 45 08             	cmp    0x8(%ebp),%eax
80101800:	75 2b                	jne    8010182d <iget+0x61>
80101802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101805:	8b 40 04             	mov    0x4(%eax),%eax
80101808:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010180b:	75 20                	jne    8010182d <iget+0x61>
      ip->ref++;
8010180d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101810:	8b 40 08             	mov    0x8(%eax),%eax
80101813:	8d 50 01             	lea    0x1(%eax),%edx
80101816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101819:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010181c:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101823:	e8 e1 3b 00 00       	call   80105409 <release>
      return ip;
80101828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182b:	eb 6f                	jmp    8010189c <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010182d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101831:	75 10                	jne    80101843 <iget+0x77>
80101833:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101836:	8b 40 08             	mov    0x8(%eax),%eax
80101839:	85 c0                	test   %eax,%eax
8010183b:	75 06                	jne    80101843 <iget+0x77>
      empty = ip;
8010183d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101840:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101843:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101847:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
8010184e:	72 9e                	jb     801017ee <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101850:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101854:	75 0c                	jne    80101862 <iget+0x96>
    panic("iget: no inodes");
80101856:	c7 04 24 e7 8c 10 80 	movl   $0x80108ce7,(%esp)
8010185d:	e8 db ec ff ff       	call   8010053d <panic>

  ip = empty;
80101862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101865:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101868:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186b:	8b 55 08             	mov    0x8(%ebp),%edx
8010186e:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101873:	8b 55 0c             	mov    0xc(%ebp),%edx
80101876:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101886:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010188d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101894:	e8 70 3b 00 00       	call   80105409 <release>

  return ip;
80101899:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010189c:	c9                   	leave  
8010189d:	c3                   	ret    

8010189e <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010189e:	55                   	push   %ebp
8010189f:	89 e5                	mov    %esp,%ebp
801018a1:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801018a4:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801018ab:	e8 f7 3a 00 00       	call   801053a7 <acquire>
  ip->ref++;
801018b0:	8b 45 08             	mov    0x8(%ebp),%eax
801018b3:	8b 40 08             	mov    0x8(%eax),%eax
801018b6:	8d 50 01             	lea    0x1(%eax),%edx
801018b9:	8b 45 08             	mov    0x8(%ebp),%eax
801018bc:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018bf:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801018c6:	e8 3e 3b 00 00       	call   80105409 <release>
  return ip;
801018cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801018ce:	c9                   	leave  
801018cf:	c3                   	ret    

801018d0 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801018d0:	55                   	push   %ebp
801018d1:	89 e5                	mov    %esp,%ebp
801018d3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801018d6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801018da:	74 0a                	je     801018e6 <ilock+0x16>
801018dc:	8b 45 08             	mov    0x8(%ebp),%eax
801018df:	8b 40 08             	mov    0x8(%eax),%eax
801018e2:	85 c0                	test   %eax,%eax
801018e4:	7f 0c                	jg     801018f2 <ilock+0x22>
    panic("ilock");
801018e6:	c7 04 24 f7 8c 10 80 	movl   $0x80108cf7,(%esp)
801018ed:	e8 4b ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801018f2:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801018f9:	e8 a9 3a 00 00       	call   801053a7 <acquire>
  while(ip->flags & I_BUSY)
801018fe:	eb 13                	jmp    80101913 <ilock+0x43>
    sleep(ip, &icache.lock);
80101900:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
80101907:	80 
80101908:	8b 45 08             	mov    0x8(%ebp),%eax
8010190b:	89 04 24             	mov    %eax,(%esp)
8010190e:	e8 ae 37 00 00       	call   801050c1 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101913:	8b 45 08             	mov    0x8(%ebp),%eax
80101916:	8b 40 0c             	mov    0xc(%eax),%eax
80101919:	83 e0 01             	and    $0x1,%eax
8010191c:	84 c0                	test   %al,%al
8010191e:	75 e0                	jne    80101900 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101920:	8b 45 08             	mov    0x8(%ebp),%eax
80101923:	8b 40 0c             	mov    0xc(%eax),%eax
80101926:	89 c2                	mov    %eax,%edx
80101928:	83 ca 01             	or     $0x1,%edx
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101931:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101938:	e8 cc 3a 00 00       	call   80105409 <release>

  if(!(ip->flags & I_VALID)){
8010193d:	8b 45 08             	mov    0x8(%ebp),%eax
80101940:	8b 40 0c             	mov    0xc(%eax),%eax
80101943:	83 e0 02             	and    $0x2,%eax
80101946:	85 c0                	test   %eax,%eax
80101948:	0f 85 ce 00 00 00    	jne    80101a1c <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
8010194e:	8b 45 08             	mov    0x8(%ebp),%eax
80101951:	8b 40 04             	mov    0x4(%eax),%eax
80101954:	c1 e8 03             	shr    $0x3,%eax
80101957:	8d 50 02             	lea    0x2(%eax),%edx
8010195a:	8b 45 08             	mov    0x8(%ebp),%eax
8010195d:	8b 00                	mov    (%eax),%eax
8010195f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101963:	89 04 24             	mov    %eax,(%esp)
80101966:	e8 3b e8 ff ff       	call   801001a6 <bread>
8010196b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010196e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101971:	8d 50 18             	lea    0x18(%eax),%edx
80101974:	8b 45 08             	mov    0x8(%ebp),%eax
80101977:	8b 40 04             	mov    0x4(%eax),%eax
8010197a:	83 e0 07             	and    $0x7,%eax
8010197d:	c1 e0 06             	shl    $0x6,%eax
80101980:	01 d0                	add    %edx,%eax
80101982:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101985:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101988:	0f b7 10             	movzwl (%eax),%edx
8010198b:	8b 45 08             	mov    0x8(%ebp),%eax
8010198e:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101992:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101995:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101999:	8b 45 08             	mov    0x8(%ebp),%eax
8010199c:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a3:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019a7:	8b 45 08             	mov    0x8(%ebp),%eax
801019aa:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019b1:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019b5:	8b 45 08             	mov    0x8(%ebp),%eax
801019b8:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
801019bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bf:	8b 50 08             	mov    0x8(%eax),%edx
801019c2:	8b 45 08             	mov    0x8(%ebp),%eax
801019c5:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801019c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cb:	8d 50 0c             	lea    0xc(%eax),%edx
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	83 c0 1c             	add    $0x1c,%eax
801019d4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019db:	00 
801019dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801019e0:	89 04 24             	mov    %eax,(%esp)
801019e3:	e8 e1 3c 00 00       	call   801056c9 <memmove>
    brelse(bp);
801019e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019eb:	89 04 24             	mov    %eax,(%esp)
801019ee:	e8 24 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
801019f3:	8b 45 08             	mov    0x8(%ebp),%eax
801019f6:	8b 40 0c             	mov    0xc(%eax),%eax
801019f9:	89 c2                	mov    %eax,%edx
801019fb:	83 ca 02             	or     $0x2,%edx
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a04:	8b 45 08             	mov    0x8(%ebp),%eax
80101a07:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a0b:	66 85 c0             	test   %ax,%ax
80101a0e:	75 0c                	jne    80101a1c <ilock+0x14c>
      panic("ilock: no type");
80101a10:	c7 04 24 fd 8c 10 80 	movl   $0x80108cfd,(%esp)
80101a17:	e8 21 eb ff ff       	call   8010053d <panic>
  }
}
80101a1c:	c9                   	leave  
80101a1d:	c3                   	ret    

80101a1e <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a1e:	55                   	push   %ebp
80101a1f:	89 e5                	mov    %esp,%ebp
80101a21:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a24:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a28:	74 17                	je     80101a41 <iunlock+0x23>
80101a2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2d:	8b 40 0c             	mov    0xc(%eax),%eax
80101a30:	83 e0 01             	and    $0x1,%eax
80101a33:	85 c0                	test   %eax,%eax
80101a35:	74 0a                	je     80101a41 <iunlock+0x23>
80101a37:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3a:	8b 40 08             	mov    0x8(%eax),%eax
80101a3d:	85 c0                	test   %eax,%eax
80101a3f:	7f 0c                	jg     80101a4d <iunlock+0x2f>
    panic("iunlock");
80101a41:	c7 04 24 0c 8d 10 80 	movl   $0x80108d0c,(%esp)
80101a48:	e8 f0 ea ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101a4d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a54:	e8 4e 39 00 00       	call   801053a7 <acquire>
  ip->flags &= ~I_BUSY;
80101a59:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5c:	8b 40 0c             	mov    0xc(%eax),%eax
80101a5f:	89 c2                	mov    %eax,%edx
80101a61:	83 e2 fe             	and    $0xfffffffe,%edx
80101a64:	8b 45 08             	mov    0x8(%ebp),%eax
80101a67:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6d:	89 04 24             	mov    %eax,(%esp)
80101a70:	e8 28 37 00 00       	call   8010519d <wakeup>
  release(&icache.lock);
80101a75:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a7c:	e8 88 39 00 00       	call   80105409 <release>
}
80101a81:	c9                   	leave  
80101a82:	c3                   	ret    

80101a83 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a83:	55                   	push   %ebp
80101a84:	89 e5                	mov    %esp,%ebp
80101a86:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a89:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101a90:	e8 12 39 00 00       	call   801053a7 <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	8b 40 08             	mov    0x8(%eax),%eax
80101a9b:	83 f8 01             	cmp    $0x1,%eax
80101a9e:	0f 85 93 00 00 00    	jne    80101b37 <iput+0xb4>
80101aa4:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa7:	8b 40 0c             	mov    0xc(%eax),%eax
80101aaa:	83 e0 02             	and    $0x2,%eax
80101aad:	85 c0                	test   %eax,%eax
80101aaf:	0f 84 82 00 00 00    	je     80101b37 <iput+0xb4>
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101abc:	66 85 c0             	test   %ax,%ax
80101abf:	75 76                	jne    80101b37 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101ac1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac4:	8b 40 0c             	mov    0xc(%eax),%eax
80101ac7:	83 e0 01             	and    $0x1,%eax
80101aca:	84 c0                	test   %al,%al
80101acc:	74 0c                	je     80101ada <iput+0x57>
      panic("iput busy");
80101ace:	c7 04 24 14 8d 10 80 	movl   $0x80108d14,(%esp)
80101ad5:	e8 63 ea ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101ada:	8b 45 08             	mov    0x8(%ebp),%eax
80101add:	8b 40 0c             	mov    0xc(%eax),%eax
80101ae0:	89 c2                	mov    %eax,%edx
80101ae2:	83 ca 01             	or     $0x1,%edx
80101ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae8:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101aeb:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101af2:	e8 12 39 00 00       	call   80105409 <release>
    itrunc(ip);
80101af7:	8b 45 08             	mov    0x8(%ebp),%eax
80101afa:	89 04 24             	mov    %eax,(%esp)
80101afd:	e8 72 01 00 00       	call   80101c74 <itrunc>
    ip->type = 0;
80101b02:	8b 45 08             	mov    0x8(%ebp),%eax
80101b05:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0e:	89 04 24             	mov    %eax,(%esp)
80101b11:	e8 fe fb ff ff       	call   80101714 <iupdate>
    acquire(&icache.lock);
80101b16:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101b1d:	e8 85 38 00 00       	call   801053a7 <acquire>
    ip->flags = 0;
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
80101b25:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	89 04 24             	mov    %eax,(%esp)
80101b32:	e8 66 36 00 00       	call   8010519d <wakeup>
  }
  ip->ref--;
80101b37:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3a:	8b 40 08             	mov    0x8(%eax),%eax
80101b3d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101b40:	8b 45 08             	mov    0x8(%ebp),%eax
80101b43:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b46:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80101b4d:	e8 b7 38 00 00       	call   80105409 <release>
}
80101b52:	c9                   	leave  
80101b53:	c3                   	ret    

80101b54 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b54:	55                   	push   %ebp
80101b55:	89 e5                	mov    %esp,%ebp
80101b57:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5d:	89 04 24             	mov    %eax,(%esp)
80101b60:	e8 b9 fe ff ff       	call   80101a1e <iunlock>
  iput(ip);
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	89 04 24             	mov    %eax,(%esp)
80101b6b:	e8 13 ff ff ff       	call   80101a83 <iput>
}
80101b70:	c9                   	leave  
80101b71:	c3                   	ret    

80101b72 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b72:	55                   	push   %ebp
80101b73:	89 e5                	mov    %esp,%ebp
80101b75:	53                   	push   %ebx
80101b76:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b79:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b7d:	77 3e                	ja     80101bbd <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b82:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b85:	83 c2 04             	add    $0x4,%edx
80101b88:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b8f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b93:	75 20                	jne    80101bb5 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b95:	8b 45 08             	mov    0x8(%ebp),%eax
80101b98:	8b 00                	mov    (%eax),%eax
80101b9a:	89 04 24             	mov    %eax,(%esp)
80101b9d:	e8 49 f8 ff ff       	call   801013eb <balloc>
80101ba2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba8:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bab:	8d 4a 04             	lea    0x4(%edx),%ecx
80101bae:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bb1:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bb8:	e9 b1 00 00 00       	jmp    80101c6e <bmap+0xfc>
  }
  bn -= NDIRECT;
80101bbd:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101bc1:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101bc5:	0f 87 97 00 00 00    	ja     80101c62 <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101bcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bce:	8b 40 4c             	mov    0x4c(%eax),%eax
80101bd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bd8:	75 19                	jne    80101bf3 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101bda:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdd:	8b 00                	mov    (%eax),%eax
80101bdf:	89 04 24             	mov    %eax,(%esp)
80101be2:	e8 04 f8 ff ff       	call   801013eb <balloc>
80101be7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bf0:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf6:	8b 00                	mov    (%eax),%eax
80101bf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bfb:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bff:	89 04 24             	mov    %eax,(%esp)
80101c02:	e8 9f e5 ff ff       	call   801001a6 <bread>
80101c07:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c0d:	83 c0 18             	add    $0x18,%eax
80101c10:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c13:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c16:	c1 e0 02             	shl    $0x2,%eax
80101c19:	03 45 ec             	add    -0x14(%ebp),%eax
80101c1c:	8b 00                	mov    (%eax),%eax
80101c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c21:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c25:	75 2b                	jne    80101c52 <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101c27:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c2a:	c1 e0 02             	shl    $0x2,%eax
80101c2d:	89 c3                	mov    %eax,%ebx
80101c2f:	03 5d ec             	add    -0x14(%ebp),%ebx
80101c32:	8b 45 08             	mov    0x8(%ebp),%eax
80101c35:	8b 00                	mov    (%eax),%eax
80101c37:	89 04 24             	mov    %eax,(%esp)
80101c3a:	e8 ac f7 ff ff       	call   801013eb <balloc>
80101c3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c45:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c4a:	89 04 24             	mov    %eax,(%esp)
80101c4d:	e8 70 1a 00 00       	call   801036c2 <log_write>
    }
    brelse(bp);
80101c52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c55:	89 04 24             	mov    %eax,(%esp)
80101c58:	e8 ba e5 ff ff       	call   80100217 <brelse>
    return addr;
80101c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c60:	eb 0c                	jmp    80101c6e <bmap+0xfc>
  }

  panic("bmap: out of range");
80101c62:	c7 04 24 1e 8d 10 80 	movl   $0x80108d1e,(%esp)
80101c69:	e8 cf e8 ff ff       	call   8010053d <panic>
}
80101c6e:	83 c4 24             	add    $0x24,%esp
80101c71:	5b                   	pop    %ebx
80101c72:	5d                   	pop    %ebp
80101c73:	c3                   	ret    

80101c74 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c74:	55                   	push   %ebp
80101c75:	89 e5                	mov    %esp,%ebp
80101c77:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c81:	eb 44                	jmp    80101cc7 <itrunc+0x53>
    if(ip->addrs[i]){
80101c83:	8b 45 08             	mov    0x8(%ebp),%eax
80101c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c89:	83 c2 04             	add    $0x4,%edx
80101c8c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c90:	85 c0                	test   %eax,%eax
80101c92:	74 2f                	je     80101cc3 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c94:	8b 45 08             	mov    0x8(%ebp),%eax
80101c97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c9a:	83 c2 04             	add    $0x4,%edx
80101c9d:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca4:	8b 00                	mov    (%eax),%eax
80101ca6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101caa:	89 04 24             	mov    %eax,(%esp)
80101cad:	e8 90 f8 ff ff       	call   80101542 <bfree>
      ip->addrs[i] = 0;
80101cb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb8:	83 c2 04             	add    $0x4,%edx
80101cbb:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101cc2:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101cc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101cc7:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ccb:	7e b6                	jle    80101c83 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cd3:	85 c0                	test   %eax,%eax
80101cd5:	0f 84 8f 00 00 00    	je     80101d6a <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cde:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ce1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce4:	8b 00                	mov    (%eax),%eax
80101ce6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cea:	89 04 24             	mov    %eax,(%esp)
80101ced:	e8 b4 e4 ff ff       	call   801001a6 <bread>
80101cf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101cf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cf8:	83 c0 18             	add    $0x18,%eax
80101cfb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101cfe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d05:	eb 2f                	jmp    80101d36 <itrunc+0xc2>
      if(a[j])
80101d07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d0a:	c1 e0 02             	shl    $0x2,%eax
80101d0d:	03 45 e8             	add    -0x18(%ebp),%eax
80101d10:	8b 00                	mov    (%eax),%eax
80101d12:	85 c0                	test   %eax,%eax
80101d14:	74 1c                	je     80101d32 <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101d16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d19:	c1 e0 02             	shl    $0x2,%eax
80101d1c:	03 45 e8             	add    -0x18(%ebp),%eax
80101d1f:	8b 10                	mov    (%eax),%edx
80101d21:	8b 45 08             	mov    0x8(%ebp),%eax
80101d24:	8b 00                	mov    (%eax),%eax
80101d26:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d2a:	89 04 24             	mov    %eax,(%esp)
80101d2d:	e8 10 f8 ff ff       	call   80101542 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101d32:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d39:	83 f8 7f             	cmp    $0x7f,%eax
80101d3c:	76 c9                	jbe    80101d07 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101d3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d41:	89 04 24             	mov    %eax,(%esp)
80101d44:	e8 ce e4 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d49:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4c:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d52:	8b 00                	mov    (%eax),%eax
80101d54:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d58:	89 04 24             	mov    %eax,(%esp)
80101d5b:	e8 e2 f7 ff ff       	call   80101542 <bfree>
    ip->addrs[NDIRECT] = 0;
80101d60:	8b 45 08             	mov    0x8(%ebp),%eax
80101d63:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6d:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	89 04 24             	mov    %eax,(%esp)
80101d7a:	e8 95 f9 ff ff       	call   80101714 <iupdate>
}
80101d7f:	c9                   	leave  
80101d80:	c3                   	ret    

80101d81 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d81:	55                   	push   %ebp
80101d82:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d84:	8b 45 08             	mov    0x8(%ebp),%eax
80101d87:	8b 00                	mov    (%eax),%eax
80101d89:	89 c2                	mov    %eax,%edx
80101d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d8e:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d91:	8b 45 08             	mov    0x8(%ebp),%eax
80101d94:	8b 50 04             	mov    0x4(%eax),%edx
80101d97:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d9a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101da0:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101da4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101da7:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101daa:	8b 45 08             	mov    0x8(%ebp),%eax
80101dad:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101db1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101db4:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101db8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbb:	8b 50 18             	mov    0x18(%eax),%edx
80101dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc1:	89 50 10             	mov    %edx,0x10(%eax)
}
80101dc4:	5d                   	pop    %ebp
80101dc5:	c3                   	ret    

80101dc6 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101dc6:	55                   	push   %ebp
80101dc7:	89 e5                	mov    %esp,%ebp
80101dc9:	53                   	push   %ebx
80101dca:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101dd4:	66 83 f8 03          	cmp    $0x3,%ax
80101dd8:	75 60                	jne    80101e3a <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101dda:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddd:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101de1:	66 85 c0             	test   %ax,%ax
80101de4:	78 20                	js     80101e06 <readi+0x40>
80101de6:	8b 45 08             	mov    0x8(%ebp),%eax
80101de9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ded:	66 83 f8 09          	cmp    $0x9,%ax
80101df1:	7f 13                	jg     80101e06 <readi+0x40>
80101df3:	8b 45 08             	mov    0x8(%ebp),%eax
80101df6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dfa:	98                   	cwtl   
80101dfb:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101e02:	85 c0                	test   %eax,%eax
80101e04:	75 0a                	jne    80101e10 <readi+0x4a>
      return -1;
80101e06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e0b:	e9 1b 01 00 00       	jmp    80101f2b <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80101e10:	8b 45 08             	mov    0x8(%ebp),%eax
80101e13:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e17:	98                   	cwtl   
80101e18:	8b 14 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%edx
80101e1f:	8b 45 14             	mov    0x14(%ebp),%eax
80101e22:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e26:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e29:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e2d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e30:	89 04 24             	mov    %eax,(%esp)
80101e33:	ff d2                	call   *%edx
80101e35:	e9 f1 00 00 00       	jmp    80101f2b <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80101e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3d:	8b 40 18             	mov    0x18(%eax),%eax
80101e40:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e43:	72 0d                	jb     80101e52 <readi+0x8c>
80101e45:	8b 45 14             	mov    0x14(%ebp),%eax
80101e48:	8b 55 10             	mov    0x10(%ebp),%edx
80101e4b:	01 d0                	add    %edx,%eax
80101e4d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e50:	73 0a                	jae    80101e5c <readi+0x96>
    return -1;
80101e52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e57:	e9 cf 00 00 00       	jmp    80101f2b <readi+0x165>
  if(off + n > ip->size)
80101e5c:	8b 45 14             	mov    0x14(%ebp),%eax
80101e5f:	8b 55 10             	mov    0x10(%ebp),%edx
80101e62:	01 c2                	add    %eax,%edx
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 40 18             	mov    0x18(%eax),%eax
80101e6a:	39 c2                	cmp    %eax,%edx
80101e6c:	76 0c                	jbe    80101e7a <readi+0xb4>
    n = ip->size - off;
80101e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e71:	8b 40 18             	mov    0x18(%eax),%eax
80101e74:	2b 45 10             	sub    0x10(%ebp),%eax
80101e77:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e81:	e9 96 00 00 00       	jmp    80101f1c <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e86:	8b 45 10             	mov    0x10(%ebp),%eax
80101e89:	c1 e8 09             	shr    $0x9,%eax
80101e8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e90:	8b 45 08             	mov    0x8(%ebp),%eax
80101e93:	89 04 24             	mov    %eax,(%esp)
80101e96:	e8 d7 fc ff ff       	call   80101b72 <bmap>
80101e9b:	8b 55 08             	mov    0x8(%ebp),%edx
80101e9e:	8b 12                	mov    (%edx),%edx
80101ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ea4:	89 14 24             	mov    %edx,(%esp)
80101ea7:	e8 fa e2 ff ff       	call   801001a6 <bread>
80101eac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101eaf:	8b 45 10             	mov    0x10(%ebp),%eax
80101eb2:	89 c2                	mov    %eax,%edx
80101eb4:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101eba:	b8 00 02 00 00       	mov    $0x200,%eax
80101ebf:	89 c1                	mov    %eax,%ecx
80101ec1:	29 d1                	sub    %edx,%ecx
80101ec3:	89 ca                	mov    %ecx,%edx
80101ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ec8:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101ecb:	89 cb                	mov    %ecx,%ebx
80101ecd:	29 c3                	sub    %eax,%ebx
80101ecf:	89 d8                	mov    %ebx,%eax
80101ed1:	39 c2                	cmp    %eax,%edx
80101ed3:	0f 46 c2             	cmovbe %edx,%eax
80101ed6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101edc:	8d 50 18             	lea    0x18(%eax),%edx
80101edf:	8b 45 10             	mov    0x10(%ebp),%eax
80101ee2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ee7:	01 c2                	add    %eax,%edx
80101ee9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eec:	89 44 24 08          	mov    %eax,0x8(%esp)
80101ef0:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ef7:	89 04 24             	mov    %eax,(%esp)
80101efa:	e8 ca 37 00 00       	call   801056c9 <memmove>
    brelse(bp);
80101eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f02:	89 04 24             	mov    %eax,(%esp)
80101f05:	e8 0d e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f0d:	01 45 f4             	add    %eax,-0xc(%ebp)
80101f10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f13:	01 45 10             	add    %eax,0x10(%ebp)
80101f16:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f19:	01 45 0c             	add    %eax,0xc(%ebp)
80101f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f1f:	3b 45 14             	cmp    0x14(%ebp),%eax
80101f22:	0f 82 5e ff ff ff    	jb     80101e86 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101f28:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101f2b:	83 c4 24             	add    $0x24,%esp
80101f2e:	5b                   	pop    %ebx
80101f2f:	5d                   	pop    %ebp
80101f30:	c3                   	ret    

80101f31 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101f31:	55                   	push   %ebp
80101f32:	89 e5                	mov    %esp,%ebp
80101f34:	53                   	push   %ebx
80101f35:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f38:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f3f:	66 83 f8 03          	cmp    $0x3,%ax
80101f43:	75 60                	jne    80101fa5 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f4c:	66 85 c0             	test   %ax,%ax
80101f4f:	78 20                	js     80101f71 <writei+0x40>
80101f51:	8b 45 08             	mov    0x8(%ebp),%eax
80101f54:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f58:	66 83 f8 09          	cmp    $0x9,%ax
80101f5c:	7f 13                	jg     80101f71 <writei+0x40>
80101f5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f61:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f65:	98                   	cwtl   
80101f66:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80101f6d:	85 c0                	test   %eax,%eax
80101f6f:	75 0a                	jne    80101f7b <writei+0x4a>
      return -1;
80101f71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f76:	e9 46 01 00 00       	jmp    801020c1 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80101f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f82:	98                   	cwtl   
80101f83:	8b 14 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%edx
80101f8a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f8d:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f91:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f94:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f98:	8b 45 08             	mov    0x8(%ebp),%eax
80101f9b:	89 04 24             	mov    %eax,(%esp)
80101f9e:	ff d2                	call   *%edx
80101fa0:	e9 1c 01 00 00       	jmp    801020c1 <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80101fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa8:	8b 40 18             	mov    0x18(%eax),%eax
80101fab:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fae:	72 0d                	jb     80101fbd <writei+0x8c>
80101fb0:	8b 45 14             	mov    0x14(%ebp),%eax
80101fb3:	8b 55 10             	mov    0x10(%ebp),%edx
80101fb6:	01 d0                	add    %edx,%eax
80101fb8:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fbb:	73 0a                	jae    80101fc7 <writei+0x96>
    return -1;
80101fbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fc2:	e9 fa 00 00 00       	jmp    801020c1 <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80101fc7:	8b 45 14             	mov    0x14(%ebp),%eax
80101fca:	8b 55 10             	mov    0x10(%ebp),%edx
80101fcd:	01 d0                	add    %edx,%eax
80101fcf:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101fd4:	76 0a                	jbe    80101fe0 <writei+0xaf>
    return -1;
80101fd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fdb:	e9 e1 00 00 00       	jmp    801020c1 <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101fe0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fe7:	e9 a1 00 00 00       	jmp    8010208d <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fec:	8b 45 10             	mov    0x10(%ebp),%eax
80101fef:	c1 e8 09             	shr    $0x9,%eax
80101ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff9:	89 04 24             	mov    %eax,(%esp)
80101ffc:	e8 71 fb ff ff       	call   80101b72 <bmap>
80102001:	8b 55 08             	mov    0x8(%ebp),%edx
80102004:	8b 12                	mov    (%edx),%edx
80102006:	89 44 24 04          	mov    %eax,0x4(%esp)
8010200a:	89 14 24             	mov    %edx,(%esp)
8010200d:	e8 94 e1 ff ff       	call   801001a6 <bread>
80102012:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102015:	8b 45 10             	mov    0x10(%ebp),%eax
80102018:	89 c2                	mov    %eax,%edx
8010201a:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102020:	b8 00 02 00 00       	mov    $0x200,%eax
80102025:	89 c1                	mov    %eax,%ecx
80102027:	29 d1                	sub    %edx,%ecx
80102029:	89 ca                	mov    %ecx,%edx
8010202b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010202e:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102031:	89 cb                	mov    %ecx,%ebx
80102033:	29 c3                	sub    %eax,%ebx
80102035:	89 d8                	mov    %ebx,%eax
80102037:	39 c2                	cmp    %eax,%edx
80102039:	0f 46 c2             	cmovbe %edx,%eax
8010203c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010203f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102042:	8d 50 18             	lea    0x18(%eax),%edx
80102045:	8b 45 10             	mov    0x10(%ebp),%eax
80102048:	25 ff 01 00 00       	and    $0x1ff,%eax
8010204d:	01 c2                	add    %eax,%edx
8010204f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102052:	89 44 24 08          	mov    %eax,0x8(%esp)
80102056:	8b 45 0c             	mov    0xc(%ebp),%eax
80102059:	89 44 24 04          	mov    %eax,0x4(%esp)
8010205d:	89 14 24             	mov    %edx,(%esp)
80102060:	e8 64 36 00 00       	call   801056c9 <memmove>
    log_write(bp);
80102065:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102068:	89 04 24             	mov    %eax,(%esp)
8010206b:	e8 52 16 00 00       	call   801036c2 <log_write>
    brelse(bp);
80102070:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102073:	89 04 24             	mov    %eax,(%esp)
80102076:	e8 9c e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010207b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010207e:	01 45 f4             	add    %eax,-0xc(%ebp)
80102081:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102084:	01 45 10             	add    %eax,0x10(%ebp)
80102087:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010208a:	01 45 0c             	add    %eax,0xc(%ebp)
8010208d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102090:	3b 45 14             	cmp    0x14(%ebp),%eax
80102093:	0f 82 53 ff ff ff    	jb     80101fec <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102099:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010209d:	74 1f                	je     801020be <writei+0x18d>
8010209f:	8b 45 08             	mov    0x8(%ebp),%eax
801020a2:	8b 40 18             	mov    0x18(%eax),%eax
801020a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020a8:	73 14                	jae    801020be <writei+0x18d>
    ip->size = off;
801020aa:	8b 45 08             	mov    0x8(%ebp),%eax
801020ad:	8b 55 10             	mov    0x10(%ebp),%edx
801020b0:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801020b3:	8b 45 08             	mov    0x8(%ebp),%eax
801020b6:	89 04 24             	mov    %eax,(%esp)
801020b9:	e8 56 f6 ff ff       	call   80101714 <iupdate>
  }
  return n;
801020be:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020c1:	83 c4 24             	add    $0x24,%esp
801020c4:	5b                   	pop    %ebx
801020c5:	5d                   	pop    %ebp
801020c6:	c3                   	ret    

801020c7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801020c7:	55                   	push   %ebp
801020c8:	89 e5                	mov    %esp,%ebp
801020ca:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801020cd:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801020d4:	00 
801020d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801020d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801020dc:	8b 45 08             	mov    0x8(%ebp),%eax
801020df:	89 04 24             	mov    %eax,(%esp)
801020e2:	e8 86 36 00 00       	call   8010576d <strncmp>
}
801020e7:	c9                   	leave  
801020e8:	c3                   	ret    

801020e9 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020e9:	55                   	push   %ebp
801020ea:	89 e5                	mov    %esp,%ebp
801020ec:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020f6:	66 83 f8 01          	cmp    $0x1,%ax
801020fa:	74 0c                	je     80102108 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801020fc:	c7 04 24 31 8d 10 80 	movl   $0x80108d31,(%esp)
80102103:	e8 35 e4 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102108:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010210f:	e9 87 00 00 00       	jmp    8010219b <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102114:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010211b:	00 
8010211c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010211f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102123:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102126:	89 44 24 04          	mov    %eax,0x4(%esp)
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	89 04 24             	mov    %eax,(%esp)
80102130:	e8 91 fc ff ff       	call   80101dc6 <readi>
80102135:	83 f8 10             	cmp    $0x10,%eax
80102138:	74 0c                	je     80102146 <dirlookup+0x5d>
      panic("dirlink read");
8010213a:	c7 04 24 43 8d 10 80 	movl   $0x80108d43,(%esp)
80102141:	e8 f7 e3 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102146:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010214a:	66 85 c0             	test   %ax,%ax
8010214d:	74 47                	je     80102196 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010214f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102152:	83 c0 02             	add    $0x2,%eax
80102155:	89 44 24 04          	mov    %eax,0x4(%esp)
80102159:	8b 45 0c             	mov    0xc(%ebp),%eax
8010215c:	89 04 24             	mov    %eax,(%esp)
8010215f:	e8 63 ff ff ff       	call   801020c7 <namecmp>
80102164:	85 c0                	test   %eax,%eax
80102166:	75 2f                	jne    80102197 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102168:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010216c:	74 08                	je     80102176 <dirlookup+0x8d>
        *poff = off;
8010216e:	8b 45 10             	mov    0x10(%ebp),%eax
80102171:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102174:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102176:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010217a:	0f b7 c0             	movzwl %ax,%eax
8010217d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102180:	8b 45 08             	mov    0x8(%ebp),%eax
80102183:	8b 00                	mov    (%eax),%eax
80102185:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102188:	89 54 24 04          	mov    %edx,0x4(%esp)
8010218c:	89 04 24             	mov    %eax,(%esp)
8010218f:	e8 38 f6 ff ff       	call   801017cc <iget>
80102194:	eb 19                	jmp    801021af <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102196:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102197:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010219b:	8b 45 08             	mov    0x8(%ebp),%eax
8010219e:	8b 40 18             	mov    0x18(%eax),%eax
801021a1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801021a4:	0f 87 6a ff ff ff    	ja     80102114 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801021aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021af:	c9                   	leave  
801021b0:	c3                   	ret    

801021b1 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801021b1:	55                   	push   %ebp
801021b2:	89 e5                	mov    %esp,%ebp
801021b4:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801021b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801021be:	00 
801021bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801021c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801021c6:	8b 45 08             	mov    0x8(%ebp),%eax
801021c9:	89 04 24             	mov    %eax,(%esp)
801021cc:	e8 18 ff ff ff       	call   801020e9 <dirlookup>
801021d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801021d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801021d8:	74 15                	je     801021ef <dirlink+0x3e>
    iput(ip);
801021da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021dd:	89 04 24             	mov    %eax,(%esp)
801021e0:	e8 9e f8 ff ff       	call   80101a83 <iput>
    return -1;
801021e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021ea:	e9 b8 00 00 00       	jmp    801022a7 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f6:	eb 44                	jmp    8010223c <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021fb:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102202:	00 
80102203:	89 44 24 08          	mov    %eax,0x8(%esp)
80102207:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010220a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010220e:	8b 45 08             	mov    0x8(%ebp),%eax
80102211:	89 04 24             	mov    %eax,(%esp)
80102214:	e8 ad fb ff ff       	call   80101dc6 <readi>
80102219:	83 f8 10             	cmp    $0x10,%eax
8010221c:	74 0c                	je     8010222a <dirlink+0x79>
      panic("dirlink read");
8010221e:	c7 04 24 43 8d 10 80 	movl   $0x80108d43,(%esp)
80102225:	e8 13 e3 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
8010222a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010222e:	66 85 c0             	test   %ax,%ax
80102231:	74 18                	je     8010224b <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102236:	83 c0 10             	add    $0x10,%eax
80102239:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010223c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010223f:	8b 45 08             	mov    0x8(%ebp),%eax
80102242:	8b 40 18             	mov    0x18(%eax),%eax
80102245:	39 c2                	cmp    %eax,%edx
80102247:	72 af                	jb     801021f8 <dirlink+0x47>
80102249:	eb 01                	jmp    8010224c <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
8010224b:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010224c:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102253:	00 
80102254:	8b 45 0c             	mov    0xc(%ebp),%eax
80102257:	89 44 24 04          	mov    %eax,0x4(%esp)
8010225b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010225e:	83 c0 02             	add    $0x2,%eax
80102261:	89 04 24             	mov    %eax,(%esp)
80102264:	e8 5c 35 00 00       	call   801057c5 <strncpy>
  de.inum = inum;
80102269:	8b 45 10             	mov    0x10(%ebp),%eax
8010226c:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102270:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102273:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010227a:	00 
8010227b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010227f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102282:	89 44 24 04          	mov    %eax,0x4(%esp)
80102286:	8b 45 08             	mov    0x8(%ebp),%eax
80102289:	89 04 24             	mov    %eax,(%esp)
8010228c:	e8 a0 fc ff ff       	call   80101f31 <writei>
80102291:	83 f8 10             	cmp    $0x10,%eax
80102294:	74 0c                	je     801022a2 <dirlink+0xf1>
    panic("dirlink");
80102296:	c7 04 24 50 8d 10 80 	movl   $0x80108d50,(%esp)
8010229d:	e8 9b e2 ff ff       	call   8010053d <panic>
  
  return 0;
801022a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022a7:	c9                   	leave  
801022a8:	c3                   	ret    

801022a9 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022a9:	55                   	push   %ebp
801022aa:	89 e5                	mov    %esp,%ebp
801022ac:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801022af:	eb 04                	jmp    801022b5 <skipelem+0xc>
    path++;
801022b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801022b5:	8b 45 08             	mov    0x8(%ebp),%eax
801022b8:	0f b6 00             	movzbl (%eax),%eax
801022bb:	3c 2f                	cmp    $0x2f,%al
801022bd:	74 f2                	je     801022b1 <skipelem+0x8>
    path++;
  if(*path == 0)
801022bf:	8b 45 08             	mov    0x8(%ebp),%eax
801022c2:	0f b6 00             	movzbl (%eax),%eax
801022c5:	84 c0                	test   %al,%al
801022c7:	75 0a                	jne    801022d3 <skipelem+0x2a>
    return 0;
801022c9:	b8 00 00 00 00       	mov    $0x0,%eax
801022ce:	e9 86 00 00 00       	jmp    80102359 <skipelem+0xb0>
  s = path;
801022d3:	8b 45 08             	mov    0x8(%ebp),%eax
801022d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801022d9:	eb 04                	jmp    801022df <skipelem+0x36>
    path++;
801022db:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801022df:	8b 45 08             	mov    0x8(%ebp),%eax
801022e2:	0f b6 00             	movzbl (%eax),%eax
801022e5:	3c 2f                	cmp    $0x2f,%al
801022e7:	74 0a                	je     801022f3 <skipelem+0x4a>
801022e9:	8b 45 08             	mov    0x8(%ebp),%eax
801022ec:	0f b6 00             	movzbl (%eax),%eax
801022ef:	84 c0                	test   %al,%al
801022f1:	75 e8                	jne    801022db <skipelem+0x32>
    path++;
  len = path - s;
801022f3:	8b 55 08             	mov    0x8(%ebp),%edx
801022f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f9:	89 d1                	mov    %edx,%ecx
801022fb:	29 c1                	sub    %eax,%ecx
801022fd:	89 c8                	mov    %ecx,%eax
801022ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102302:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102306:	7e 1c                	jle    80102324 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
80102308:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010230f:	00 
80102310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102313:	89 44 24 04          	mov    %eax,0x4(%esp)
80102317:	8b 45 0c             	mov    0xc(%ebp),%eax
8010231a:	89 04 24             	mov    %eax,(%esp)
8010231d:	e8 a7 33 00 00       	call   801056c9 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102322:	eb 28                	jmp    8010234c <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102324:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102327:	89 44 24 08          	mov    %eax,0x8(%esp)
8010232b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010232e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102332:	8b 45 0c             	mov    0xc(%ebp),%eax
80102335:	89 04 24             	mov    %eax,(%esp)
80102338:	e8 8c 33 00 00       	call   801056c9 <memmove>
    name[len] = 0;
8010233d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102340:	03 45 0c             	add    0xc(%ebp),%eax
80102343:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102346:	eb 04                	jmp    8010234c <skipelem+0xa3>
    path++;
80102348:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010234c:	8b 45 08             	mov    0x8(%ebp),%eax
8010234f:	0f b6 00             	movzbl (%eax),%eax
80102352:	3c 2f                	cmp    $0x2f,%al
80102354:	74 f2                	je     80102348 <skipelem+0x9f>
    path++;
  return path;
80102356:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102359:	c9                   	leave  
8010235a:	c3                   	ret    

8010235b <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010235b:	55                   	push   %ebp
8010235c:	89 e5                	mov    %esp,%ebp
8010235e:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102361:	8b 45 08             	mov    0x8(%ebp),%eax
80102364:	0f b6 00             	movzbl (%eax),%eax
80102367:	3c 2f                	cmp    $0x2f,%al
80102369:	75 1c                	jne    80102387 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010236b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102372:	00 
80102373:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010237a:	e8 4d f4 ff ff       	call   801017cc <iget>
8010237f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102382:	e9 af 00 00 00       	jmp    80102436 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102387:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010238d:	8b 40 6c             	mov    0x6c(%eax),%eax
80102390:	89 04 24             	mov    %eax,(%esp)
80102393:	e8 06 f5 ff ff       	call   8010189e <idup>
80102398:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010239b:	e9 96 00 00 00       	jmp    80102436 <namex+0xdb>
    ilock(ip);
801023a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a3:	89 04 24             	mov    %eax,(%esp)
801023a6:	e8 25 f5 ff ff       	call   801018d0 <ilock>
    if(ip->type != T_DIR){
801023ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023b2:	66 83 f8 01          	cmp    $0x1,%ax
801023b6:	74 15                	je     801023cd <namex+0x72>
      iunlockput(ip);
801023b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bb:	89 04 24             	mov    %eax,(%esp)
801023be:	e8 91 f7 ff ff       	call   80101b54 <iunlockput>
      return 0;
801023c3:	b8 00 00 00 00       	mov    $0x0,%eax
801023c8:	e9 a3 00 00 00       	jmp    80102470 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801023cd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023d1:	74 1d                	je     801023f0 <namex+0x95>
801023d3:	8b 45 08             	mov    0x8(%ebp),%eax
801023d6:	0f b6 00             	movzbl (%eax),%eax
801023d9:	84 c0                	test   %al,%al
801023db:	75 13                	jne    801023f0 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801023dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e0:	89 04 24             	mov    %eax,(%esp)
801023e3:	e8 36 f6 ff ff       	call   80101a1e <iunlock>
      return ip;
801023e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023eb:	e9 80 00 00 00       	jmp    80102470 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801023f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801023f7:	00 
801023f8:	8b 45 10             	mov    0x10(%ebp),%eax
801023fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801023ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102402:	89 04 24             	mov    %eax,(%esp)
80102405:	e8 df fc ff ff       	call   801020e9 <dirlookup>
8010240a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010240d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102411:	75 12                	jne    80102425 <namex+0xca>
      iunlockput(ip);
80102413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102416:	89 04 24             	mov    %eax,(%esp)
80102419:	e8 36 f7 ff ff       	call   80101b54 <iunlockput>
      return 0;
8010241e:	b8 00 00 00 00       	mov    $0x0,%eax
80102423:	eb 4b                	jmp    80102470 <namex+0x115>
    }
    iunlockput(ip);
80102425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102428:	89 04 24             	mov    %eax,(%esp)
8010242b:	e8 24 f7 ff ff       	call   80101b54 <iunlockput>
    ip = next;
80102430:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102433:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102436:	8b 45 10             	mov    0x10(%ebp),%eax
80102439:	89 44 24 04          	mov    %eax,0x4(%esp)
8010243d:	8b 45 08             	mov    0x8(%ebp),%eax
80102440:	89 04 24             	mov    %eax,(%esp)
80102443:	e8 61 fe ff ff       	call   801022a9 <skipelem>
80102448:	89 45 08             	mov    %eax,0x8(%ebp)
8010244b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010244f:	0f 85 4b ff ff ff    	jne    801023a0 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102455:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102459:	74 12                	je     8010246d <namex+0x112>
    iput(ip);
8010245b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245e:	89 04 24             	mov    %eax,(%esp)
80102461:	e8 1d f6 ff ff       	call   80101a83 <iput>
    return 0;
80102466:	b8 00 00 00 00       	mov    $0x0,%eax
8010246b:	eb 03                	jmp    80102470 <namex+0x115>
  }
  return ip;
8010246d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102470:	c9                   	leave  
80102471:	c3                   	ret    

80102472 <namei>:

struct inode*
namei(char *path)
{
80102472:	55                   	push   %ebp
80102473:	89 e5                	mov    %esp,%ebp
80102475:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102478:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010247b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010247f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102486:	00 
80102487:	8b 45 08             	mov    0x8(%ebp),%eax
8010248a:	89 04 24             	mov    %eax,(%esp)
8010248d:	e8 c9 fe ff ff       	call   8010235b <namex>
}
80102492:	c9                   	leave  
80102493:	c3                   	ret    

80102494 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102494:	55                   	push   %ebp
80102495:	89 e5                	mov    %esp,%ebp
80102497:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010249a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010249d:	89 44 24 08          	mov    %eax,0x8(%esp)
801024a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024a8:	00 
801024a9:	8b 45 08             	mov    0x8(%ebp),%eax
801024ac:	89 04 24             	mov    %eax,(%esp)
801024af:	e8 a7 fe ff ff       	call   8010235b <namex>
}
801024b4:	c9                   	leave  
801024b5:	c3                   	ret    
	...

801024b8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801024b8:	55                   	push   %ebp
801024b9:	89 e5                	mov    %esp,%ebp
801024bb:	53                   	push   %ebx
801024bc:	83 ec 14             	sub    $0x14,%esp
801024bf:	8b 45 08             	mov    0x8(%ebp),%eax
801024c2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024c6:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801024ca:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801024ce:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801024d2:	ec                   	in     (%dx),%al
801024d3:	89 c3                	mov    %eax,%ebx
801024d5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801024d8:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801024dc:	83 c4 14             	add    $0x14,%esp
801024df:	5b                   	pop    %ebx
801024e0:	5d                   	pop    %ebp
801024e1:	c3                   	ret    

801024e2 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801024e2:	55                   	push   %ebp
801024e3:	89 e5                	mov    %esp,%ebp
801024e5:	57                   	push   %edi
801024e6:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024e7:	8b 55 08             	mov    0x8(%ebp),%edx
801024ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024ed:	8b 45 10             	mov    0x10(%ebp),%eax
801024f0:	89 cb                	mov    %ecx,%ebx
801024f2:	89 df                	mov    %ebx,%edi
801024f4:	89 c1                	mov    %eax,%ecx
801024f6:	fc                   	cld    
801024f7:	f3 6d                	rep insl (%dx),%es:(%edi)
801024f9:	89 c8                	mov    %ecx,%eax
801024fb:	89 fb                	mov    %edi,%ebx
801024fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102500:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102503:	5b                   	pop    %ebx
80102504:	5f                   	pop    %edi
80102505:	5d                   	pop    %ebp
80102506:	c3                   	ret    

80102507 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102507:	55                   	push   %ebp
80102508:	89 e5                	mov    %esp,%ebp
8010250a:	83 ec 08             	sub    $0x8,%esp
8010250d:	8b 55 08             	mov    0x8(%ebp),%edx
80102510:	8b 45 0c             	mov    0xc(%ebp),%eax
80102513:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102517:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010251a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010251e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102522:	ee                   	out    %al,(%dx)
}
80102523:	c9                   	leave  
80102524:	c3                   	ret    

80102525 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102525:	55                   	push   %ebp
80102526:	89 e5                	mov    %esp,%ebp
80102528:	56                   	push   %esi
80102529:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010252a:	8b 55 08             	mov    0x8(%ebp),%edx
8010252d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102530:	8b 45 10             	mov    0x10(%ebp),%eax
80102533:	89 cb                	mov    %ecx,%ebx
80102535:	89 de                	mov    %ebx,%esi
80102537:	89 c1                	mov    %eax,%ecx
80102539:	fc                   	cld    
8010253a:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010253c:	89 c8                	mov    %ecx,%eax
8010253e:	89 f3                	mov    %esi,%ebx
80102540:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102543:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102546:	5b                   	pop    %ebx
80102547:	5e                   	pop    %esi
80102548:	5d                   	pop    %ebp
80102549:	c3                   	ret    

8010254a <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010254a:	55                   	push   %ebp
8010254b:	89 e5                	mov    %esp,%ebp
8010254d:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102550:	90                   	nop
80102551:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102558:	e8 5b ff ff ff       	call   801024b8 <inb>
8010255d:	0f b6 c0             	movzbl %al,%eax
80102560:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102563:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102566:	25 c0 00 00 00       	and    $0xc0,%eax
8010256b:	83 f8 40             	cmp    $0x40,%eax
8010256e:	75 e1                	jne    80102551 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102570:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102574:	74 11                	je     80102587 <idewait+0x3d>
80102576:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102579:	83 e0 21             	and    $0x21,%eax
8010257c:	85 c0                	test   %eax,%eax
8010257e:	74 07                	je     80102587 <idewait+0x3d>
    return -1;
80102580:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102585:	eb 05                	jmp    8010258c <idewait+0x42>
  return 0;
80102587:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010258c:	c9                   	leave  
8010258d:	c3                   	ret    

8010258e <ideinit>:

void
ideinit(void)
{
8010258e:	55                   	push   %ebp
8010258f:	89 e5                	mov    %esp,%ebp
80102591:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102594:	c7 44 24 04 58 8d 10 	movl   $0x80108d58,0x4(%esp)
8010259b:	80 
8010259c:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801025a3:	e8 de 2d 00 00       	call   80105386 <initlock>
  picenable(IRQ_IDE);
801025a8:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025af:	e8 c1 18 00 00       	call   80103e75 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801025b4:	a1 60 39 11 80       	mov    0x80113960,%eax
801025b9:	83 e8 01             	sub    $0x1,%eax
801025bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801025c0:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801025c7:	e8 12 04 00 00       	call   801029de <ioapicenable>
  idewait(0);
801025cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801025d3:	e8 72 ff ff ff       	call   8010254a <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801025d8:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801025df:	00 
801025e0:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025e7:	e8 1b ff ff ff       	call   80102507 <outb>
  for(i=0; i<1000; i++){
801025ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025f3:	eb 20                	jmp    80102615 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801025f5:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025fc:	e8 b7 fe ff ff       	call   801024b8 <inb>
80102601:	84 c0                	test   %al,%al
80102603:	74 0c                	je     80102611 <ideinit+0x83>
      havedisk1 = 1;
80102605:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
8010260c:	00 00 00 
      break;
8010260f:	eb 0d                	jmp    8010261e <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102611:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102615:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010261c:	7e d7                	jle    801025f5 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010261e:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102625:	00 
80102626:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010262d:	e8 d5 fe ff ff       	call   80102507 <outb>
}
80102632:	c9                   	leave  
80102633:	c3                   	ret    

80102634 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102634:	55                   	push   %ebp
80102635:	89 e5                	mov    %esp,%ebp
80102637:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010263a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010263e:	75 0c                	jne    8010264c <idestart+0x18>
    panic("idestart");
80102640:	c7 04 24 5c 8d 10 80 	movl   $0x80108d5c,(%esp)
80102647:	e8 f1 de ff ff       	call   8010053d <panic>

  idewait(0);
8010264c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102653:	e8 f2 fe ff ff       	call   8010254a <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102658:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010265f:	00 
80102660:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102667:	e8 9b fe ff ff       	call   80102507 <outb>
  outb(0x1f2, 1);  // number of sectors
8010266c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102673:	00 
80102674:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010267b:	e8 87 fe ff ff       	call   80102507 <outb>
  outb(0x1f3, b->sector & 0xff);
80102680:	8b 45 08             	mov    0x8(%ebp),%eax
80102683:	8b 40 08             	mov    0x8(%eax),%eax
80102686:	0f b6 c0             	movzbl %al,%eax
80102689:	89 44 24 04          	mov    %eax,0x4(%esp)
8010268d:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102694:	e8 6e fe ff ff       	call   80102507 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102699:	8b 45 08             	mov    0x8(%ebp),%eax
8010269c:	8b 40 08             	mov    0x8(%eax),%eax
8010269f:	c1 e8 08             	shr    $0x8,%eax
801026a2:	0f b6 c0             	movzbl %al,%eax
801026a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801026a9:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801026b0:	e8 52 fe ff ff       	call   80102507 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
801026b5:	8b 45 08             	mov    0x8(%ebp),%eax
801026b8:	8b 40 08             	mov    0x8(%eax),%eax
801026bb:	c1 e8 10             	shr    $0x10,%eax
801026be:	0f b6 c0             	movzbl %al,%eax
801026c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801026c5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801026cc:	e8 36 fe ff ff       	call   80102507 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801026d1:	8b 45 08             	mov    0x8(%ebp),%eax
801026d4:	8b 40 04             	mov    0x4(%eax),%eax
801026d7:	83 e0 01             	and    $0x1,%eax
801026da:	89 c2                	mov    %eax,%edx
801026dc:	c1 e2 04             	shl    $0x4,%edx
801026df:	8b 45 08             	mov    0x8(%ebp),%eax
801026e2:	8b 40 08             	mov    0x8(%eax),%eax
801026e5:	c1 e8 18             	shr    $0x18,%eax
801026e8:	83 e0 0f             	and    $0xf,%eax
801026eb:	09 d0                	or     %edx,%eax
801026ed:	83 c8 e0             	or     $0xffffffe0,%eax
801026f0:	0f b6 c0             	movzbl %al,%eax
801026f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801026f7:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026fe:	e8 04 fe ff ff       	call   80102507 <outb>
  if(b->flags & B_DIRTY){
80102703:	8b 45 08             	mov    0x8(%ebp),%eax
80102706:	8b 00                	mov    (%eax),%eax
80102708:	83 e0 04             	and    $0x4,%eax
8010270b:	85 c0                	test   %eax,%eax
8010270d:	74 34                	je     80102743 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
8010270f:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102716:	00 
80102717:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010271e:	e8 e4 fd ff ff       	call   80102507 <outb>
    outsl(0x1f0, b->data, 512/4);
80102723:	8b 45 08             	mov    0x8(%ebp),%eax
80102726:	83 c0 18             	add    $0x18,%eax
80102729:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102730:	00 
80102731:	89 44 24 04          	mov    %eax,0x4(%esp)
80102735:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010273c:	e8 e4 fd ff ff       	call   80102525 <outsl>
80102741:	eb 14                	jmp    80102757 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102743:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
8010274a:	00 
8010274b:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102752:	e8 b0 fd ff ff       	call   80102507 <outb>
  }
}
80102757:	c9                   	leave  
80102758:	c3                   	ret    

80102759 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102759:	55                   	push   %ebp
8010275a:	89 e5                	mov    %esp,%ebp
8010275c:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010275f:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102766:	e8 3c 2c 00 00       	call   801053a7 <acquire>
  if((b = idequeue) == 0){
8010276b:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102770:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102773:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102777:	75 11                	jne    8010278a <ideintr+0x31>
    release(&idelock);
80102779:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102780:	e8 84 2c 00 00       	call   80105409 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102785:	e9 90 00 00 00       	jmp    8010281a <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010278a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278d:	8b 40 14             	mov    0x14(%eax),%eax
80102790:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102798:	8b 00                	mov    (%eax),%eax
8010279a:	83 e0 04             	and    $0x4,%eax
8010279d:	85 c0                	test   %eax,%eax
8010279f:	75 2e                	jne    801027cf <ideintr+0x76>
801027a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801027a8:	e8 9d fd ff ff       	call   8010254a <idewait>
801027ad:	85 c0                	test   %eax,%eax
801027af:	78 1e                	js     801027cf <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
801027b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b4:	83 c0 18             	add    $0x18,%eax
801027b7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801027be:	00 
801027bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801027c3:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801027ca:	e8 13 fd ff ff       	call   801024e2 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801027cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d2:	8b 00                	mov    (%eax),%eax
801027d4:	89 c2                	mov    %eax,%edx
801027d6:	83 ca 02             	or     $0x2,%edx
801027d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027dc:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801027de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e1:	8b 00                	mov    (%eax),%eax
801027e3:	89 c2                	mov    %eax,%edx
801027e5:	83 e2 fb             	and    $0xfffffffb,%edx
801027e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027eb:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801027ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027f0:	89 04 24             	mov    %eax,(%esp)
801027f3:	e8 a5 29 00 00       	call   8010519d <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801027f8:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801027fd:	85 c0                	test   %eax,%eax
801027ff:	74 0d                	je     8010280e <ideintr+0xb5>
    idestart(idequeue);
80102801:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102806:	89 04 24             	mov    %eax,(%esp)
80102809:	e8 26 fe ff ff       	call   80102634 <idestart>

  release(&idelock);
8010280e:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102815:	e8 ef 2b 00 00       	call   80105409 <release>
}
8010281a:	c9                   	leave  
8010281b:	c3                   	ret    

8010281c <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010281c:	55                   	push   %ebp
8010281d:	89 e5                	mov    %esp,%ebp
8010281f:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102822:	8b 45 08             	mov    0x8(%ebp),%eax
80102825:	8b 00                	mov    (%eax),%eax
80102827:	83 e0 01             	and    $0x1,%eax
8010282a:	85 c0                	test   %eax,%eax
8010282c:	75 0c                	jne    8010283a <iderw+0x1e>
    panic("iderw: buf not busy");
8010282e:	c7 04 24 65 8d 10 80 	movl   $0x80108d65,(%esp)
80102835:	e8 03 dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010283a:	8b 45 08             	mov    0x8(%ebp),%eax
8010283d:	8b 00                	mov    (%eax),%eax
8010283f:	83 e0 06             	and    $0x6,%eax
80102842:	83 f8 02             	cmp    $0x2,%eax
80102845:	75 0c                	jne    80102853 <iderw+0x37>
    panic("iderw: nothing to do");
80102847:	c7 04 24 79 8d 10 80 	movl   $0x80108d79,(%esp)
8010284e:	e8 ea dc ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
80102853:	8b 45 08             	mov    0x8(%ebp),%eax
80102856:	8b 40 04             	mov    0x4(%eax),%eax
80102859:	85 c0                	test   %eax,%eax
8010285b:	74 15                	je     80102872 <iderw+0x56>
8010285d:	a1 58 c6 10 80       	mov    0x8010c658,%eax
80102862:	85 c0                	test   %eax,%eax
80102864:	75 0c                	jne    80102872 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102866:	c7 04 24 8e 8d 10 80 	movl   $0x80108d8e,(%esp)
8010286d:	e8 cb dc ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102872:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
80102879:	e8 29 2b 00 00       	call   801053a7 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
8010287e:	8b 45 08             	mov    0x8(%ebp),%eax
80102881:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102888:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
8010288f:	eb 0b                	jmp    8010289c <iderw+0x80>
80102891:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102894:	8b 00                	mov    (%eax),%eax
80102896:	83 c0 14             	add    $0x14,%eax
80102899:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010289c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289f:	8b 00                	mov    (%eax),%eax
801028a1:	85 c0                	test   %eax,%eax
801028a3:	75 ec                	jne    80102891 <iderw+0x75>
    ;
  *pp = b;
801028a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a8:	8b 55 08             	mov    0x8(%ebp),%edx
801028ab:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801028ad:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028b2:	3b 45 08             	cmp    0x8(%ebp),%eax
801028b5:	75 22                	jne    801028d9 <iderw+0xbd>
    idestart(b);
801028b7:	8b 45 08             	mov    0x8(%ebp),%eax
801028ba:	89 04 24             	mov    %eax,(%esp)
801028bd:	e8 72 fd ff ff       	call   80102634 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028c2:	eb 15                	jmp    801028d9 <iderw+0xbd>
    sleep(b, &idelock);
801028c4:	c7 44 24 04 20 c6 10 	movl   $0x8010c620,0x4(%esp)
801028cb:	80 
801028cc:	8b 45 08             	mov    0x8(%ebp),%eax
801028cf:	89 04 24             	mov    %eax,(%esp)
801028d2:	e8 ea 27 00 00       	call   801050c1 <sleep>
801028d7:	eb 01                	jmp    801028da <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801028d9:	90                   	nop
801028da:	8b 45 08             	mov    0x8(%ebp),%eax
801028dd:	8b 00                	mov    (%eax),%eax
801028df:	83 e0 06             	and    $0x6,%eax
801028e2:	83 f8 02             	cmp    $0x2,%eax
801028e5:	75 dd                	jne    801028c4 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
801028e7:	c7 04 24 20 c6 10 80 	movl   $0x8010c620,(%esp)
801028ee:	e8 16 2b 00 00       	call   80105409 <release>
}
801028f3:	c9                   	leave  
801028f4:	c3                   	ret    
801028f5:	00 00                	add    %al,(%eax)
	...

801028f8 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801028f8:	55                   	push   %ebp
801028f9:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028fb:	a1 34 32 11 80       	mov    0x80113234,%eax
80102900:	8b 55 08             	mov    0x8(%ebp),%edx
80102903:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102905:	a1 34 32 11 80       	mov    0x80113234,%eax
8010290a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010290d:	5d                   	pop    %ebp
8010290e:	c3                   	ret    

8010290f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010290f:	55                   	push   %ebp
80102910:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102912:	a1 34 32 11 80       	mov    0x80113234,%eax
80102917:	8b 55 08             	mov    0x8(%ebp),%edx
8010291a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010291c:	a1 34 32 11 80       	mov    0x80113234,%eax
80102921:	8b 55 0c             	mov    0xc(%ebp),%edx
80102924:	89 50 10             	mov    %edx,0x10(%eax)
}
80102927:	5d                   	pop    %ebp
80102928:	c3                   	ret    

80102929 <ioapicinit>:

void
ioapicinit(void)
{
80102929:	55                   	push   %ebp
8010292a:	89 e5                	mov    %esp,%ebp
8010292c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
8010292f:	a1 64 33 11 80       	mov    0x80113364,%eax
80102934:	85 c0                	test   %eax,%eax
80102936:	0f 84 9f 00 00 00    	je     801029db <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010293c:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
80102943:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102946:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010294d:	e8 a6 ff ff ff       	call   801028f8 <ioapicread>
80102952:	c1 e8 10             	shr    $0x10,%eax
80102955:	25 ff 00 00 00       	and    $0xff,%eax
8010295a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010295d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102964:	e8 8f ff ff ff       	call   801028f8 <ioapicread>
80102969:	c1 e8 18             	shr    $0x18,%eax
8010296c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010296f:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
80102976:	0f b6 c0             	movzbl %al,%eax
80102979:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010297c:	74 0c                	je     8010298a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010297e:	c7 04 24 ac 8d 10 80 	movl   $0x80108dac,(%esp)
80102985:	e8 17 da ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
8010298a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102991:	eb 3e                	jmp    801029d1 <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102996:	83 c0 20             	add    $0x20,%eax
80102999:	0d 00 00 01 00       	or     $0x10000,%eax
8010299e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801029a1:	83 c2 08             	add    $0x8,%edx
801029a4:	01 d2                	add    %edx,%edx
801029a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801029aa:	89 14 24             	mov    %edx,(%esp)
801029ad:	e8 5d ff ff ff       	call   8010290f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
801029b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b5:	83 c0 08             	add    $0x8,%eax
801029b8:	01 c0                	add    %eax,%eax
801029ba:	83 c0 01             	add    $0x1,%eax
801029bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801029c4:	00 
801029c5:	89 04 24             	mov    %eax,(%esp)
801029c8:	e8 42 ff ff ff       	call   8010290f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801029d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029d4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801029d7:	7e ba                	jle    80102993 <ioapicinit+0x6a>
801029d9:	eb 01                	jmp    801029dc <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
801029db:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
801029dc:	c9                   	leave  
801029dd:	c3                   	ret    

801029de <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
801029de:	55                   	push   %ebp
801029df:	89 e5                	mov    %esp,%ebp
801029e1:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
801029e4:	a1 64 33 11 80       	mov    0x80113364,%eax
801029e9:	85 c0                	test   %eax,%eax
801029eb:	74 39                	je     80102a26 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801029ed:	8b 45 08             	mov    0x8(%ebp),%eax
801029f0:	83 c0 20             	add    $0x20,%eax
801029f3:	8b 55 08             	mov    0x8(%ebp),%edx
801029f6:	83 c2 08             	add    $0x8,%edx
801029f9:	01 d2                	add    %edx,%edx
801029fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ff:	89 14 24             	mov    %edx,(%esp)
80102a02:	e8 08 ff ff ff       	call   8010290f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a07:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a0a:	c1 e0 18             	shl    $0x18,%eax
80102a0d:	8b 55 08             	mov    0x8(%ebp),%edx
80102a10:	83 c2 08             	add    $0x8,%edx
80102a13:	01 d2                	add    %edx,%edx
80102a15:	83 c2 01             	add    $0x1,%edx
80102a18:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a1c:	89 14 24             	mov    %edx,(%esp)
80102a1f:	e8 eb fe ff ff       	call   8010290f <ioapicwrite>
80102a24:	eb 01                	jmp    80102a27 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102a26:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102a27:	c9                   	leave  
80102a28:	c3                   	ret    
80102a29:	00 00                	add    %al,(%eax)
	...

80102a2c <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a2c:	55                   	push   %ebp
80102a2d:	89 e5                	mov    %esp,%ebp
80102a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a32:	05 00 00 00 80       	add    $0x80000000,%eax
80102a37:	5d                   	pop    %ebp
80102a38:	c3                   	ret    

80102a39 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a39:	55                   	push   %ebp
80102a3a:	89 e5                	mov    %esp,%ebp
80102a3c:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102a3f:	c7 44 24 04 de 8d 10 	movl   $0x80108dde,0x4(%esp)
80102a46:	80 
80102a47:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102a4e:	e8 33 29 00 00       	call   80105386 <initlock>
  kmem.use_lock = 0;
80102a53:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102a5a:	00 00 00 
  freerange(vstart, vend);
80102a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a60:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a64:	8b 45 08             	mov    0x8(%ebp),%eax
80102a67:	89 04 24             	mov    %eax,(%esp)
80102a6a:	e8 26 00 00 00       	call   80102a95 <freerange>
}
80102a6f:	c9                   	leave  
80102a70:	c3                   	ret    

80102a71 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a71:	55                   	push   %ebp
80102a72:	89 e5                	mov    %esp,%ebp
80102a74:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a77:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a81:	89 04 24             	mov    %eax,(%esp)
80102a84:	e8 0c 00 00 00       	call   80102a95 <freerange>
  kmem.use_lock = 1;
80102a89:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102a90:	00 00 00 
}
80102a93:	c9                   	leave  
80102a94:	c3                   	ret    

80102a95 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a95:	55                   	push   %ebp
80102a96:	89 e5                	mov    %esp,%ebp
80102a98:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102aa3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102aa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102aab:	eb 12                	jmp    80102abf <freerange+0x2a>
    kfree(p);
80102aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab0:	89 04 24             	mov    %eax,(%esp)
80102ab3:	e8 16 00 00 00       	call   80102ace <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ab8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac2:	05 00 10 00 00       	add    $0x1000,%eax
80102ac7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102aca:	76 e1                	jbe    80102aad <freerange+0x18>
    kfree(p);
}
80102acc:	c9                   	leave  
80102acd:	c3                   	ret    

80102ace <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102ace:	55                   	push   %ebp
80102acf:	89 e5                	mov    %esp,%ebp
80102ad1:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad7:	25 ff 0f 00 00       	and    $0xfff,%eax
80102adc:	85 c0                	test   %eax,%eax
80102ade:	75 1b                	jne    80102afb <kfree+0x2d>
80102ae0:	81 7d 08 5c 68 11 80 	cmpl   $0x8011685c,0x8(%ebp)
80102ae7:	72 12                	jb     80102afb <kfree+0x2d>
80102ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80102aec:	89 04 24             	mov    %eax,(%esp)
80102aef:	e8 38 ff ff ff       	call   80102a2c <v2p>
80102af4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102af9:	76 0c                	jbe    80102b07 <kfree+0x39>
    panic("kfree");
80102afb:	c7 04 24 e3 8d 10 80 	movl   $0x80108de3,(%esp)
80102b02:	e8 36 da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b07:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102b0e:	00 
80102b0f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102b16:	00 
80102b17:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1a:	89 04 24             	mov    %eax,(%esp)
80102b1d:	e8 d4 2a 00 00       	call   801055f6 <memset>

  if(kmem.use_lock)
80102b22:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b27:	85 c0                	test   %eax,%eax
80102b29:	74 0c                	je     80102b37 <kfree+0x69>
    acquire(&kmem.lock);
80102b2b:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102b32:	e8 70 28 00 00       	call   801053a7 <acquire>
  r = (struct run*)v;
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b3d:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b46:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4b:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102b50:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b55:	85 c0                	test   %eax,%eax
80102b57:	74 0c                	je     80102b65 <kfree+0x97>
    release(&kmem.lock);
80102b59:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102b60:	e8 a4 28 00 00       	call   80105409 <release>
}
80102b65:	c9                   	leave  
80102b66:	c3                   	ret    

80102b67 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b67:	55                   	push   %ebp
80102b68:	89 e5                	mov    %esp,%ebp
80102b6a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b6d:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b72:	85 c0                	test   %eax,%eax
80102b74:	74 0c                	je     80102b82 <kalloc+0x1b>
    acquire(&kmem.lock);
80102b76:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102b7d:	e8 25 28 00 00       	call   801053a7 <acquire>
  r = kmem.freelist;
80102b82:	a1 78 32 11 80       	mov    0x80113278,%eax
80102b87:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b8e:	74 0a                	je     80102b9a <kalloc+0x33>
    kmem.freelist = r->next;
80102b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b93:	8b 00                	mov    (%eax),%eax
80102b95:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102b9a:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b9f:	85 c0                	test   %eax,%eax
80102ba1:	74 0c                	je     80102baf <kalloc+0x48>
    release(&kmem.lock);
80102ba3:	c7 04 24 40 32 11 80 	movl   $0x80113240,(%esp)
80102baa:	e8 5a 28 00 00       	call   80105409 <release>
  return (char*)r;
80102baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102bb2:	c9                   	leave  
80102bb3:	c3                   	ret    

80102bb4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102bb4:	55                   	push   %ebp
80102bb5:	89 e5                	mov    %esp,%ebp
80102bb7:	53                   	push   %ebx
80102bb8:	83 ec 14             	sub    $0x14,%esp
80102bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbe:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bc2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102bc6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102bca:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102bce:	ec                   	in     (%dx),%al
80102bcf:	89 c3                	mov    %eax,%ebx
80102bd1:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102bd4:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102bd8:	83 c4 14             	add    $0x14,%esp
80102bdb:	5b                   	pop    %ebx
80102bdc:	5d                   	pop    %ebp
80102bdd:	c3                   	ret    

80102bde <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102bde:	55                   	push   %ebp
80102bdf:	89 e5                	mov    %esp,%ebp
80102be1:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102be4:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102beb:	e8 c4 ff ff ff       	call   80102bb4 <inb>
80102bf0:	0f b6 c0             	movzbl %al,%eax
80102bf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bf9:	83 e0 01             	and    $0x1,%eax
80102bfc:	85 c0                	test   %eax,%eax
80102bfe:	75 0a                	jne    80102c0a <kbdgetc+0x2c>
    return -1;
80102c00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c05:	e9 23 01 00 00       	jmp    80102d2d <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102c0a:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102c11:	e8 9e ff ff ff       	call   80102bb4 <inb>
80102c16:	0f b6 c0             	movzbl %al,%eax
80102c19:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c1c:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c23:	75 17                	jne    80102c3c <kbdgetc+0x5e>
    shift |= E0ESC;
80102c25:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c2a:	83 c8 40             	or     $0x40,%eax
80102c2d:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102c32:	b8 00 00 00 00       	mov    $0x0,%eax
80102c37:	e9 f1 00 00 00       	jmp    80102d2d <kbdgetc+0x14f>
  } else if(data & 0x80){
80102c3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c3f:	25 80 00 00 00       	and    $0x80,%eax
80102c44:	85 c0                	test   %eax,%eax
80102c46:	74 45                	je     80102c8d <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c48:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c4d:	83 e0 40             	and    $0x40,%eax
80102c50:	85 c0                	test   %eax,%eax
80102c52:	75 08                	jne    80102c5c <kbdgetc+0x7e>
80102c54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c57:	83 e0 7f             	and    $0x7f,%eax
80102c5a:	eb 03                	jmp    80102c5f <kbdgetc+0x81>
80102c5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c62:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c65:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c6a:	0f b6 00             	movzbl (%eax),%eax
80102c6d:	83 c8 40             	or     $0x40,%eax
80102c70:	0f b6 c0             	movzbl %al,%eax
80102c73:	f7 d0                	not    %eax
80102c75:	89 c2                	mov    %eax,%edx
80102c77:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c7c:	21 d0                	and    %edx,%eax
80102c7e:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102c83:	b8 00 00 00 00       	mov    $0x0,%eax
80102c88:	e9 a0 00 00 00       	jmp    80102d2d <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102c8d:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c92:	83 e0 40             	and    $0x40,%eax
80102c95:	85 c0                	test   %eax,%eax
80102c97:	74 14                	je     80102cad <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c99:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102ca0:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ca5:	83 e0 bf             	and    $0xffffffbf,%eax
80102ca8:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102cad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cb0:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102cb5:	0f b6 00             	movzbl (%eax),%eax
80102cb8:	0f b6 d0             	movzbl %al,%edx
80102cbb:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102cc0:	09 d0                	or     %edx,%eax
80102cc2:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102cc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cca:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102ccf:	0f b6 00             	movzbl (%eax),%eax
80102cd2:	0f b6 d0             	movzbl %al,%edx
80102cd5:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102cda:	31 d0                	xor    %edx,%eax
80102cdc:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102ce1:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ce6:	83 e0 03             	and    $0x3,%eax
80102ce9:	8b 04 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%eax
80102cf0:	03 45 fc             	add    -0x4(%ebp),%eax
80102cf3:	0f b6 00             	movzbl (%eax),%eax
80102cf6:	0f b6 c0             	movzbl %al,%eax
80102cf9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102cfc:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d01:	83 e0 08             	and    $0x8,%eax
80102d04:	85 c0                	test   %eax,%eax
80102d06:	74 22                	je     80102d2a <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102d08:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d0c:	76 0c                	jbe    80102d1a <kbdgetc+0x13c>
80102d0e:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d12:	77 06                	ja     80102d1a <kbdgetc+0x13c>
      c += 'A' - 'a';
80102d14:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d18:	eb 10                	jmp    80102d2a <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102d1a:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d1e:	76 0a                	jbe    80102d2a <kbdgetc+0x14c>
80102d20:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d24:	77 04                	ja     80102d2a <kbdgetc+0x14c>
      c += 'a' - 'A';
80102d26:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d2d:	c9                   	leave  
80102d2e:	c3                   	ret    

80102d2f <kbdintr>:

void
kbdintr(void)
{
80102d2f:	55                   	push   %ebp
80102d30:	89 e5                	mov    %esp,%ebp
80102d32:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102d35:	c7 04 24 de 2b 10 80 	movl   $0x80102bde,(%esp)
80102d3c:	e8 6c da ff ff       	call   801007ad <consoleintr>
}
80102d41:	c9                   	leave  
80102d42:	c3                   	ret    
	...

80102d44 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d44:	55                   	push   %ebp
80102d45:	89 e5                	mov    %esp,%ebp
80102d47:	53                   	push   %ebx
80102d48:	83 ec 14             	sub    $0x14,%esp
80102d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d4e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d52:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102d56:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102d5a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102d5e:	ec                   	in     (%dx),%al
80102d5f:	89 c3                	mov    %eax,%ebx
80102d61:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102d64:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102d68:	83 c4 14             	add    $0x14,%esp
80102d6b:	5b                   	pop    %ebx
80102d6c:	5d                   	pop    %ebp
80102d6d:	c3                   	ret    

80102d6e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d6e:	55                   	push   %ebp
80102d6f:	89 e5                	mov    %esp,%ebp
80102d71:	83 ec 08             	sub    $0x8,%esp
80102d74:	8b 55 08             	mov    0x8(%ebp),%edx
80102d77:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d7a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d7e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d81:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d85:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d89:	ee                   	out    %al,(%dx)
}
80102d8a:	c9                   	leave  
80102d8b:	c3                   	ret    

80102d8c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102d8c:	55                   	push   %ebp
80102d8d:	89 e5                	mov    %esp,%ebp
80102d8f:	53                   	push   %ebx
80102d90:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d93:	9c                   	pushf  
80102d94:	5b                   	pop    %ebx
80102d95:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102d98:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d9b:	83 c4 10             	add    $0x10,%esp
80102d9e:	5b                   	pop    %ebx
80102d9f:	5d                   	pop    %ebp
80102da0:	c3                   	ret    

80102da1 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102da1:	55                   	push   %ebp
80102da2:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102da4:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102da9:	8b 55 08             	mov    0x8(%ebp),%edx
80102dac:	c1 e2 02             	shl    $0x2,%edx
80102daf:	01 c2                	add    %eax,%edx
80102db1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102db4:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102db6:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102dbb:	83 c0 20             	add    $0x20,%eax
80102dbe:	8b 00                	mov    (%eax),%eax
}
80102dc0:	5d                   	pop    %ebp
80102dc1:	c3                   	ret    

80102dc2 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102dc2:	55                   	push   %ebp
80102dc3:	89 e5                	mov    %esp,%ebp
80102dc5:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102dc8:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102dcd:	85 c0                	test   %eax,%eax
80102dcf:	0f 84 47 01 00 00    	je     80102f1c <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102dd5:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102ddc:	00 
80102ddd:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102de4:	e8 b8 ff ff ff       	call   80102da1 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102de9:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102df0:	00 
80102df1:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102df8:	e8 a4 ff ff ff       	call   80102da1 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102dfd:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102e04:	00 
80102e05:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102e0c:	e8 90 ff ff ff       	call   80102da1 <lapicw>
  lapicw(TICR, 10000000); 
80102e11:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102e18:	00 
80102e19:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102e20:	e8 7c ff ff ff       	call   80102da1 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e25:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e2c:	00 
80102e2d:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102e34:	e8 68 ff ff ff       	call   80102da1 <lapicw>
  lapicw(LINT1, MASKED);
80102e39:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e40:	00 
80102e41:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e48:	e8 54 ff ff ff       	call   80102da1 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e4d:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e52:	83 c0 30             	add    $0x30,%eax
80102e55:	8b 00                	mov    (%eax),%eax
80102e57:	c1 e8 10             	shr    $0x10,%eax
80102e5a:	25 ff 00 00 00       	and    $0xff,%eax
80102e5f:	83 f8 03             	cmp    $0x3,%eax
80102e62:	76 14                	jbe    80102e78 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80102e64:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e6b:	00 
80102e6c:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e73:	e8 29 ff ff ff       	call   80102da1 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e78:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e7f:	00 
80102e80:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e87:	e8 15 ff ff ff       	call   80102da1 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e8c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e93:	00 
80102e94:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e9b:	e8 01 ff ff ff       	call   80102da1 <lapicw>
  lapicw(ESR, 0);
80102ea0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ea7:	00 
80102ea8:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102eaf:	e8 ed fe ff ff       	call   80102da1 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102eb4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ebb:	00 
80102ebc:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102ec3:	e8 d9 fe ff ff       	call   80102da1 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ec8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ecf:	00 
80102ed0:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102ed7:	e8 c5 fe ff ff       	call   80102da1 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102edc:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102ee3:	00 
80102ee4:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102eeb:	e8 b1 fe ff ff       	call   80102da1 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102ef0:	90                   	nop
80102ef1:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102ef6:	05 00 03 00 00       	add    $0x300,%eax
80102efb:	8b 00                	mov    (%eax),%eax
80102efd:	25 00 10 00 00       	and    $0x1000,%eax
80102f02:	85 c0                	test   %eax,%eax
80102f04:	75 eb                	jne    80102ef1 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f06:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f0d:	00 
80102f0e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102f15:	e8 87 fe ff ff       	call   80102da1 <lapicw>
80102f1a:	eb 01                	jmp    80102f1d <lapicinit+0x15b>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102f1c:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102f1d:	c9                   	leave  
80102f1e:	c3                   	ret    

80102f1f <cpunum>:

int
cpunum(void)
{
80102f1f:	55                   	push   %ebp
80102f20:	89 e5                	mov    %esp,%ebp
80102f22:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f25:	e8 62 fe ff ff       	call   80102d8c <readeflags>
80102f2a:	25 00 02 00 00       	and    $0x200,%eax
80102f2f:	85 c0                	test   %eax,%eax
80102f31:	74 29                	je     80102f5c <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80102f33:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102f38:	85 c0                	test   %eax,%eax
80102f3a:	0f 94 c2             	sete   %dl
80102f3d:	83 c0 01             	add    $0x1,%eax
80102f40:	a3 60 c6 10 80       	mov    %eax,0x8010c660
80102f45:	84 d2                	test   %dl,%dl
80102f47:	74 13                	je     80102f5c <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f49:	8b 45 04             	mov    0x4(%ebp),%eax
80102f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f50:	c7 04 24 ec 8d 10 80 	movl   $0x80108dec,(%esp)
80102f57:	e8 45 d4 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f5c:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f61:	85 c0                	test   %eax,%eax
80102f63:	74 0f                	je     80102f74 <cpunum+0x55>
    return lapic[ID]>>24;
80102f65:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f6a:	83 c0 20             	add    $0x20,%eax
80102f6d:	8b 00                	mov    (%eax),%eax
80102f6f:	c1 e8 18             	shr    $0x18,%eax
80102f72:	eb 05                	jmp    80102f79 <cpunum+0x5a>
  return 0;
80102f74:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f79:	c9                   	leave  
80102f7a:	c3                   	ret    

80102f7b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f7b:	55                   	push   %ebp
80102f7c:	89 e5                	mov    %esp,%ebp
80102f7e:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f81:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f86:	85 c0                	test   %eax,%eax
80102f88:	74 14                	je     80102f9e <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f8a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f91:	00 
80102f92:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f99:	e8 03 fe ff ff       	call   80102da1 <lapicw>
}
80102f9e:	c9                   	leave  
80102f9f:	c3                   	ret    

80102fa0 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102fa0:	55                   	push   %ebp
80102fa1:	89 e5                	mov    %esp,%ebp
}
80102fa3:	5d                   	pop    %ebp
80102fa4:	c3                   	ret    

80102fa5 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fa5:	55                   	push   %ebp
80102fa6:	89 e5                	mov    %esp,%ebp
80102fa8:	83 ec 1c             	sub    $0x1c,%esp
80102fab:	8b 45 08             	mov    0x8(%ebp),%eax
80102fae:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fb1:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102fb8:	00 
80102fb9:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102fc0:	e8 a9 fd ff ff       	call   80102d6e <outb>
  outb(CMOS_PORT+1, 0x0A);
80102fc5:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102fcc:	00 
80102fcd:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102fd4:	e8 95 fd ff ff       	call   80102d6e <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fd9:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102fe0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fe3:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102fe8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102feb:	8d 50 02             	lea    0x2(%eax),%edx
80102fee:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ff1:	c1 e8 04             	shr    $0x4,%eax
80102ff4:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102ff7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102ffb:	c1 e0 18             	shl    $0x18,%eax
80102ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
80103002:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103009:	e8 93 fd ff ff       	call   80102da1 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010300e:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103015:	00 
80103016:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010301d:	e8 7f fd ff ff       	call   80102da1 <lapicw>
  microdelay(200);
80103022:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103029:	e8 72 ff ff ff       	call   80102fa0 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010302e:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103035:	00 
80103036:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010303d:	e8 5f fd ff ff       	call   80102da1 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103042:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103049:	e8 52 ff ff ff       	call   80102fa0 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010304e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103055:	eb 40                	jmp    80103097 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103057:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010305b:	c1 e0 18             	shl    $0x18,%eax
8010305e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103062:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103069:	e8 33 fd ff ff       	call   80102da1 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010306e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103071:	c1 e8 0c             	shr    $0xc,%eax
80103074:	80 cc 06             	or     $0x6,%ah
80103077:	89 44 24 04          	mov    %eax,0x4(%esp)
8010307b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103082:	e8 1a fd ff ff       	call   80102da1 <lapicw>
    microdelay(200);
80103087:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010308e:	e8 0d ff ff ff       	call   80102fa0 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103093:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103097:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010309b:	7e ba                	jle    80103057 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010309d:	c9                   	leave  
8010309e:	c3                   	ret    

8010309f <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010309f:	55                   	push   %ebp
801030a0:	89 e5                	mov    %esp,%ebp
801030a2:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801030a5:	8b 45 08             	mov    0x8(%ebp),%eax
801030a8:	0f b6 c0             	movzbl %al,%eax
801030ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801030af:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801030b6:	e8 b3 fc ff ff       	call   80102d6e <outb>
  microdelay(200);
801030bb:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030c2:	e8 d9 fe ff ff       	call   80102fa0 <microdelay>

  return inb(CMOS_RETURN);
801030c7:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801030ce:	e8 71 fc ff ff       	call   80102d44 <inb>
801030d3:	0f b6 c0             	movzbl %al,%eax
}
801030d6:	c9                   	leave  
801030d7:	c3                   	ret    

801030d8 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030d8:	55                   	push   %ebp
801030d9:	89 e5                	mov    %esp,%ebp
801030db:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801030de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030e5:	e8 b5 ff ff ff       	call   8010309f <cmos_read>
801030ea:	8b 55 08             	mov    0x8(%ebp),%edx
801030ed:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801030ef:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801030f6:	e8 a4 ff ff ff       	call   8010309f <cmos_read>
801030fb:	8b 55 08             	mov    0x8(%ebp),%edx
801030fe:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103101:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103108:	e8 92 ff ff ff       	call   8010309f <cmos_read>
8010310d:	8b 55 08             	mov    0x8(%ebp),%edx
80103110:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103113:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
8010311a:	e8 80 ff ff ff       	call   8010309f <cmos_read>
8010311f:	8b 55 08             	mov    0x8(%ebp),%edx
80103122:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103125:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010312c:	e8 6e ff ff ff       	call   8010309f <cmos_read>
80103131:	8b 55 08             	mov    0x8(%ebp),%edx
80103134:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103137:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010313e:	e8 5c ff ff ff       	call   8010309f <cmos_read>
80103143:	8b 55 08             	mov    0x8(%ebp),%edx
80103146:	89 42 14             	mov    %eax,0x14(%edx)
}
80103149:	c9                   	leave  
8010314a:	c3                   	ret    

8010314b <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010314b:	55                   	push   %ebp
8010314c:	89 e5                	mov    %esp,%ebp
8010314e:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103151:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103158:	e8 42 ff ff ff       	call   8010309f <cmos_read>
8010315d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103163:	83 e0 04             	and    $0x4,%eax
80103166:	85 c0                	test   %eax,%eax
80103168:	0f 94 c0             	sete   %al
8010316b:	0f b6 c0             	movzbl %al,%eax
8010316e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103171:	eb 01                	jmp    80103174 <cmostime+0x29>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103173:	90                   	nop

  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103174:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103177:	89 04 24             	mov    %eax,(%esp)
8010317a:	e8 59 ff ff ff       	call   801030d8 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010317f:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103186:	e8 14 ff ff ff       	call   8010309f <cmos_read>
8010318b:	25 80 00 00 00       	and    $0x80,%eax
80103190:	85 c0                	test   %eax,%eax
80103192:	75 2b                	jne    801031bf <cmostime+0x74>
        continue;
    fill_rtcdate(&t2);
80103194:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103197:	89 04 24             	mov    %eax,(%esp)
8010319a:	e8 39 ff ff ff       	call   801030d8 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010319f:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801031a6:	00 
801031a7:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801031ae:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031b1:	89 04 24             	mov    %eax,(%esp)
801031b4:	e8 b4 24 00 00       	call   8010566d <memcmp>
801031b9:	85 c0                	test   %eax,%eax
801031bb:	75 b6                	jne    80103173 <cmostime+0x28>
      break;
801031bd:	eb 03                	jmp    801031c2 <cmostime+0x77>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801031bf:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801031c0:	eb b1                	jmp    80103173 <cmostime+0x28>

  // convert
  if (bcd) {
801031c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801031c6:	0f 84 a8 00 00 00    	je     80103274 <cmostime+0x129>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801031cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031cf:	89 c2                	mov    %eax,%edx
801031d1:	c1 ea 04             	shr    $0x4,%edx
801031d4:	89 d0                	mov    %edx,%eax
801031d6:	c1 e0 02             	shl    $0x2,%eax
801031d9:	01 d0                	add    %edx,%eax
801031db:	01 c0                	add    %eax,%eax
801031dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
801031e0:	83 e2 0f             	and    $0xf,%edx
801031e3:	01 d0                	add    %edx,%eax
801031e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031eb:	89 c2                	mov    %eax,%edx
801031ed:	c1 ea 04             	shr    $0x4,%edx
801031f0:	89 d0                	mov    %edx,%eax
801031f2:	c1 e0 02             	shl    $0x2,%eax
801031f5:	01 d0                	add    %edx,%eax
801031f7:	01 c0                	add    %eax,%eax
801031f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031fc:	83 e2 0f             	and    $0xf,%edx
801031ff:	01 d0                	add    %edx,%eax
80103201:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103204:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103207:	89 c2                	mov    %eax,%edx
80103209:	c1 ea 04             	shr    $0x4,%edx
8010320c:	89 d0                	mov    %edx,%eax
8010320e:	c1 e0 02             	shl    $0x2,%eax
80103211:	01 d0                	add    %edx,%eax
80103213:	01 c0                	add    %eax,%eax
80103215:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103218:	83 e2 0f             	and    $0xf,%edx
8010321b:	01 d0                	add    %edx,%eax
8010321d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103220:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103223:	89 c2                	mov    %eax,%edx
80103225:	c1 ea 04             	shr    $0x4,%edx
80103228:	89 d0                	mov    %edx,%eax
8010322a:	c1 e0 02             	shl    $0x2,%eax
8010322d:	01 d0                	add    %edx,%eax
8010322f:	01 c0                	add    %eax,%eax
80103231:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103234:	83 e2 0f             	and    $0xf,%edx
80103237:	01 d0                	add    %edx,%eax
80103239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010323c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010323f:	89 c2                	mov    %eax,%edx
80103241:	c1 ea 04             	shr    $0x4,%edx
80103244:	89 d0                	mov    %edx,%eax
80103246:	c1 e0 02             	shl    $0x2,%eax
80103249:	01 d0                	add    %edx,%eax
8010324b:	01 c0                	add    %eax,%eax
8010324d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103250:	83 e2 0f             	and    $0xf,%edx
80103253:	01 d0                	add    %edx,%eax
80103255:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103258:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010325b:	89 c2                	mov    %eax,%edx
8010325d:	c1 ea 04             	shr    $0x4,%edx
80103260:	89 d0                	mov    %edx,%eax
80103262:	c1 e0 02             	shl    $0x2,%eax
80103265:	01 d0                	add    %edx,%eax
80103267:	01 c0                	add    %eax,%eax
80103269:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010326c:	83 e2 0f             	and    $0xf,%edx
8010326f:	01 d0                	add    %edx,%eax
80103271:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103274:	8b 45 08             	mov    0x8(%ebp),%eax
80103277:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010327a:	89 10                	mov    %edx,(%eax)
8010327c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010327f:	89 50 04             	mov    %edx,0x4(%eax)
80103282:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103285:	89 50 08             	mov    %edx,0x8(%eax)
80103288:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010328b:	89 50 0c             	mov    %edx,0xc(%eax)
8010328e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103291:	89 50 10             	mov    %edx,0x10(%eax)
80103294:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103297:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010329a:	8b 45 08             	mov    0x8(%ebp),%eax
8010329d:	8b 40 14             	mov    0x14(%eax),%eax
801032a0:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801032a6:	8b 45 08             	mov    0x8(%ebp),%eax
801032a9:	89 50 14             	mov    %edx,0x14(%eax)
}
801032ac:	c9                   	leave  
801032ad:	c3                   	ret    
	...

801032b0 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
801032b0:	55                   	push   %ebp
801032b1:	89 e5                	mov    %esp,%ebp
801032b3:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801032b6:	c7 44 24 04 18 8e 10 	movl   $0x80108e18,0x4(%esp)
801032bd:	80 
801032be:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801032c5:	e8 bc 20 00 00       	call   80105386 <initlock>
  readsb(ROOTDEV, &sb);
801032ca:	8d 45 e8             	lea    -0x18(%ebp),%eax
801032cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801032d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801032d8:	e8 77 e0 ff ff       	call   80101354 <readsb>
  log.start = sb.size - sb.nlog;
801032dd:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e3:	89 d1                	mov    %edx,%ecx
801032e5:	29 c1                	sub    %eax,%ecx
801032e7:	89 c8                	mov    %ecx,%eax
801032e9:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
801032ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032f1:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = ROOTDEV;
801032f6:	c7 05 c4 32 11 80 01 	movl   $0x1,0x801132c4
801032fd:	00 00 00 
  recover_from_log();
80103300:	e8 97 01 00 00       	call   8010349c <recover_from_log>
}
80103305:	c9                   	leave  
80103306:	c3                   	ret    

80103307 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103307:	55                   	push   %ebp
80103308:	89 e5                	mov    %esp,%ebp
8010330a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010330d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103314:	e9 89 00 00 00       	jmp    801033a2 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103319:	a1 b4 32 11 80       	mov    0x801132b4,%eax
8010331e:	03 45 f4             	add    -0xc(%ebp),%eax
80103321:	83 c0 01             	add    $0x1,%eax
80103324:	89 c2                	mov    %eax,%edx
80103326:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010332b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010332f:	89 04 24             	mov    %eax,(%esp)
80103332:	e8 6f ce ff ff       	call   801001a6 <bread>
80103337:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010333a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010333d:	83 c0 10             	add    $0x10,%eax
80103340:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103347:	89 c2                	mov    %eax,%edx
80103349:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010334e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103352:	89 04 24             	mov    %eax,(%esp)
80103355:	e8 4c ce ff ff       	call   801001a6 <bread>
8010335a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010335d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103360:	8d 50 18             	lea    0x18(%eax),%edx
80103363:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103366:	83 c0 18             	add    $0x18,%eax
80103369:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103370:	00 
80103371:	89 54 24 04          	mov    %edx,0x4(%esp)
80103375:	89 04 24             	mov    %eax,(%esp)
80103378:	e8 4c 23 00 00       	call   801056c9 <memmove>
    bwrite(dbuf);  // write dst to disk
8010337d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103380:	89 04 24             	mov    %eax,(%esp)
80103383:	e8 55 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103388:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010338b:	89 04 24             	mov    %eax,(%esp)
8010338e:	e8 84 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103393:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103396:	89 04 24             	mov    %eax,(%esp)
80103399:	e8 79 ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010339e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033a2:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801033a7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033aa:	0f 8f 69 ff ff ff    	jg     80103319 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801033b0:	c9                   	leave  
801033b1:	c3                   	ret    

801033b2 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801033b2:	55                   	push   %ebp
801033b3:	89 e5                	mov    %esp,%ebp
801033b5:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033b8:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801033bd:	89 c2                	mov    %eax,%edx
801033bf:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801033c4:	89 54 24 04          	mov    %edx,0x4(%esp)
801033c8:	89 04 24             	mov    %eax,(%esp)
801033cb:	e8 d6 cd ff ff       	call   801001a6 <bread>
801033d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033d6:	83 c0 18             	add    $0x18,%eax
801033d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033df:	8b 00                	mov    (%eax),%eax
801033e1:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
801033e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033ed:	eb 1b                	jmp    8010340a <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
801033ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033f5:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033fc:	83 c2 10             	add    $0x10,%edx
801033ff:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103406:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010340a:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010340f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103412:	7f db                	jg     801033ef <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103414:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103417:	89 04 24             	mov    %eax,(%esp)
8010341a:	e8 f8 cd ff ff       	call   80100217 <brelse>
}
8010341f:	c9                   	leave  
80103420:	c3                   	ret    

80103421 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103421:	55                   	push   %ebp
80103422:	89 e5                	mov    %esp,%ebp
80103424:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103427:	a1 b4 32 11 80       	mov    0x801132b4,%eax
8010342c:	89 c2                	mov    %eax,%edx
8010342e:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103433:	89 54 24 04          	mov    %edx,0x4(%esp)
80103437:	89 04 24             	mov    %eax,(%esp)
8010343a:	e8 67 cd ff ff       	call   801001a6 <bread>
8010343f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103442:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103445:	83 c0 18             	add    $0x18,%eax
80103448:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010344b:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
80103451:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103454:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103456:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010345d:	eb 1b                	jmp    8010347a <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
8010345f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103462:	83 c0 10             	add    $0x10,%eax
80103465:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
8010346c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103472:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103476:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010347a:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010347f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103482:	7f db                	jg     8010345f <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103484:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103487:	89 04 24             	mov    %eax,(%esp)
8010348a:	e8 4e cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
8010348f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103492:	89 04 24             	mov    %eax,(%esp)
80103495:	e8 7d cd ff ff       	call   80100217 <brelse>
}
8010349a:	c9                   	leave  
8010349b:	c3                   	ret    

8010349c <recover_from_log>:

static void
recover_from_log(void)
{
8010349c:	55                   	push   %ebp
8010349d:	89 e5                	mov    %esp,%ebp
8010349f:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801034a2:	e8 0b ff ff ff       	call   801033b2 <read_head>
  install_trans(); // if committed, copy from log to disk
801034a7:	e8 5b fe ff ff       	call   80103307 <install_trans>
  log.lh.n = 0;
801034ac:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801034b3:	00 00 00 
  write_head(); // clear the log
801034b6:	e8 66 ff ff ff       	call   80103421 <write_head>
}
801034bb:	c9                   	leave  
801034bc:	c3                   	ret    

801034bd <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034bd:	55                   	push   %ebp
801034be:	89 e5                	mov    %esp,%ebp
801034c0:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801034c3:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034ca:	e8 d8 1e 00 00       	call   801053a7 <acquire>
  while(1){
    if(log.committing){
801034cf:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801034d4:	85 c0                	test   %eax,%eax
801034d6:	74 16                	je     801034ee <begin_op+0x31>
      sleep(&log, &log.lock);
801034d8:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
801034df:	80 
801034e0:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801034e7:	e8 d5 1b 00 00       	call   801050c1 <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
801034ec:	eb e1                	jmp    801034cf <begin_op+0x12>
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034ee:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
801034f4:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034f9:	8d 50 01             	lea    0x1(%eax),%edx
801034fc:	89 d0                	mov    %edx,%eax
801034fe:	c1 e0 02             	shl    $0x2,%eax
80103501:	01 d0                	add    %edx,%eax
80103503:	01 c0                	add    %eax,%eax
80103505:	01 c8                	add    %ecx,%eax
80103507:	83 f8 1e             	cmp    $0x1e,%eax
8010350a:	7e 16                	jle    80103522 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010350c:	c7 44 24 04 80 32 11 	movl   $0x80113280,0x4(%esp)
80103513:	80 
80103514:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010351b:	e8 a1 1b 00 00       	call   801050c1 <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
80103520:	eb ad                	jmp    801034cf <begin_op+0x12>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
80103522:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103527:	83 c0 01             	add    $0x1,%eax
8010352a:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
8010352f:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103536:	e8 ce 1e 00 00       	call   80105409 <release>
      break;
8010353b:	90                   	nop
    }
  }
}
8010353c:	c9                   	leave  
8010353d:	c3                   	ret    

8010353e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010353e:	55                   	push   %ebp
8010353f:	89 e5                	mov    %esp,%ebp
80103541:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103544:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010354b:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103552:	e8 50 1e 00 00       	call   801053a7 <acquire>
  log.outstanding -= 1;
80103557:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010355c:	83 e8 01             	sub    $0x1,%eax
8010355f:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
80103564:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103569:	85 c0                	test   %eax,%eax
8010356b:	74 0c                	je     80103579 <end_op+0x3b>
    panic("log.committing");
8010356d:	c7 04 24 1c 8e 10 80 	movl   $0x80108e1c,(%esp)
80103574:	e8 c4 cf ff ff       	call   8010053d <panic>
  if(log.outstanding == 0){
80103579:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010357e:	85 c0                	test   %eax,%eax
80103580:	75 13                	jne    80103595 <end_op+0x57>
    do_commit = 1;
80103582:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103589:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
80103590:	00 00 00 
80103593:	eb 0c                	jmp    801035a1 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103595:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010359c:	e8 fc 1b 00 00       	call   8010519d <wakeup>
  }
  release(&log.lock);
801035a1:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801035a8:	e8 5c 1e 00 00       	call   80105409 <release>

  if(do_commit){
801035ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035b1:	74 33                	je     801035e6 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035b3:	e8 db 00 00 00       	call   80103693 <commit>
    acquire(&log.lock);
801035b8:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801035bf:	e8 e3 1d 00 00       	call   801053a7 <acquire>
    log.committing = 0;
801035c4:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
801035cb:	00 00 00 
    wakeup(&log);
801035ce:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801035d5:	e8 c3 1b 00 00       	call   8010519d <wakeup>
    release(&log.lock);
801035da:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
801035e1:	e8 23 1e 00 00       	call   80105409 <release>
  }
}
801035e6:	c9                   	leave  
801035e7:	c3                   	ret    

801035e8 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801035e8:	55                   	push   %ebp
801035e9:	89 e5                	mov    %esp,%ebp
801035eb:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035f5:	e9 89 00 00 00       	jmp    80103683 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035fa:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801035ff:	03 45 f4             	add    -0xc(%ebp),%eax
80103602:	83 c0 01             	add    $0x1,%eax
80103605:	89 c2                	mov    %eax,%edx
80103607:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010360c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103610:	89 04 24             	mov    %eax,(%esp)
80103613:	e8 8e cb ff ff       	call   801001a6 <bread>
80103618:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
8010361b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010361e:	83 c0 10             	add    $0x10,%eax
80103621:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103628:	89 c2                	mov    %eax,%edx
8010362a:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010362f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103633:	89 04 24             	mov    %eax,(%esp)
80103636:	e8 6b cb ff ff       	call   801001a6 <bread>
8010363b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010363e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103641:	8d 50 18             	lea    0x18(%eax),%edx
80103644:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103647:	83 c0 18             	add    $0x18,%eax
8010364a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103651:	00 
80103652:	89 54 24 04          	mov    %edx,0x4(%esp)
80103656:	89 04 24             	mov    %eax,(%esp)
80103659:	e8 6b 20 00 00       	call   801056c9 <memmove>
    bwrite(to);  // write the log
8010365e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103661:	89 04 24             	mov    %eax,(%esp)
80103664:	e8 74 cb ff ff       	call   801001dd <bwrite>
    brelse(from); 
80103669:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010366c:	89 04 24             	mov    %eax,(%esp)
8010366f:	e8 a3 cb ff ff       	call   80100217 <brelse>
    brelse(to);
80103674:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103677:	89 04 24             	mov    %eax,(%esp)
8010367a:	e8 98 cb ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010367f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103683:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103688:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010368b:	0f 8f 69 ff ff ff    	jg     801035fa <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103691:	c9                   	leave  
80103692:	c3                   	ret    

80103693 <commit>:

static void
commit()
{
80103693:	55                   	push   %ebp
80103694:	89 e5                	mov    %esp,%ebp
80103696:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103699:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010369e:	85 c0                	test   %eax,%eax
801036a0:	7e 1e                	jle    801036c0 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036a2:	e8 41 ff ff ff       	call   801035e8 <write_log>
    write_head();    // Write header to disk -- the real commit
801036a7:	e8 75 fd ff ff       	call   80103421 <write_head>
    install_trans(); // Now install writes to home locations
801036ac:	e8 56 fc ff ff       	call   80103307 <install_trans>
    log.lh.n = 0; 
801036b1:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801036b8:	00 00 00 
    write_head();    // Erase the transaction from the log
801036bb:	e8 61 fd ff ff       	call   80103421 <write_head>
  }
}
801036c0:	c9                   	leave  
801036c1:	c3                   	ret    

801036c2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036c2:	55                   	push   %ebp
801036c3:	89 e5                	mov    %esp,%ebp
801036c5:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036c8:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036cd:	83 f8 1d             	cmp    $0x1d,%eax
801036d0:	7f 12                	jg     801036e4 <log_write+0x22>
801036d2:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036d7:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
801036dd:	83 ea 01             	sub    $0x1,%edx
801036e0:	39 d0                	cmp    %edx,%eax
801036e2:	7c 0c                	jl     801036f0 <log_write+0x2e>
    panic("too big a transaction");
801036e4:	c7 04 24 2b 8e 10 80 	movl   $0x80108e2b,(%esp)
801036eb:	e8 4d ce ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
801036f0:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801036f5:	85 c0                	test   %eax,%eax
801036f7:	7f 0c                	jg     80103705 <log_write+0x43>
    panic("log_write outside of trans");
801036f9:	c7 04 24 41 8e 10 80 	movl   $0x80108e41,(%esp)
80103700:	e8 38 ce ff ff       	call   8010053d <panic>

  acquire(&log.lock);
80103705:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
8010370c:	e8 96 1c 00 00       	call   801053a7 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103711:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103718:	eb 1d                	jmp    80103737 <log_write+0x75>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
8010371a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010371d:	83 c0 10             	add    $0x10,%eax
80103720:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103727:	89 c2                	mov    %eax,%edx
80103729:	8b 45 08             	mov    0x8(%ebp),%eax
8010372c:	8b 40 08             	mov    0x8(%eax),%eax
8010372f:	39 c2                	cmp    %eax,%edx
80103731:	74 10                	je     80103743 <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103733:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103737:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010373c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010373f:	7f d9                	jg     8010371a <log_write+0x58>
80103741:	eb 01                	jmp    80103744 <log_write+0x82>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
80103743:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103744:	8b 45 08             	mov    0x8(%ebp),%eax
80103747:	8b 40 08             	mov    0x8(%eax),%eax
8010374a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010374d:	83 c2 10             	add    $0x10,%edx
80103750:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
  if (i == log.lh.n)
80103757:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010375c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010375f:	75 0d                	jne    8010376e <log_write+0xac>
    log.lh.n++;
80103761:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103766:	83 c0 01             	add    $0x1,%eax
80103769:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
8010376e:	8b 45 08             	mov    0x8(%ebp),%eax
80103771:	8b 00                	mov    (%eax),%eax
80103773:	89 c2                	mov    %eax,%edx
80103775:	83 ca 04             	or     $0x4,%edx
80103778:	8b 45 08             	mov    0x8(%ebp),%eax
8010377b:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010377d:	c7 04 24 80 32 11 80 	movl   $0x80113280,(%esp)
80103784:	e8 80 1c 00 00       	call   80105409 <release>
}
80103789:	c9                   	leave  
8010378a:	c3                   	ret    
	...

8010378c <v2p>:
8010378c:	55                   	push   %ebp
8010378d:	89 e5                	mov    %esp,%ebp
8010378f:	8b 45 08             	mov    0x8(%ebp),%eax
80103792:	05 00 00 00 80       	add    $0x80000000,%eax
80103797:	5d                   	pop    %ebp
80103798:	c3                   	ret    

80103799 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103799:	55                   	push   %ebp
8010379a:	89 e5                	mov    %esp,%ebp
8010379c:	8b 45 08             	mov    0x8(%ebp),%eax
8010379f:	05 00 00 00 80       	add    $0x80000000,%eax
801037a4:	5d                   	pop    %ebp
801037a5:	c3                   	ret    

801037a6 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801037a6:	55                   	push   %ebp
801037a7:	89 e5                	mov    %esp,%ebp
801037a9:	53                   	push   %ebx
801037aa:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
801037ad:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037b0:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
801037b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037b6:	89 c3                	mov    %eax,%ebx
801037b8:	89 d8                	mov    %ebx,%eax
801037ba:	f0 87 02             	lock xchg %eax,(%edx)
801037bd:	89 c3                	mov    %eax,%ebx
801037bf:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801037c5:	83 c4 10             	add    $0x10,%esp
801037c8:	5b                   	pop    %ebx
801037c9:	5d                   	pop    %ebp
801037ca:	c3                   	ret    

801037cb <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037cb:	55                   	push   %ebp
801037cc:	89 e5                	mov    %esp,%ebp
801037ce:	83 e4 f0             	and    $0xfffffff0,%esp
801037d1:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801037d4:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801037db:	80 
801037dc:	c7 04 24 5c 68 11 80 	movl   $0x8011685c,(%esp)
801037e3:	e8 51 f2 ff ff       	call   80102a39 <kinit1>
  kvmalloc();      // kernel page table
801037e8:	e8 69 4c 00 00       	call   80108456 <kvmalloc>
  mpinit();        // collect info about this machine
801037ed:	e8 53 04 00 00       	call   80103c45 <mpinit>
  lapicinit();
801037f2:	e8 cb f5 ff ff       	call   80102dc2 <lapicinit>
  seginit();       // set up segments
801037f7:	e8 fd 45 00 00       	call   80107df9 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037fc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103802:	0f b6 00             	movzbl (%eax),%eax
80103805:	0f b6 c0             	movzbl %al,%eax
80103808:	89 44 24 04          	mov    %eax,0x4(%esp)
8010380c:	c7 04 24 5c 8e 10 80 	movl   $0x80108e5c,(%esp)
80103813:	e8 89 cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
80103818:	e8 8d 06 00 00       	call   80103eaa <picinit>
  ioapicinit();    // another interrupt controller
8010381d:	e8 07 f1 ff ff       	call   80102929 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103822:	e8 66 d2 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
80103827:	e8 18 39 00 00       	call   80107144 <uartinit>
  pinit();         // process table
8010382c:	e8 8e 0b 00 00       	call   801043bf <pinit>
  tvinit();        // trap vectors
80103831:	e8 39 34 00 00       	call   80106c6f <tvinit>
  binit();         // buffer cache
80103836:	e8 f9 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010383b:	e8 28 d7 ff ff       	call   80100f68 <fileinit>
  iinit();         // inode cache
80103840:	e8 d6 dd ff ff       	call   8010161b <iinit>
  ideinit();       // disk
80103845:	e8 44 ed ff ff       	call   8010258e <ideinit>
  if(!ismp)
8010384a:	a1 64 33 11 80       	mov    0x80113364,%eax
8010384f:	85 c0                	test   %eax,%eax
80103851:	75 05                	jne    80103858 <main+0x8d>
    timerinit();   // uniprocessor timer
80103853:	e8 5a 33 00 00       	call   80106bb2 <timerinit>
  startothers();   // start other processors
80103858:	e8 7f 00 00 00       	call   801038dc <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010385d:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103864:	8e 
80103865:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
8010386c:	e8 00 f2 ff ff       	call   80102a71 <kinit2>
  userinit();      // first user process
80103871:	e8 77 0c 00 00       	call   801044ed <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103876:	e8 1a 00 00 00       	call   80103895 <mpmain>

8010387b <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010387b:	55                   	push   %ebp
8010387c:	89 e5                	mov    %esp,%ebp
8010387e:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103881:	e8 e7 4b 00 00       	call   8010846d <switchkvm>
  seginit();
80103886:	e8 6e 45 00 00       	call   80107df9 <seginit>
  lapicinit();
8010388b:	e8 32 f5 ff ff       	call   80102dc2 <lapicinit>
  mpmain();
80103890:	e8 00 00 00 00       	call   80103895 <mpmain>

80103895 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103895:	55                   	push   %ebp
80103896:	89 e5                	mov    %esp,%ebp
80103898:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010389b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038a1:	0f b6 00             	movzbl (%eax),%eax
801038a4:	0f b6 c0             	movzbl %al,%eax
801038a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801038ab:	c7 04 24 73 8e 10 80 	movl   $0x80108e73,(%esp)
801038b2:	e8 ea ca ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
801038b7:	e8 27 35 00 00       	call   80106de3 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801038bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038c2:	05 a8 00 00 00       	add    $0xa8,%eax
801038c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801038ce:	00 
801038cf:	89 04 24             	mov    %eax,(%esp)
801038d2:	e8 cf fe ff ff       	call   801037a6 <xchg>
  scheduler();     // start running processes
801038d7:	e8 bc 16 00 00       	call   80104f98 <scheduler>

801038dc <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038dc:	55                   	push   %ebp
801038dd:	89 e5                	mov    %esp,%ebp
801038df:	53                   	push   %ebx
801038e0:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801038e3:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801038ea:	e8 aa fe ff ff       	call   80103799 <p2v>
801038ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038f2:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038f7:	89 44 24 08          	mov    %eax,0x8(%esp)
801038fb:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
80103902:	80 
80103903:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103906:	89 04 24             	mov    %eax,(%esp)
80103909:	e8 bb 1d 00 00       	call   801056c9 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
8010390e:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
80103915:	e9 86 00 00 00       	jmp    801039a0 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
8010391a:	e8 00 f6 ff ff       	call   80102f1f <cpunum>
8010391f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103925:	05 80 33 11 80       	add    $0x80113380,%eax
8010392a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010392d:	74 69                	je     80103998 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010392f:	e8 33 f2 ff ff       	call   80102b67 <kalloc>
80103934:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103937:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010393a:	83 e8 04             	sub    $0x4,%eax
8010393d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103940:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103946:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010394b:	83 e8 08             	sub    $0x8,%eax
8010394e:	c7 00 7b 38 10 80    	movl   $0x8010387b,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103957:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010395a:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
80103961:	e8 26 fe ff ff       	call   8010378c <v2p>
80103966:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103968:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010396b:	89 04 24             	mov    %eax,(%esp)
8010396e:	e8 19 fe ff ff       	call   8010378c <v2p>
80103973:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103976:	0f b6 12             	movzbl (%edx),%edx
80103979:	0f b6 d2             	movzbl %dl,%edx
8010397c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103980:	89 14 24             	mov    %edx,(%esp)
80103983:	e8 1d f6 ff ff       	call   80102fa5 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103988:	90                   	nop
80103989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010398c:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103992:	85 c0                	test   %eax,%eax
80103994:	74 f3                	je     80103989 <startothers+0xad>
80103996:	eb 01                	jmp    80103999 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103998:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103999:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801039a0:	a1 60 39 11 80       	mov    0x80113960,%eax
801039a5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039ab:	05 80 33 11 80       	add    $0x80113380,%eax
801039b0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039b3:	0f 87 61 ff ff ff    	ja     8010391a <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039b9:	83 c4 24             	add    $0x24,%esp
801039bc:	5b                   	pop    %ebx
801039bd:	5d                   	pop    %ebp
801039be:	c3                   	ret    
	...

801039c0 <p2v>:
801039c0:	55                   	push   %ebp
801039c1:	89 e5                	mov    %esp,%ebp
801039c3:	8b 45 08             	mov    0x8(%ebp),%eax
801039c6:	05 00 00 00 80       	add    $0x80000000,%eax
801039cb:	5d                   	pop    %ebp
801039cc:	c3                   	ret    

801039cd <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039cd:	55                   	push   %ebp
801039ce:	89 e5                	mov    %esp,%ebp
801039d0:	53                   	push   %ebx
801039d1:	83 ec 14             	sub    $0x14,%esp
801039d4:	8b 45 08             	mov    0x8(%ebp),%eax
801039d7:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039db:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801039df:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801039e3:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801039e7:	ec                   	in     (%dx),%al
801039e8:	89 c3                	mov    %eax,%ebx
801039ea:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801039ed:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801039f1:	83 c4 14             	add    $0x14,%esp
801039f4:	5b                   	pop    %ebx
801039f5:	5d                   	pop    %ebp
801039f6:	c3                   	ret    

801039f7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039f7:	55                   	push   %ebp
801039f8:	89 e5                	mov    %esp,%ebp
801039fa:	83 ec 08             	sub    $0x8,%esp
801039fd:	8b 55 08             	mov    0x8(%ebp),%edx
80103a00:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a03:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a07:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a0a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a0e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a12:	ee                   	out    %al,(%dx)
}
80103a13:	c9                   	leave  
80103a14:	c3                   	ret    

80103a15 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103a15:	55                   	push   %ebp
80103a16:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103a18:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103a1d:	89 c2                	mov    %eax,%edx
80103a1f:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103a24:	89 d1                	mov    %edx,%ecx
80103a26:	29 c1                	sub    %eax,%ecx
80103a28:	89 c8                	mov    %ecx,%eax
80103a2a:	c1 f8 02             	sar    $0x2,%eax
80103a2d:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103a33:	5d                   	pop    %ebp
80103a34:	c3                   	ret    

80103a35 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103a35:	55                   	push   %ebp
80103a36:	89 e5                	mov    %esp,%ebp
80103a38:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103a3b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a42:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a49:	eb 13                	jmp    80103a5e <sum+0x29>
    sum += addr[i];
80103a4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a4e:	03 45 08             	add    0x8(%ebp),%eax
80103a51:	0f b6 00             	movzbl (%eax),%eax
80103a54:	0f b6 c0             	movzbl %al,%eax
80103a57:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a5a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a61:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a64:	7c e5                	jl     80103a4b <sum+0x16>
    sum += addr[i];
  return sum;
80103a66:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a69:	c9                   	leave  
80103a6a:	c3                   	ret    

80103a6b <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a6b:	55                   	push   %ebp
80103a6c:	89 e5                	mov    %esp,%ebp
80103a6e:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a71:	8b 45 08             	mov    0x8(%ebp),%eax
80103a74:	89 04 24             	mov    %eax,(%esp)
80103a77:	e8 44 ff ff ff       	call   801039c0 <p2v>
80103a7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a82:	03 45 f0             	add    -0x10(%ebp),%eax
80103a85:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a8e:	eb 3f                	jmp    80103acf <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a90:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a97:	00 
80103a98:	c7 44 24 04 84 8e 10 	movl   $0x80108e84,0x4(%esp)
80103a9f:	80 
80103aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa3:	89 04 24             	mov    %eax,(%esp)
80103aa6:	e8 c2 1b 00 00       	call   8010566d <memcmp>
80103aab:	85 c0                	test   %eax,%eax
80103aad:	75 1c                	jne    80103acb <mpsearch1+0x60>
80103aaf:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103ab6:	00 
80103ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aba:	89 04 24             	mov    %eax,(%esp)
80103abd:	e8 73 ff ff ff       	call   80103a35 <sum>
80103ac2:	84 c0                	test   %al,%al
80103ac4:	75 05                	jne    80103acb <mpsearch1+0x60>
      return (struct mp*)p;
80103ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac9:	eb 11                	jmp    80103adc <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103acb:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ad2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ad5:	72 b9                	jb     80103a90 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103ad7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103adc:	c9                   	leave  
80103add:	c3                   	ret    

80103ade <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ade:	55                   	push   %ebp
80103adf:	89 e5                	mov    %esp,%ebp
80103ae1:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ae4:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aee:	83 c0 0f             	add    $0xf,%eax
80103af1:	0f b6 00             	movzbl (%eax),%eax
80103af4:	0f b6 c0             	movzbl %al,%eax
80103af7:	89 c2                	mov    %eax,%edx
80103af9:	c1 e2 08             	shl    $0x8,%edx
80103afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aff:	83 c0 0e             	add    $0xe,%eax
80103b02:	0f b6 00             	movzbl (%eax),%eax
80103b05:	0f b6 c0             	movzbl %al,%eax
80103b08:	09 d0                	or     %edx,%eax
80103b0a:	c1 e0 04             	shl    $0x4,%eax
80103b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b14:	74 21                	je     80103b37 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b16:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b1d:	00 
80103b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b21:	89 04 24             	mov    %eax,(%esp)
80103b24:	e8 42 ff ff ff       	call   80103a6b <mpsearch1>
80103b29:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b2c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b30:	74 50                	je     80103b82 <mpsearch+0xa4>
      return mp;
80103b32:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b35:	eb 5f                	jmp    80103b96 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b3a:	83 c0 14             	add    $0x14,%eax
80103b3d:	0f b6 00             	movzbl (%eax),%eax
80103b40:	0f b6 c0             	movzbl %al,%eax
80103b43:	89 c2                	mov    %eax,%edx
80103b45:	c1 e2 08             	shl    $0x8,%edx
80103b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4b:	83 c0 13             	add    $0x13,%eax
80103b4e:	0f b6 00             	movzbl (%eax),%eax
80103b51:	0f b6 c0             	movzbl %al,%eax
80103b54:	09 d0                	or     %edx,%eax
80103b56:	c1 e0 0a             	shl    $0xa,%eax
80103b59:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b5f:	2d 00 04 00 00       	sub    $0x400,%eax
80103b64:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b6b:	00 
80103b6c:	89 04 24             	mov    %eax,(%esp)
80103b6f:	e8 f7 fe ff ff       	call   80103a6b <mpsearch1>
80103b74:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b77:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b7b:	74 05                	je     80103b82 <mpsearch+0xa4>
      return mp;
80103b7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b80:	eb 14                	jmp    80103b96 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b82:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b89:	00 
80103b8a:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b91:	e8 d5 fe ff ff       	call   80103a6b <mpsearch1>
}
80103b96:	c9                   	leave  
80103b97:	c3                   	ret    

80103b98 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b98:	55                   	push   %ebp
80103b99:	89 e5                	mov    %esp,%ebp
80103b9b:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b9e:	e8 3b ff ff ff       	call   80103ade <mpsearch>
80103ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ba6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103baa:	74 0a                	je     80103bb6 <mpconfig+0x1e>
80103bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103baf:	8b 40 04             	mov    0x4(%eax),%eax
80103bb2:	85 c0                	test   %eax,%eax
80103bb4:	75 0a                	jne    80103bc0 <mpconfig+0x28>
    return 0;
80103bb6:	b8 00 00 00 00       	mov    $0x0,%eax
80103bbb:	e9 83 00 00 00       	jmp    80103c43 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc3:	8b 40 04             	mov    0x4(%eax),%eax
80103bc6:	89 04 24             	mov    %eax,(%esp)
80103bc9:	e8 f2 fd ff ff       	call   801039c0 <p2v>
80103bce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bd1:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bd8:	00 
80103bd9:	c7 44 24 04 89 8e 10 	movl   $0x80108e89,0x4(%esp)
80103be0:	80 
80103be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be4:	89 04 24             	mov    %eax,(%esp)
80103be7:	e8 81 1a 00 00       	call   8010566d <memcmp>
80103bec:	85 c0                	test   %eax,%eax
80103bee:	74 07                	je     80103bf7 <mpconfig+0x5f>
    return 0;
80103bf0:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf5:	eb 4c                	jmp    80103c43 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfa:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bfe:	3c 01                	cmp    $0x1,%al
80103c00:	74 12                	je     80103c14 <mpconfig+0x7c>
80103c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c05:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c09:	3c 04                	cmp    $0x4,%al
80103c0b:	74 07                	je     80103c14 <mpconfig+0x7c>
    return 0;
80103c0d:	b8 00 00 00 00       	mov    $0x0,%eax
80103c12:	eb 2f                	jmp    80103c43 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103c14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c17:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c1b:	0f b7 c0             	movzwl %ax,%eax
80103c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c25:	89 04 24             	mov    %eax,(%esp)
80103c28:	e8 08 fe ff ff       	call   80103a35 <sum>
80103c2d:	84 c0                	test   %al,%al
80103c2f:	74 07                	je     80103c38 <mpconfig+0xa0>
    return 0;
80103c31:	b8 00 00 00 00       	mov    $0x0,%eax
80103c36:	eb 0b                	jmp    80103c43 <mpconfig+0xab>
  *pmp = mp;
80103c38:	8b 45 08             	mov    0x8(%ebp),%eax
80103c3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c3e:	89 10                	mov    %edx,(%eax)
  return conf;
80103c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c43:	c9                   	leave  
80103c44:	c3                   	ret    

80103c45 <mpinit>:

void
mpinit(void)
{
80103c45:	55                   	push   %ebp
80103c46:	89 e5                	mov    %esp,%ebp
80103c48:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c4b:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103c52:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c55:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c58:	89 04 24             	mov    %eax,(%esp)
80103c5b:	e8 38 ff ff ff       	call   80103b98 <mpconfig>
80103c60:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c63:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c67:	0f 84 9c 01 00 00    	je     80103e09 <mpinit+0x1c4>
    return;
  ismp = 1;
80103c6d:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103c74:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7a:	8b 40 24             	mov    0x24(%eax),%eax
80103c7d:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c85:	83 c0 2c             	add    $0x2c,%eax
80103c88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c8e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c92:	0f b7 c0             	movzwl %ax,%eax
80103c95:	03 45 f0             	add    -0x10(%ebp),%eax
80103c98:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c9b:	e9 f4 00 00 00       	jmp    80103d94 <mpinit+0x14f>
    switch(*p){
80103ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca3:	0f b6 00             	movzbl (%eax),%eax
80103ca6:	0f b6 c0             	movzbl %al,%eax
80103ca9:	83 f8 04             	cmp    $0x4,%eax
80103cac:	0f 87 bf 00 00 00    	ja     80103d71 <mpinit+0x12c>
80103cb2:	8b 04 85 cc 8e 10 80 	mov    -0x7fef7134(,%eax,4),%eax
80103cb9:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cbe:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103cc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cc4:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cc8:	0f b6 d0             	movzbl %al,%edx
80103ccb:	a1 60 39 11 80       	mov    0x80113960,%eax
80103cd0:	39 c2                	cmp    %eax,%edx
80103cd2:	74 2d                	je     80103d01 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103cd4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cd7:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cdb:	0f b6 d0             	movzbl %al,%edx
80103cde:	a1 60 39 11 80       	mov    0x80113960,%eax
80103ce3:	89 54 24 08          	mov    %edx,0x8(%esp)
80103ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ceb:	c7 04 24 8e 8e 10 80 	movl   $0x80108e8e,(%esp)
80103cf2:	e8 aa c6 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103cf7:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103cfe:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103d01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d04:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103d08:	0f b6 c0             	movzbl %al,%eax
80103d0b:	83 e0 02             	and    $0x2,%eax
80103d0e:	85 c0                	test   %eax,%eax
80103d10:	74 15                	je     80103d27 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103d12:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d17:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d1d:	05 80 33 11 80       	add    $0x80113380,%eax
80103d22:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103d27:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103d2d:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d32:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103d38:	81 c2 80 33 11 80    	add    $0x80113380,%edx
80103d3e:	88 02                	mov    %al,(%edx)
      ncpu++;
80103d40:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d45:	83 c0 01             	add    $0x1,%eax
80103d48:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103d4d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d51:	eb 41                	jmp    80103d94 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d56:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d5c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d60:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103d65:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d69:	eb 29                	jmp    80103d94 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d6b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d6f:	eb 23                	jmp    80103d94 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d74:	0f b6 00             	movzbl (%eax),%eax
80103d77:	0f b6 c0             	movzbl %al,%eax
80103d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d7e:	c7 04 24 ac 8e 10 80 	movl   $0x80108eac,(%esp)
80103d85:	e8 17 c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d8a:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103d91:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d97:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d9a:	0f 82 00 ff ff ff    	jb     80103ca0 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103da0:	a1 64 33 11 80       	mov    0x80113364,%eax
80103da5:	85 c0                	test   %eax,%eax
80103da7:	75 1d                	jne    80103dc6 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103da9:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103db0:	00 00 00 
    lapic = 0;
80103db3:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103dba:	00 00 00 
    ioapicid = 0;
80103dbd:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103dc4:	eb 44                	jmp    80103e0a <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc9:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103dcd:	84 c0                	test   %al,%al
80103dcf:	74 39                	je     80103e0a <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103dd1:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103dd8:	00 
80103dd9:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103de0:	e8 12 fc ff ff       	call   801039f7 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103de5:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103dec:	e8 dc fb ff ff       	call   801039cd <inb>
80103df1:	83 c8 01             	or     $0x1,%eax
80103df4:	0f b6 c0             	movzbl %al,%eax
80103df7:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dfb:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e02:	e8 f0 fb ff ff       	call   801039f7 <outb>
80103e07:	eb 01                	jmp    80103e0a <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103e09:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103e0a:	c9                   	leave  
80103e0b:	c3                   	ret    

80103e0c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e0c:	55                   	push   %ebp
80103e0d:	89 e5                	mov    %esp,%ebp
80103e0f:	83 ec 08             	sub    $0x8,%esp
80103e12:	8b 55 08             	mov    0x8(%ebp),%edx
80103e15:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e18:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e1c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e1f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e23:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e27:	ee                   	out    %al,(%dx)
}
80103e28:	c9                   	leave  
80103e29:	c3                   	ret    

80103e2a <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103e2a:	55                   	push   %ebp
80103e2b:	89 e5                	mov    %esp,%ebp
80103e2d:	83 ec 0c             	sub    $0xc,%esp
80103e30:	8b 45 08             	mov    0x8(%ebp),%eax
80103e33:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103e37:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e3b:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103e41:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e45:	0f b6 c0             	movzbl %al,%eax
80103e48:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e4c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e53:	e8 b4 ff ff ff       	call   80103e0c <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e58:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e5c:	66 c1 e8 08          	shr    $0x8,%ax
80103e60:	0f b6 c0             	movzbl %al,%eax
80103e63:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e67:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e6e:	e8 99 ff ff ff       	call   80103e0c <outb>
}
80103e73:	c9                   	leave  
80103e74:	c3                   	ret    

80103e75 <picenable>:

void
picenable(int irq)
{
80103e75:	55                   	push   %ebp
80103e76:	89 e5                	mov    %esp,%ebp
80103e78:	53                   	push   %ebx
80103e79:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7f:	ba 01 00 00 00       	mov    $0x1,%edx
80103e84:	89 d3                	mov    %edx,%ebx
80103e86:	89 c1                	mov    %eax,%ecx
80103e88:	d3 e3                	shl    %cl,%ebx
80103e8a:	89 d8                	mov    %ebx,%eax
80103e8c:	89 c2                	mov    %eax,%edx
80103e8e:	f7 d2                	not    %edx
80103e90:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103e97:	21 d0                	and    %edx,%eax
80103e99:	0f b7 c0             	movzwl %ax,%eax
80103e9c:	89 04 24             	mov    %eax,(%esp)
80103e9f:	e8 86 ff ff ff       	call   80103e2a <picsetmask>
}
80103ea4:	83 c4 04             	add    $0x4,%esp
80103ea7:	5b                   	pop    %ebx
80103ea8:	5d                   	pop    %ebp
80103ea9:	c3                   	ret    

80103eaa <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103eaa:	55                   	push   %ebp
80103eab:	89 e5                	mov    %esp,%ebp
80103ead:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103eb0:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103eb7:	00 
80103eb8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ebf:	e8 48 ff ff ff       	call   80103e0c <outb>
  outb(IO_PIC2+1, 0xFF);
80103ec4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ecb:	00 
80103ecc:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ed3:	e8 34 ff ff ff       	call   80103e0c <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103ed8:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103edf:	00 
80103ee0:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ee7:	e8 20 ff ff ff       	call   80103e0c <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103eec:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103ef3:	00 
80103ef4:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103efb:	e8 0c ff ff ff       	call   80103e0c <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f00:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103f07:	00 
80103f08:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f0f:	e8 f8 fe ff ff       	call   80103e0c <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103f14:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f1b:	00 
80103f1c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f23:	e8 e4 fe ff ff       	call   80103e0c <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f28:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103f2f:	00 
80103f30:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f37:	e8 d0 fe ff ff       	call   80103e0c <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f3c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103f43:	00 
80103f44:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f4b:	e8 bc fe ff ff       	call   80103e0c <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f50:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f57:	00 
80103f58:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f5f:	e8 a8 fe ff ff       	call   80103e0c <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f64:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f6b:	00 
80103f6c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f73:	e8 94 fe ff ff       	call   80103e0c <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f78:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f7f:	00 
80103f80:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f87:	e8 80 fe ff ff       	call   80103e0c <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f8c:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f93:	00 
80103f94:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f9b:	e8 6c fe ff ff       	call   80103e0c <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103fa0:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103fa7:	00 
80103fa8:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103faf:	e8 58 fe ff ff       	call   80103e0c <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103fb4:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103fbb:	00 
80103fbc:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103fc3:	e8 44 fe ff ff       	call   80103e0c <outb>

  if(irqmask != 0xFFFF)
80103fc8:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fcf:	66 83 f8 ff          	cmp    $0xffff,%ax
80103fd3:	74 12                	je     80103fe7 <picinit+0x13d>
    picsetmask(irqmask);
80103fd5:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fdc:	0f b7 c0             	movzwl %ax,%eax
80103fdf:	89 04 24             	mov    %eax,(%esp)
80103fe2:	e8 43 fe ff ff       	call   80103e2a <picsetmask>
}
80103fe7:	c9                   	leave  
80103fe8:	c3                   	ret    
80103fe9:	00 00                	add    %al,(%eax)
	...

80103fec <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fec:	55                   	push   %ebp
80103fed:	89 e5                	mov    %esp,%ebp
80103fef:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103ff2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103ff9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ffc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104002:	8b 45 0c             	mov    0xc(%ebp),%eax
80104005:	8b 10                	mov    (%eax),%edx
80104007:	8b 45 08             	mov    0x8(%ebp),%eax
8010400a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010400c:	e8 73 cf ff ff       	call   80100f84 <filealloc>
80104011:	8b 55 08             	mov    0x8(%ebp),%edx
80104014:	89 02                	mov    %eax,(%edx)
80104016:	8b 45 08             	mov    0x8(%ebp),%eax
80104019:	8b 00                	mov    (%eax),%eax
8010401b:	85 c0                	test   %eax,%eax
8010401d:	0f 84 c8 00 00 00    	je     801040eb <pipealloc+0xff>
80104023:	e8 5c cf ff ff       	call   80100f84 <filealloc>
80104028:	8b 55 0c             	mov    0xc(%ebp),%edx
8010402b:	89 02                	mov    %eax,(%edx)
8010402d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104030:	8b 00                	mov    (%eax),%eax
80104032:	85 c0                	test   %eax,%eax
80104034:	0f 84 b1 00 00 00    	je     801040eb <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010403a:	e8 28 eb ff ff       	call   80102b67 <kalloc>
8010403f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104042:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104046:	0f 84 9e 00 00 00    	je     801040ea <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
8010404c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404f:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104056:	00 00 00 
  p->writeopen = 1;
80104059:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405c:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104063:	00 00 00 
  p->nwrite = 0;
80104066:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104069:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104070:	00 00 00 
  p->nread = 0;
80104073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104076:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010407d:	00 00 00 
  initlock(&p->lock, "pipe");
80104080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104083:	c7 44 24 04 e0 8e 10 	movl   $0x80108ee0,0x4(%esp)
8010408a:	80 
8010408b:	89 04 24             	mov    %eax,(%esp)
8010408e:	e8 f3 12 00 00       	call   80105386 <initlock>
  (*f0)->type = FD_PIPE;
80104093:	8b 45 08             	mov    0x8(%ebp),%eax
80104096:	8b 00                	mov    (%eax),%eax
80104098:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010409e:	8b 45 08             	mov    0x8(%ebp),%eax
801040a1:	8b 00                	mov    (%eax),%eax
801040a3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801040a7:	8b 45 08             	mov    0x8(%ebp),%eax
801040aa:	8b 00                	mov    (%eax),%eax
801040ac:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040b0:	8b 45 08             	mov    0x8(%ebp),%eax
801040b3:	8b 00                	mov    (%eax),%eax
801040b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040b8:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801040bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801040be:	8b 00                	mov    (%eax),%eax
801040c0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801040c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c9:	8b 00                	mov    (%eax),%eax
801040cb:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801040cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d2:	8b 00                	mov    (%eax),%eax
801040d4:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801040db:	8b 00                	mov    (%eax),%eax
801040dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040e0:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040e3:	b8 00 00 00 00       	mov    $0x0,%eax
801040e8:	eb 43                	jmp    8010412d <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801040ea:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801040eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040ef:	74 0b                	je     801040fc <pipealloc+0x110>
    kfree((char*)p);
801040f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f4:	89 04 24             	mov    %eax,(%esp)
801040f7:	e8 d2 e9 ff ff       	call   80102ace <kfree>
  if(*f0)
801040fc:	8b 45 08             	mov    0x8(%ebp),%eax
801040ff:	8b 00                	mov    (%eax),%eax
80104101:	85 c0                	test   %eax,%eax
80104103:	74 0d                	je     80104112 <pipealloc+0x126>
    fileclose(*f0);
80104105:	8b 45 08             	mov    0x8(%ebp),%eax
80104108:	8b 00                	mov    (%eax),%eax
8010410a:	89 04 24             	mov    %eax,(%esp)
8010410d:	e8 1a cf ff ff       	call   8010102c <fileclose>
  if(*f1)
80104112:	8b 45 0c             	mov    0xc(%ebp),%eax
80104115:	8b 00                	mov    (%eax),%eax
80104117:	85 c0                	test   %eax,%eax
80104119:	74 0d                	je     80104128 <pipealloc+0x13c>
    fileclose(*f1);
8010411b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010411e:	8b 00                	mov    (%eax),%eax
80104120:	89 04 24             	mov    %eax,(%esp)
80104123:	e8 04 cf ff ff       	call   8010102c <fileclose>
  return -1;
80104128:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010412d:	c9                   	leave  
8010412e:	c3                   	ret    

8010412f <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010412f:	55                   	push   %ebp
80104130:	89 e5                	mov    %esp,%ebp
80104132:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104135:	8b 45 08             	mov    0x8(%ebp),%eax
80104138:	89 04 24             	mov    %eax,(%esp)
8010413b:	e8 67 12 00 00       	call   801053a7 <acquire>
  if(writable){
80104140:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104144:	74 1f                	je     80104165 <pipeclose+0x36>
    p->writeopen = 0;
80104146:	8b 45 08             	mov    0x8(%ebp),%eax
80104149:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104150:	00 00 00 
    wakeup(&p->nread);
80104153:	8b 45 08             	mov    0x8(%ebp),%eax
80104156:	05 34 02 00 00       	add    $0x234,%eax
8010415b:	89 04 24             	mov    %eax,(%esp)
8010415e:	e8 3a 10 00 00       	call   8010519d <wakeup>
80104163:	eb 1d                	jmp    80104182 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104165:	8b 45 08             	mov    0x8(%ebp),%eax
80104168:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010416f:	00 00 00 
    wakeup(&p->nwrite);
80104172:	8b 45 08             	mov    0x8(%ebp),%eax
80104175:	05 38 02 00 00       	add    $0x238,%eax
8010417a:	89 04 24             	mov    %eax,(%esp)
8010417d:	e8 1b 10 00 00       	call   8010519d <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104182:	8b 45 08             	mov    0x8(%ebp),%eax
80104185:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010418b:	85 c0                	test   %eax,%eax
8010418d:	75 25                	jne    801041b4 <pipeclose+0x85>
8010418f:	8b 45 08             	mov    0x8(%ebp),%eax
80104192:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104198:	85 c0                	test   %eax,%eax
8010419a:	75 18                	jne    801041b4 <pipeclose+0x85>
    release(&p->lock);
8010419c:	8b 45 08             	mov    0x8(%ebp),%eax
8010419f:	89 04 24             	mov    %eax,(%esp)
801041a2:	e8 62 12 00 00       	call   80105409 <release>
    kfree((char*)p);
801041a7:	8b 45 08             	mov    0x8(%ebp),%eax
801041aa:	89 04 24             	mov    %eax,(%esp)
801041ad:	e8 1c e9 ff ff       	call   80102ace <kfree>
801041b2:	eb 0b                	jmp    801041bf <pipeclose+0x90>
  } else
    release(&p->lock);
801041b4:	8b 45 08             	mov    0x8(%ebp),%eax
801041b7:	89 04 24             	mov    %eax,(%esp)
801041ba:	e8 4a 12 00 00       	call   80105409 <release>
}
801041bf:	c9                   	leave  
801041c0:	c3                   	ret    

801041c1 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041c1:	55                   	push   %ebp
801041c2:	89 e5                	mov    %esp,%ebp
801041c4:	53                   	push   %ebx
801041c5:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041c8:	8b 45 08             	mov    0x8(%ebp),%eax
801041cb:	89 04 24             	mov    %eax,(%esp)
801041ce:	e8 d4 11 00 00       	call   801053a7 <acquire>
  for(i = 0; i < n; i++){
801041d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041da:	e9 a6 00 00 00       	jmp    80104285 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801041df:	8b 45 08             	mov    0x8(%ebp),%eax
801041e2:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041e8:	85 c0                	test   %eax,%eax
801041ea:	74 0d                	je     801041f9 <pipewrite+0x38>
801041ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041f2:	8b 40 28             	mov    0x28(%eax),%eax
801041f5:	85 c0                	test   %eax,%eax
801041f7:	74 15                	je     8010420e <pipewrite+0x4d>
        release(&p->lock);
801041f9:	8b 45 08             	mov    0x8(%ebp),%eax
801041fc:	89 04 24             	mov    %eax,(%esp)
801041ff:	e8 05 12 00 00       	call   80105409 <release>
        return -1;
80104204:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104209:	e9 9d 00 00 00       	jmp    801042ab <pipewrite+0xea>
      }
      wakeup(&p->nread);
8010420e:	8b 45 08             	mov    0x8(%ebp),%eax
80104211:	05 34 02 00 00       	add    $0x234,%eax
80104216:	89 04 24             	mov    %eax,(%esp)
80104219:	e8 7f 0f 00 00       	call   8010519d <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010421e:	8b 45 08             	mov    0x8(%ebp),%eax
80104221:	8b 55 08             	mov    0x8(%ebp),%edx
80104224:	81 c2 38 02 00 00    	add    $0x238,%edx
8010422a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010422e:	89 14 24             	mov    %edx,(%esp)
80104231:	e8 8b 0e 00 00       	call   801050c1 <sleep>
80104236:	eb 01                	jmp    80104239 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104238:	90                   	nop
80104239:	8b 45 08             	mov    0x8(%ebp),%eax
8010423c:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104242:	8b 45 08             	mov    0x8(%ebp),%eax
80104245:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010424b:	05 00 02 00 00       	add    $0x200,%eax
80104250:	39 c2                	cmp    %eax,%edx
80104252:	74 8b                	je     801041df <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104254:	8b 45 08             	mov    0x8(%ebp),%eax
80104257:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010425d:	89 c3                	mov    %eax,%ebx
8010425f:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104265:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104268:	03 55 0c             	add    0xc(%ebp),%edx
8010426b:	0f b6 0a             	movzbl (%edx),%ecx
8010426e:	8b 55 08             	mov    0x8(%ebp),%edx
80104271:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104275:	8d 50 01             	lea    0x1(%eax),%edx
80104278:	8b 45 08             	mov    0x8(%ebp),%eax
8010427b:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104281:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104288:	3b 45 10             	cmp    0x10(%ebp),%eax
8010428b:	7c ab                	jl     80104238 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010428d:	8b 45 08             	mov    0x8(%ebp),%eax
80104290:	05 34 02 00 00       	add    $0x234,%eax
80104295:	89 04 24             	mov    %eax,(%esp)
80104298:	e8 00 0f 00 00       	call   8010519d <wakeup>
  release(&p->lock);
8010429d:	8b 45 08             	mov    0x8(%ebp),%eax
801042a0:	89 04 24             	mov    %eax,(%esp)
801042a3:	e8 61 11 00 00       	call   80105409 <release>
  return n;
801042a8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042ab:	83 c4 24             	add    $0x24,%esp
801042ae:	5b                   	pop    %ebx
801042af:	5d                   	pop    %ebp
801042b0:	c3                   	ret    

801042b1 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042b1:	55                   	push   %ebp
801042b2:	89 e5                	mov    %esp,%ebp
801042b4:	53                   	push   %ebx
801042b5:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801042b8:	8b 45 08             	mov    0x8(%ebp),%eax
801042bb:	89 04 24             	mov    %eax,(%esp)
801042be:	e8 e4 10 00 00       	call   801053a7 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042c3:	eb 3a                	jmp    801042ff <piperead+0x4e>
    if(proc->killed){
801042c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042cb:	8b 40 28             	mov    0x28(%eax),%eax
801042ce:	85 c0                	test   %eax,%eax
801042d0:	74 15                	je     801042e7 <piperead+0x36>
      release(&p->lock);
801042d2:	8b 45 08             	mov    0x8(%ebp),%eax
801042d5:	89 04 24             	mov    %eax,(%esp)
801042d8:	e8 2c 11 00 00       	call   80105409 <release>
      return -1;
801042dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042e2:	e9 b6 00 00 00       	jmp    8010439d <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042e7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ea:	8b 55 08             	mov    0x8(%ebp),%edx
801042ed:	81 c2 34 02 00 00    	add    $0x234,%edx
801042f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801042f7:	89 14 24             	mov    %edx,(%esp)
801042fa:	e8 c2 0d 00 00       	call   801050c1 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104302:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104308:	8b 45 08             	mov    0x8(%ebp),%eax
8010430b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104311:	39 c2                	cmp    %eax,%edx
80104313:	75 0d                	jne    80104322 <piperead+0x71>
80104315:	8b 45 08             	mov    0x8(%ebp),%eax
80104318:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010431e:	85 c0                	test   %eax,%eax
80104320:	75 a3                	jne    801042c5 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104322:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104329:	eb 49                	jmp    80104374 <piperead+0xc3>
    if(p->nread == p->nwrite)
8010432b:	8b 45 08             	mov    0x8(%ebp),%eax
8010432e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104334:	8b 45 08             	mov    0x8(%ebp),%eax
80104337:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010433d:	39 c2                	cmp    %eax,%edx
8010433f:	74 3d                	je     8010437e <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104344:	89 c2                	mov    %eax,%edx
80104346:	03 55 0c             	add    0xc(%ebp),%edx
80104349:	8b 45 08             	mov    0x8(%ebp),%eax
8010434c:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104352:	89 c3                	mov    %eax,%ebx
80104354:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
8010435a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010435d:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104362:	88 0a                	mov    %cl,(%edx)
80104364:	8d 50 01             	lea    0x1(%eax),%edx
80104367:	8b 45 08             	mov    0x8(%ebp),%eax
8010436a:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104370:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104377:	3b 45 10             	cmp    0x10(%ebp),%eax
8010437a:	7c af                	jl     8010432b <piperead+0x7a>
8010437c:	eb 01                	jmp    8010437f <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
8010437e:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010437f:	8b 45 08             	mov    0x8(%ebp),%eax
80104382:	05 38 02 00 00       	add    $0x238,%eax
80104387:	89 04 24             	mov    %eax,(%esp)
8010438a:	e8 0e 0e 00 00       	call   8010519d <wakeup>
  release(&p->lock);
8010438f:	8b 45 08             	mov    0x8(%ebp),%eax
80104392:	89 04 24             	mov    %eax,(%esp)
80104395:	e8 6f 10 00 00       	call   80105409 <release>
  return i;
8010439a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010439d:	83 c4 24             	add    $0x24,%esp
801043a0:	5b                   	pop    %ebx
801043a1:	5d                   	pop    %ebp
801043a2:	c3                   	ret    
	...

801043a4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801043a4:	55                   	push   %ebp
801043a5:	89 e5                	mov    %esp,%ebp
801043a7:	53                   	push   %ebx
801043a8:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043ab:	9c                   	pushf  
801043ac:	5b                   	pop    %ebx
801043ad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
801043b0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801043b3:	83 c4 10             	add    $0x10,%esp
801043b6:	5b                   	pop    %ebx
801043b7:	5d                   	pop    %ebp
801043b8:	c3                   	ret    

801043b9 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801043b9:	55                   	push   %ebp
801043ba:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043bc:	fb                   	sti    
}
801043bd:	5d                   	pop    %ebp
801043be:	c3                   	ret    

801043bf <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801043bf:	55                   	push   %ebp
801043c0:	89 e5                	mov    %esp,%ebp
801043c2:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801043c5:	c7 44 24 04 e5 8e 10 	movl   $0x80108ee5,0x4(%esp)
801043cc:	80 
801043cd:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801043d4:	e8 ad 0f 00 00       	call   80105386 <initlock>
}
801043d9:	c9                   	leave  
801043da:	c3                   	ret    

801043db <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801043db:	55                   	push   %ebp
801043dc:	89 e5                	mov    %esp,%ebp
801043de:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801043e1:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801043e8:	e8 ba 0f 00 00       	call   801053a7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043ed:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801043f4:	eb 11                	jmp    80104407 <allocproc+0x2c>
    if(p->state == UNUSED)
801043f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f9:	8b 40 0c             	mov    0xc(%eax),%eax
801043fc:	85 c0                	test   %eax,%eax
801043fe:	74 26                	je     80104426 <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104400:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104407:	81 7d f4 b4 5f 11 80 	cmpl   $0x80115fb4,-0xc(%ebp)
8010440e:	72 e6                	jb     801043f6 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104410:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104417:	e8 ed 0f 00 00       	call   80105409 <release>
  return 0;
8010441c:	b8 00 00 00 00       	mov    $0x0,%eax
80104421:	e9 c5 00 00 00       	jmp    801044eb <allocproc+0x110>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104426:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104427:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442a:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104431:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104436:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104439:	89 42 10             	mov    %eax,0x10(%edx)
8010443c:	83 c0 01             	add    $0x1,%eax
8010443f:	a3 04 c0 10 80       	mov    %eax,0x8010c004
  p->ctime = ticks;
80104444:	a1 00 68 11 80       	mov    0x80116800,%eax
80104449:	89 c2                	mov    %eax,%edx
8010444b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444e:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  release(&ptable.lock);
80104454:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010445b:	e8 a9 0f 00 00       	call   80105409 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104460:	e8 02 e7 ff ff       	call   80102b67 <kalloc>
80104465:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104468:	89 42 08             	mov    %eax,0x8(%edx)
8010446b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446e:	8b 40 08             	mov    0x8(%eax),%eax
80104471:	85 c0                	test   %eax,%eax
80104473:	75 11                	jne    80104486 <allocproc+0xab>
    p->state = UNUSED;
80104475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104478:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010447f:	b8 00 00 00 00       	mov    $0x0,%eax
80104484:	eb 65                	jmp    801044eb <allocproc+0x110>
  }
  sp = p->kstack + KSTACKSIZE;
80104486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104489:	8b 40 08             	mov    0x8(%eax),%eax
8010448c:	05 00 10 00 00       	add    $0x1000,%eax
80104491:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104494:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104498:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010449e:	89 50 1c             	mov    %edx,0x1c(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801044a1:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801044a5:	ba 24 6c 10 80       	mov    $0x80106c24,%edx
801044aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ad:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801044af:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801044b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044b9:	89 50 20             	mov    %edx,0x20(%eax)
  memset(p->context, 0, sizeof *p->context);
801044bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bf:	8b 40 20             	mov    0x20(%eax),%eax
801044c2:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801044c9:	00 
801044ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044d1:	00 
801044d2:	89 04 24             	mov    %eax,(%esp)
801044d5:	e8 1c 11 00 00       	call   801055f6 <memset>
  p->context->eip = (uint)forkret;
801044da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dd:	8b 40 20             	mov    0x20(%eax),%eax
801044e0:	ba 95 50 10 80       	mov    $0x80105095,%edx
801044e5:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801044e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044eb:	c9                   	leave  
801044ec:	c3                   	ret    

801044ed <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801044ed:	55                   	push   %ebp
801044ee:	89 e5                	mov    %esp,%ebp
801044f0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801044f3:	e8 e3 fe ff ff       	call   801043db <allocproc>
801044f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801044fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fe:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
80104503:	e8 91 3e 00 00       	call   80108399 <setupkvm>
80104508:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010450b:	89 42 04             	mov    %eax,0x4(%edx)
8010450e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104511:	8b 40 04             	mov    0x4(%eax),%eax
80104514:	85 c0                	test   %eax,%eax
80104516:	75 0c                	jne    80104524 <userinit+0x37>
    panic("userinit: out of memory?");
80104518:	c7 04 24 ec 8e 10 80 	movl   $0x80108eec,(%esp)
8010451f:	e8 19 c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104524:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452c:	8b 40 04             	mov    0x4(%eax),%eax
8010452f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104533:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
8010453a:	80 
8010453b:	89 04 24             	mov    %eax,(%esp)
8010453e:	e8 ae 40 00 00       	call   801085f1 <inituvm>
  p->sz = PGSIZE;
80104543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104546:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010454c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104552:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104559:	00 
8010455a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104561:	00 
80104562:	89 04 24             	mov    %eax,(%esp)
80104565:	e8 8c 10 00 00       	call   801055f6 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010456a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104570:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104579:	8b 40 1c             	mov    0x1c(%eax),%eax
8010457c:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104585:	8b 40 1c             	mov    0x1c(%eax),%eax
80104588:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010458b:	8b 52 1c             	mov    0x1c(%edx),%edx
8010458e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104592:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104599:	8b 40 1c             	mov    0x1c(%eax),%eax
8010459c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010459f:	8b 52 1c             	mov    0x1c(%edx),%edx
801045a2:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801045a6:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801045aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ad:	8b 40 1c             	mov    0x1c(%eax),%eax
801045b0:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801045b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ba:	8b 40 1c             	mov    0x1c(%eax),%eax
801045bd:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801045c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c7:	8b 40 1c             	mov    0x1c(%eax),%eax
801045ca:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801045d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d4:	83 c0 70             	add    $0x70,%eax
801045d7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045de:	00 
801045df:	c7 44 24 04 05 8f 10 	movl   $0x80108f05,0x4(%esp)
801045e6:	80 
801045e7:	89 04 24             	mov    %eax,(%esp)
801045ea:	e8 37 12 00 00       	call   80105826 <safestrcpy>
  p->cwd = namei("/");
801045ef:	c7 04 24 0e 8f 10 80 	movl   $0x80108f0e,(%esp)
801045f6:	e8 77 de ff ff       	call   80102472 <namei>
801045fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045fe:	89 42 6c             	mov    %eax,0x6c(%edx)

  p->state = RUNNABLE;
80104601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104604:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010460b:	c9                   	leave  
8010460c:	c3                   	ret    

8010460d <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010460d:	55                   	push   %ebp
8010460e:	89 e5                	mov    %esp,%ebp
80104610:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
80104613:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104619:	8b 00                	mov    (%eax),%eax
8010461b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010461e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104622:	7e 34                	jle    80104658 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104624:	8b 45 08             	mov    0x8(%ebp),%eax
80104627:	89 c2                	mov    %eax,%edx
80104629:	03 55 f4             	add    -0xc(%ebp),%edx
8010462c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104632:	8b 40 04             	mov    0x4(%eax),%eax
80104635:	89 54 24 08          	mov    %edx,0x8(%esp)
80104639:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010463c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104640:	89 04 24             	mov    %eax,(%esp)
80104643:	e8 23 41 00 00       	call   8010876b <allocuvm>
80104648:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010464b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010464f:	75 41                	jne    80104692 <growproc+0x85>
      return -1;
80104651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104656:	eb 58                	jmp    801046b0 <growproc+0xa3>
  } else if(n < 0){
80104658:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010465c:	79 34                	jns    80104692 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010465e:	8b 45 08             	mov    0x8(%ebp),%eax
80104661:	89 c2                	mov    %eax,%edx
80104663:	03 55 f4             	add    -0xc(%ebp),%edx
80104666:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010466c:	8b 40 04             	mov    0x4(%eax),%eax
8010466f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104673:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104676:	89 54 24 04          	mov    %edx,0x4(%esp)
8010467a:	89 04 24             	mov    %eax,(%esp)
8010467d:	e8 c3 41 00 00       	call   80108845 <deallocuvm>
80104682:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104685:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104689:	75 07                	jne    80104692 <growproc+0x85>
      return -1;
8010468b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104690:	eb 1e                	jmp    801046b0 <growproc+0xa3>
  }
  proc->sz = sz;
80104692:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104698:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010469b:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010469d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046a3:	89 04 24             	mov    %eax,(%esp)
801046a6:	e8 df 3d 00 00       	call   8010848a <switchuvm>
  return 0;
801046ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801046b0:	c9                   	leave  
801046b1:	c3                   	ret    

801046b2 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801046b2:	55                   	push   %ebp
801046b3:	89 e5                	mov    %esp,%ebp
801046b5:	57                   	push   %edi
801046b6:	56                   	push   %esi
801046b7:	53                   	push   %ebx
801046b8:	83 ec 2c             	sub    $0x2c,%esp
//  char* TAG = "fork";
  int i, pid, gid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801046bb:	e8 1b fd ff ff       	call   801043db <allocproc>
801046c0:	89 45 dc             	mov    %eax,-0x24(%ebp)
801046c3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801046c7:	75 0a                	jne    801046d3 <fork+0x21>
    return -1;
801046c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ce:	e9 7d 01 00 00       	jmp    80104850 <fork+0x19e>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801046d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d9:	8b 10                	mov    (%eax),%edx
801046db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e1:	8b 40 04             	mov    0x4(%eax),%eax
801046e4:	89 54 24 04          	mov    %edx,0x4(%esp)
801046e8:	89 04 24             	mov    %eax,(%esp)
801046eb:	e8 e5 42 00 00       	call   801089d5 <copyuvm>
801046f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046f3:	89 42 04             	mov    %eax,0x4(%edx)
801046f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046f9:	8b 40 04             	mov    0x4(%eax),%eax
801046fc:	85 c0                	test   %eax,%eax
801046fe:	75 2c                	jne    8010472c <fork+0x7a>
    kfree(np->kstack);
80104700:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104703:	8b 40 08             	mov    0x8(%eax),%eax
80104706:	89 04 24             	mov    %eax,(%esp)
80104709:	e8 c0 e3 ff ff       	call   80102ace <kfree>
    np->kstack = 0;
8010470e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104711:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104718:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010471b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104722:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104727:	e9 24 01 00 00       	jmp    80104850 <fork+0x19e>
  }
  np->sz = proc->sz;
8010472c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104732:	8b 10                	mov    (%eax),%edx
80104734:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104737:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104739:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104740:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104743:	89 50 18             	mov    %edx,0x18(%eax)
  *np->tf = *proc->tf;
80104746:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104749:	8b 50 1c             	mov    0x1c(%eax),%edx
8010474c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104752:	8b 40 1c             	mov    0x1c(%eax),%eax
80104755:	89 c3                	mov    %eax,%ebx
80104757:	b8 13 00 00 00       	mov    $0x13,%eax
8010475c:	89 d7                	mov    %edx,%edi
8010475e:	89 de                	mov    %ebx,%esi
80104760:	89 c1                	mov    %eax,%ecx
80104762:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104764:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104767:	8b 40 1c             	mov    0x1c(%eax),%eax
8010476a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104771:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104778:	eb 3d                	jmp    801047b7 <fork+0x105>
    if(proc->ofile[i])
8010477a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104780:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104783:	83 c2 08             	add    $0x8,%edx
80104786:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010478a:	85 c0                	test   %eax,%eax
8010478c:	74 25                	je     801047b3 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010478e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104794:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104797:	83 c2 08             	add    $0x8,%edx
8010479a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010479e:	89 04 24             	mov    %eax,(%esp)
801047a1:	e8 3e c8 ff ff       	call   80100fe4 <filedup>
801047a6:	8b 55 dc             	mov    -0x24(%ebp),%edx
801047a9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801047ac:	83 c1 08             	add    $0x8,%ecx
801047af:	89 44 8a 0c          	mov    %eax,0xc(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801047b3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801047b7:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801047bb:	7e bd                	jle    8010477a <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801047bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c3:	8b 40 6c             	mov    0x6c(%eax),%eax
801047c6:	89 04 24             	mov    %eax,(%esp)
801047c9:	e8 d0 d0 ff ff       	call   8010189e <idup>
801047ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
801047d1:	89 42 6c             	mov    %eax,0x6c(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801047d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047da:	8d 50 70             	lea    0x70(%eax),%edx
801047dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047e0:	83 c0 70             	add    $0x70,%eax
801047e3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047ea:	00 
801047eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801047ef:	89 04 24             	mov    %eax,(%esp)
801047f2:	e8 2f 10 00 00       	call   80105826 <safestrcpy>
 
  pid = np->pid;
801047f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801047fa:	8b 40 10             	mov    0x10(%eax),%eax
801047fd:	89 45 d8             	mov    %eax,-0x28(%ebp)

  //Set group id
  //if father is shell -> gid = this new process pid
  if( proc->pid == SHELL_PID){
80104800:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104806:	8b 40 10             	mov    0x10(%eax),%eax
80104809:	83 f8 02             	cmp    $0x2,%eax
8010480c:	75 08                	jne    80104816 <fork+0x164>
	  gid = pid;
8010480e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104811:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104814:	eb 0c                	jmp    80104822 <fork+0x170>
  }
  //else, take father gid
  else{
	  gid = proc->gid;
80104816:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481c:	8b 40 14             	mov    0x14(%eax),%eax
8010481f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  }

  np->gid = gid;
80104822:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104825:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104828:	89 50 14             	mov    %edx,0x14(%eax)

  //cprintf("\n[debug] [fork] Created a new process son of '%s' with pid %d, and guid: %d\n", np->name, pid, gid);
  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
8010482b:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104832:	e8 70 0b 00 00       	call   801053a7 <acquire>
  np->state = RUNNABLE;
80104837:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010483a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104841:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104848:	e8 bc 0b 00 00       	call   80105409 <release>
  
  return pid;
8010484d:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104850:	83 c4 2c             	add    $0x2c,%esp
80104853:	5b                   	pop    %ebx
80104854:	5e                   	pop    %esi
80104855:	5f                   	pop    %edi
80104856:	5d                   	pop    %ebp
80104857:	c3                   	ret    

80104858 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(int status)
{
80104858:	55                   	push   %ebp
80104859:	89 e5                	mov    %esp,%ebp
8010485b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  //cprintf("\n[debug] [exit] Process '%s' (%d) Exited with status code %d\n", proc->name, proc->pid, status);

  if(proc == initproc)
8010485e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104865:	a1 68 c6 10 80       	mov    0x8010c668,%eax
8010486a:	39 c2                	cmp    %eax,%edx
8010486c:	75 0c                	jne    8010487a <exit+0x22>
    panic("init exiting");
8010486e:	c7 04 24 10 8f 10 80 	movl   $0x80108f10,(%esp)
80104875:	e8 c3 bc ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010487a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104881:	eb 44                	jmp    801048c7 <exit+0x6f>
    if(proc->ofile[fd]){
80104883:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104889:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010488c:	83 c2 08             	add    $0x8,%edx
8010488f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80104893:	85 c0                	test   %eax,%eax
80104895:	74 2c                	je     801048c3 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104897:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489d:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048a0:	83 c2 08             	add    $0x8,%edx
801048a3:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801048a7:	89 04 24             	mov    %eax,(%esp)
801048aa:	e8 7d c7 ff ff       	call   8010102c <fileclose>
      proc->ofile[fd] = 0;
801048af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801048b8:	83 c2 08             	add    $0x8,%edx
801048bb:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
801048c2:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801048c3:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801048c7:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801048cb:	7e b6                	jle    80104883 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
801048cd:	e8 eb eb ff ff       	call   801034bd <begin_op>
  iput(proc->cwd);
801048d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d8:	8b 40 6c             	mov    0x6c(%eax),%eax
801048db:	89 04 24             	mov    %eax,(%esp)
801048de:	e8 a0 d1 ff ff       	call   80101a83 <iput>
  end_op();
801048e3:	e8 56 ec ff ff       	call   8010353e <end_op>
  proc->cwd = 0;
801048e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ee:	c7 40 6c 00 00 00 00 	movl   $0x0,0x6c(%eax)


  acquire(&ptable.lock);
801048f5:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801048fc:	e8 a6 0a 00 00       	call   801053a7 <acquire>

  proc->status = status;
80104901:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104907:	8b 55 08             	mov    0x8(%ebp),%edx
8010490a:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  proc->ttime = ticks;
80104910:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104916:	8b 15 00 68 11 80    	mov    0x80116800,%edx
8010491c:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104922:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104928:	8b 40 18             	mov    0x18(%eax),%eax
8010492b:	89 04 24             	mov    %eax,(%esp)
8010492e:	e8 29 08 00 00       	call   8010515c <wakeup1>
//  cprintf("\n This is your captin speaking, here is : %s \n", ptable.proc[SHELL_PID].name);


  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104933:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010493a:	eb 3b                	jmp    80104977 <exit+0x11f>
    if(p->parent == proc){
8010493c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493f:	8b 50 18             	mov    0x18(%eax),%edx
80104942:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104948:	39 c2                	cmp    %eax,%edx
8010494a:	75 24                	jne    80104970 <exit+0x118>
      p->parent = initproc;
8010494c:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104955:	89 50 18             	mov    %edx,0x18(%eax)
      if(p->state == ZOMBIE)
80104958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495b:	8b 40 0c             	mov    0xc(%eax),%eax
8010495e:	83 f8 05             	cmp    $0x5,%eax
80104961:	75 0d                	jne    80104970 <exit+0x118>
        wakeup1(initproc);
80104963:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104968:	89 04 24             	mov    %eax,(%esp)
8010496b:	e8 ec 07 00 00       	call   8010515c <wakeup1>
  wakeup1(proc->parent);
//  cprintf("\n This is your captin speaking, here is : %s \n", ptable.proc[SHELL_PID].name);


  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104970:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104977:	81 7d f4 b4 5f 11 80 	cmpl   $0x80115fb4,-0xc(%ebp)
8010497e:	72 bc                	jb     8010493c <exit+0xe4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104980:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104986:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010498d:	e8 1f 06 00 00       	call   80104fb1 <sched>
  panic("zombie exit");
80104992:	c7 04 24 1d 8f 10 80 	movl   $0x80108f1d,(%esp)
80104999:	e8 9f bb ff ff       	call   8010053d <panic>

8010499e <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(int* status)
{
8010499e:	55                   	push   %ebp
8010499f:	89 e5                	mov    %esp,%ebp
801049a1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
801049a4:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801049ab:	e8 f7 09 00 00       	call   801053a7 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
801049b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049b7:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801049be:	e9 b5 00 00 00       	jmp    80104a78 <wait+0xda>
      if(p->parent != proc)
801049c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c6:	8b 50 18             	mov    0x18(%eax),%edx
801049c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049cf:	39 c2                	cmp    %eax,%edx
801049d1:	0f 85 99 00 00 00    	jne    80104a70 <wait+0xd2>
        continue;
      havekids = 1;
801049d7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801049de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e1:	8b 40 0c             	mov    0xc(%eax),%eax
801049e4:	83 f8 05             	cmp    $0x5,%eax
801049e7:	0f 85 84 00 00 00    	jne    80104a71 <wait+0xd3>
        // Found one.
        pid = p->pid;
801049ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f0:	8b 40 10             	mov    0x10(%eax),%eax
801049f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
801049f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f9:	8b 40 08             	mov    0x8(%eax),%eax
801049fc:	89 04 24             	mov    %eax,(%esp)
801049ff:	e8 ca e0 ff ff       	call   80102ace <kfree>
        p->kstack = 0;
80104a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a07:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a11:	8b 40 04             	mov    0x4(%eax),%eax
80104a14:	89 04 24             	mov    %eax,(%esp)
80104a17:	e8 e5 3e 00 00       	call   80108901 <freevm>
        p->state = UNUSED;
80104a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a29:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a33:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        p->name[0] = 0;
80104a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3d:	c6 40 70 00          	movb   $0x0,0x70(%eax)
        p->killed = 0;
80104a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a44:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)

        if(status){ // if user did not send status=0 (do not care)
80104a4b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a4f:	74 0e                	je     80104a5f <wait+0xc1>
            *status = p->status; //return status to caller
80104a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a54:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80104a5d:	89 10                	mov    %edx,(%eax)
        }

        release(&ptable.lock);
80104a5f:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104a66:	e8 9e 09 00 00       	call   80105409 <release>

        return pid;
80104a6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a6e:	eb 56                	jmp    80104ac6 <wait+0x128>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104a70:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a71:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104a78:	81 7d f4 b4 5f 11 80 	cmpl   $0x80115fb4,-0xc(%ebp)
80104a7f:	0f 82 3e ff ff ff    	jb     801049c3 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104a85:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a89:	74 0d                	je     80104a98 <wait+0xfa>
80104a8b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a91:	8b 40 28             	mov    0x28(%eax),%eax
80104a94:	85 c0                	test   %eax,%eax
80104a96:	74 13                	je     80104aab <wait+0x10d>
      release(&ptable.lock);
80104a98:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104a9f:	e8 65 09 00 00       	call   80105409 <release>
      return -1;
80104aa4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aa9:	eb 1b                	jmp    80104ac6 <wait+0x128>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104aab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ab1:	c7 44 24 04 80 39 11 	movl   $0x80113980,0x4(%esp)
80104ab8:	80 
80104ab9:	89 04 24             	mov    %eax,(%esp)
80104abc:	e8 00 06 00 00       	call   801050c1 <sleep>
  }
80104ac1:	e9 ea fe ff ff       	jmp    801049b0 <wait+0x12>
}
80104ac6:	c9                   	leave  
80104ac7:	c3                   	ret    

80104ac8 <shellWait>:

int
shellWait(int childPid)
{
80104ac8:	55                   	push   %ebp
80104ac9:	89 e5                	mov    %esp,%ebp
80104acb:	83 ec 28             	sub    $0x28,%esp
  for(;;){
    // Scan through table looking for zombie children.
   // havekids = 0;
   // isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ace:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104ad5:	e9 91 00 00 00       	jmp    80104b6b <shellWait+0xa3>
      if(p->parent != proc)
80104ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104add:	8b 50 18             	mov    0x18(%eax),%edx
80104ae0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ae6:	39 c2                	cmp    %eax,%edx
80104ae8:	75 79                	jne    80104b63 <shellWait+0x9b>
        continue;
    //  havekids = 1;
      if( p->pid == childPid ){
80104aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aed:	8b 40 10             	mov    0x10(%eax),%eax
80104af0:	3b 45 08             	cmp    0x8(%ebp),%eax
80104af3:	75 6f                	jne    80104b64 <shellWait+0x9c>
    	 //isMyChild = 1;
		 if(p->state == ZOMBIE ){
80104af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af8:	8b 40 0c             	mov    0xc(%eax),%eax
80104afb:	83 f8 05             	cmp    $0x5,%eax
80104afe:	75 64                	jne    80104b64 <shellWait+0x9c>
			// Found one.
			pid = p->pid;
80104b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b03:	8b 40 10             	mov    0x10(%eax),%eax
80104b06:	89 45 f0             	mov    %eax,-0x10(%ebp)
			kfree(p->kstack);
80104b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0c:	8b 40 08             	mov    0x8(%eax),%eax
80104b0f:	89 04 24             	mov    %eax,(%esp)
80104b12:	e8 b7 df ff ff       	call   80102ace <kfree>
			p->kstack = 0;
80104b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
			freevm(p->pgdir);
80104b21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b24:	8b 40 04             	mov    0x4(%eax),%eax
80104b27:	89 04 24             	mov    %eax,(%esp)
80104b2a:	e8 d2 3d 00 00       	call   80108901 <freevm>
			p->state = UNUSED;
80104b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b32:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
			p->pid = 0;
80104b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b3c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
			p->parent = 0;
80104b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b46:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
			p->name[0] = 0;
80104b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b50:	c6 40 70 00          	movb   $0x0,0x70(%eax)
			p->killed = 0;
80104b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b57:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)
			return pid;
80104b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
      }

    }
	sleep(proc, &ptable.lock);
  }
}
80104b61:	c9                   	leave  
80104b62:	c3                   	ret    
   // havekids = 0;
   // isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b63:	90                   	nop
  for(;;){
    // Scan through table looking for zombie children.
   // havekids = 0;
   // isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b64:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104b6b:	81 7d f4 b4 5f 11 80 	cmpl   $0x80115fb4,-0xc(%ebp)
80104b72:	0f 82 62 ff ff ff    	jb     80104ada <shellWait+0x12>
			return pid;
		  }
      }

    }
	sleep(proc, &ptable.lock);
80104b78:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b7e:	c7 44 24 04 80 39 11 	movl   $0x80113980,0x4(%esp)
80104b85:	80 
80104b86:	89 04 24             	mov    %eax,(%esp)
80104b89:	e8 33 05 00 00       	call   801050c1 <sleep>
  }
80104b8e:	e9 3b ff ff ff       	jmp    80104ace <shellWait+0x6>

80104b93 <waitpid>:

// Wait for a child process *with a specific pid* to exit and return its pid.
// Return -1 if this process has no children.
int
waitpid(int childPid, int* status, int options)
{
80104b93:	55                   	push   %ebp
80104b94:	89 e5                	mov    %esp,%ebp
80104b96:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid, isMyChild;

  acquire(&ptable.lock);
80104b99:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104ba0:	e8 02 08 00 00       	call   801053a7 <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104ba5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    isMyChild = 0;
80104bac:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bb3:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104bba:	e9 ce 00 00 00       	jmp    80104c8d <waitpid+0xfa>
      if(p->parent != proc)
80104bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc2:	8b 50 18             	mov    0x18(%eax),%edx
80104bc5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bcb:	39 c2                	cmp    %eax,%edx
80104bcd:	0f 85 b2 00 00 00    	jne    80104c85 <waitpid+0xf2>
        continue;
      havekids = 1;
80104bd3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if( p->pid == childPid ){
80104bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdd:	8b 40 10             	mov    0x10(%eax),%eax
80104be0:	3b 45 08             	cmp    0x8(%ebp),%eax
80104be3:	0f 85 9d 00 00 00    	jne    80104c86 <waitpid+0xf3>
    	 isMyChild = 1;
80104be9:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
		 if(p->state == ZOMBIE ){
80104bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf3:	8b 40 0c             	mov    0xc(%eax),%eax
80104bf6:	83 f8 05             	cmp    $0x5,%eax
80104bf9:	0f 85 87 00 00 00    	jne    80104c86 <waitpid+0xf3>
			// Found one.
			pid = p->pid;
80104bff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c02:	8b 40 10             	mov    0x10(%eax),%eax
80104c05:	89 45 e8             	mov    %eax,-0x18(%ebp)
			kfree(p->kstack);
80104c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0b:	8b 40 08             	mov    0x8(%eax),%eax
80104c0e:	89 04 24             	mov    %eax,(%esp)
80104c11:	e8 b8 de ff ff       	call   80102ace <kfree>
			p->kstack = 0;
80104c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c19:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
			freevm(p->pgdir);
80104c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c23:	8b 40 04             	mov    0x4(%eax),%eax
80104c26:	89 04 24             	mov    %eax,(%esp)
80104c29:	e8 d3 3c 00 00       	call   80108901 <freevm>
			p->state = UNUSED;
80104c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c31:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
			p->pid = 0;
80104c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3b:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
			p->parent = 0;
80104c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c45:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
			p->name[0] = 0;
80104c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4f:	c6 40 70 00          	movb   $0x0,0x70(%eax)
			p->killed = 0;
80104c53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c56:	c7 40 28 00 00 00 00 	movl   $0x0,0x28(%eax)

			if(status){ // if user did not send status=0 (do not care)
80104c5d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104c61:	74 0e                	je     80104c71 <waitpid+0xde>
				*status = p->status; //return status to caller
80104c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c66:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104c6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c6f:	89 10                	mov    %edx,(%eax)
			}

			release(&ptable.lock);
80104c71:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104c78:	e8 8c 07 00 00       	call   80105409 <release>

			return pid;
80104c7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c80:	e9 8f 00 00 00       	jmp    80104d14 <waitpid+0x181>
    havekids = 0;
    isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104c85:	90                   	nop
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c86:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104c8d:	81 7d f4 b4 5f 11 80 	cmpl   $0x80115fb4,-0xc(%ebp)
80104c94:	0f 82 25 ff ff ff    	jb     80104bbf <waitpid+0x2c>
      }

    }

    // No point waiting if we don't have any children.
    if(!havekids || !isMyChild || proc->killed){
80104c9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c9e:	74 13                	je     80104cb3 <waitpid+0x120>
80104ca0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104ca4:	74 0d                	je     80104cb3 <waitpid+0x120>
80104ca6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cac:	8b 40 28             	mov    0x28(%eax),%eax
80104caf:	85 c0                	test   %eax,%eax
80104cb1:	74 13                	je     80104cc6 <waitpid+0x133>
      release(&ptable.lock);
80104cb3:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104cba:	e8 4a 07 00 00       	call   80105409 <release>
      return -1;
80104cbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cc4:	eb 4e                	jmp    80104d14 <waitpid+0x181>
    }

    switch (options) {
80104cc6:	8b 45 10             	mov    0x10(%ebp),%eax
80104cc9:	85 c0                	test   %eax,%eax
80104ccb:	74 07                	je     80104cd4 <waitpid+0x141>
80104ccd:	83 f8 01             	cmp    $0x1,%eax
80104cd0:	74 1e                	je     80104cf0 <waitpid+0x15d>
80104cd2:	eb 2f                	jmp    80104d03 <waitpid+0x170>
		case BLOCKING:
			sleep(proc, &ptable.lock);
80104cd4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cda:	c7 44 24 04 80 39 11 	movl   $0x80113980,0x4(%esp)
80104ce1:	80 
80104ce2:	89 04 24             	mov    %eax,(%esp)
80104ce5:	e8 d7 03 00 00       	call   801050c1 <sleep>
			break;
80104cea:	90                   	nop
			release(&ptable.lock);
			return -1;
			break;
	}

  }
80104ceb:	e9 b5 fe ff ff       	jmp    80104ba5 <waitpid+0x12>
    switch (options) {
		case BLOCKING:
			sleep(proc, &ptable.lock);
			break;
		case NONBLOCKING:
			release(&ptable.lock);
80104cf0:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104cf7:	e8 0d 07 00 00       	call   80105409 <release>
			return -1;
80104cfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d01:	eb 11                	jmp    80104d14 <waitpid+0x181>
			break;
		default:
			release(&ptable.lock);
80104d03:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d0a:	e8 fa 06 00 00       	call   80105409 <release>
			return -1;
80104d0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			break;
	}

  }
}
80104d14:	c9                   	leave  
80104d15:	c3                   	ret    

80104d16 <wait_stat>:

int
wait_stat(int* wtime, int* rtime, int* iotime)
{
80104d16:	55                   	push   %ebp
80104d17:	89 e5                	mov    %esp,%ebp
80104d19:	83 ec 18             	sub    $0x18,%esp
	*wtime = proc->retime;
80104d1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d22:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
80104d28:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2b:	89 10                	mov    %edx,(%eax)
	*rtime = proc->rutime;
80104d2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d33:	8b 90 94 00 00 00    	mov    0x94(%eax),%edx
80104d39:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d3c:	89 10                	mov    %edx,(%eax)
	*iotime = proc->stime;
80104d3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d44:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80104d4a:	8b 45 10             	mov    0x10(%ebp),%eax
80104d4d:	89 10                	mov    %edx,(%eax)

	return wait(0);
80104d4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104d56:	e8 43 fc ff ff       	call   8010499e <wait>
}
80104d5b:	c9                   	leave  
80104d5c:	c3                   	ret    

80104d5d <foreground>:

int
foreground(int gid)
{
80104d5d:	55                   	push   %ebp
80104d5e:	89 e5                	mov    %esp,%ebp
80104d60:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct proc* p;
	int pids[64];
	int counter = 0;
80104d66:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
//	int i, status;
	int i;
	int retVal = -1;
80104d6d:	c7 45 e8 ff ff ff ff 	movl   $0xffffffff,-0x18(%ebp)

	//cprintf("called fg with gid: %d \n", gid);
	acquire(&ptable.lock);
80104d74:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104d7b:	e8 27 06 00 00       	call   801053a7 <acquire>
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d80:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104d87:	eb 60                	jmp    80104de9 <foreground+0x8c>
			if( ( p->state == RUNNING ||  p->state == RUNNABLE ||  p->state == SLEEPING) &&
80104d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d8c:	8b 40 0c             	mov    0xc(%eax),%eax
80104d8f:	83 f8 04             	cmp    $0x4,%eax
80104d92:	74 16                	je     80104daa <foreground+0x4d>
80104d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d97:	8b 40 0c             	mov    0xc(%eax),%eax
80104d9a:	83 f8 03             	cmp    $0x3,%eax
80104d9d:	74 0b                	je     80104daa <foreground+0x4d>
80104d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104da2:	8b 40 0c             	mov    0xc(%eax),%eax
80104da5:	83 f8 02             	cmp    $0x2,%eax
80104da8:	75 38                	jne    80104de2 <foreground+0x85>
				(p->parent == initproc) &&
80104daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dad:	8b 50 18             	mov    0x18(%eax),%edx
80104db0:	a1 68 c6 10 80       	mov    0x8010c668,%eax
	int retVal = -1;

	//cprintf("called fg with gid: %d \n", gid);
	acquire(&ptable.lock);
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
			if( ( p->state == RUNNING ||  p->state == RUNNABLE ||  p->state == SLEEPING) &&
80104db5:	39 c2                	cmp    %eax,%edx
80104db7:	75 29                	jne    80104de2 <foreground+0x85>
				(p->parent == initproc) &&
				(p->gid == gid) )
80104db9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbc:	8b 40 14             	mov    0x14(%eax),%eax

	//cprintf("called fg with gid: %d \n", gid);
	acquire(&ptable.lock);
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
			if( ( p->state == RUNNING ||  p->state == RUNNABLE ||  p->state == SLEEPING) &&
				(p->parent == initproc) &&
80104dbf:	3b 45 08             	cmp    0x8(%ebp),%eax
80104dc2:	75 1e                	jne    80104de2 <foreground+0x85>
				(p->gid == gid) )
			{
				p->parent = &ptable.proc[1]; //parent = shell
80104dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dc7:	c7 40 18 4c 3a 11 80 	movl   $0x80113a4c,0x18(%eax)
				pids[counter] = p->pid;
80104dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd1:	8b 50 10             	mov    0x10(%eax),%edx
80104dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dd7:	89 94 85 e8 fe ff ff 	mov    %edx,-0x118(%ebp,%eax,4)
				counter++;
80104dde:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
	int i;
	int retVal = -1;

	//cprintf("called fg with gid: %d \n", gid);
	acquire(&ptable.lock);
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104de2:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104de9:	81 7d f4 b4 5f 11 80 	cmpl   $0x80115fb4,-0xc(%ebp)
80104df0:	72 97                	jb     80104d89 <foreground+0x2c>
				p->parent = &ptable.proc[1]; //parent = shell
				pids[counter] = p->pid;
				counter++;
			}
	}
	for(i=0; i < counter; i++){
80104df2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80104df9:	eb 22                	jmp    80104e1d <foreground+0xc0>
		//cprintf("**waiting for: %d \n ",pids[i]);
		if (shellWait(pids[i]) != -1)	retVal = 1;
80104dfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104dfe:	8b 84 85 e8 fe ff ff 	mov    -0x118(%ebp,%eax,4),%eax
80104e05:	89 04 24             	mov    %eax,(%esp)
80104e08:	e8 bb fc ff ff       	call   80104ac8 <shellWait>
80104e0d:	83 f8 ff             	cmp    $0xffffffff,%eax
80104e10:	74 07                	je     80104e19 <foreground+0xbc>
80104e12:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
				p->parent = &ptable.proc[1]; //parent = shell
				pids[counter] = p->pid;
				counter++;
			}
	}
	for(i=0; i < counter; i++){
80104e19:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104e1d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104e20:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104e23:	7c d6                	jl     80104dfb <foreground+0x9e>
		//cprintf("**waiting for: %d \n ",pids[i]);
		if (shellWait(pids[i]) != -1)	retVal = 1;
	}
	release(&ptable.lock);
80104e25:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104e2c:	e8 d8 05 00 00       	call   80105409 <release>
		cprintf("**waiting for: %d \n ",pids[i]);
		waitpid(pids[i], &status, BLOCKING);
	}
	*/

	return retVal;
80104e31:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
80104e34:	c9                   	leave  
80104e35:	c3                   	ret    

80104e36 <list_pgroup>:
// Filling process_info_entry array with <pid,name> that is not zombie and has required <gid>
// should be called with a 64(=MAX NUM OF PROCESSES), will set <size> accordingly
int
list_pgroup(int gid, process_info_entry* arr, int* size)
{
80104e36:	55                   	push   %ebp
80104e37:	89 e5                	mov    %esp,%ebp
80104e39:	83 ec 28             	sub    $0x28,%esp
	struct proc* p;
	int i = 0;
80104e3c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	acquire(&ptable.lock);
80104e43:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104e4a:	e8 58 05 00 00       	call   801053a7 <acquire>
//		j++;
//	}

//	cprintf("requested listing of processes with group id %d \n", gid);

	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e4f:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104e56:	eb 7c                	jmp    80104ed4 <list_pgroup+0x9e>
		if( ( p->state == RUNNING ||  p->state == RUNNABLE ||  p->state == SLEEPING) &&
80104e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5b:	8b 40 0c             	mov    0xc(%eax),%eax
80104e5e:	83 f8 04             	cmp    $0x4,%eax
80104e61:	74 16                	je     80104e79 <list_pgroup+0x43>
80104e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e66:	8b 40 0c             	mov    0xc(%eax),%eax
80104e69:	83 f8 03             	cmp    $0x3,%eax
80104e6c:	74 0b                	je     80104e79 <list_pgroup+0x43>
80104e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e71:	8b 40 0c             	mov    0xc(%eax),%eax
80104e74:	83 f8 02             	cmp    $0x2,%eax
80104e77:	75 54                	jne    80104ecd <list_pgroup+0x97>
			p->gid == gid ){
80104e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7c:	8b 40 14             	mov    0x14(%eax),%eax
//	}

//	cprintf("requested listing of processes with group id %d \n", gid);

	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
		if( ( p->state == RUNNING ||  p->state == RUNNABLE ||  p->state == SLEEPING) &&
80104e7f:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e82:	75 49                	jne    80104ecd <list_pgroup+0x97>
			p->gid == gid ){

			arr[i].pid = p->pid;
80104e84:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e87:	89 d0                	mov    %edx,%eax
80104e89:	c1 e0 02             	shl    $0x2,%eax
80104e8c:	01 d0                	add    %edx,%eax
80104e8e:	c1 e0 02             	shl    $0x2,%eax
80104e91:	03 45 0c             	add    0xc(%ebp),%eax
80104e94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e97:	8b 52 10             	mov    0x10(%edx),%edx
80104e9a:	89 10                	mov    %edx,(%eax)
			safestrcpy(arr[i].name, p->name, sizeof(arr[i].name));
80104e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9f:	8d 48 70             	lea    0x70(%eax),%ecx
80104ea2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ea5:	89 d0                	mov    %edx,%eax
80104ea7:	c1 e0 02             	shl    $0x2,%eax
80104eaa:	01 d0                	add    %edx,%eax
80104eac:	c1 e0 02             	shl    $0x2,%eax
80104eaf:	03 45 0c             	add    0xc(%ebp),%eax
80104eb2:	83 c0 04             	add    $0x4,%eax
80104eb5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104ebc:	00 
80104ebd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80104ec1:	89 04 24             	mov    %eax,(%esp)
80104ec4:	e8 5d 09 00 00       	call   80105826 <safestrcpy>
			i++;
80104ec9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
//		j++;
//	}

//	cprintf("requested listing of processes with group id %d \n", gid);

	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ecd:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104ed4:	81 7d f4 b4 5f 11 80 	cmpl   $0x80115fb4,-0xc(%ebp)
80104edb:	0f 82 77 ff ff ff    	jb     80104e58 <list_pgroup+0x22>
		}
	}

//	cprintf("found %d for group id %d  \n", i, gid);

	*size = i;
80104ee1:	8b 45 10             	mov    0x10(%ebp),%eax
80104ee4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ee7:	89 10                	mov    %edx,(%eax)
	release(&ptable.lock);
80104ee9:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104ef0:	e8 14 05 00 00       	call   80105409 <release>

	return 0;
80104ef5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104efa:	c9                   	leave  
80104efb:	c3                   	ret    

80104efc <scheduler_frr>:
#endif

#ifdef FRR
void
scheduler_frr(void)
{
80104efc:	55                   	push   %ebp
80104efd:	89 e5                	mov    %esp,%ebp
80104eff:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104f02:	e8 b2 f4 ff ff       	call   801043b9 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104f07:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104f0e:	e8 94 04 00 00       	call   801053a7 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f13:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104f1a:	eb 62                	jmp    80104f7e <scheduler_frr+0x82>
      if(p->state != RUNNABLE)
80104f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f1f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f22:	83 f8 03             	cmp    $0x3,%eax
80104f25:	75 4f                	jne    80104f76 <scheduler_frr+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f2a:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f33:	89 04 24             	mov    %eax,(%esp)
80104f36:	e8 4f 35 00 00       	call   8010848a <switchuvm>
      p->state = RUNNING;
80104f3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3e:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104f45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f4b:	8b 40 20             	mov    0x20(%eax),%eax
80104f4e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104f55:	83 c2 04             	add    $0x4,%edx
80104f58:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f5c:	89 14 24             	mov    %edx,(%esp)
80104f5f:	e8 38 09 00 00       	call   8010589c <swtch>
      switchkvm();
80104f64:	e8 04 35 00 00       	call   8010846d <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104f69:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104f70:	00 00 00 00 
80104f74:	eb 01                	jmp    80104f77 <scheduler_frr+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104f76:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f77:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80104f7e:	81 7d f4 b4 5f 11 80 	cmpl   $0x80115fb4,-0xc(%ebp)
80104f85:	72 95                	jb     80104f1c <scheduler_frr+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104f87:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104f8e:	e8 76 04 00 00       	call   80105409 <release>

  }
80104f93:	e9 6a ff ff ff       	jmp    80104f02 <scheduler_frr+0x6>

80104f98 <scheduler>:
#endif


void
scheduler(void)
{
80104f98:	55                   	push   %ebp
80104f99:	89 e5                	mov    %esp,%ebp
80104f9b:	83 ec 18             	sub    $0x18,%esp
	#ifdef DEFAULT
		scheduler_default();

	#elif FRR
		cprintf("FRR!!");
80104f9e:	c7 04 24 29 8f 10 80 	movl   $0x80108f29,(%esp)
80104fa5:	e8 f7 b3 ff ff       	call   801003a1 <cprintf>
		scheduler_frr();
80104faa:	e8 4d ff ff ff       	call   80104efc <scheduler_frr>

	#elif CFS
//		scheduler_cfs();
	#endif

		for(; ;){};
80104faf:	eb fe                	jmp    80104faf <scheduler+0x17>

80104fb1 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104fb1:	55                   	push   %ebp
80104fb2:	89 e5                	mov    %esp,%ebp
80104fb4:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104fb7:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80104fbe:	e8 02 05 00 00       	call   801054c5 <holding>
80104fc3:	85 c0                	test   %eax,%eax
80104fc5:	75 0c                	jne    80104fd3 <sched+0x22>
    panic("sched ptable.lock");
80104fc7:	c7 04 24 2f 8f 10 80 	movl   $0x80108f2f,(%esp)
80104fce:	e8 6a b5 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104fd3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fd9:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104fdf:	83 f8 01             	cmp    $0x1,%eax
80104fe2:	74 0c                	je     80104ff0 <sched+0x3f>
    panic("sched locks");
80104fe4:	c7 04 24 41 8f 10 80 	movl   $0x80108f41,(%esp)
80104feb:	e8 4d b5 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104ff0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ff6:	8b 40 0c             	mov    0xc(%eax),%eax
80104ff9:	83 f8 04             	cmp    $0x4,%eax
80104ffc:	75 0c                	jne    8010500a <sched+0x59>
    panic("sched running");
80104ffe:	c7 04 24 4d 8f 10 80 	movl   $0x80108f4d,(%esp)
80105005:	e8 33 b5 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
8010500a:	e8 95 f3 ff ff       	call   801043a4 <readeflags>
8010500f:	25 00 02 00 00       	and    $0x200,%eax
80105014:	85 c0                	test   %eax,%eax
80105016:	74 0c                	je     80105024 <sched+0x73>
    panic("sched interruptible");
80105018:	c7 04 24 5b 8f 10 80 	movl   $0x80108f5b,(%esp)
8010501f:	e8 19 b5 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80105024:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010502a:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105030:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80105033:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105039:	8b 40 04             	mov    0x4(%eax),%eax
8010503c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80105043:	83 c2 20             	add    $0x20,%edx
80105046:	89 44 24 04          	mov    %eax,0x4(%esp)
8010504a:	89 14 24             	mov    %edx,(%esp)
8010504d:	e8 4a 08 00 00       	call   8010589c <swtch>
  cpu->intena = intena;
80105052:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105058:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010505b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105061:	c9                   	leave  
80105062:	c3                   	ret    

80105063 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80105063:	55                   	push   %ebp
80105064:	89 e5                	mov    %esp,%ebp
80105066:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105069:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105070:	e8 32 03 00 00       	call   801053a7 <acquire>
  proc->state = RUNNABLE;
80105075:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010507b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105082:	e8 2a ff ff ff       	call   80104fb1 <sched>
  release(&ptable.lock);
80105087:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010508e:	e8 76 03 00 00       	call   80105409 <release>
}
80105093:	c9                   	leave  
80105094:	c3                   	ret    

80105095 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80105095:	55                   	push   %ebp
80105096:	89 e5                	mov    %esp,%ebp
80105098:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
8010509b:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801050a2:	e8 62 03 00 00       	call   80105409 <release>

  if (first) {
801050a7:	a1 20 c0 10 80       	mov    0x8010c020,%eax
801050ac:	85 c0                	test   %eax,%eax
801050ae:	74 0f                	je     801050bf <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801050b0:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
801050b7:	00 00 00 
    initlog();
801050ba:	e8 f1 e1 ff ff       	call   801032b0 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801050bf:	c9                   	leave  
801050c0:	c3                   	ret    

801050c1 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801050c1:	55                   	push   %ebp
801050c2:	89 e5                	mov    %esp,%ebp
801050c4:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
801050c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050cd:	85 c0                	test   %eax,%eax
801050cf:	75 0c                	jne    801050dd <sleep+0x1c>
    panic("sleep");
801050d1:	c7 04 24 6f 8f 10 80 	movl   $0x80108f6f,(%esp)
801050d8:	e8 60 b4 ff ff       	call   8010053d <panic>

  if(lk == 0)
801050dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801050e1:	75 0c                	jne    801050ef <sleep+0x2e>
    panic("sleep without lk");
801050e3:	c7 04 24 75 8f 10 80 	movl   $0x80108f75,(%esp)
801050ea:	e8 4e b4 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801050ef:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
801050f6:	74 17                	je     8010510f <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801050f8:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801050ff:	e8 a3 02 00 00       	call   801053a7 <acquire>
    release(lk);
80105104:	8b 45 0c             	mov    0xc(%ebp),%eax
80105107:	89 04 24             	mov    %eax,(%esp)
8010510a:	e8 fa 02 00 00       	call   80105409 <release>
  }

  // Go to sleep.
  proc->chan = chan;
8010510f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105115:	8b 55 08             	mov    0x8(%ebp),%edx
80105118:	89 50 24             	mov    %edx,0x24(%eax)
  proc->state = SLEEPING;
8010511b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105121:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105128:	e8 84 fe ff ff       	call   80104fb1 <sched>

  // Tidy up.
  proc->chan = 0;
8010512d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105133:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010513a:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80105141:	74 17                	je     8010515a <sleep+0x99>
    release(&ptable.lock);
80105143:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
8010514a:	e8 ba 02 00 00       	call   80105409 <release>
    acquire(lk);
8010514f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105152:	89 04 24             	mov    %eax,(%esp)
80105155:	e8 4d 02 00 00       	call   801053a7 <acquire>
  }
}
8010515a:	c9                   	leave  
8010515b:	c3                   	ret    

8010515c <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010515c:	55                   	push   %ebp
8010515d:	89 e5                	mov    %esp,%ebp
8010515f:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80105162:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
80105169:	eb 27                	jmp    80105192 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
8010516b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010516e:	8b 40 0c             	mov    0xc(%eax),%eax
80105171:	83 f8 02             	cmp    $0x2,%eax
80105174:	75 15                	jne    8010518b <wakeup1+0x2f>
80105176:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105179:	8b 40 24             	mov    0x24(%eax),%eax
8010517c:	3b 45 08             	cmp    0x8(%ebp),%eax
8010517f:	75 0a                	jne    8010518b <wakeup1+0x2f>
      p->state = RUNNABLE;
80105181:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105184:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010518b:	81 45 fc 98 00 00 00 	addl   $0x98,-0x4(%ebp)
80105192:	81 7d fc b4 5f 11 80 	cmpl   $0x80115fb4,-0x4(%ebp)
80105199:	72 d0                	jb     8010516b <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
8010519b:	c9                   	leave  
8010519c:	c3                   	ret    

8010519d <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010519d:	55                   	push   %ebp
8010519e:	89 e5                	mov    %esp,%ebp
801051a0:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
801051a3:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801051aa:	e8 f8 01 00 00       	call   801053a7 <acquire>
  wakeup1(chan);
801051af:	8b 45 08             	mov    0x8(%ebp),%eax
801051b2:	89 04 24             	mov    %eax,(%esp)
801051b5:	e8 a2 ff ff ff       	call   8010515c <wakeup1>
  release(&ptable.lock);
801051ba:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801051c1:	e8 43 02 00 00       	call   80105409 <release>
}
801051c6:	c9                   	leave  
801051c7:	c3                   	ret    

801051c8 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801051c8:	55                   	push   %ebp
801051c9:	89 e5                	mov    %esp,%ebp
801051cb:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
801051ce:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
801051d5:	e8 cd 01 00 00       	call   801053a7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051da:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
801051e1:	eb 44                	jmp    80105227 <kill+0x5f>
    if(p->pid == pid){
801051e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e6:	8b 40 10             	mov    0x10(%eax),%eax
801051e9:	3b 45 08             	cmp    0x8(%ebp),%eax
801051ec:	75 32                	jne    80105220 <kill+0x58>
      p->killed = 1;
801051ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f1:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801051f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fb:	8b 40 0c             	mov    0xc(%eax),%eax
801051fe:	83 f8 02             	cmp    $0x2,%eax
80105201:	75 0a                	jne    8010520d <kill+0x45>
        p->state = RUNNABLE;
80105203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105206:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010520d:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105214:	e8 f0 01 00 00       	call   80105409 <release>
      return 0;
80105219:	b8 00 00 00 00       	mov    $0x0,%eax
8010521e:	eb 21                	jmp    80105241 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105220:	81 45 f4 98 00 00 00 	addl   $0x98,-0xc(%ebp)
80105227:	81 7d f4 b4 5f 11 80 	cmpl   $0x80115fb4,-0xc(%ebp)
8010522e:	72 b3                	jb     801051e3 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105230:	c7 04 24 80 39 11 80 	movl   $0x80113980,(%esp)
80105237:	e8 cd 01 00 00       	call   80105409 <release>
  return -1;
8010523c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105241:	c9                   	leave  
80105242:	c3                   	ret    

80105243 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105243:	55                   	push   %ebp
80105244:	89 e5                	mov    %esp,%ebp
80105246:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105249:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
80105250:	e9 db 00 00 00       	jmp    80105330 <procdump+0xed>
    if(p->state == UNUSED)
80105255:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105258:	8b 40 0c             	mov    0xc(%eax),%eax
8010525b:	85 c0                	test   %eax,%eax
8010525d:	0f 84 c5 00 00 00    	je     80105328 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105263:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105266:	8b 40 0c             	mov    0xc(%eax),%eax
80105269:	83 f8 05             	cmp    $0x5,%eax
8010526c:	77 23                	ja     80105291 <procdump+0x4e>
8010526e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105271:	8b 40 0c             	mov    0xc(%eax),%eax
80105274:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010527b:	85 c0                	test   %eax,%eax
8010527d:	74 12                	je     80105291 <procdump+0x4e>
      state = states[p->state];
8010527f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105282:	8b 40 0c             	mov    0xc(%eax),%eax
80105285:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010528c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010528f:	eb 07                	jmp    80105298 <procdump+0x55>
    else
      state = "???";
80105291:	c7 45 ec 86 8f 10 80 	movl   $0x80108f86,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105298:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010529b:	8d 50 70             	lea    0x70(%eax),%edx
8010529e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052a1:	8b 40 10             	mov    0x10(%eax),%eax
801052a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
801052a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801052ab:	89 54 24 08          	mov    %edx,0x8(%esp)
801052af:	89 44 24 04          	mov    %eax,0x4(%esp)
801052b3:	c7 04 24 8a 8f 10 80 	movl   $0x80108f8a,(%esp)
801052ba:	e8 e2 b0 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
801052bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052c2:	8b 40 0c             	mov    0xc(%eax),%eax
801052c5:	83 f8 02             	cmp    $0x2,%eax
801052c8:	75 50                	jne    8010531a <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801052ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052cd:	8b 40 20             	mov    0x20(%eax),%eax
801052d0:	8b 40 0c             	mov    0xc(%eax),%eax
801052d3:	83 c0 08             	add    $0x8,%eax
801052d6:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801052d9:	89 54 24 04          	mov    %edx,0x4(%esp)
801052dd:	89 04 24             	mov    %eax,(%esp)
801052e0:	e8 73 01 00 00       	call   80105458 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801052e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052ec:	eb 1b                	jmp    80105309 <procdump+0xc6>
        cprintf(" %p", pc[i]);
801052ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052f1:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801052f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801052f9:	c7 04 24 93 8f 10 80 	movl   $0x80108f93,(%esp)
80105300:	e8 9c b0 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105305:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105309:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010530d:	7f 0b                	jg     8010531a <procdump+0xd7>
8010530f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105312:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105316:	85 c0                	test   %eax,%eax
80105318:	75 d4                	jne    801052ee <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010531a:	c7 04 24 97 8f 10 80 	movl   $0x80108f97,(%esp)
80105321:	e8 7b b0 ff ff       	call   801003a1 <cprintf>
80105326:	eb 01                	jmp    80105329 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105328:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105329:	81 45 f0 98 00 00 00 	addl   $0x98,-0x10(%ebp)
80105330:	81 7d f0 b4 5f 11 80 	cmpl   $0x80115fb4,-0x10(%ebp)
80105337:	0f 82 18 ff ff ff    	jb     80105255 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010533d:	c9                   	leave  
8010533e:	c3                   	ret    
	...

80105340 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
80105343:	53                   	push   %ebx
80105344:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105347:	9c                   	pushf  
80105348:	5b                   	pop    %ebx
80105349:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010534c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010534f:	83 c4 10             	add    $0x10,%esp
80105352:	5b                   	pop    %ebx
80105353:	5d                   	pop    %ebp
80105354:	c3                   	ret    

80105355 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105355:	55                   	push   %ebp
80105356:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105358:	fa                   	cli    
}
80105359:	5d                   	pop    %ebp
8010535a:	c3                   	ret    

8010535b <sti>:

static inline void
sti(void)
{
8010535b:	55                   	push   %ebp
8010535c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010535e:	fb                   	sti    
}
8010535f:	5d                   	pop    %ebp
80105360:	c3                   	ret    

80105361 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105361:	55                   	push   %ebp
80105362:	89 e5                	mov    %esp,%ebp
80105364:	53                   	push   %ebx
80105365:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80105368:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010536b:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
8010536e:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105371:	89 c3                	mov    %eax,%ebx
80105373:	89 d8                	mov    %ebx,%eax
80105375:	f0 87 02             	lock xchg %eax,(%edx)
80105378:	89 c3                	mov    %eax,%ebx
8010537a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010537d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105380:	83 c4 10             	add    $0x10,%esp
80105383:	5b                   	pop    %ebx
80105384:	5d                   	pop    %ebp
80105385:	c3                   	ret    

80105386 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105386:	55                   	push   %ebp
80105387:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105389:	8b 45 08             	mov    0x8(%ebp),%eax
8010538c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010538f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105392:	8b 45 08             	mov    0x8(%ebp),%eax
80105395:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010539b:	8b 45 08             	mov    0x8(%ebp),%eax
8010539e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801053a5:	5d                   	pop    %ebp
801053a6:	c3                   	ret    

801053a7 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801053a7:	55                   	push   %ebp
801053a8:	89 e5                	mov    %esp,%ebp
801053aa:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801053ad:	e8 3d 01 00 00       	call   801054ef <pushcli>
  if(holding(lk))
801053b2:	8b 45 08             	mov    0x8(%ebp),%eax
801053b5:	89 04 24             	mov    %eax,(%esp)
801053b8:	e8 08 01 00 00       	call   801054c5 <holding>
801053bd:	85 c0                	test   %eax,%eax
801053bf:	74 0c                	je     801053cd <acquire+0x26>
    panic("acquire");
801053c1:	c7 04 24 c3 8f 10 80 	movl   $0x80108fc3,(%esp)
801053c8:	e8 70 b1 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801053cd:	90                   	nop
801053ce:	8b 45 08             	mov    0x8(%ebp),%eax
801053d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801053d8:	00 
801053d9:	89 04 24             	mov    %eax,(%esp)
801053dc:	e8 80 ff ff ff       	call   80105361 <xchg>
801053e1:	85 c0                	test   %eax,%eax
801053e3:	75 e9                	jne    801053ce <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801053e5:	8b 45 08             	mov    0x8(%ebp),%eax
801053e8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801053ef:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801053f2:	8b 45 08             	mov    0x8(%ebp),%eax
801053f5:	83 c0 0c             	add    $0xc,%eax
801053f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801053fc:	8d 45 08             	lea    0x8(%ebp),%eax
801053ff:	89 04 24             	mov    %eax,(%esp)
80105402:	e8 51 00 00 00       	call   80105458 <getcallerpcs>
}
80105407:	c9                   	leave  
80105408:	c3                   	ret    

80105409 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105409:	55                   	push   %ebp
8010540a:	89 e5                	mov    %esp,%ebp
8010540c:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010540f:	8b 45 08             	mov    0x8(%ebp),%eax
80105412:	89 04 24             	mov    %eax,(%esp)
80105415:	e8 ab 00 00 00       	call   801054c5 <holding>
8010541a:	85 c0                	test   %eax,%eax
8010541c:	75 0c                	jne    8010542a <release+0x21>
    panic("release");
8010541e:	c7 04 24 cb 8f 10 80 	movl   $0x80108fcb,(%esp)
80105425:	e8 13 b1 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
8010542a:	8b 45 08             	mov    0x8(%ebp),%eax
8010542d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105434:	8b 45 08             	mov    0x8(%ebp),%eax
80105437:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010543e:	8b 45 08             	mov    0x8(%ebp),%eax
80105441:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105448:	00 
80105449:	89 04 24             	mov    %eax,(%esp)
8010544c:	e8 10 ff ff ff       	call   80105361 <xchg>

  popcli();
80105451:	e8 e1 00 00 00       	call   80105537 <popcli>
}
80105456:	c9                   	leave  
80105457:	c3                   	ret    

80105458 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105458:	55                   	push   %ebp
80105459:	89 e5                	mov    %esp,%ebp
8010545b:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
8010545e:	8b 45 08             	mov    0x8(%ebp),%eax
80105461:	83 e8 08             	sub    $0x8,%eax
80105464:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105467:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010546e:	eb 32                	jmp    801054a2 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105470:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105474:	74 47                	je     801054bd <getcallerpcs+0x65>
80105476:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010547d:	76 3e                	jbe    801054bd <getcallerpcs+0x65>
8010547f:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105483:	74 38                	je     801054bd <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105485:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105488:	c1 e0 02             	shl    $0x2,%eax
8010548b:	03 45 0c             	add    0xc(%ebp),%eax
8010548e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105491:	8b 52 04             	mov    0x4(%edx),%edx
80105494:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80105496:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105499:	8b 00                	mov    (%eax),%eax
8010549b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010549e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054a2:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054a6:	7e c8                	jle    80105470 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801054a8:	eb 13                	jmp    801054bd <getcallerpcs+0x65>
    pcs[i] = 0;
801054aa:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054ad:	c1 e0 02             	shl    $0x2,%eax
801054b0:	03 45 0c             	add    0xc(%ebp),%eax
801054b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801054b9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054bd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054c1:	7e e7                	jle    801054aa <getcallerpcs+0x52>
    pcs[i] = 0;
}
801054c3:	c9                   	leave  
801054c4:	c3                   	ret    

801054c5 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801054c5:	55                   	push   %ebp
801054c6:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801054c8:	8b 45 08             	mov    0x8(%ebp),%eax
801054cb:	8b 00                	mov    (%eax),%eax
801054cd:	85 c0                	test   %eax,%eax
801054cf:	74 17                	je     801054e8 <holding+0x23>
801054d1:	8b 45 08             	mov    0x8(%ebp),%eax
801054d4:	8b 50 08             	mov    0x8(%eax),%edx
801054d7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054dd:	39 c2                	cmp    %eax,%edx
801054df:	75 07                	jne    801054e8 <holding+0x23>
801054e1:	b8 01 00 00 00       	mov    $0x1,%eax
801054e6:	eb 05                	jmp    801054ed <holding+0x28>
801054e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054ed:	5d                   	pop    %ebp
801054ee:	c3                   	ret    

801054ef <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801054ef:	55                   	push   %ebp
801054f0:	89 e5                	mov    %esp,%ebp
801054f2:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801054f5:	e8 46 fe ff ff       	call   80105340 <readeflags>
801054fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801054fd:	e8 53 fe ff ff       	call   80105355 <cli>
  if(cpu->ncli++ == 0)
80105502:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105508:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010550e:	85 d2                	test   %edx,%edx
80105510:	0f 94 c1             	sete   %cl
80105513:	83 c2 01             	add    $0x1,%edx
80105516:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010551c:	84 c9                	test   %cl,%cl
8010551e:	74 15                	je     80105535 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105520:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105526:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105529:	81 e2 00 02 00 00    	and    $0x200,%edx
8010552f:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105535:	c9                   	leave  
80105536:	c3                   	ret    

80105537 <popcli>:

void
popcli(void)
{
80105537:	55                   	push   %ebp
80105538:	89 e5                	mov    %esp,%ebp
8010553a:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010553d:	e8 fe fd ff ff       	call   80105340 <readeflags>
80105542:	25 00 02 00 00       	and    $0x200,%eax
80105547:	85 c0                	test   %eax,%eax
80105549:	74 0c                	je     80105557 <popcli+0x20>
    panic("popcli - interruptible");
8010554b:	c7 04 24 d3 8f 10 80 	movl   $0x80108fd3,(%esp)
80105552:	e8 e6 af ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
80105557:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010555d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105563:	83 ea 01             	sub    $0x1,%edx
80105566:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010556c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105572:	85 c0                	test   %eax,%eax
80105574:	79 0c                	jns    80105582 <popcli+0x4b>
    panic("popcli");
80105576:	c7 04 24 ea 8f 10 80 	movl   $0x80108fea,(%esp)
8010557d:	e8 bb af ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105582:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105588:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010558e:	85 c0                	test   %eax,%eax
80105590:	75 15                	jne    801055a7 <popcli+0x70>
80105592:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105598:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010559e:	85 c0                	test   %eax,%eax
801055a0:	74 05                	je     801055a7 <popcli+0x70>
    sti();
801055a2:	e8 b4 fd ff ff       	call   8010535b <sti>
}
801055a7:	c9                   	leave  
801055a8:	c3                   	ret    
801055a9:	00 00                	add    %al,(%eax)
	...

801055ac <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801055ac:	55                   	push   %ebp
801055ad:	89 e5                	mov    %esp,%ebp
801055af:	57                   	push   %edi
801055b0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801055b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055b4:	8b 55 10             	mov    0x10(%ebp),%edx
801055b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ba:	89 cb                	mov    %ecx,%ebx
801055bc:	89 df                	mov    %ebx,%edi
801055be:	89 d1                	mov    %edx,%ecx
801055c0:	fc                   	cld    
801055c1:	f3 aa                	rep stos %al,%es:(%edi)
801055c3:	89 ca                	mov    %ecx,%edx
801055c5:	89 fb                	mov    %edi,%ebx
801055c7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055ca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801055cd:	5b                   	pop    %ebx
801055ce:	5f                   	pop    %edi
801055cf:	5d                   	pop    %ebp
801055d0:	c3                   	ret    

801055d1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801055d1:	55                   	push   %ebp
801055d2:	89 e5                	mov    %esp,%ebp
801055d4:	57                   	push   %edi
801055d5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801055d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055d9:	8b 55 10             	mov    0x10(%ebp),%edx
801055dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801055df:	89 cb                	mov    %ecx,%ebx
801055e1:	89 df                	mov    %ebx,%edi
801055e3:	89 d1                	mov    %edx,%ecx
801055e5:	fc                   	cld    
801055e6:	f3 ab                	rep stos %eax,%es:(%edi)
801055e8:	89 ca                	mov    %ecx,%edx
801055ea:	89 fb                	mov    %edi,%ebx
801055ec:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055ef:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801055f2:	5b                   	pop    %ebx
801055f3:	5f                   	pop    %edi
801055f4:	5d                   	pop    %ebp
801055f5:	c3                   	ret    

801055f6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801055f6:	55                   	push   %ebp
801055f7:	89 e5                	mov    %esp,%ebp
801055f9:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801055fc:	8b 45 08             	mov    0x8(%ebp),%eax
801055ff:	83 e0 03             	and    $0x3,%eax
80105602:	85 c0                	test   %eax,%eax
80105604:	75 49                	jne    8010564f <memset+0x59>
80105606:	8b 45 10             	mov    0x10(%ebp),%eax
80105609:	83 e0 03             	and    $0x3,%eax
8010560c:	85 c0                	test   %eax,%eax
8010560e:	75 3f                	jne    8010564f <memset+0x59>
    c &= 0xFF;
80105610:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105617:	8b 45 10             	mov    0x10(%ebp),%eax
8010561a:	c1 e8 02             	shr    $0x2,%eax
8010561d:	89 c2                	mov    %eax,%edx
8010561f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105622:	89 c1                	mov    %eax,%ecx
80105624:	c1 e1 18             	shl    $0x18,%ecx
80105627:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562a:	c1 e0 10             	shl    $0x10,%eax
8010562d:	09 c1                	or     %eax,%ecx
8010562f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105632:	c1 e0 08             	shl    $0x8,%eax
80105635:	09 c8                	or     %ecx,%eax
80105637:	0b 45 0c             	or     0xc(%ebp),%eax
8010563a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010563e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105642:	8b 45 08             	mov    0x8(%ebp),%eax
80105645:	89 04 24             	mov    %eax,(%esp)
80105648:	e8 84 ff ff ff       	call   801055d1 <stosl>
8010564d:	eb 19                	jmp    80105668 <memset+0x72>
  } else
    stosb(dst, c, n);
8010564f:	8b 45 10             	mov    0x10(%ebp),%eax
80105652:	89 44 24 08          	mov    %eax,0x8(%esp)
80105656:	8b 45 0c             	mov    0xc(%ebp),%eax
80105659:	89 44 24 04          	mov    %eax,0x4(%esp)
8010565d:	8b 45 08             	mov    0x8(%ebp),%eax
80105660:	89 04 24             	mov    %eax,(%esp)
80105663:	e8 44 ff ff ff       	call   801055ac <stosb>
  return dst;
80105668:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010566b:	c9                   	leave  
8010566c:	c3                   	ret    

8010566d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010566d:	55                   	push   %ebp
8010566e:	89 e5                	mov    %esp,%ebp
80105670:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105673:	8b 45 08             	mov    0x8(%ebp),%eax
80105676:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105679:	8b 45 0c             	mov    0xc(%ebp),%eax
8010567c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010567f:	eb 32                	jmp    801056b3 <memcmp+0x46>
    if(*s1 != *s2)
80105681:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105684:	0f b6 10             	movzbl (%eax),%edx
80105687:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010568a:	0f b6 00             	movzbl (%eax),%eax
8010568d:	38 c2                	cmp    %al,%dl
8010568f:	74 1a                	je     801056ab <memcmp+0x3e>
      return *s1 - *s2;
80105691:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105694:	0f b6 00             	movzbl (%eax),%eax
80105697:	0f b6 d0             	movzbl %al,%edx
8010569a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010569d:	0f b6 00             	movzbl (%eax),%eax
801056a0:	0f b6 c0             	movzbl %al,%eax
801056a3:	89 d1                	mov    %edx,%ecx
801056a5:	29 c1                	sub    %eax,%ecx
801056a7:	89 c8                	mov    %ecx,%eax
801056a9:	eb 1c                	jmp    801056c7 <memcmp+0x5a>
    s1++, s2++;
801056ab:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056af:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801056b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056b7:	0f 95 c0             	setne  %al
801056ba:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801056be:	84 c0                	test   %al,%al
801056c0:	75 bf                	jne    80105681 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801056c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056c7:	c9                   	leave  
801056c8:	c3                   	ret    

801056c9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801056c9:	55                   	push   %ebp
801056ca:	89 e5                	mov    %esp,%ebp
801056cc:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801056cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801056d5:	8b 45 08             	mov    0x8(%ebp),%eax
801056d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801056db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056e1:	73 54                	jae    80105737 <memmove+0x6e>
801056e3:	8b 45 10             	mov    0x10(%ebp),%eax
801056e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056e9:	01 d0                	add    %edx,%eax
801056eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056ee:	76 47                	jbe    80105737 <memmove+0x6e>
    s += n;
801056f0:	8b 45 10             	mov    0x10(%ebp),%eax
801056f3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801056f6:	8b 45 10             	mov    0x10(%ebp),%eax
801056f9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801056fc:	eb 13                	jmp    80105711 <memmove+0x48>
      *--d = *--s;
801056fe:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105702:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105706:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105709:	0f b6 10             	movzbl (%eax),%edx
8010570c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010570f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105711:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105715:	0f 95 c0             	setne  %al
80105718:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010571c:	84 c0                	test   %al,%al
8010571e:	75 de                	jne    801056fe <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105720:	eb 25                	jmp    80105747 <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105722:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105725:	0f b6 10             	movzbl (%eax),%edx
80105728:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010572b:	88 10                	mov    %dl,(%eax)
8010572d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105731:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105735:	eb 01                	jmp    80105738 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105737:	90                   	nop
80105738:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010573c:	0f 95 c0             	setne  %al
8010573f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105743:	84 c0                	test   %al,%al
80105745:	75 db                	jne    80105722 <memmove+0x59>
      *d++ = *s++;

  return dst;
80105747:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010574a:	c9                   	leave  
8010574b:	c3                   	ret    

8010574c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010574c:	55                   	push   %ebp
8010574d:	89 e5                	mov    %esp,%ebp
8010574f:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105752:	8b 45 10             	mov    0x10(%ebp),%eax
80105755:	89 44 24 08          	mov    %eax,0x8(%esp)
80105759:	8b 45 0c             	mov    0xc(%ebp),%eax
8010575c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105760:	8b 45 08             	mov    0x8(%ebp),%eax
80105763:	89 04 24             	mov    %eax,(%esp)
80105766:	e8 5e ff ff ff       	call   801056c9 <memmove>
}
8010576b:	c9                   	leave  
8010576c:	c3                   	ret    

8010576d <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010576d:	55                   	push   %ebp
8010576e:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105770:	eb 0c                	jmp    8010577e <strncmp+0x11>
    n--, p++, q++;
80105772:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105776:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010577a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010577e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105782:	74 1a                	je     8010579e <strncmp+0x31>
80105784:	8b 45 08             	mov    0x8(%ebp),%eax
80105787:	0f b6 00             	movzbl (%eax),%eax
8010578a:	84 c0                	test   %al,%al
8010578c:	74 10                	je     8010579e <strncmp+0x31>
8010578e:	8b 45 08             	mov    0x8(%ebp),%eax
80105791:	0f b6 10             	movzbl (%eax),%edx
80105794:	8b 45 0c             	mov    0xc(%ebp),%eax
80105797:	0f b6 00             	movzbl (%eax),%eax
8010579a:	38 c2                	cmp    %al,%dl
8010579c:	74 d4                	je     80105772 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010579e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057a2:	75 07                	jne    801057ab <strncmp+0x3e>
    return 0;
801057a4:	b8 00 00 00 00       	mov    $0x0,%eax
801057a9:	eb 18                	jmp    801057c3 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801057ab:	8b 45 08             	mov    0x8(%ebp),%eax
801057ae:	0f b6 00             	movzbl (%eax),%eax
801057b1:	0f b6 d0             	movzbl %al,%edx
801057b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801057b7:	0f b6 00             	movzbl (%eax),%eax
801057ba:	0f b6 c0             	movzbl %al,%eax
801057bd:	89 d1                	mov    %edx,%ecx
801057bf:	29 c1                	sub    %eax,%ecx
801057c1:	89 c8                	mov    %ecx,%eax
}
801057c3:	5d                   	pop    %ebp
801057c4:	c3                   	ret    

801057c5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801057c5:	55                   	push   %ebp
801057c6:	89 e5                	mov    %esp,%ebp
801057c8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801057cb:	8b 45 08             	mov    0x8(%ebp),%eax
801057ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801057d1:	90                   	nop
801057d2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057d6:	0f 9f c0             	setg   %al
801057d9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801057dd:	84 c0                	test   %al,%al
801057df:	74 30                	je     80105811 <strncpy+0x4c>
801057e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801057e4:	0f b6 10             	movzbl (%eax),%edx
801057e7:	8b 45 08             	mov    0x8(%ebp),%eax
801057ea:	88 10                	mov    %dl,(%eax)
801057ec:	8b 45 08             	mov    0x8(%ebp),%eax
801057ef:	0f b6 00             	movzbl (%eax),%eax
801057f2:	84 c0                	test   %al,%al
801057f4:	0f 95 c0             	setne  %al
801057f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801057fb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801057ff:	84 c0                	test   %al,%al
80105801:	75 cf                	jne    801057d2 <strncpy+0xd>
    ;
  while(n-- > 0)
80105803:	eb 0c                	jmp    80105811 <strncpy+0x4c>
    *s++ = 0;
80105805:	8b 45 08             	mov    0x8(%ebp),%eax
80105808:	c6 00 00             	movb   $0x0,(%eax)
8010580b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010580f:	eb 01                	jmp    80105812 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105811:	90                   	nop
80105812:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105816:	0f 9f c0             	setg   %al
80105819:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010581d:	84 c0                	test   %al,%al
8010581f:	75 e4                	jne    80105805 <strncpy+0x40>
    *s++ = 0;
  return os;
80105821:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105824:	c9                   	leave  
80105825:	c3                   	ret    

80105826 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105826:	55                   	push   %ebp
80105827:	89 e5                	mov    %esp,%ebp
80105829:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010582c:	8b 45 08             	mov    0x8(%ebp),%eax
8010582f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105832:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105836:	7f 05                	jg     8010583d <safestrcpy+0x17>
    return os;
80105838:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010583b:	eb 35                	jmp    80105872 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
8010583d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105841:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105845:	7e 22                	jle    80105869 <safestrcpy+0x43>
80105847:	8b 45 0c             	mov    0xc(%ebp),%eax
8010584a:	0f b6 10             	movzbl (%eax),%edx
8010584d:	8b 45 08             	mov    0x8(%ebp),%eax
80105850:	88 10                	mov    %dl,(%eax)
80105852:	8b 45 08             	mov    0x8(%ebp),%eax
80105855:	0f b6 00             	movzbl (%eax),%eax
80105858:	84 c0                	test   %al,%al
8010585a:	0f 95 c0             	setne  %al
8010585d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105861:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105865:	84 c0                	test   %al,%al
80105867:	75 d4                	jne    8010583d <safestrcpy+0x17>
    ;
  *s = 0;
80105869:	8b 45 08             	mov    0x8(%ebp),%eax
8010586c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010586f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105872:	c9                   	leave  
80105873:	c3                   	ret    

80105874 <strlen>:

int
strlen(const char *s)
{
80105874:	55                   	push   %ebp
80105875:	89 e5                	mov    %esp,%ebp
80105877:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010587a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105881:	eb 04                	jmp    80105887 <strlen+0x13>
80105883:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105887:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010588a:	03 45 08             	add    0x8(%ebp),%eax
8010588d:	0f b6 00             	movzbl (%eax),%eax
80105890:	84 c0                	test   %al,%al
80105892:	75 ef                	jne    80105883 <strlen+0xf>
    ;
  return n;
80105894:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105897:	c9                   	leave  
80105898:	c3                   	ret    
80105899:	00 00                	add    %al,(%eax)
	...

8010589c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010589c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801058a0:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
801058a4:	55                   	push   %ebp
  pushl %ebx
801058a5:	53                   	push   %ebx
  pushl %esi
801058a6:	56                   	push   %esi
  pushl %edi
801058a7:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801058a8:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801058aa:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801058ac:	5f                   	pop    %edi
  popl %esi
801058ad:	5e                   	pop    %esi
  popl %ebx
801058ae:	5b                   	pop    %ebx
  popl %ebp
801058af:	5d                   	pop    %ebp
  ret
801058b0:	c3                   	ret    
801058b1:	00 00                	add    %al,(%eax)
	...

801058b4 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801058b4:	55                   	push   %ebp
801058b5:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801058b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058bd:	8b 00                	mov    (%eax),%eax
801058bf:	3b 45 08             	cmp    0x8(%ebp),%eax
801058c2:	76 12                	jbe    801058d6 <fetchint+0x22>
801058c4:	8b 45 08             	mov    0x8(%ebp),%eax
801058c7:	8d 50 04             	lea    0x4(%eax),%edx
801058ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058d0:	8b 00                	mov    (%eax),%eax
801058d2:	39 c2                	cmp    %eax,%edx
801058d4:	76 07                	jbe    801058dd <fetchint+0x29>
    return -1;
801058d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058db:	eb 0f                	jmp    801058ec <fetchint+0x38>
  *ip = *(int*)(addr);
801058dd:	8b 45 08             	mov    0x8(%ebp),%eax
801058e0:	8b 10                	mov    (%eax),%edx
801058e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801058e5:	89 10                	mov    %edx,(%eax)
  return 0;
801058e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058ec:	5d                   	pop    %ebp
801058ed:	c3                   	ret    

801058ee <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801058ee:	55                   	push   %ebp
801058ef:	89 e5                	mov    %esp,%ebp
801058f1:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801058f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058fa:	8b 00                	mov    (%eax),%eax
801058fc:	3b 45 08             	cmp    0x8(%ebp),%eax
801058ff:	77 07                	ja     80105908 <fetchstr+0x1a>
    return -1;
80105901:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105906:	eb 48                	jmp    80105950 <fetchstr+0x62>
  *pp = (char*)addr;
80105908:	8b 55 08             	mov    0x8(%ebp),%edx
8010590b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010590e:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105910:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105916:	8b 00                	mov    (%eax),%eax
80105918:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010591b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010591e:	8b 00                	mov    (%eax),%eax
80105920:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105923:	eb 1e                	jmp    80105943 <fetchstr+0x55>
    if(*s == 0)
80105925:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105928:	0f b6 00             	movzbl (%eax),%eax
8010592b:	84 c0                	test   %al,%al
8010592d:	75 10                	jne    8010593f <fetchstr+0x51>
      return s - *pp;
8010592f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105932:	8b 45 0c             	mov    0xc(%ebp),%eax
80105935:	8b 00                	mov    (%eax),%eax
80105937:	89 d1                	mov    %edx,%ecx
80105939:	29 c1                	sub    %eax,%ecx
8010593b:	89 c8                	mov    %ecx,%eax
8010593d:	eb 11                	jmp    80105950 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010593f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105943:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105946:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105949:	72 da                	jb     80105925 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010594b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105950:	c9                   	leave  
80105951:	c3                   	ret    

80105952 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105952:	55                   	push   %ebp
80105953:	89 e5                	mov    %esp,%ebp
80105955:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105958:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010595e:	8b 40 1c             	mov    0x1c(%eax),%eax
80105961:	8b 50 44             	mov    0x44(%eax),%edx
80105964:	8b 45 08             	mov    0x8(%ebp),%eax
80105967:	c1 e0 02             	shl    $0x2,%eax
8010596a:	01 d0                	add    %edx,%eax
8010596c:	8d 50 04             	lea    0x4(%eax),%edx
8010596f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105972:	89 44 24 04          	mov    %eax,0x4(%esp)
80105976:	89 14 24             	mov    %edx,(%esp)
80105979:	e8 36 ff ff ff       	call   801058b4 <fetchint>
}
8010597e:	c9                   	leave  
8010597f:	c3                   	ret    

80105980 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105980:	55                   	push   %ebp
80105981:	89 e5                	mov    %esp,%ebp
80105983:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105986:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105989:	89 44 24 04          	mov    %eax,0x4(%esp)
8010598d:	8b 45 08             	mov    0x8(%ebp),%eax
80105990:	89 04 24             	mov    %eax,(%esp)
80105993:	e8 ba ff ff ff       	call   80105952 <argint>
80105998:	85 c0                	test   %eax,%eax
8010599a:	79 07                	jns    801059a3 <argptr+0x23>
    return -1;
8010599c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059a1:	eb 3d                	jmp    801059e0 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
801059a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059a6:	89 c2                	mov    %eax,%edx
801059a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059ae:	8b 00                	mov    (%eax),%eax
801059b0:	39 c2                	cmp    %eax,%edx
801059b2:	73 16                	jae    801059ca <argptr+0x4a>
801059b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059b7:	89 c2                	mov    %eax,%edx
801059b9:	8b 45 10             	mov    0x10(%ebp),%eax
801059bc:	01 c2                	add    %eax,%edx
801059be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059c4:	8b 00                	mov    (%eax),%eax
801059c6:	39 c2                	cmp    %eax,%edx
801059c8:	76 07                	jbe    801059d1 <argptr+0x51>
    return -1;
801059ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cf:	eb 0f                	jmp    801059e0 <argptr+0x60>
  *pp = (char*)i;
801059d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059d4:	89 c2                	mov    %eax,%edx
801059d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801059d9:	89 10                	mov    %edx,(%eax)
  return 0;
801059db:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059e0:	c9                   	leave  
801059e1:	c3                   	ret    

801059e2 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801059e2:	55                   	push   %ebp
801059e3:	89 e5                	mov    %esp,%ebp
801059e5:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801059e8:	8d 45 fc             	lea    -0x4(%ebp),%eax
801059eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ef:	8b 45 08             	mov    0x8(%ebp),%eax
801059f2:	89 04 24             	mov    %eax,(%esp)
801059f5:	e8 58 ff ff ff       	call   80105952 <argint>
801059fa:	85 c0                	test   %eax,%eax
801059fc:	79 07                	jns    80105a05 <argstr+0x23>
    return -1;
801059fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a03:	eb 12                	jmp    80105a17 <argstr+0x35>
  return fetchstr(addr, pp);
80105a05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a08:	8b 55 0c             	mov    0xc(%ebp),%edx
80105a0b:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a0f:	89 04 24             	mov    %eax,(%esp)
80105a12:	e8 d7 fe ff ff       	call   801058ee <fetchstr>
}
80105a17:	c9                   	leave  
80105a18:	c3                   	ret    

80105a19 <syscall>:
[SYS_foreground]    sys_foreground,
};

void
syscall(void)
{
80105a19:	55                   	push   %ebp
80105a1a:	89 e5                	mov    %esp,%ebp
80105a1c:	53                   	push   %ebx
80105a1d:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105a20:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a26:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a29:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105a2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a33:	7e 30                	jle    80105a65 <syscall+0x4c>
80105a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a38:	83 f8 19             	cmp    $0x19,%eax
80105a3b:	77 28                	ja     80105a65 <syscall+0x4c>
80105a3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a40:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a47:	85 c0                	test   %eax,%eax
80105a49:	74 1a                	je     80105a65 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105a4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a51:	8b 58 1c             	mov    0x1c(%eax),%ebx
80105a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a57:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a5e:	ff d0                	call   *%eax
80105a60:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105a63:	eb 3d                	jmp    80105aa2 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105a65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a6b:	8d 48 70             	lea    0x70(%eax),%ecx
80105a6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105a74:	8b 40 10             	mov    0x10(%eax),%eax
80105a77:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a7a:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105a7e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a82:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a86:	c7 04 24 f1 8f 10 80 	movl   $0x80108ff1,(%esp)
80105a8d:	e8 0f a9 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105a92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a98:	8b 40 1c             	mov    0x1c(%eax),%eax
80105a9b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105aa2:	83 c4 24             	add    $0x24,%esp
80105aa5:	5b                   	pop    %ebx
80105aa6:	5d                   	pop    %ebp
80105aa7:	c3                   	ret    

80105aa8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105aa8:	55                   	push   %ebp
80105aa9:	89 e5                	mov    %esp,%ebp
80105aab:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105aae:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ab8:	89 04 24             	mov    %eax,(%esp)
80105abb:	e8 92 fe ff ff       	call   80105952 <argint>
80105ac0:	85 c0                	test   %eax,%eax
80105ac2:	79 07                	jns    80105acb <argfd+0x23>
    return -1;
80105ac4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac9:	eb 50                	jmp    80105b1b <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105acb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ace:	85 c0                	test   %eax,%eax
80105ad0:	78 21                	js     80105af3 <argfd+0x4b>
80105ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad5:	83 f8 0f             	cmp    $0xf,%eax
80105ad8:	7f 19                	jg     80105af3 <argfd+0x4b>
80105ada:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ae0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ae3:	83 c2 08             	add    $0x8,%edx
80105ae6:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105aea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105af1:	75 07                	jne    80105afa <argfd+0x52>
    return -1;
80105af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105af8:	eb 21                	jmp    80105b1b <argfd+0x73>
  if(pfd)
80105afa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105afe:	74 08                	je     80105b08 <argfd+0x60>
    *pfd = fd;
80105b00:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b03:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b06:	89 10                	mov    %edx,(%eax)
  if(pf)
80105b08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b0c:	74 08                	je     80105b16 <argfd+0x6e>
    *pf = f;
80105b0e:	8b 45 10             	mov    0x10(%ebp),%eax
80105b11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b14:	89 10                	mov    %edx,(%eax)
  return 0;
80105b16:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b1b:	c9                   	leave  
80105b1c:	c3                   	ret    

80105b1d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105b1d:	55                   	push   %ebp
80105b1e:	89 e5                	mov    %esp,%ebp
80105b20:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105b23:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105b2a:	eb 30                	jmp    80105b5c <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105b2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b32:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b35:	83 c2 08             	add    $0x8,%edx
80105b38:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105b3c:	85 c0                	test   %eax,%eax
80105b3e:	75 18                	jne    80105b58 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105b40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b46:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b49:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b4c:	8b 55 08             	mov    0x8(%ebp),%edx
80105b4f:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      return fd;
80105b53:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b56:	eb 0f                	jmp    80105b67 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105b58:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105b5c:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105b60:	7e ca                	jle    80105b2c <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105b62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b67:	c9                   	leave  
80105b68:	c3                   	ret    

80105b69 <sys_dup>:

int
sys_dup(void)
{
80105b69:	55                   	push   %ebp
80105b6a:	89 e5                	mov    %esp,%ebp
80105b6c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105b6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b72:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b7d:	00 
80105b7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b85:	e8 1e ff ff ff       	call   80105aa8 <argfd>
80105b8a:	85 c0                	test   %eax,%eax
80105b8c:	79 07                	jns    80105b95 <sys_dup+0x2c>
    return -1;
80105b8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b93:	eb 29                	jmp    80105bbe <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b98:	89 04 24             	mov    %eax,(%esp)
80105b9b:	e8 7d ff ff ff       	call   80105b1d <fdalloc>
80105ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ba3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ba7:	79 07                	jns    80105bb0 <sys_dup+0x47>
    return -1;
80105ba9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bae:	eb 0e                	jmp    80105bbe <sys_dup+0x55>
  filedup(f);
80105bb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb3:	89 04 24             	mov    %eax,(%esp)
80105bb6:	e8 29 b4 ff ff       	call   80100fe4 <filedup>
  return fd;
80105bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105bbe:	c9                   	leave  
80105bbf:	c3                   	ret    

80105bc0 <sys_read>:

int
sys_read(void)
{
80105bc0:	55                   	push   %ebp
80105bc1:	89 e5                	mov    %esp,%ebp
80105bc3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105bc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bc9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bcd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105bd4:	00 
80105bd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bdc:	e8 c7 fe ff ff       	call   80105aa8 <argfd>
80105be1:	85 c0                	test   %eax,%eax
80105be3:	78 35                	js     80105c1a <sys_read+0x5a>
80105be5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105be8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bec:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105bf3:	e8 5a fd ff ff       	call   80105952 <argint>
80105bf8:	85 c0                	test   %eax,%eax
80105bfa:	78 1e                	js     80105c1a <sys_read+0x5a>
80105bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bff:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c03:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c06:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c11:	e8 6a fd ff ff       	call   80105980 <argptr>
80105c16:	85 c0                	test   %eax,%eax
80105c18:	79 07                	jns    80105c21 <sys_read+0x61>
    return -1;
80105c1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c1f:	eb 19                	jmp    80105c3a <sys_read+0x7a>
  return fileread(f, p, n);
80105c21:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c24:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c2a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105c2e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c32:	89 04 24             	mov    %eax,(%esp)
80105c35:	e8 17 b5 ff ff       	call   80101151 <fileread>
}
80105c3a:	c9                   	leave  
80105c3b:	c3                   	ret    

80105c3c <sys_write>:

int
sys_write(void)
{
80105c3c:	55                   	push   %ebp
80105c3d:	89 e5                	mov    %esp,%ebp
80105c3f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c42:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c45:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c49:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c50:	00 
80105c51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c58:	e8 4b fe ff ff       	call   80105aa8 <argfd>
80105c5d:	85 c0                	test   %eax,%eax
80105c5f:	78 35                	js     80105c96 <sys_write+0x5a>
80105c61:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c64:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c68:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105c6f:	e8 de fc ff ff       	call   80105952 <argint>
80105c74:	85 c0                	test   %eax,%eax
80105c76:	78 1e                	js     80105c96 <sys_write+0x5a>
80105c78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c7f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c82:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c86:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105c8d:	e8 ee fc ff ff       	call   80105980 <argptr>
80105c92:	85 c0                	test   %eax,%eax
80105c94:	79 07                	jns    80105c9d <sys_write+0x61>
    return -1;
80105c96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c9b:	eb 19                	jmp    80105cb6 <sys_write+0x7a>
  return filewrite(f, p, n);
80105c9d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105ca0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105caa:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cae:	89 04 24             	mov    %eax,(%esp)
80105cb1:	e8 57 b5 ff ff       	call   8010120d <filewrite>
}
80105cb6:	c9                   	leave  
80105cb7:	c3                   	ret    

80105cb8 <sys_close>:

int
sys_close(void)
{
80105cb8:	55                   	push   %ebp
80105cb9:	89 e5                	mov    %esp,%ebp
80105cbb:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105cbe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cc1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ccc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cd3:	e8 d0 fd ff ff       	call   80105aa8 <argfd>
80105cd8:	85 c0                	test   %eax,%eax
80105cda:	79 07                	jns    80105ce3 <sys_close+0x2b>
    return -1;
80105cdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ce1:	eb 24                	jmp    80105d07 <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105ce3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ce9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cec:	83 c2 08             	add    $0x8,%edx
80105cef:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80105cf6:	00 
  fileclose(f);
80105cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cfa:	89 04 24             	mov    %eax,(%esp)
80105cfd:	e8 2a b3 ff ff       	call   8010102c <fileclose>
  return 0;
80105d02:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d07:	c9                   	leave  
80105d08:	c3                   	ret    

80105d09 <sys_fstat>:

int
sys_fstat(void)
{
80105d09:	55                   	push   %ebp
80105d0a:	89 e5                	mov    %esp,%ebp
80105d0c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105d0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d12:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d1d:	00 
80105d1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d25:	e8 7e fd ff ff       	call   80105aa8 <argfd>
80105d2a:	85 c0                	test   %eax,%eax
80105d2c:	78 1f                	js     80105d4d <sys_fstat+0x44>
80105d2e:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105d35:	00 
80105d36:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d39:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d44:	e8 37 fc ff ff       	call   80105980 <argptr>
80105d49:	85 c0                	test   %eax,%eax
80105d4b:	79 07                	jns    80105d54 <sys_fstat+0x4b>
    return -1;
80105d4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d52:	eb 12                	jmp    80105d66 <sys_fstat+0x5d>
  return filestat(f, st);
80105d54:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d5e:	89 04 24             	mov    %eax,(%esp)
80105d61:	e8 9c b3 ff ff       	call   80101102 <filestat>
}
80105d66:	c9                   	leave  
80105d67:	c3                   	ret    

80105d68 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105d68:	55                   	push   %ebp
80105d69:	89 e5                	mov    %esp,%ebp
80105d6b:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105d6e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105d71:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d7c:	e8 61 fc ff ff       	call   801059e2 <argstr>
80105d81:	85 c0                	test   %eax,%eax
80105d83:	78 17                	js     80105d9c <sys_link+0x34>
80105d85:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d88:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d93:	e8 4a fc ff ff       	call   801059e2 <argstr>
80105d98:	85 c0                	test   %eax,%eax
80105d9a:	79 0a                	jns    80105da6 <sys_link+0x3e>
    return -1;
80105d9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105da1:	e9 41 01 00 00       	jmp    80105ee7 <sys_link+0x17f>

  begin_op();
80105da6:	e8 12 d7 ff ff       	call   801034bd <begin_op>
  if((ip = namei(old)) == 0){
80105dab:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105dae:	89 04 24             	mov    %eax,(%esp)
80105db1:	e8 bc c6 ff ff       	call   80102472 <namei>
80105db6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105db9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dbd:	75 0f                	jne    80105dce <sys_link+0x66>
    end_op();
80105dbf:	e8 7a d7 ff ff       	call   8010353e <end_op>
    return -1;
80105dc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc9:	e9 19 01 00 00       	jmp    80105ee7 <sys_link+0x17f>
  }

  ilock(ip);
80105dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd1:	89 04 24             	mov    %eax,(%esp)
80105dd4:	e8 f7 ba ff ff       	call   801018d0 <ilock>
  if(ip->type == T_DIR){
80105dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105de0:	66 83 f8 01          	cmp    $0x1,%ax
80105de4:	75 1a                	jne    80105e00 <sys_link+0x98>
    iunlockput(ip);
80105de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105de9:	89 04 24             	mov    %eax,(%esp)
80105dec:	e8 63 bd ff ff       	call   80101b54 <iunlockput>
    end_op();
80105df1:	e8 48 d7 ff ff       	call   8010353e <end_op>
    return -1;
80105df6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dfb:	e9 e7 00 00 00       	jmp    80105ee7 <sys_link+0x17f>
  }

  ip->nlink++;
80105e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e03:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e07:	8d 50 01             	lea    0x1(%eax),%edx
80105e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e14:	89 04 24             	mov    %eax,(%esp)
80105e17:	e8 f8 b8 ff ff       	call   80101714 <iupdate>
  iunlock(ip);
80105e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1f:	89 04 24             	mov    %eax,(%esp)
80105e22:	e8 f7 bb ff ff       	call   80101a1e <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105e27:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105e2a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105e2d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e31:	89 04 24             	mov    %eax,(%esp)
80105e34:	e8 5b c6 ff ff       	call   80102494 <nameiparent>
80105e39:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e3c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e40:	74 68                	je     80105eaa <sys_link+0x142>
    goto bad;
  ilock(dp);
80105e42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e45:	89 04 24             	mov    %eax,(%esp)
80105e48:	e8 83 ba ff ff       	call   801018d0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e50:	8b 10                	mov    (%eax),%edx
80105e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e55:	8b 00                	mov    (%eax),%eax
80105e57:	39 c2                	cmp    %eax,%edx
80105e59:	75 20                	jne    80105e7b <sys_link+0x113>
80105e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5e:	8b 40 04             	mov    0x4(%eax),%eax
80105e61:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e65:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e68:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6f:	89 04 24             	mov    %eax,(%esp)
80105e72:	e8 3a c3 ff ff       	call   801021b1 <dirlink>
80105e77:	85 c0                	test   %eax,%eax
80105e79:	79 0d                	jns    80105e88 <sys_link+0x120>
    iunlockput(dp);
80105e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7e:	89 04 24             	mov    %eax,(%esp)
80105e81:	e8 ce bc ff ff       	call   80101b54 <iunlockput>
    goto bad;
80105e86:	eb 23                	jmp    80105eab <sys_link+0x143>
  }
  iunlockput(dp);
80105e88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8b:	89 04 24             	mov    %eax,(%esp)
80105e8e:	e8 c1 bc ff ff       	call   80101b54 <iunlockput>
  iput(ip);
80105e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e96:	89 04 24             	mov    %eax,(%esp)
80105e99:	e8 e5 bb ff ff       	call   80101a83 <iput>

  end_op();
80105e9e:	e8 9b d6 ff ff       	call   8010353e <end_op>

  return 0;
80105ea3:	b8 00 00 00 00       	mov    $0x0,%eax
80105ea8:	eb 3d                	jmp    80105ee7 <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105eaa:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eae:	89 04 24             	mov    %eax,(%esp)
80105eb1:	e8 1a ba ff ff       	call   801018d0 <ilock>
  ip->nlink--;
80105eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb9:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ebd:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec3:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eca:	89 04 24             	mov    %eax,(%esp)
80105ecd:	e8 42 b8 ff ff       	call   80101714 <iupdate>
  iunlockput(ip);
80105ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed5:	89 04 24             	mov    %eax,(%esp)
80105ed8:	e8 77 bc ff ff       	call   80101b54 <iunlockput>
  end_op();
80105edd:	e8 5c d6 ff ff       	call   8010353e <end_op>
  return -1;
80105ee2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ee7:	c9                   	leave  
80105ee8:	c3                   	ret    

80105ee9 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105ee9:	55                   	push   %ebp
80105eea:	89 e5                	mov    %esp,%ebp
80105eec:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eef:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ef6:	eb 4b                	jmp    80105f43 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105efb:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105f02:	00 
80105f03:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f07:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f0e:	8b 45 08             	mov    0x8(%ebp),%eax
80105f11:	89 04 24             	mov    %eax,(%esp)
80105f14:	e8 ad be ff ff       	call   80101dc6 <readi>
80105f19:	83 f8 10             	cmp    $0x10,%eax
80105f1c:	74 0c                	je     80105f2a <isdirempty+0x41>
      panic("isdirempty: readi");
80105f1e:	c7 04 24 0d 90 10 80 	movl   $0x8010900d,(%esp)
80105f25:	e8 13 a6 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105f2a:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105f2e:	66 85 c0             	test   %ax,%ax
80105f31:	74 07                	je     80105f3a <isdirempty+0x51>
      return 0;
80105f33:	b8 00 00 00 00       	mov    $0x0,%eax
80105f38:	eb 1b                	jmp    80105f55 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3d:	83 c0 10             	add    $0x10,%eax
80105f40:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f46:	8b 45 08             	mov    0x8(%ebp),%eax
80105f49:	8b 40 18             	mov    0x18(%eax),%eax
80105f4c:	39 c2                	cmp    %eax,%edx
80105f4e:	72 a8                	jb     80105ef8 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105f50:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105f55:	c9                   	leave  
80105f56:	c3                   	ret    

80105f57 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105f57:	55                   	push   %ebp
80105f58:	89 e5                	mov    %esp,%ebp
80105f5a:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105f5d:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f60:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f64:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f6b:	e8 72 fa ff ff       	call   801059e2 <argstr>
80105f70:	85 c0                	test   %eax,%eax
80105f72:	79 0a                	jns    80105f7e <sys_unlink+0x27>
    return -1;
80105f74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f79:	e9 af 01 00 00       	jmp    8010612d <sys_unlink+0x1d6>

  begin_op();
80105f7e:	e8 3a d5 ff ff       	call   801034bd <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f83:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f86:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f89:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f8d:	89 04 24             	mov    %eax,(%esp)
80105f90:	e8 ff c4 ff ff       	call   80102494 <nameiparent>
80105f95:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f98:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f9c:	75 0f                	jne    80105fad <sys_unlink+0x56>
    end_op();
80105f9e:	e8 9b d5 ff ff       	call   8010353e <end_op>
    return -1;
80105fa3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa8:	e9 80 01 00 00       	jmp    8010612d <sys_unlink+0x1d6>
  }

  ilock(dp);
80105fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb0:	89 04 24             	mov    %eax,(%esp)
80105fb3:	e8 18 b9 ff ff       	call   801018d0 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105fb8:	c7 44 24 04 1f 90 10 	movl   $0x8010901f,0x4(%esp)
80105fbf:	80 
80105fc0:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fc3:	89 04 24             	mov    %eax,(%esp)
80105fc6:	e8 fc c0 ff ff       	call   801020c7 <namecmp>
80105fcb:	85 c0                	test   %eax,%eax
80105fcd:	0f 84 45 01 00 00    	je     80106118 <sys_unlink+0x1c1>
80105fd3:	c7 44 24 04 21 90 10 	movl   $0x80109021,0x4(%esp)
80105fda:	80 
80105fdb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105fde:	89 04 24             	mov    %eax,(%esp)
80105fe1:	e8 e1 c0 ff ff       	call   801020c7 <namecmp>
80105fe6:	85 c0                	test   %eax,%eax
80105fe8:	0f 84 2a 01 00 00    	je     80106118 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105fee:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ff1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ff5:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fff:	89 04 24             	mov    %eax,(%esp)
80106002:	e8 e2 c0 ff ff       	call   801020e9 <dirlookup>
80106007:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010600a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010600e:	0f 84 03 01 00 00    	je     80106117 <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
80106014:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106017:	89 04 24             	mov    %eax,(%esp)
8010601a:	e8 b1 b8 ff ff       	call   801018d0 <ilock>

  if(ip->nlink < 1)
8010601f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106022:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106026:	66 85 c0             	test   %ax,%ax
80106029:	7f 0c                	jg     80106037 <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
8010602b:	c7 04 24 24 90 10 80 	movl   $0x80109024,(%esp)
80106032:	e8 06 a5 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010603e:	66 83 f8 01          	cmp    $0x1,%ax
80106042:	75 1f                	jne    80106063 <sys_unlink+0x10c>
80106044:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106047:	89 04 24             	mov    %eax,(%esp)
8010604a:	e8 9a fe ff ff       	call   80105ee9 <isdirempty>
8010604f:	85 c0                	test   %eax,%eax
80106051:	75 10                	jne    80106063 <sys_unlink+0x10c>
    iunlockput(ip);
80106053:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106056:	89 04 24             	mov    %eax,(%esp)
80106059:	e8 f6 ba ff ff       	call   80101b54 <iunlockput>
    goto bad;
8010605e:	e9 b5 00 00 00       	jmp    80106118 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80106063:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010606a:	00 
8010606b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106072:	00 
80106073:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106076:	89 04 24             	mov    %eax,(%esp)
80106079:	e8 78 f5 ff ff       	call   801055f6 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010607e:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106081:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106088:	00 
80106089:	89 44 24 08          	mov    %eax,0x8(%esp)
8010608d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106090:	89 44 24 04          	mov    %eax,0x4(%esp)
80106094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106097:	89 04 24             	mov    %eax,(%esp)
8010609a:	e8 92 be ff ff       	call   80101f31 <writei>
8010609f:	83 f8 10             	cmp    $0x10,%eax
801060a2:	74 0c                	je     801060b0 <sys_unlink+0x159>
    panic("unlink: writei");
801060a4:	c7 04 24 36 90 10 80 	movl   $0x80109036,(%esp)
801060ab:	e8 8d a4 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
801060b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060b7:	66 83 f8 01          	cmp    $0x1,%ax
801060bb:	75 1c                	jne    801060d9 <sys_unlink+0x182>
    dp->nlink--;
801060bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060c4:	8d 50 ff             	lea    -0x1(%eax),%edx
801060c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ca:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
801060ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d1:	89 04 24             	mov    %eax,(%esp)
801060d4:	e8 3b b6 ff ff       	call   80101714 <iupdate>
  }
  iunlockput(dp);
801060d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060dc:	89 04 24             	mov    %eax,(%esp)
801060df:	e8 70 ba ff ff       	call   80101b54 <iunlockput>

  ip->nlink--;
801060e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801060eb:	8d 50 ff             	lea    -0x1(%eax),%edx
801060ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f1:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801060f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f8:	89 04 24             	mov    %eax,(%esp)
801060fb:	e8 14 b6 ff ff       	call   80101714 <iupdate>
  iunlockput(ip);
80106100:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106103:	89 04 24             	mov    %eax,(%esp)
80106106:	e8 49 ba ff ff       	call   80101b54 <iunlockput>

  end_op();
8010610b:	e8 2e d4 ff ff       	call   8010353e <end_op>

  return 0;
80106110:	b8 00 00 00 00       	mov    $0x0,%eax
80106115:	eb 16                	jmp    8010612d <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80106117:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80106118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010611b:	89 04 24             	mov    %eax,(%esp)
8010611e:	e8 31 ba ff ff       	call   80101b54 <iunlockput>
  end_op();
80106123:	e8 16 d4 ff ff       	call   8010353e <end_op>
  return -1;
80106128:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010612d:	c9                   	leave  
8010612e:	c3                   	ret    

8010612f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010612f:	55                   	push   %ebp
80106130:	89 e5                	mov    %esp,%ebp
80106132:	83 ec 48             	sub    $0x48,%esp
80106135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106138:	8b 55 10             	mov    0x10(%ebp),%edx
8010613b:	8b 45 14             	mov    0x14(%ebp),%eax
8010613e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106142:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106146:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010614a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010614d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106151:	8b 45 08             	mov    0x8(%ebp),%eax
80106154:	89 04 24             	mov    %eax,(%esp)
80106157:	e8 38 c3 ff ff       	call   80102494 <nameiparent>
8010615c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010615f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106163:	75 0a                	jne    8010616f <create+0x40>
    return 0;
80106165:	b8 00 00 00 00       	mov    $0x0,%eax
8010616a:	e9 7e 01 00 00       	jmp    801062ed <create+0x1be>
  ilock(dp);
8010616f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106172:	89 04 24             	mov    %eax,(%esp)
80106175:	e8 56 b7 ff ff       	call   801018d0 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010617a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010617d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106181:	8d 45 de             	lea    -0x22(%ebp),%eax
80106184:	89 44 24 04          	mov    %eax,0x4(%esp)
80106188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010618b:	89 04 24             	mov    %eax,(%esp)
8010618e:	e8 56 bf ff ff       	call   801020e9 <dirlookup>
80106193:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106196:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010619a:	74 47                	je     801061e3 <create+0xb4>
    iunlockput(dp);
8010619c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619f:	89 04 24             	mov    %eax,(%esp)
801061a2:	e8 ad b9 ff ff       	call   80101b54 <iunlockput>
    ilock(ip);
801061a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061aa:	89 04 24             	mov    %eax,(%esp)
801061ad:	e8 1e b7 ff ff       	call   801018d0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801061b2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801061b7:	75 15                	jne    801061ce <create+0x9f>
801061b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061bc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801061c0:	66 83 f8 02          	cmp    $0x2,%ax
801061c4:	75 08                	jne    801061ce <create+0x9f>
      return ip;
801061c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c9:	e9 1f 01 00 00       	jmp    801062ed <create+0x1be>
    iunlockput(ip);
801061ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d1:	89 04 24             	mov    %eax,(%esp)
801061d4:	e8 7b b9 ff ff       	call   80101b54 <iunlockput>
    return 0;
801061d9:	b8 00 00 00 00       	mov    $0x0,%eax
801061de:	e9 0a 01 00 00       	jmp    801062ed <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801061e3:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801061e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ea:	8b 00                	mov    (%eax),%eax
801061ec:	89 54 24 04          	mov    %edx,0x4(%esp)
801061f0:	89 04 24             	mov    %eax,(%esp)
801061f3:	e8 3f b4 ff ff       	call   80101637 <ialloc>
801061f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061ff:	75 0c                	jne    8010620d <create+0xde>
    panic("create: ialloc");
80106201:	c7 04 24 45 90 10 80 	movl   $0x80109045,(%esp)
80106208:	e8 30 a3 ff ff       	call   8010053d <panic>

  ilock(ip);
8010620d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106210:	89 04 24             	mov    %eax,(%esp)
80106213:	e8 b8 b6 ff ff       	call   801018d0 <ilock>
  ip->major = major;
80106218:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010621b:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010621f:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106223:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106226:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010622a:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
8010622e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106231:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106237:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010623a:	89 04 24             	mov    %eax,(%esp)
8010623d:	e8 d2 b4 ff ff       	call   80101714 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106242:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106247:	75 6a                	jne    801062b3 <create+0x184>
    dp->nlink++;  // for ".."
80106249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010624c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106250:	8d 50 01             	lea    0x1(%eax),%edx
80106253:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106256:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010625a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010625d:	89 04 24             	mov    %eax,(%esp)
80106260:	e8 af b4 ff ff       	call   80101714 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106265:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106268:	8b 40 04             	mov    0x4(%eax),%eax
8010626b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010626f:	c7 44 24 04 1f 90 10 	movl   $0x8010901f,0x4(%esp)
80106276:	80 
80106277:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010627a:	89 04 24             	mov    %eax,(%esp)
8010627d:	e8 2f bf ff ff       	call   801021b1 <dirlink>
80106282:	85 c0                	test   %eax,%eax
80106284:	78 21                	js     801062a7 <create+0x178>
80106286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106289:	8b 40 04             	mov    0x4(%eax),%eax
8010628c:	89 44 24 08          	mov    %eax,0x8(%esp)
80106290:	c7 44 24 04 21 90 10 	movl   $0x80109021,0x4(%esp)
80106297:	80 
80106298:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010629b:	89 04 24             	mov    %eax,(%esp)
8010629e:	e8 0e bf ff ff       	call   801021b1 <dirlink>
801062a3:	85 c0                	test   %eax,%eax
801062a5:	79 0c                	jns    801062b3 <create+0x184>
      panic("create dots");
801062a7:	c7 04 24 54 90 10 80 	movl   $0x80109054,(%esp)
801062ae:	e8 8a a2 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801062b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b6:	8b 40 04             	mov    0x4(%eax),%eax
801062b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801062bd:	8d 45 de             	lea    -0x22(%ebp),%eax
801062c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c7:	89 04 24             	mov    %eax,(%esp)
801062ca:	e8 e2 be ff ff       	call   801021b1 <dirlink>
801062cf:	85 c0                	test   %eax,%eax
801062d1:	79 0c                	jns    801062df <create+0x1b0>
    panic("create: dirlink");
801062d3:	c7 04 24 60 90 10 80 	movl   $0x80109060,(%esp)
801062da:	e8 5e a2 ff ff       	call   8010053d <panic>

  iunlockput(dp);
801062df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e2:	89 04 24             	mov    %eax,(%esp)
801062e5:	e8 6a b8 ff ff       	call   80101b54 <iunlockput>

  return ip;
801062ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062ed:	c9                   	leave  
801062ee:	c3                   	ret    

801062ef <sys_open>:

int
sys_open(void)
{
801062ef:	55                   	push   %ebp
801062f0:	89 e5                	mov    %esp,%ebp
801062f2:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062f5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801062fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106303:	e8 da f6 ff ff       	call   801059e2 <argstr>
80106308:	85 c0                	test   %eax,%eax
8010630a:	78 17                	js     80106323 <sys_open+0x34>
8010630c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010630f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106313:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010631a:	e8 33 f6 ff ff       	call   80105952 <argint>
8010631f:	85 c0                	test   %eax,%eax
80106321:	79 0a                	jns    8010632d <sys_open+0x3e>
    return -1;
80106323:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106328:	e9 5a 01 00 00       	jmp    80106487 <sys_open+0x198>

  begin_op();
8010632d:	e8 8b d1 ff ff       	call   801034bd <begin_op>

  if(omode & O_CREATE){
80106332:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106335:	25 00 02 00 00       	and    $0x200,%eax
8010633a:	85 c0                	test   %eax,%eax
8010633c:	74 3b                	je     80106379 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010633e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106341:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106348:	00 
80106349:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106350:	00 
80106351:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106358:	00 
80106359:	89 04 24             	mov    %eax,(%esp)
8010635c:	e8 ce fd ff ff       	call   8010612f <create>
80106361:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106364:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106368:	75 6b                	jne    801063d5 <sys_open+0xe6>
      end_op();
8010636a:	e8 cf d1 ff ff       	call   8010353e <end_op>
      return -1;
8010636f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106374:	e9 0e 01 00 00       	jmp    80106487 <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
80106379:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010637c:	89 04 24             	mov    %eax,(%esp)
8010637f:	e8 ee c0 ff ff       	call   80102472 <namei>
80106384:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106387:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010638b:	75 0f                	jne    8010639c <sys_open+0xad>
      end_op();
8010638d:	e8 ac d1 ff ff       	call   8010353e <end_op>
      return -1;
80106392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106397:	e9 eb 00 00 00       	jmp    80106487 <sys_open+0x198>
    }
    ilock(ip);
8010639c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639f:	89 04 24             	mov    %eax,(%esp)
801063a2:	e8 29 b5 ff ff       	call   801018d0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801063a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063aa:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801063ae:	66 83 f8 01          	cmp    $0x1,%ax
801063b2:	75 21                	jne    801063d5 <sys_open+0xe6>
801063b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063b7:	85 c0                	test   %eax,%eax
801063b9:	74 1a                	je     801063d5 <sys_open+0xe6>
      iunlockput(ip);
801063bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063be:	89 04 24             	mov    %eax,(%esp)
801063c1:	e8 8e b7 ff ff       	call   80101b54 <iunlockput>
      end_op();
801063c6:	e8 73 d1 ff ff       	call   8010353e <end_op>
      return -1;
801063cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d0:	e9 b2 00 00 00       	jmp    80106487 <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801063d5:	e8 aa ab ff ff       	call   80100f84 <filealloc>
801063da:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063e1:	74 14                	je     801063f7 <sys_open+0x108>
801063e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063e6:	89 04 24             	mov    %eax,(%esp)
801063e9:	e8 2f f7 ff ff       	call   80105b1d <fdalloc>
801063ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063f5:	79 28                	jns    8010641f <sys_open+0x130>
    if(f)
801063f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063fb:	74 0b                	je     80106408 <sys_open+0x119>
      fileclose(f);
801063fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106400:	89 04 24             	mov    %eax,(%esp)
80106403:	e8 24 ac ff ff       	call   8010102c <fileclose>
    iunlockput(ip);
80106408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640b:	89 04 24             	mov    %eax,(%esp)
8010640e:	e8 41 b7 ff ff       	call   80101b54 <iunlockput>
    end_op();
80106413:	e8 26 d1 ff ff       	call   8010353e <end_op>
    return -1;
80106418:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641d:	eb 68                	jmp    80106487 <sys_open+0x198>
  }
  iunlock(ip);
8010641f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106422:	89 04 24             	mov    %eax,(%esp)
80106425:	e8 f4 b5 ff ff       	call   80101a1e <iunlock>
  end_op();
8010642a:	e8 0f d1 ff ff       	call   8010353e <end_op>

  f->type = FD_INODE;
8010642f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106432:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010643b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010643e:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106444:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
8010644b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010644e:	83 e0 01             	and    $0x1,%eax
80106451:	85 c0                	test   %eax,%eax
80106453:	0f 94 c2             	sete   %dl
80106456:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106459:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010645c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010645f:	83 e0 01             	and    $0x1,%eax
80106462:	84 c0                	test   %al,%al
80106464:	75 0a                	jne    80106470 <sys_open+0x181>
80106466:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106469:	83 e0 02             	and    $0x2,%eax
8010646c:	85 c0                	test   %eax,%eax
8010646e:	74 07                	je     80106477 <sys_open+0x188>
80106470:	b8 01 00 00 00       	mov    $0x1,%eax
80106475:	eb 05                	jmp    8010647c <sys_open+0x18d>
80106477:	b8 00 00 00 00       	mov    $0x0,%eax
8010647c:	89 c2                	mov    %eax,%edx
8010647e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106481:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106484:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106487:	c9                   	leave  
80106488:	c3                   	ret    

80106489 <sys_mkdir>:

int
sys_mkdir(void)
{
80106489:	55                   	push   %ebp
8010648a:	89 e5                	mov    %esp,%ebp
8010648c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010648f:	e8 29 d0 ff ff       	call   801034bd <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106494:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106497:	89 44 24 04          	mov    %eax,0x4(%esp)
8010649b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064a2:	e8 3b f5 ff ff       	call   801059e2 <argstr>
801064a7:	85 c0                	test   %eax,%eax
801064a9:	78 2c                	js     801064d7 <sys_mkdir+0x4e>
801064ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801064b5:	00 
801064b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801064bd:	00 
801064be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801064c5:	00 
801064c6:	89 04 24             	mov    %eax,(%esp)
801064c9:	e8 61 fc ff ff       	call   8010612f <create>
801064ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064d5:	75 0c                	jne    801064e3 <sys_mkdir+0x5a>
    end_op();
801064d7:	e8 62 d0 ff ff       	call   8010353e <end_op>
    return -1;
801064dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e1:	eb 15                	jmp    801064f8 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801064e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e6:	89 04 24             	mov    %eax,(%esp)
801064e9:	e8 66 b6 ff ff       	call   80101b54 <iunlockput>
  end_op();
801064ee:	e8 4b d0 ff ff       	call   8010353e <end_op>
  return 0;
801064f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064f8:	c9                   	leave  
801064f9:	c3                   	ret    

801064fa <sys_mknod>:

int
sys_mknod(void)
{
801064fa:	55                   	push   %ebp
801064fb:	89 e5                	mov    %esp,%ebp
801064fd:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106500:	e8 b8 cf ff ff       	call   801034bd <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106505:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106508:	89 44 24 04          	mov    %eax,0x4(%esp)
8010650c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106513:	e8 ca f4 ff ff       	call   801059e2 <argstr>
80106518:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010651b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010651f:	78 5e                	js     8010657f <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106521:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106524:	89 44 24 04          	mov    %eax,0x4(%esp)
80106528:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010652f:	e8 1e f4 ff ff       	call   80105952 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106534:	85 c0                	test   %eax,%eax
80106536:	78 47                	js     8010657f <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106538:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010653b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010653f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106546:	e8 07 f4 ff ff       	call   80105952 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010654b:	85 c0                	test   %eax,%eax
8010654d:	78 30                	js     8010657f <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010654f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106552:	0f bf c8             	movswl %ax,%ecx
80106555:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106558:	0f bf d0             	movswl %ax,%edx
8010655b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010655e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106562:	89 54 24 08          	mov    %edx,0x8(%esp)
80106566:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010656d:	00 
8010656e:	89 04 24             	mov    %eax,(%esp)
80106571:	e8 b9 fb ff ff       	call   8010612f <create>
80106576:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106579:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010657d:	75 0c                	jne    8010658b <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010657f:	e8 ba cf ff ff       	call   8010353e <end_op>
    return -1;
80106584:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106589:	eb 15                	jmp    801065a0 <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010658b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010658e:	89 04 24             	mov    %eax,(%esp)
80106591:	e8 be b5 ff ff       	call   80101b54 <iunlockput>
  end_op();
80106596:	e8 a3 cf ff ff       	call   8010353e <end_op>
  return 0;
8010659b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065a0:	c9                   	leave  
801065a1:	c3                   	ret    

801065a2 <sys_chdir>:

int
sys_chdir(void)
{
801065a2:	55                   	push   %ebp
801065a3:	89 e5                	mov    %esp,%ebp
801065a5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801065a8:	e8 10 cf ff ff       	call   801034bd <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801065ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065b0:	89 44 24 04          	mov    %eax,0x4(%esp)
801065b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065bb:	e8 22 f4 ff ff       	call   801059e2 <argstr>
801065c0:	85 c0                	test   %eax,%eax
801065c2:	78 14                	js     801065d8 <sys_chdir+0x36>
801065c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c7:	89 04 24             	mov    %eax,(%esp)
801065ca:	e8 a3 be ff ff       	call   80102472 <namei>
801065cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065d6:	75 0c                	jne    801065e4 <sys_chdir+0x42>
    end_op();
801065d8:	e8 61 cf ff ff       	call   8010353e <end_op>
    return -1;
801065dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e2:	eb 61                	jmp    80106645 <sys_chdir+0xa3>
  }
  ilock(ip);
801065e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e7:	89 04 24             	mov    %eax,(%esp)
801065ea:	e8 e1 b2 ff ff       	call   801018d0 <ilock>
  if(ip->type != T_DIR){
801065ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801065f6:	66 83 f8 01          	cmp    $0x1,%ax
801065fa:	74 17                	je     80106613 <sys_chdir+0x71>
    iunlockput(ip);
801065fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ff:	89 04 24             	mov    %eax,(%esp)
80106602:	e8 4d b5 ff ff       	call   80101b54 <iunlockput>
    end_op();
80106607:	e8 32 cf ff ff       	call   8010353e <end_op>
    return -1;
8010660c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106611:	eb 32                	jmp    80106645 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106616:	89 04 24             	mov    %eax,(%esp)
80106619:	e8 00 b4 ff ff       	call   80101a1e <iunlock>
  iput(proc->cwd);
8010661e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106624:	8b 40 6c             	mov    0x6c(%eax),%eax
80106627:	89 04 24             	mov    %eax,(%esp)
8010662a:	e8 54 b4 ff ff       	call   80101a83 <iput>
  end_op();
8010662f:	e8 0a cf ff ff       	call   8010353e <end_op>
  proc->cwd = ip;
80106634:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010663a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010663d:	89 50 6c             	mov    %edx,0x6c(%eax)
  return 0;
80106640:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106645:	c9                   	leave  
80106646:	c3                   	ret    

80106647 <sys_exec>:

int
sys_exec(void)
{
80106647:	55                   	push   %ebp
80106648:	89 e5                	mov    %esp,%ebp
8010664a:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106650:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106653:	89 44 24 04          	mov    %eax,0x4(%esp)
80106657:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010665e:	e8 7f f3 ff ff       	call   801059e2 <argstr>
80106663:	85 c0                	test   %eax,%eax
80106665:	78 1a                	js     80106681 <sys_exec+0x3a>
80106667:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010666d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106671:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106678:	e8 d5 f2 ff ff       	call   80105952 <argint>
8010667d:	85 c0                	test   %eax,%eax
8010667f:	79 0a                	jns    8010668b <sys_exec+0x44>
    return -1;
80106681:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106686:	e9 cc 00 00 00       	jmp    80106757 <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
8010668b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106692:	00 
80106693:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010669a:	00 
8010669b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066a1:	89 04 24             	mov    %eax,(%esp)
801066a4:	e8 4d ef ff ff       	call   801055f6 <memset>
  for(i=0;; i++){
801066a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801066b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b3:	83 f8 1f             	cmp    $0x1f,%eax
801066b6:	76 0a                	jbe    801066c2 <sys_exec+0x7b>
      return -1;
801066b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066bd:	e9 95 00 00 00       	jmp    80106757 <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801066c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c5:	c1 e0 02             	shl    $0x2,%eax
801066c8:	89 c2                	mov    %eax,%edx
801066ca:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801066d0:	01 c2                	add    %eax,%edx
801066d2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801066d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801066dc:	89 14 24             	mov    %edx,(%esp)
801066df:	e8 d0 f1 ff ff       	call   801058b4 <fetchint>
801066e4:	85 c0                	test   %eax,%eax
801066e6:	79 07                	jns    801066ef <sys_exec+0xa8>
      return -1;
801066e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ed:	eb 68                	jmp    80106757 <sys_exec+0x110>
    if(uarg == 0){
801066ef:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066f5:	85 c0                	test   %eax,%eax
801066f7:	75 26                	jne    8010671f <sys_exec+0xd8>
      argv[i] = 0;
801066f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066fc:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106703:	00 00 00 00 
      break;
80106707:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106708:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010670b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106711:	89 54 24 04          	mov    %edx,0x4(%esp)
80106715:	89 04 24             	mov    %eax,(%esp)
80106718:	e8 df a3 ff ff       	call   80100afc <exec>
8010671d:	eb 38                	jmp    80106757 <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010671f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106722:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106729:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010672f:	01 c2                	add    %eax,%edx
80106731:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106737:	89 54 24 04          	mov    %edx,0x4(%esp)
8010673b:	89 04 24             	mov    %eax,(%esp)
8010673e:	e8 ab f1 ff ff       	call   801058ee <fetchstr>
80106743:	85 c0                	test   %eax,%eax
80106745:	79 07                	jns    8010674e <sys_exec+0x107>
      return -1;
80106747:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674c:	eb 09                	jmp    80106757 <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010674e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106752:	e9 59 ff ff ff       	jmp    801066b0 <sys_exec+0x69>
  return exec(path, argv);
}
80106757:	c9                   	leave  
80106758:	c3                   	ret    

80106759 <sys_pipe>:

int
sys_pipe(void)
{
80106759:	55                   	push   %ebp
8010675a:	89 e5                	mov    %esp,%ebp
8010675c:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010675f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106766:	00 
80106767:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010676a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010676e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106775:	e8 06 f2 ff ff       	call   80105980 <argptr>
8010677a:	85 c0                	test   %eax,%eax
8010677c:	79 0a                	jns    80106788 <sys_pipe+0x2f>
    return -1;
8010677e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106783:	e9 9b 00 00 00       	jmp    80106823 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106788:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010678b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010678f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106792:	89 04 24             	mov    %eax,(%esp)
80106795:	e8 52 d8 ff ff       	call   80103fec <pipealloc>
8010679a:	85 c0                	test   %eax,%eax
8010679c:	79 07                	jns    801067a5 <sys_pipe+0x4c>
    return -1;
8010679e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a3:	eb 7e                	jmp    80106823 <sys_pipe+0xca>
  fd0 = -1;
801067a5:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801067ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067af:	89 04 24             	mov    %eax,(%esp)
801067b2:	e8 66 f3 ff ff       	call   80105b1d <fdalloc>
801067b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067be:	78 14                	js     801067d4 <sys_pipe+0x7b>
801067c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067c3:	89 04 24             	mov    %eax,(%esp)
801067c6:	e8 52 f3 ff ff       	call   80105b1d <fdalloc>
801067cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801067ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067d2:	79 37                	jns    8010680b <sys_pipe+0xb2>
    if(fd0 >= 0)
801067d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067d8:	78 14                	js     801067ee <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801067da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801067e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067e3:	83 c2 08             	add    $0x8,%edx
801067e6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
801067ed:	00 
    fileclose(rf);
801067ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
801067f1:	89 04 24             	mov    %eax,(%esp)
801067f4:	e8 33 a8 ff ff       	call   8010102c <fileclose>
    fileclose(wf);
801067f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067fc:	89 04 24             	mov    %eax,(%esp)
801067ff:	e8 28 a8 ff ff       	call   8010102c <fileclose>
    return -1;
80106804:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106809:	eb 18                	jmp    80106823 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010680b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010680e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106811:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106813:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106816:	8d 50 04             	lea    0x4(%eax),%edx
80106819:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010681c:	89 02                	mov    %eax,(%edx)
  return 0;
8010681e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106823:	c9                   	leave  
80106824:	c3                   	ret    
80106825:	00 00                	add    %al,(%eax)
	...

80106828 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106828:	55                   	push   %ebp
80106829:	89 e5                	mov    %esp,%ebp
8010682b:	83 ec 08             	sub    $0x8,%esp
  return fork();
8010682e:	e8 7f de ff ff       	call   801046b2 <fork>
}
80106833:	c9                   	leave  
80106834:	c3                   	ret    

80106835 <sys_exit>:

int
sys_exit(void)
{
80106835:	55                   	push   %ebp
80106836:	89 e5                	mov    %esp,%ebp
80106838:	83 ec 28             	sub    $0x28,%esp
	int status;
	if(argint(0, &status) < 0)
8010683b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010683e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106842:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106849:	e8 04 f1 ff ff       	call   80105952 <argint>
8010684e:	85 c0                	test   %eax,%eax
80106850:	79 07                	jns    80106859 <sys_exit+0x24>
	    return -1;
80106852:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106857:	eb 10                	jmp    80106869 <sys_exit+0x34>

	exit(status);
80106859:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685c:	89 04 24             	mov    %eax,(%esp)
8010685f:	e8 f4 df ff ff       	call   80104858 <exit>
	return 0;  // not reached
80106864:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106869:	c9                   	leave  
8010686a:	c3                   	ret    

8010686b <sys_wait>:

int
sys_wait(void)
{
8010686b:	55                   	push   %ebp
8010686c:	89 e5                	mov    %esp,%ebp
8010686e:	83 ec 28             	sub    $0x28,%esp
	int* status;
	//take argument from environment
	if(argptr(0,(char**)&status, sizeof(int)) <0){ //error check
80106871:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106878:	00 
80106879:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010687c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106880:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106887:	e8 f4 f0 ff ff       	call   80105980 <argptr>
8010688c:	85 c0                	test   %eax,%eax
8010688e:	79 07                	jns    80106897 <sys_wait+0x2c>
		return -1;
80106890:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106895:	eb 0b                	jmp    801068a2 <sys_wait+0x37>
	}
	return wait(status);
80106897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010689a:	89 04 24             	mov    %eax,(%esp)
8010689d:	e8 fc e0 ff ff       	call   8010499e <wait>
}
801068a2:	c9                   	leave  
801068a3:	c3                   	ret    

801068a4 <sys_waitpid>:

int
sys_waitpid(void)
{
801068a4:	55                   	push   %ebp
801068a5:	89 e5                	mov    %esp,%ebp
801068a7:	83 ec 28             	sub    $0x28,%esp
	int pid;
	int *status;
	int options;

	if (	(argint(0, &pid) < 0) ||
801068aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801068ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801068b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068b8:	e8 95 f0 ff ff       	call   80105952 <argint>
801068bd:	85 c0                	test   %eax,%eax
801068bf:	78 36                	js     801068f7 <sys_waitpid+0x53>
			(argptr(1,(char**)&status, sizeof(int)) < 0) ||
801068c1:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801068c8:	00 
801068c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801068d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801068d7:	e8 a4 f0 ff ff       	call   80105980 <argptr>
{
	int pid;
	int *status;
	int options;

	if (	(argint(0, &pid) < 0) ||
801068dc:	85 c0                	test   %eax,%eax
801068de:	78 17                	js     801068f7 <sys_waitpid+0x53>
			(argptr(1,(char**)&status, sizeof(int)) < 0) ||
			(argint(2, &options) < 0) ){
801068e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801068e7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801068ee:	e8 5f f0 ff ff       	call   80105952 <argint>
	int pid;
	int *status;
	int options;

	if (	(argint(0, &pid) < 0) ||
			(argptr(1,(char**)&status, sizeof(int)) < 0) ||
801068f3:	85 c0                	test   %eax,%eax
801068f5:	79 07                	jns    801068fe <sys_waitpid+0x5a>
			(argint(2, &options) < 0) ){

		return -1;
801068f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068fc:	eb 19                	jmp    80106917 <sys_waitpid+0x73>
	}

	return waitpid(pid, status, options);
801068fe:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106901:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106907:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010690b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010690f:	89 04 24             	mov    %eax,(%esp)
80106912:	e8 7c e2 ff ff       	call   80104b93 <waitpid>
}
80106917:	c9                   	leave  
80106918:	c3                   	ret    

80106919 <sys_wait_stat>:

int
sys_wait_stat(void)
{
80106919:	55                   	push   %ebp
8010691a:	89 e5                	mov    %esp,%ebp
8010691c:	83 ec 28             	sub    $0x28,%esp
	int *wtime, *rtime, *iotime;

	if (	(argptr(0,(char**)&wtime, sizeof(int)) < 0) ||
8010691f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106926:	00 
80106927:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010692a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010692e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106935:	e8 46 f0 ff ff       	call   80105980 <argptr>
8010693a:	85 c0                	test   %eax,%eax
8010693c:	78 3e                	js     8010697c <sys_wait_stat+0x63>
			(argptr(1,(char**)&rtime, sizeof(int)) < 0) ||
8010693e:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106945:	00 
80106946:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106949:	89 44 24 04          	mov    %eax,0x4(%esp)
8010694d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106954:	e8 27 f0 ff ff       	call   80105980 <argptr>
int
sys_wait_stat(void)
{
	int *wtime, *rtime, *iotime;

	if (	(argptr(0,(char**)&wtime, sizeof(int)) < 0) ||
80106959:	85 c0                	test   %eax,%eax
8010695b:	78 1f                	js     8010697c <sys_wait_stat+0x63>
			(argptr(1,(char**)&rtime, sizeof(int)) < 0) ||
			(argptr(2,(char**)&iotime, sizeof(int)) < 0) ){
8010695d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80106964:	00 
80106965:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106968:	89 44 24 04          	mov    %eax,0x4(%esp)
8010696c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106973:	e8 08 f0 ff ff       	call   80105980 <argptr>
sys_wait_stat(void)
{
	int *wtime, *rtime, *iotime;

	if (	(argptr(0,(char**)&wtime, sizeof(int)) < 0) ||
			(argptr(1,(char**)&rtime, sizeof(int)) < 0) ||
80106978:	85 c0                	test   %eax,%eax
8010697a:	79 07                	jns    80106983 <sys_wait_stat+0x6a>
			(argptr(2,(char**)&iotime, sizeof(int)) < 0) ){

		return -1;
8010697c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106981:	eb 19                	jmp    8010699c <sys_wait_stat+0x83>
	}

	return wait_stat(wtime, rtime, iotime);
80106983:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106986:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010698c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106990:	89 54 24 04          	mov    %edx,0x4(%esp)
80106994:	89 04 24             	mov    %eax,(%esp)
80106997:	e8 7a e3 ff ff       	call   80104d16 <wait_stat>
}
8010699c:	c9                   	leave  
8010699d:	c3                   	ret    

8010699e <sys_list_pgroup>:

int
sys_list_pgroup(void)
{
8010699e:	55                   	push   %ebp
8010699f:	89 e5                	mov    %esp,%ebp
801069a1:	83 ec 28             	sub    $0x28,%esp
	int gid;
	process_info_entry* arr;
	int* size;

	if (	(argint(0, &gid) < 0) ||
801069a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801069ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069b2:	e8 9b ef ff ff       	call   80105952 <argint>
801069b7:	85 c0                	test   %eax,%eax
801069b9:	78 3e                	js     801069f9 <sys_list_pgroup+0x5b>
			(argptr(1,(char**)&arr, sizeof(process_info_entry)) < 0) ||
801069bb:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801069c2:	00 
801069c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801069ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801069d1:	e8 aa ef ff ff       	call   80105980 <argptr>
{
	int gid;
	process_info_entry* arr;
	int* size;

	if (	(argint(0, &gid) < 0) ||
801069d6:	85 c0                	test   %eax,%eax
801069d8:	78 1f                	js     801069f9 <sys_list_pgroup+0x5b>
			(argptr(1,(char**)&arr, sizeof(process_info_entry)) < 0) ||
			(argptr(2,(char**)&size, sizeof(int)) < 0)){
801069da:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801069e1:	00 
801069e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801069e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801069e9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801069f0:	e8 8b ef ff ff       	call   80105980 <argptr>
	int gid;
	process_info_entry* arr;
	int* size;

	if (	(argint(0, &gid) < 0) ||
			(argptr(1,(char**)&arr, sizeof(process_info_entry)) < 0) ||
801069f5:	85 c0                	test   %eax,%eax
801069f7:	79 07                	jns    80106a00 <sys_list_pgroup+0x62>
			(argptr(2,(char**)&size, sizeof(int)) < 0)){

		return -1;
801069f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069fe:	eb 19                	jmp    80106a19 <sys_list_pgroup+0x7b>
	}

	return list_pgroup(gid, arr, size);
80106a00:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106a03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106a0d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a11:	89 04 24             	mov    %eax,(%esp)
80106a14:	e8 1d e4 ff ff       	call   80104e36 <list_pgroup>
}
80106a19:	c9                   	leave  
80106a1a:	c3                   	ret    

80106a1b <sys_foreground>:

int
sys_foreground(void)
{
80106a1b:	55                   	push   %ebp
80106a1c:	89 e5                	mov    %esp,%ebp
80106a1e:	83 ec 28             	sub    $0x28,%esp
	int gid;

	if (argint(0, &gid) < 0){
80106a21:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a24:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a2f:	e8 1e ef ff ff       	call   80105952 <argint>
80106a34:	85 c0                	test   %eax,%eax
80106a36:	79 07                	jns    80106a3f <sys_foreground+0x24>
		return -1;
80106a38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a3d:	eb 0b                	jmp    80106a4a <sys_foreground+0x2f>
	}

	return foreground(gid);
80106a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a42:	89 04 24             	mov    %eax,(%esp)
80106a45:	e8 13 e3 ff ff       	call   80104d5d <foreground>
}
80106a4a:	c9                   	leave  
80106a4b:	c3                   	ret    

80106a4c <sys_kill>:

int
sys_kill(void)
{
80106a4c:	55                   	push   %ebp
80106a4d:	89 e5                	mov    %esp,%ebp
80106a4f:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a55:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a60:	e8 ed ee ff ff       	call   80105952 <argint>
80106a65:	85 c0                	test   %eax,%eax
80106a67:	79 07                	jns    80106a70 <sys_kill+0x24>
    return -1;
80106a69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6e:	eb 0b                	jmp    80106a7b <sys_kill+0x2f>
  return kill(pid);
80106a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a73:	89 04 24             	mov    %eax,(%esp)
80106a76:	e8 4d e7 ff ff       	call   801051c8 <kill>
}
80106a7b:	c9                   	leave  
80106a7c:	c3                   	ret    

80106a7d <sys_getpid>:

int
sys_getpid(void)
{
80106a7d:	55                   	push   %ebp
80106a7e:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106a80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a86:	8b 40 10             	mov    0x10(%eax),%eax
}
80106a89:	5d                   	pop    %ebp
80106a8a:	c3                   	ret    

80106a8b <sys_sbrk>:

int
sys_sbrk(void)
{
80106a8b:	55                   	push   %ebp
80106a8c:	89 e5                	mov    %esp,%ebp
80106a8e:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106a91:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a94:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a9f:	e8 ae ee ff ff       	call   80105952 <argint>
80106aa4:	85 c0                	test   %eax,%eax
80106aa6:	79 07                	jns    80106aaf <sys_sbrk+0x24>
    return -1;
80106aa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aad:	eb 24                	jmp    80106ad3 <sys_sbrk+0x48>
  addr = proc->sz;
80106aaf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ab5:	8b 00                	mov    (%eax),%eax
80106ab7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106abd:	89 04 24             	mov    %eax,(%esp)
80106ac0:	e8 48 db ff ff       	call   8010460d <growproc>
80106ac5:	85 c0                	test   %eax,%eax
80106ac7:	79 07                	jns    80106ad0 <sys_sbrk+0x45>
    return -1;
80106ac9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ace:	eb 03                	jmp    80106ad3 <sys_sbrk+0x48>
  return addr;
80106ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106ad3:	c9                   	leave  
80106ad4:	c3                   	ret    

80106ad5 <sys_sleep>:

int
sys_sleep(void)
{
80106ad5:	55                   	push   %ebp
80106ad6:	89 e5                	mov    %esp,%ebp
80106ad8:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106adb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ade:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ae2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ae9:	e8 64 ee ff ff       	call   80105952 <argint>
80106aee:	85 c0                	test   %eax,%eax
80106af0:	79 07                	jns    80106af9 <sys_sleep+0x24>
    return -1;
80106af2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106af7:	eb 6c                	jmp    80106b65 <sys_sleep+0x90>
  acquire(&tickslock);
80106af9:	c7 04 24 c0 5f 11 80 	movl   $0x80115fc0,(%esp)
80106b00:	e8 a2 e8 ff ff       	call   801053a7 <acquire>
  ticks0 = ticks;
80106b05:	a1 00 68 11 80       	mov    0x80116800,%eax
80106b0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106b0d:	eb 34                	jmp    80106b43 <sys_sleep+0x6e>
    if(proc->killed){
80106b0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b15:	8b 40 28             	mov    0x28(%eax),%eax
80106b18:	85 c0                	test   %eax,%eax
80106b1a:	74 13                	je     80106b2f <sys_sleep+0x5a>
      release(&tickslock);
80106b1c:	c7 04 24 c0 5f 11 80 	movl   $0x80115fc0,(%esp)
80106b23:	e8 e1 e8 ff ff       	call   80105409 <release>
      return -1;
80106b28:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b2d:	eb 36                	jmp    80106b65 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106b2f:	c7 44 24 04 c0 5f 11 	movl   $0x80115fc0,0x4(%esp)
80106b36:	80 
80106b37:	c7 04 24 00 68 11 80 	movl   $0x80116800,(%esp)
80106b3e:	e8 7e e5 ff ff       	call   801050c1 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106b43:	a1 00 68 11 80       	mov    0x80116800,%eax
80106b48:	89 c2                	mov    %eax,%edx
80106b4a:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b50:	39 c2                	cmp    %eax,%edx
80106b52:	72 bb                	jb     80106b0f <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106b54:	c7 04 24 c0 5f 11 80 	movl   $0x80115fc0,(%esp)
80106b5b:	e8 a9 e8 ff ff       	call   80105409 <release>
  return 0;
80106b60:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b65:	c9                   	leave  
80106b66:	c3                   	ret    

80106b67 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106b67:	55                   	push   %ebp
80106b68:	89 e5                	mov    %esp,%ebp
80106b6a:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106b6d:	c7 04 24 c0 5f 11 80 	movl   $0x80115fc0,(%esp)
80106b74:	e8 2e e8 ff ff       	call   801053a7 <acquire>
  xticks = ticks;
80106b79:	a1 00 68 11 80       	mov    0x80116800,%eax
80106b7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106b81:	c7 04 24 c0 5f 11 80 	movl   $0x80115fc0,(%esp)
80106b88:	e8 7c e8 ff ff       	call   80105409 <release>
  return xticks;
80106b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106b90:	c9                   	leave  
80106b91:	c3                   	ret    
	...

80106b94 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b94:	55                   	push   %ebp
80106b95:	89 e5                	mov    %esp,%ebp
80106b97:	83 ec 08             	sub    $0x8,%esp
80106b9a:	8b 55 08             	mov    0x8(%ebp),%edx
80106b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106ba0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106ba4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ba7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106bab:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106baf:	ee                   	out    %al,(%dx)
}
80106bb0:	c9                   	leave  
80106bb1:	c3                   	ret    

80106bb2 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106bb2:	55                   	push   %ebp
80106bb3:	89 e5                	mov    %esp,%ebp
80106bb5:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106bb8:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106bbf:	00 
80106bc0:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106bc7:	e8 c8 ff ff ff       	call   80106b94 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106bcc:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106bd3:	00 
80106bd4:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106bdb:	e8 b4 ff ff ff       	call   80106b94 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106be0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106be7:	00 
80106be8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106bef:	e8 a0 ff ff ff       	call   80106b94 <outb>
  picenable(IRQ_TIMER);
80106bf4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bfb:	e8 75 d2 ff ff       	call   80103e75 <picenable>
}
80106c00:	c9                   	leave  
80106c01:	c3                   	ret    
	...

80106c04 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106c04:	1e                   	push   %ds
  pushl %es
80106c05:	06                   	push   %es
  pushl %fs
80106c06:	0f a0                	push   %fs
  pushl %gs
80106c08:	0f a8                	push   %gs
  pushal
80106c0a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106c0b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106c0f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106c11:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106c13:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106c17:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106c19:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106c1b:	54                   	push   %esp
  call trap
80106c1c:	e8 5a 02 00 00       	call   80106e7b <trap>
  addl $4, %esp
80106c21:	83 c4 04             	add    $0x4,%esp

80106c24 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106c24:	61                   	popa   
  popl %gs
80106c25:	0f a9                	pop    %gs
  popl %fs
80106c27:	0f a1                	pop    %fs
  popl %es
80106c29:	07                   	pop    %es
  popl %ds
80106c2a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106c2b:	83 c4 08             	add    $0x8,%esp
  iret
80106c2e:	cf                   	iret   
	...

80106c30 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106c30:	55                   	push   %ebp
80106c31:	89 e5                	mov    %esp,%ebp
80106c33:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106c36:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c39:	83 e8 01             	sub    $0x1,%eax
80106c3c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106c40:	8b 45 08             	mov    0x8(%ebp),%eax
80106c43:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106c47:	8b 45 08             	mov    0x8(%ebp),%eax
80106c4a:	c1 e8 10             	shr    $0x10,%eax
80106c4d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106c51:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106c54:	0f 01 18             	lidtl  (%eax)
}
80106c57:	c9                   	leave  
80106c58:	c3                   	ret    

80106c59 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106c59:	55                   	push   %ebp
80106c5a:	89 e5                	mov    %esp,%ebp
80106c5c:	53                   	push   %ebx
80106c5d:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106c60:	0f 20 d3             	mov    %cr2,%ebx
80106c63:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106c66:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106c69:	83 c4 10             	add    $0x10,%esp
80106c6c:	5b                   	pop    %ebx
80106c6d:	5d                   	pop    %ebp
80106c6e:	c3                   	ret    

80106c6f <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106c6f:	55                   	push   %ebp
80106c70:	89 e5                	mov    %esp,%ebp
80106c72:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106c75:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c7c:	e9 c3 00 00 00       	jmp    80106d44 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c84:	8b 04 85 a8 c0 10 80 	mov    -0x7fef3f58(,%eax,4),%eax
80106c8b:	89 c2                	mov    %eax,%edx
80106c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c90:	66 89 14 c5 00 60 11 	mov    %dx,-0x7feea000(,%eax,8)
80106c97:	80 
80106c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c9b:	66 c7 04 c5 02 60 11 	movw   $0x8,-0x7fee9ffe(,%eax,8)
80106ca2:	80 08 00 
80106ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca8:	0f b6 14 c5 04 60 11 	movzbl -0x7fee9ffc(,%eax,8),%edx
80106caf:	80 
80106cb0:	83 e2 e0             	and    $0xffffffe0,%edx
80106cb3:	88 14 c5 04 60 11 80 	mov    %dl,-0x7fee9ffc(,%eax,8)
80106cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cbd:	0f b6 14 c5 04 60 11 	movzbl -0x7fee9ffc(,%eax,8),%edx
80106cc4:	80 
80106cc5:	83 e2 1f             	and    $0x1f,%edx
80106cc8:	88 14 c5 04 60 11 80 	mov    %dl,-0x7fee9ffc(,%eax,8)
80106ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cd2:	0f b6 14 c5 05 60 11 	movzbl -0x7fee9ffb(,%eax,8),%edx
80106cd9:	80 
80106cda:	83 e2 f0             	and    $0xfffffff0,%edx
80106cdd:	83 ca 0e             	or     $0xe,%edx
80106ce0:	88 14 c5 05 60 11 80 	mov    %dl,-0x7fee9ffb(,%eax,8)
80106ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cea:	0f b6 14 c5 05 60 11 	movzbl -0x7fee9ffb(,%eax,8),%edx
80106cf1:	80 
80106cf2:	83 e2 ef             	and    $0xffffffef,%edx
80106cf5:	88 14 c5 05 60 11 80 	mov    %dl,-0x7fee9ffb(,%eax,8)
80106cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cff:	0f b6 14 c5 05 60 11 	movzbl -0x7fee9ffb(,%eax,8),%edx
80106d06:	80 
80106d07:	83 e2 9f             	and    $0xffffff9f,%edx
80106d0a:	88 14 c5 05 60 11 80 	mov    %dl,-0x7fee9ffb(,%eax,8)
80106d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d14:	0f b6 14 c5 05 60 11 	movzbl -0x7fee9ffb(,%eax,8),%edx
80106d1b:	80 
80106d1c:	83 ca 80             	or     $0xffffff80,%edx
80106d1f:	88 14 c5 05 60 11 80 	mov    %dl,-0x7fee9ffb(,%eax,8)
80106d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d29:	8b 04 85 a8 c0 10 80 	mov    -0x7fef3f58(,%eax,4),%eax
80106d30:	c1 e8 10             	shr    $0x10,%eax
80106d33:	89 c2                	mov    %eax,%edx
80106d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d38:	66 89 14 c5 06 60 11 	mov    %dx,-0x7fee9ffa(,%eax,8)
80106d3f:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106d40:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d44:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106d4b:	0f 8e 30 ff ff ff    	jle    80106c81 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106d51:	a1 a8 c1 10 80       	mov    0x8010c1a8,%eax
80106d56:	66 a3 00 62 11 80    	mov    %ax,0x80116200
80106d5c:	66 c7 05 02 62 11 80 	movw   $0x8,0x80116202
80106d63:	08 00 
80106d65:	0f b6 05 04 62 11 80 	movzbl 0x80116204,%eax
80106d6c:	83 e0 e0             	and    $0xffffffe0,%eax
80106d6f:	a2 04 62 11 80       	mov    %al,0x80116204
80106d74:	0f b6 05 04 62 11 80 	movzbl 0x80116204,%eax
80106d7b:	83 e0 1f             	and    $0x1f,%eax
80106d7e:	a2 04 62 11 80       	mov    %al,0x80116204
80106d83:	0f b6 05 05 62 11 80 	movzbl 0x80116205,%eax
80106d8a:	83 c8 0f             	or     $0xf,%eax
80106d8d:	a2 05 62 11 80       	mov    %al,0x80116205
80106d92:	0f b6 05 05 62 11 80 	movzbl 0x80116205,%eax
80106d99:	83 e0 ef             	and    $0xffffffef,%eax
80106d9c:	a2 05 62 11 80       	mov    %al,0x80116205
80106da1:	0f b6 05 05 62 11 80 	movzbl 0x80116205,%eax
80106da8:	83 c8 60             	or     $0x60,%eax
80106dab:	a2 05 62 11 80       	mov    %al,0x80116205
80106db0:	0f b6 05 05 62 11 80 	movzbl 0x80116205,%eax
80106db7:	83 c8 80             	or     $0xffffff80,%eax
80106dba:	a2 05 62 11 80       	mov    %al,0x80116205
80106dbf:	a1 a8 c1 10 80       	mov    0x8010c1a8,%eax
80106dc4:	c1 e8 10             	shr    $0x10,%eax
80106dc7:	66 a3 06 62 11 80    	mov    %ax,0x80116206
  
  initlock(&tickslock, "time");
80106dcd:	c7 44 24 04 70 90 10 	movl   $0x80109070,0x4(%esp)
80106dd4:	80 
80106dd5:	c7 04 24 c0 5f 11 80 	movl   $0x80115fc0,(%esp)
80106ddc:	e8 a5 e5 ff ff       	call   80105386 <initlock>
}
80106de1:	c9                   	leave  
80106de2:	c3                   	ret    

80106de3 <idtinit>:

void
idtinit(void)
{
80106de3:	55                   	push   %ebp
80106de4:	89 e5                	mov    %esp,%ebp
80106de6:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106de9:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106df0:	00 
80106df1:	c7 04 24 00 60 11 80 	movl   $0x80116000,(%esp)
80106df8:	e8 33 fe ff ff       	call   80106c30 <lidt>
}
80106dfd:	c9                   	leave  
80106dfe:	c3                   	ret    

80106dff <updateStats>:
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

void updateStats()
{
80106dff:	55                   	push   %ebp
80106e00:	89 e5                	mov    %esp,%ebp
80106e02:	83 ec 10             	sub    $0x10,%esp
	struct proc* p;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80106e05:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
80106e0c:	eb 62                	jmp    80106e70 <updateStats+0x71>
		switch (p->state) {
80106e0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e11:	8b 40 0c             	mov    0xc(%eax),%eax
80106e14:	83 f8 03             	cmp    $0x3,%eax
80106e17:	74 21                	je     80106e3a <updateStats+0x3b>
80106e19:	83 f8 04             	cmp    $0x4,%eax
80106e1c:	74 33                	je     80106e51 <updateStats+0x52>
80106e1e:	83 f8 02             	cmp    $0x2,%eax
80106e21:	75 45                	jne    80106e68 <updateStats+0x69>
			case SLEEPING:
				p->stime++;
80106e23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e26:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80106e2c:	8d 50 01             	lea    0x1(%eax),%edx
80106e2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e32:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
				break;
80106e38:	eb 2f                	jmp    80106e69 <updateStats+0x6a>
			case RUNNABLE:
				p->retime++;
80106e3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e3d:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80106e43:	8d 50 01             	lea    0x1(%eax),%edx
80106e46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e49:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
				break;
80106e4f:	eb 18                	jmp    80106e69 <updateStats+0x6a>
			case RUNNING:
				p->rutime++;
80106e51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e54:	8b 80 94 00 00 00    	mov    0x94(%eax),%eax
80106e5a:	8d 50 01             	lea    0x1(%eax),%edx
80106e5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106e60:	89 90 94 00 00 00    	mov    %edx,0x94(%eax)
				break;
80106e66:	eb 01                	jmp    80106e69 <updateStats+0x6a>
			default:
				break;
80106e68:	90                   	nop
} ptable;

void updateStats()
{
	struct proc* p;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80106e69:	81 45 fc 98 00 00 00 	addl   $0x98,-0x4(%ebp)
80106e70:	81 7d fc b4 5f 11 80 	cmpl   $0x80115fb4,-0x4(%ebp)
80106e77:	72 95                	jb     80106e0e <updateStats+0xf>
				break;
			default:
				break;
		}
    }
}
80106e79:	c9                   	leave  
80106e7a:	c3                   	ret    

80106e7b <trap>:


//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106e7b:	55                   	push   %ebp
80106e7c:	89 e5                	mov    %esp,%ebp
80106e7e:	57                   	push   %edi
80106e7f:	56                   	push   %esi
80106e80:	53                   	push   %ebx
80106e81:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106e84:	8b 45 08             	mov    0x8(%ebp),%eax
80106e87:	8b 40 30             	mov    0x30(%eax),%eax
80106e8a:	83 f8 40             	cmp    $0x40,%eax
80106e8d:	75 4c                	jne    80106edb <trap+0x60>
    if(proc->killed)
80106e8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e95:	8b 40 28             	mov    0x28(%eax),%eax
80106e98:	85 c0                	test   %eax,%eax
80106e9a:	74 0c                	je     80106ea8 <trap+0x2d>
      exit(EXIT_STATUS_DEFAULT);
80106e9c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106ea3:	e8 b0 d9 ff ff       	call   80104858 <exit>
    proc->tf = tf;
80106ea8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106eae:	8b 55 08             	mov    0x8(%ebp),%edx
80106eb1:	89 50 1c             	mov    %edx,0x1c(%eax)
    syscall();
80106eb4:	e8 60 eb ff ff       	call   80105a19 <syscall>
    if(proc->killed)
80106eb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ebf:	8b 40 28             	mov    0x28(%eax),%eax
80106ec2:	85 c0                	test   %eax,%eax
80106ec4:	0f 84 26 02 00 00    	je     801070f0 <trap+0x275>
      exit(EXIT_STATUS_DEFAULT);
80106eca:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106ed1:	e8 82 d9 ff ff       	call   80104858 <exit>
    return;
80106ed6:	e9 15 02 00 00       	jmp    801070f0 <trap+0x275>
  }

  switch(tf->trapno){
80106edb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ede:	8b 40 30             	mov    0x30(%eax),%eax
80106ee1:	83 e8 20             	sub    $0x20,%eax
80106ee4:	83 f8 1f             	cmp    $0x1f,%eax
80106ee7:	0f 87 c1 00 00 00    	ja     80106fae <trap+0x133>
80106eed:	8b 04 85 18 91 10 80 	mov    -0x7fef6ee8(,%eax,4),%eax
80106ef4:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106ef6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106efc:	0f b6 00             	movzbl (%eax),%eax
80106eff:	84 c0                	test   %al,%al
80106f01:	75 36                	jne    80106f39 <trap+0xbe>
      acquire(&tickslock);
80106f03:	c7 04 24 c0 5f 11 80 	movl   $0x80115fc0,(%esp)
80106f0a:	e8 98 e4 ff ff       	call   801053a7 <acquire>
      ticks++;
80106f0f:	a1 00 68 11 80       	mov    0x80116800,%eax
80106f14:	83 c0 01             	add    $0x1,%eax
80106f17:	a3 00 68 11 80       	mov    %eax,0x80116800
      wakeup(&ticks);
80106f1c:	c7 04 24 00 68 11 80 	movl   $0x80116800,(%esp)
80106f23:	e8 75 e2 ff ff       	call   8010519d <wakeup>
      release(&tickslock);
80106f28:	c7 04 24 c0 5f 11 80 	movl   $0x80115fc0,(%esp)
80106f2f:	e8 d5 e4 ff ff       	call   80105409 <release>

      updateStats();
80106f34:	e8 c6 fe ff ff       	call   80106dff <updateStats>
    }
    lapiceoi();
80106f39:	e8 3d c0 ff ff       	call   80102f7b <lapiceoi>
    break;
80106f3e:	e9 41 01 00 00       	jmp    80107084 <trap+0x209>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106f43:	e8 11 b8 ff ff       	call   80102759 <ideintr>
    lapiceoi();
80106f48:	e8 2e c0 ff ff       	call   80102f7b <lapiceoi>
    break;
80106f4d:	e9 32 01 00 00       	jmp    80107084 <trap+0x209>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106f52:	e8 d8 bd ff ff       	call   80102d2f <kbdintr>
    lapiceoi();
80106f57:	e8 1f c0 ff ff       	call   80102f7b <lapiceoi>
    break;
80106f5c:	e9 23 01 00 00       	jmp    80107084 <trap+0x209>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106f61:	e8 92 03 00 00       	call   801072f8 <uartintr>
    lapiceoi();
80106f66:	e8 10 c0 ff ff       	call   80102f7b <lapiceoi>
    break;
80106f6b:	e9 14 01 00 00       	jmp    80107084 <trap+0x209>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106f70:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106f73:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106f76:	8b 45 08             	mov    0x8(%ebp),%eax
80106f79:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106f7d:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106f80:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106f86:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106f89:	0f b6 c0             	movzbl %al,%eax
80106f8c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106f90:	89 54 24 08          	mov    %edx,0x8(%esp)
80106f94:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f98:	c7 04 24 78 90 10 80 	movl   $0x80109078,(%esp)
80106f9f:	e8 fd 93 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106fa4:	e8 d2 bf ff ff       	call   80102f7b <lapiceoi>
    break;
80106fa9:	e9 d6 00 00 00       	jmp    80107084 <trap+0x209>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106fae:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106fb4:	85 c0                	test   %eax,%eax
80106fb6:	74 11                	je     80106fc9 <trap+0x14e>
80106fb8:	8b 45 08             	mov    0x8(%ebp),%eax
80106fbb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106fbf:	0f b7 c0             	movzwl %ax,%eax
80106fc2:	83 e0 03             	and    $0x3,%eax
80106fc5:	85 c0                	test   %eax,%eax
80106fc7:	75 46                	jne    8010700f <trap+0x194>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106fc9:	e8 8b fc ff ff       	call   80106c59 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106fce:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106fd1:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106fd4:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106fdb:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106fde:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106fe1:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106fe4:	8b 52 30             	mov    0x30(%edx),%edx
80106fe7:	89 44 24 10          	mov    %eax,0x10(%esp)
80106feb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106fef:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106ff3:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ff7:	c7 04 24 9c 90 10 80 	movl   $0x8010909c,(%esp)
80106ffe:	e8 9e 93 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107003:	c7 04 24 ce 90 10 80 	movl   $0x801090ce,(%esp)
8010700a:	e8 2e 95 ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010700f:	e8 45 fc ff ff       	call   80106c59 <rcr2>
80107014:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107016:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107019:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010701c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107022:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107025:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107028:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010702b:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010702e:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107031:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107034:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010703a:	83 c0 70             	add    $0x70,%eax
8010703d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107040:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107046:	8b 40 10             	mov    0x10(%eax),%eax
80107049:	89 54 24 1c          	mov    %edx,0x1c(%esp)
8010704d:	89 7c 24 18          	mov    %edi,0x18(%esp)
80107051:	89 74 24 14          	mov    %esi,0x14(%esp)
80107055:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107059:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010705d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107060:	89 54 24 08          	mov    %edx,0x8(%esp)
80107064:	89 44 24 04          	mov    %eax,0x4(%esp)
80107068:	c7 04 24 d4 90 10 80 	movl   $0x801090d4,(%esp)
8010706f:	e8 2d 93 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80107074:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010707a:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
80107081:	eb 01                	jmp    80107084 <trap+0x209>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107083:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107084:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010708a:	85 c0                	test   %eax,%eax
8010708c:	74 2b                	je     801070b9 <trap+0x23e>
8010708e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107094:	8b 40 28             	mov    0x28(%eax),%eax
80107097:	85 c0                	test   %eax,%eax
80107099:	74 1e                	je     801070b9 <trap+0x23e>
8010709b:	8b 45 08             	mov    0x8(%ebp),%eax
8010709e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801070a2:	0f b7 c0             	movzwl %ax,%eax
801070a5:	83 e0 03             	and    $0x3,%eax
801070a8:	83 f8 03             	cmp    $0x3,%eax
801070ab:	75 0c                	jne    801070b9 <trap+0x23e>
    exit(EXIT_STATUS_DEFAULT);
801070ad:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801070b4:	e8 9f d7 ff ff       	call   80104858 <exit>
	    if( !(ticks % QUANTA) ) yield();
  }
#endif

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801070b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070bf:	85 c0                	test   %eax,%eax
801070c1:	74 2e                	je     801070f1 <trap+0x276>
801070c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070c9:	8b 40 28             	mov    0x28(%eax),%eax
801070cc:	85 c0                	test   %eax,%eax
801070ce:	74 21                	je     801070f1 <trap+0x276>
801070d0:	8b 45 08             	mov    0x8(%ebp),%eax
801070d3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801070d7:	0f b7 c0             	movzwl %ax,%eax
801070da:	83 e0 03             	and    $0x3,%eax
801070dd:	83 f8 03             	cmp    $0x3,%eax
801070e0:	75 0f                	jne    801070f1 <trap+0x276>
    exit(EXIT_STATUS_DEFAULT);
801070e2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801070e9:	e8 6a d7 ff ff       	call   80104858 <exit>
801070ee:	eb 01                	jmp    801070f1 <trap+0x276>
      exit(EXIT_STATUS_DEFAULT);
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit(EXIT_STATUS_DEFAULT);
    return;
801070f0:	90                   	nop
#endif

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit(EXIT_STATUS_DEFAULT);
}
801070f1:	83 c4 3c             	add    $0x3c,%esp
801070f4:	5b                   	pop    %ebx
801070f5:	5e                   	pop    %esi
801070f6:	5f                   	pop    %edi
801070f7:	5d                   	pop    %ebp
801070f8:	c3                   	ret    
801070f9:	00 00                	add    %al,(%eax)
	...

801070fc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801070fc:	55                   	push   %ebp
801070fd:	89 e5                	mov    %esp,%ebp
801070ff:	53                   	push   %ebx
80107100:	83 ec 14             	sub    $0x14,%esp
80107103:	8b 45 08             	mov    0x8(%ebp),%eax
80107106:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010710a:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010710e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80107112:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80107116:	ec                   	in     (%dx),%al
80107117:	89 c3                	mov    %eax,%ebx
80107119:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010711c:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80107120:	83 c4 14             	add    $0x14,%esp
80107123:	5b                   	pop    %ebx
80107124:	5d                   	pop    %ebp
80107125:	c3                   	ret    

80107126 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107126:	55                   	push   %ebp
80107127:	89 e5                	mov    %esp,%ebp
80107129:	83 ec 08             	sub    $0x8,%esp
8010712c:	8b 55 08             	mov    0x8(%ebp),%edx
8010712f:	8b 45 0c             	mov    0xc(%ebp),%eax
80107132:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107136:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107139:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010713d:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107141:	ee                   	out    %al,(%dx)
}
80107142:	c9                   	leave  
80107143:	c3                   	ret    

80107144 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107144:	55                   	push   %ebp
80107145:	89 e5                	mov    %esp,%ebp
80107147:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
8010714a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107151:	00 
80107152:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107159:	e8 c8 ff ff ff       	call   80107126 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
8010715e:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107165:	00 
80107166:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010716d:	e8 b4 ff ff ff       	call   80107126 <outb>
  outb(COM1+0, 115200/9600);
80107172:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107179:	00 
8010717a:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107181:	e8 a0 ff ff ff       	call   80107126 <outb>
  outb(COM1+1, 0);
80107186:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010718d:	00 
8010718e:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107195:	e8 8c ff ff ff       	call   80107126 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010719a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801071a1:	00 
801071a2:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801071a9:	e8 78 ff ff ff       	call   80107126 <outb>
  outb(COM1+4, 0);
801071ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801071b5:	00 
801071b6:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801071bd:	e8 64 ff ff ff       	call   80107126 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801071c2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801071c9:	00 
801071ca:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801071d1:	e8 50 ff ff ff       	call   80107126 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801071d6:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801071dd:	e8 1a ff ff ff       	call   801070fc <inb>
801071e2:	3c ff                	cmp    $0xff,%al
801071e4:	74 6c                	je     80107252 <uartinit+0x10e>
    return;
  uart = 1;
801071e6:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
801071ed:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801071f0:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801071f7:	e8 00 ff ff ff       	call   801070fc <inb>
  inb(COM1+0);
801071fc:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107203:	e8 f4 fe ff ff       	call   801070fc <inb>
  picenable(IRQ_COM1);
80107208:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010720f:	e8 61 cc ff ff       	call   80103e75 <picenable>
  ioapicenable(IRQ_COM1, 0);
80107214:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010721b:	00 
8010721c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107223:	e8 b6 b7 ff ff       	call   801029de <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107228:	c7 45 f4 98 91 10 80 	movl   $0x80109198,-0xc(%ebp)
8010722f:	eb 15                	jmp    80107246 <uartinit+0x102>
    uartputc(*p);
80107231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107234:	0f b6 00             	movzbl (%eax),%eax
80107237:	0f be c0             	movsbl %al,%eax
8010723a:	89 04 24             	mov    %eax,(%esp)
8010723d:	e8 13 00 00 00       	call   80107255 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107242:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107249:	0f b6 00             	movzbl (%eax),%eax
8010724c:	84 c0                	test   %al,%al
8010724e:	75 e1                	jne    80107231 <uartinit+0xed>
80107250:	eb 01                	jmp    80107253 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80107252:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80107253:	c9                   	leave  
80107254:	c3                   	ret    

80107255 <uartputc>:

void
uartputc(int c)
{
80107255:	55                   	push   %ebp
80107256:	89 e5                	mov    %esp,%ebp
80107258:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
8010725b:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107260:	85 c0                	test   %eax,%eax
80107262:	74 4d                	je     801072b1 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107264:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010726b:	eb 10                	jmp    8010727d <uartputc+0x28>
    microdelay(10);
8010726d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107274:	e8 27 bd ff ff       	call   80102fa0 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107279:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010727d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107281:	7f 16                	jg     80107299 <uartputc+0x44>
80107283:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010728a:	e8 6d fe ff ff       	call   801070fc <inb>
8010728f:	0f b6 c0             	movzbl %al,%eax
80107292:	83 e0 20             	and    $0x20,%eax
80107295:	85 c0                	test   %eax,%eax
80107297:	74 d4                	je     8010726d <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107299:	8b 45 08             	mov    0x8(%ebp),%eax
8010729c:	0f b6 c0             	movzbl %al,%eax
8010729f:	89 44 24 04          	mov    %eax,0x4(%esp)
801072a3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801072aa:	e8 77 fe ff ff       	call   80107126 <outb>
801072af:	eb 01                	jmp    801072b2 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
801072b1:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
801072b2:	c9                   	leave  
801072b3:	c3                   	ret    

801072b4 <uartgetc>:

static int
uartgetc(void)
{
801072b4:	55                   	push   %ebp
801072b5:	89 e5                	mov    %esp,%ebp
801072b7:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801072ba:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801072bf:	85 c0                	test   %eax,%eax
801072c1:	75 07                	jne    801072ca <uartgetc+0x16>
    return -1;
801072c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072c8:	eb 2c                	jmp    801072f6 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801072ca:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801072d1:	e8 26 fe ff ff       	call   801070fc <inb>
801072d6:	0f b6 c0             	movzbl %al,%eax
801072d9:	83 e0 01             	and    $0x1,%eax
801072dc:	85 c0                	test   %eax,%eax
801072de:	75 07                	jne    801072e7 <uartgetc+0x33>
    return -1;
801072e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072e5:	eb 0f                	jmp    801072f6 <uartgetc+0x42>
  return inb(COM1+0);
801072e7:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801072ee:	e8 09 fe ff ff       	call   801070fc <inb>
801072f3:	0f b6 c0             	movzbl %al,%eax
}
801072f6:	c9                   	leave  
801072f7:	c3                   	ret    

801072f8 <uartintr>:

void
uartintr(void)
{
801072f8:	55                   	push   %ebp
801072f9:	89 e5                	mov    %esp,%ebp
801072fb:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801072fe:	c7 04 24 b4 72 10 80 	movl   $0x801072b4,(%esp)
80107305:	e8 a3 94 ff ff       	call   801007ad <consoleintr>
}
8010730a:	c9                   	leave  
8010730b:	c3                   	ret    

8010730c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $0
8010730e:	6a 00                	push   $0x0
  jmp alltraps
80107310:	e9 ef f8 ff ff       	jmp    80106c04 <alltraps>

80107315 <vector1>:
.globl vector1
vector1:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $1
80107317:	6a 01                	push   $0x1
  jmp alltraps
80107319:	e9 e6 f8 ff ff       	jmp    80106c04 <alltraps>

8010731e <vector2>:
.globl vector2
vector2:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $2
80107320:	6a 02                	push   $0x2
  jmp alltraps
80107322:	e9 dd f8 ff ff       	jmp    80106c04 <alltraps>

80107327 <vector3>:
.globl vector3
vector3:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $3
80107329:	6a 03                	push   $0x3
  jmp alltraps
8010732b:	e9 d4 f8 ff ff       	jmp    80106c04 <alltraps>

80107330 <vector4>:
.globl vector4
vector4:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $4
80107332:	6a 04                	push   $0x4
  jmp alltraps
80107334:	e9 cb f8 ff ff       	jmp    80106c04 <alltraps>

80107339 <vector5>:
.globl vector5
vector5:
  pushl $0
80107339:	6a 00                	push   $0x0
  pushl $5
8010733b:	6a 05                	push   $0x5
  jmp alltraps
8010733d:	e9 c2 f8 ff ff       	jmp    80106c04 <alltraps>

80107342 <vector6>:
.globl vector6
vector6:
  pushl $0
80107342:	6a 00                	push   $0x0
  pushl $6
80107344:	6a 06                	push   $0x6
  jmp alltraps
80107346:	e9 b9 f8 ff ff       	jmp    80106c04 <alltraps>

8010734b <vector7>:
.globl vector7
vector7:
  pushl $0
8010734b:	6a 00                	push   $0x0
  pushl $7
8010734d:	6a 07                	push   $0x7
  jmp alltraps
8010734f:	e9 b0 f8 ff ff       	jmp    80106c04 <alltraps>

80107354 <vector8>:
.globl vector8
vector8:
  pushl $8
80107354:	6a 08                	push   $0x8
  jmp alltraps
80107356:	e9 a9 f8 ff ff       	jmp    80106c04 <alltraps>

8010735b <vector9>:
.globl vector9
vector9:
  pushl $0
8010735b:	6a 00                	push   $0x0
  pushl $9
8010735d:	6a 09                	push   $0x9
  jmp alltraps
8010735f:	e9 a0 f8 ff ff       	jmp    80106c04 <alltraps>

80107364 <vector10>:
.globl vector10
vector10:
  pushl $10
80107364:	6a 0a                	push   $0xa
  jmp alltraps
80107366:	e9 99 f8 ff ff       	jmp    80106c04 <alltraps>

8010736b <vector11>:
.globl vector11
vector11:
  pushl $11
8010736b:	6a 0b                	push   $0xb
  jmp alltraps
8010736d:	e9 92 f8 ff ff       	jmp    80106c04 <alltraps>

80107372 <vector12>:
.globl vector12
vector12:
  pushl $12
80107372:	6a 0c                	push   $0xc
  jmp alltraps
80107374:	e9 8b f8 ff ff       	jmp    80106c04 <alltraps>

80107379 <vector13>:
.globl vector13
vector13:
  pushl $13
80107379:	6a 0d                	push   $0xd
  jmp alltraps
8010737b:	e9 84 f8 ff ff       	jmp    80106c04 <alltraps>

80107380 <vector14>:
.globl vector14
vector14:
  pushl $14
80107380:	6a 0e                	push   $0xe
  jmp alltraps
80107382:	e9 7d f8 ff ff       	jmp    80106c04 <alltraps>

80107387 <vector15>:
.globl vector15
vector15:
  pushl $0
80107387:	6a 00                	push   $0x0
  pushl $15
80107389:	6a 0f                	push   $0xf
  jmp alltraps
8010738b:	e9 74 f8 ff ff       	jmp    80106c04 <alltraps>

80107390 <vector16>:
.globl vector16
vector16:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $16
80107392:	6a 10                	push   $0x10
  jmp alltraps
80107394:	e9 6b f8 ff ff       	jmp    80106c04 <alltraps>

80107399 <vector17>:
.globl vector17
vector17:
  pushl $17
80107399:	6a 11                	push   $0x11
  jmp alltraps
8010739b:	e9 64 f8 ff ff       	jmp    80106c04 <alltraps>

801073a0 <vector18>:
.globl vector18
vector18:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $18
801073a2:	6a 12                	push   $0x12
  jmp alltraps
801073a4:	e9 5b f8 ff ff       	jmp    80106c04 <alltraps>

801073a9 <vector19>:
.globl vector19
vector19:
  pushl $0
801073a9:	6a 00                	push   $0x0
  pushl $19
801073ab:	6a 13                	push   $0x13
  jmp alltraps
801073ad:	e9 52 f8 ff ff       	jmp    80106c04 <alltraps>

801073b2 <vector20>:
.globl vector20
vector20:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $20
801073b4:	6a 14                	push   $0x14
  jmp alltraps
801073b6:	e9 49 f8 ff ff       	jmp    80106c04 <alltraps>

801073bb <vector21>:
.globl vector21
vector21:
  pushl $0
801073bb:	6a 00                	push   $0x0
  pushl $21
801073bd:	6a 15                	push   $0x15
  jmp alltraps
801073bf:	e9 40 f8 ff ff       	jmp    80106c04 <alltraps>

801073c4 <vector22>:
.globl vector22
vector22:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $22
801073c6:	6a 16                	push   $0x16
  jmp alltraps
801073c8:	e9 37 f8 ff ff       	jmp    80106c04 <alltraps>

801073cd <vector23>:
.globl vector23
vector23:
  pushl $0
801073cd:	6a 00                	push   $0x0
  pushl $23
801073cf:	6a 17                	push   $0x17
  jmp alltraps
801073d1:	e9 2e f8 ff ff       	jmp    80106c04 <alltraps>

801073d6 <vector24>:
.globl vector24
vector24:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $24
801073d8:	6a 18                	push   $0x18
  jmp alltraps
801073da:	e9 25 f8 ff ff       	jmp    80106c04 <alltraps>

801073df <vector25>:
.globl vector25
vector25:
  pushl $0
801073df:	6a 00                	push   $0x0
  pushl $25
801073e1:	6a 19                	push   $0x19
  jmp alltraps
801073e3:	e9 1c f8 ff ff       	jmp    80106c04 <alltraps>

801073e8 <vector26>:
.globl vector26
vector26:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $26
801073ea:	6a 1a                	push   $0x1a
  jmp alltraps
801073ec:	e9 13 f8 ff ff       	jmp    80106c04 <alltraps>

801073f1 <vector27>:
.globl vector27
vector27:
  pushl $0
801073f1:	6a 00                	push   $0x0
  pushl $27
801073f3:	6a 1b                	push   $0x1b
  jmp alltraps
801073f5:	e9 0a f8 ff ff       	jmp    80106c04 <alltraps>

801073fa <vector28>:
.globl vector28
vector28:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $28
801073fc:	6a 1c                	push   $0x1c
  jmp alltraps
801073fe:	e9 01 f8 ff ff       	jmp    80106c04 <alltraps>

80107403 <vector29>:
.globl vector29
vector29:
  pushl $0
80107403:	6a 00                	push   $0x0
  pushl $29
80107405:	6a 1d                	push   $0x1d
  jmp alltraps
80107407:	e9 f8 f7 ff ff       	jmp    80106c04 <alltraps>

8010740c <vector30>:
.globl vector30
vector30:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $30
8010740e:	6a 1e                	push   $0x1e
  jmp alltraps
80107410:	e9 ef f7 ff ff       	jmp    80106c04 <alltraps>

80107415 <vector31>:
.globl vector31
vector31:
  pushl $0
80107415:	6a 00                	push   $0x0
  pushl $31
80107417:	6a 1f                	push   $0x1f
  jmp alltraps
80107419:	e9 e6 f7 ff ff       	jmp    80106c04 <alltraps>

8010741e <vector32>:
.globl vector32
vector32:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $32
80107420:	6a 20                	push   $0x20
  jmp alltraps
80107422:	e9 dd f7 ff ff       	jmp    80106c04 <alltraps>

80107427 <vector33>:
.globl vector33
vector33:
  pushl $0
80107427:	6a 00                	push   $0x0
  pushl $33
80107429:	6a 21                	push   $0x21
  jmp alltraps
8010742b:	e9 d4 f7 ff ff       	jmp    80106c04 <alltraps>

80107430 <vector34>:
.globl vector34
vector34:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $34
80107432:	6a 22                	push   $0x22
  jmp alltraps
80107434:	e9 cb f7 ff ff       	jmp    80106c04 <alltraps>

80107439 <vector35>:
.globl vector35
vector35:
  pushl $0
80107439:	6a 00                	push   $0x0
  pushl $35
8010743b:	6a 23                	push   $0x23
  jmp alltraps
8010743d:	e9 c2 f7 ff ff       	jmp    80106c04 <alltraps>

80107442 <vector36>:
.globl vector36
vector36:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $36
80107444:	6a 24                	push   $0x24
  jmp alltraps
80107446:	e9 b9 f7 ff ff       	jmp    80106c04 <alltraps>

8010744b <vector37>:
.globl vector37
vector37:
  pushl $0
8010744b:	6a 00                	push   $0x0
  pushl $37
8010744d:	6a 25                	push   $0x25
  jmp alltraps
8010744f:	e9 b0 f7 ff ff       	jmp    80106c04 <alltraps>

80107454 <vector38>:
.globl vector38
vector38:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $38
80107456:	6a 26                	push   $0x26
  jmp alltraps
80107458:	e9 a7 f7 ff ff       	jmp    80106c04 <alltraps>

8010745d <vector39>:
.globl vector39
vector39:
  pushl $0
8010745d:	6a 00                	push   $0x0
  pushl $39
8010745f:	6a 27                	push   $0x27
  jmp alltraps
80107461:	e9 9e f7 ff ff       	jmp    80106c04 <alltraps>

80107466 <vector40>:
.globl vector40
vector40:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $40
80107468:	6a 28                	push   $0x28
  jmp alltraps
8010746a:	e9 95 f7 ff ff       	jmp    80106c04 <alltraps>

8010746f <vector41>:
.globl vector41
vector41:
  pushl $0
8010746f:	6a 00                	push   $0x0
  pushl $41
80107471:	6a 29                	push   $0x29
  jmp alltraps
80107473:	e9 8c f7 ff ff       	jmp    80106c04 <alltraps>

80107478 <vector42>:
.globl vector42
vector42:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $42
8010747a:	6a 2a                	push   $0x2a
  jmp alltraps
8010747c:	e9 83 f7 ff ff       	jmp    80106c04 <alltraps>

80107481 <vector43>:
.globl vector43
vector43:
  pushl $0
80107481:	6a 00                	push   $0x0
  pushl $43
80107483:	6a 2b                	push   $0x2b
  jmp alltraps
80107485:	e9 7a f7 ff ff       	jmp    80106c04 <alltraps>

8010748a <vector44>:
.globl vector44
vector44:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $44
8010748c:	6a 2c                	push   $0x2c
  jmp alltraps
8010748e:	e9 71 f7 ff ff       	jmp    80106c04 <alltraps>

80107493 <vector45>:
.globl vector45
vector45:
  pushl $0
80107493:	6a 00                	push   $0x0
  pushl $45
80107495:	6a 2d                	push   $0x2d
  jmp alltraps
80107497:	e9 68 f7 ff ff       	jmp    80106c04 <alltraps>

8010749c <vector46>:
.globl vector46
vector46:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $46
8010749e:	6a 2e                	push   $0x2e
  jmp alltraps
801074a0:	e9 5f f7 ff ff       	jmp    80106c04 <alltraps>

801074a5 <vector47>:
.globl vector47
vector47:
  pushl $0
801074a5:	6a 00                	push   $0x0
  pushl $47
801074a7:	6a 2f                	push   $0x2f
  jmp alltraps
801074a9:	e9 56 f7 ff ff       	jmp    80106c04 <alltraps>

801074ae <vector48>:
.globl vector48
vector48:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $48
801074b0:	6a 30                	push   $0x30
  jmp alltraps
801074b2:	e9 4d f7 ff ff       	jmp    80106c04 <alltraps>

801074b7 <vector49>:
.globl vector49
vector49:
  pushl $0
801074b7:	6a 00                	push   $0x0
  pushl $49
801074b9:	6a 31                	push   $0x31
  jmp alltraps
801074bb:	e9 44 f7 ff ff       	jmp    80106c04 <alltraps>

801074c0 <vector50>:
.globl vector50
vector50:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $50
801074c2:	6a 32                	push   $0x32
  jmp alltraps
801074c4:	e9 3b f7 ff ff       	jmp    80106c04 <alltraps>

801074c9 <vector51>:
.globl vector51
vector51:
  pushl $0
801074c9:	6a 00                	push   $0x0
  pushl $51
801074cb:	6a 33                	push   $0x33
  jmp alltraps
801074cd:	e9 32 f7 ff ff       	jmp    80106c04 <alltraps>

801074d2 <vector52>:
.globl vector52
vector52:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $52
801074d4:	6a 34                	push   $0x34
  jmp alltraps
801074d6:	e9 29 f7 ff ff       	jmp    80106c04 <alltraps>

801074db <vector53>:
.globl vector53
vector53:
  pushl $0
801074db:	6a 00                	push   $0x0
  pushl $53
801074dd:	6a 35                	push   $0x35
  jmp alltraps
801074df:	e9 20 f7 ff ff       	jmp    80106c04 <alltraps>

801074e4 <vector54>:
.globl vector54
vector54:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $54
801074e6:	6a 36                	push   $0x36
  jmp alltraps
801074e8:	e9 17 f7 ff ff       	jmp    80106c04 <alltraps>

801074ed <vector55>:
.globl vector55
vector55:
  pushl $0
801074ed:	6a 00                	push   $0x0
  pushl $55
801074ef:	6a 37                	push   $0x37
  jmp alltraps
801074f1:	e9 0e f7 ff ff       	jmp    80106c04 <alltraps>

801074f6 <vector56>:
.globl vector56
vector56:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $56
801074f8:	6a 38                	push   $0x38
  jmp alltraps
801074fa:	e9 05 f7 ff ff       	jmp    80106c04 <alltraps>

801074ff <vector57>:
.globl vector57
vector57:
  pushl $0
801074ff:	6a 00                	push   $0x0
  pushl $57
80107501:	6a 39                	push   $0x39
  jmp alltraps
80107503:	e9 fc f6 ff ff       	jmp    80106c04 <alltraps>

80107508 <vector58>:
.globl vector58
vector58:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $58
8010750a:	6a 3a                	push   $0x3a
  jmp alltraps
8010750c:	e9 f3 f6 ff ff       	jmp    80106c04 <alltraps>

80107511 <vector59>:
.globl vector59
vector59:
  pushl $0
80107511:	6a 00                	push   $0x0
  pushl $59
80107513:	6a 3b                	push   $0x3b
  jmp alltraps
80107515:	e9 ea f6 ff ff       	jmp    80106c04 <alltraps>

8010751a <vector60>:
.globl vector60
vector60:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $60
8010751c:	6a 3c                	push   $0x3c
  jmp alltraps
8010751e:	e9 e1 f6 ff ff       	jmp    80106c04 <alltraps>

80107523 <vector61>:
.globl vector61
vector61:
  pushl $0
80107523:	6a 00                	push   $0x0
  pushl $61
80107525:	6a 3d                	push   $0x3d
  jmp alltraps
80107527:	e9 d8 f6 ff ff       	jmp    80106c04 <alltraps>

8010752c <vector62>:
.globl vector62
vector62:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $62
8010752e:	6a 3e                	push   $0x3e
  jmp alltraps
80107530:	e9 cf f6 ff ff       	jmp    80106c04 <alltraps>

80107535 <vector63>:
.globl vector63
vector63:
  pushl $0
80107535:	6a 00                	push   $0x0
  pushl $63
80107537:	6a 3f                	push   $0x3f
  jmp alltraps
80107539:	e9 c6 f6 ff ff       	jmp    80106c04 <alltraps>

8010753e <vector64>:
.globl vector64
vector64:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $64
80107540:	6a 40                	push   $0x40
  jmp alltraps
80107542:	e9 bd f6 ff ff       	jmp    80106c04 <alltraps>

80107547 <vector65>:
.globl vector65
vector65:
  pushl $0
80107547:	6a 00                	push   $0x0
  pushl $65
80107549:	6a 41                	push   $0x41
  jmp alltraps
8010754b:	e9 b4 f6 ff ff       	jmp    80106c04 <alltraps>

80107550 <vector66>:
.globl vector66
vector66:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $66
80107552:	6a 42                	push   $0x42
  jmp alltraps
80107554:	e9 ab f6 ff ff       	jmp    80106c04 <alltraps>

80107559 <vector67>:
.globl vector67
vector67:
  pushl $0
80107559:	6a 00                	push   $0x0
  pushl $67
8010755b:	6a 43                	push   $0x43
  jmp alltraps
8010755d:	e9 a2 f6 ff ff       	jmp    80106c04 <alltraps>

80107562 <vector68>:
.globl vector68
vector68:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $68
80107564:	6a 44                	push   $0x44
  jmp alltraps
80107566:	e9 99 f6 ff ff       	jmp    80106c04 <alltraps>

8010756b <vector69>:
.globl vector69
vector69:
  pushl $0
8010756b:	6a 00                	push   $0x0
  pushl $69
8010756d:	6a 45                	push   $0x45
  jmp alltraps
8010756f:	e9 90 f6 ff ff       	jmp    80106c04 <alltraps>

80107574 <vector70>:
.globl vector70
vector70:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $70
80107576:	6a 46                	push   $0x46
  jmp alltraps
80107578:	e9 87 f6 ff ff       	jmp    80106c04 <alltraps>

8010757d <vector71>:
.globl vector71
vector71:
  pushl $0
8010757d:	6a 00                	push   $0x0
  pushl $71
8010757f:	6a 47                	push   $0x47
  jmp alltraps
80107581:	e9 7e f6 ff ff       	jmp    80106c04 <alltraps>

80107586 <vector72>:
.globl vector72
vector72:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $72
80107588:	6a 48                	push   $0x48
  jmp alltraps
8010758a:	e9 75 f6 ff ff       	jmp    80106c04 <alltraps>

8010758f <vector73>:
.globl vector73
vector73:
  pushl $0
8010758f:	6a 00                	push   $0x0
  pushl $73
80107591:	6a 49                	push   $0x49
  jmp alltraps
80107593:	e9 6c f6 ff ff       	jmp    80106c04 <alltraps>

80107598 <vector74>:
.globl vector74
vector74:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $74
8010759a:	6a 4a                	push   $0x4a
  jmp alltraps
8010759c:	e9 63 f6 ff ff       	jmp    80106c04 <alltraps>

801075a1 <vector75>:
.globl vector75
vector75:
  pushl $0
801075a1:	6a 00                	push   $0x0
  pushl $75
801075a3:	6a 4b                	push   $0x4b
  jmp alltraps
801075a5:	e9 5a f6 ff ff       	jmp    80106c04 <alltraps>

801075aa <vector76>:
.globl vector76
vector76:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $76
801075ac:	6a 4c                	push   $0x4c
  jmp alltraps
801075ae:	e9 51 f6 ff ff       	jmp    80106c04 <alltraps>

801075b3 <vector77>:
.globl vector77
vector77:
  pushl $0
801075b3:	6a 00                	push   $0x0
  pushl $77
801075b5:	6a 4d                	push   $0x4d
  jmp alltraps
801075b7:	e9 48 f6 ff ff       	jmp    80106c04 <alltraps>

801075bc <vector78>:
.globl vector78
vector78:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $78
801075be:	6a 4e                	push   $0x4e
  jmp alltraps
801075c0:	e9 3f f6 ff ff       	jmp    80106c04 <alltraps>

801075c5 <vector79>:
.globl vector79
vector79:
  pushl $0
801075c5:	6a 00                	push   $0x0
  pushl $79
801075c7:	6a 4f                	push   $0x4f
  jmp alltraps
801075c9:	e9 36 f6 ff ff       	jmp    80106c04 <alltraps>

801075ce <vector80>:
.globl vector80
vector80:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $80
801075d0:	6a 50                	push   $0x50
  jmp alltraps
801075d2:	e9 2d f6 ff ff       	jmp    80106c04 <alltraps>

801075d7 <vector81>:
.globl vector81
vector81:
  pushl $0
801075d7:	6a 00                	push   $0x0
  pushl $81
801075d9:	6a 51                	push   $0x51
  jmp alltraps
801075db:	e9 24 f6 ff ff       	jmp    80106c04 <alltraps>

801075e0 <vector82>:
.globl vector82
vector82:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $82
801075e2:	6a 52                	push   $0x52
  jmp alltraps
801075e4:	e9 1b f6 ff ff       	jmp    80106c04 <alltraps>

801075e9 <vector83>:
.globl vector83
vector83:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $83
801075eb:	6a 53                	push   $0x53
  jmp alltraps
801075ed:	e9 12 f6 ff ff       	jmp    80106c04 <alltraps>

801075f2 <vector84>:
.globl vector84
vector84:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $84
801075f4:	6a 54                	push   $0x54
  jmp alltraps
801075f6:	e9 09 f6 ff ff       	jmp    80106c04 <alltraps>

801075fb <vector85>:
.globl vector85
vector85:
  pushl $0
801075fb:	6a 00                	push   $0x0
  pushl $85
801075fd:	6a 55                	push   $0x55
  jmp alltraps
801075ff:	e9 00 f6 ff ff       	jmp    80106c04 <alltraps>

80107604 <vector86>:
.globl vector86
vector86:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $86
80107606:	6a 56                	push   $0x56
  jmp alltraps
80107608:	e9 f7 f5 ff ff       	jmp    80106c04 <alltraps>

8010760d <vector87>:
.globl vector87
vector87:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $87
8010760f:	6a 57                	push   $0x57
  jmp alltraps
80107611:	e9 ee f5 ff ff       	jmp    80106c04 <alltraps>

80107616 <vector88>:
.globl vector88
vector88:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $88
80107618:	6a 58                	push   $0x58
  jmp alltraps
8010761a:	e9 e5 f5 ff ff       	jmp    80106c04 <alltraps>

8010761f <vector89>:
.globl vector89
vector89:
  pushl $0
8010761f:	6a 00                	push   $0x0
  pushl $89
80107621:	6a 59                	push   $0x59
  jmp alltraps
80107623:	e9 dc f5 ff ff       	jmp    80106c04 <alltraps>

80107628 <vector90>:
.globl vector90
vector90:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $90
8010762a:	6a 5a                	push   $0x5a
  jmp alltraps
8010762c:	e9 d3 f5 ff ff       	jmp    80106c04 <alltraps>

80107631 <vector91>:
.globl vector91
vector91:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $91
80107633:	6a 5b                	push   $0x5b
  jmp alltraps
80107635:	e9 ca f5 ff ff       	jmp    80106c04 <alltraps>

8010763a <vector92>:
.globl vector92
vector92:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $92
8010763c:	6a 5c                	push   $0x5c
  jmp alltraps
8010763e:	e9 c1 f5 ff ff       	jmp    80106c04 <alltraps>

80107643 <vector93>:
.globl vector93
vector93:
  pushl $0
80107643:	6a 00                	push   $0x0
  pushl $93
80107645:	6a 5d                	push   $0x5d
  jmp alltraps
80107647:	e9 b8 f5 ff ff       	jmp    80106c04 <alltraps>

8010764c <vector94>:
.globl vector94
vector94:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $94
8010764e:	6a 5e                	push   $0x5e
  jmp alltraps
80107650:	e9 af f5 ff ff       	jmp    80106c04 <alltraps>

80107655 <vector95>:
.globl vector95
vector95:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $95
80107657:	6a 5f                	push   $0x5f
  jmp alltraps
80107659:	e9 a6 f5 ff ff       	jmp    80106c04 <alltraps>

8010765e <vector96>:
.globl vector96
vector96:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $96
80107660:	6a 60                	push   $0x60
  jmp alltraps
80107662:	e9 9d f5 ff ff       	jmp    80106c04 <alltraps>

80107667 <vector97>:
.globl vector97
vector97:
  pushl $0
80107667:	6a 00                	push   $0x0
  pushl $97
80107669:	6a 61                	push   $0x61
  jmp alltraps
8010766b:	e9 94 f5 ff ff       	jmp    80106c04 <alltraps>

80107670 <vector98>:
.globl vector98
vector98:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $98
80107672:	6a 62                	push   $0x62
  jmp alltraps
80107674:	e9 8b f5 ff ff       	jmp    80106c04 <alltraps>

80107679 <vector99>:
.globl vector99
vector99:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $99
8010767b:	6a 63                	push   $0x63
  jmp alltraps
8010767d:	e9 82 f5 ff ff       	jmp    80106c04 <alltraps>

80107682 <vector100>:
.globl vector100
vector100:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $100
80107684:	6a 64                	push   $0x64
  jmp alltraps
80107686:	e9 79 f5 ff ff       	jmp    80106c04 <alltraps>

8010768b <vector101>:
.globl vector101
vector101:
  pushl $0
8010768b:	6a 00                	push   $0x0
  pushl $101
8010768d:	6a 65                	push   $0x65
  jmp alltraps
8010768f:	e9 70 f5 ff ff       	jmp    80106c04 <alltraps>

80107694 <vector102>:
.globl vector102
vector102:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $102
80107696:	6a 66                	push   $0x66
  jmp alltraps
80107698:	e9 67 f5 ff ff       	jmp    80106c04 <alltraps>

8010769d <vector103>:
.globl vector103
vector103:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $103
8010769f:	6a 67                	push   $0x67
  jmp alltraps
801076a1:	e9 5e f5 ff ff       	jmp    80106c04 <alltraps>

801076a6 <vector104>:
.globl vector104
vector104:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $104
801076a8:	6a 68                	push   $0x68
  jmp alltraps
801076aa:	e9 55 f5 ff ff       	jmp    80106c04 <alltraps>

801076af <vector105>:
.globl vector105
vector105:
  pushl $0
801076af:	6a 00                	push   $0x0
  pushl $105
801076b1:	6a 69                	push   $0x69
  jmp alltraps
801076b3:	e9 4c f5 ff ff       	jmp    80106c04 <alltraps>

801076b8 <vector106>:
.globl vector106
vector106:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $106
801076ba:	6a 6a                	push   $0x6a
  jmp alltraps
801076bc:	e9 43 f5 ff ff       	jmp    80106c04 <alltraps>

801076c1 <vector107>:
.globl vector107
vector107:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $107
801076c3:	6a 6b                	push   $0x6b
  jmp alltraps
801076c5:	e9 3a f5 ff ff       	jmp    80106c04 <alltraps>

801076ca <vector108>:
.globl vector108
vector108:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $108
801076cc:	6a 6c                	push   $0x6c
  jmp alltraps
801076ce:	e9 31 f5 ff ff       	jmp    80106c04 <alltraps>

801076d3 <vector109>:
.globl vector109
vector109:
  pushl $0
801076d3:	6a 00                	push   $0x0
  pushl $109
801076d5:	6a 6d                	push   $0x6d
  jmp alltraps
801076d7:	e9 28 f5 ff ff       	jmp    80106c04 <alltraps>

801076dc <vector110>:
.globl vector110
vector110:
  pushl $0
801076dc:	6a 00                	push   $0x0
  pushl $110
801076de:	6a 6e                	push   $0x6e
  jmp alltraps
801076e0:	e9 1f f5 ff ff       	jmp    80106c04 <alltraps>

801076e5 <vector111>:
.globl vector111
vector111:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $111
801076e7:	6a 6f                	push   $0x6f
  jmp alltraps
801076e9:	e9 16 f5 ff ff       	jmp    80106c04 <alltraps>

801076ee <vector112>:
.globl vector112
vector112:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $112
801076f0:	6a 70                	push   $0x70
  jmp alltraps
801076f2:	e9 0d f5 ff ff       	jmp    80106c04 <alltraps>

801076f7 <vector113>:
.globl vector113
vector113:
  pushl $0
801076f7:	6a 00                	push   $0x0
  pushl $113
801076f9:	6a 71                	push   $0x71
  jmp alltraps
801076fb:	e9 04 f5 ff ff       	jmp    80106c04 <alltraps>

80107700 <vector114>:
.globl vector114
vector114:
  pushl $0
80107700:	6a 00                	push   $0x0
  pushl $114
80107702:	6a 72                	push   $0x72
  jmp alltraps
80107704:	e9 fb f4 ff ff       	jmp    80106c04 <alltraps>

80107709 <vector115>:
.globl vector115
vector115:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $115
8010770b:	6a 73                	push   $0x73
  jmp alltraps
8010770d:	e9 f2 f4 ff ff       	jmp    80106c04 <alltraps>

80107712 <vector116>:
.globl vector116
vector116:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $116
80107714:	6a 74                	push   $0x74
  jmp alltraps
80107716:	e9 e9 f4 ff ff       	jmp    80106c04 <alltraps>

8010771b <vector117>:
.globl vector117
vector117:
  pushl $0
8010771b:	6a 00                	push   $0x0
  pushl $117
8010771d:	6a 75                	push   $0x75
  jmp alltraps
8010771f:	e9 e0 f4 ff ff       	jmp    80106c04 <alltraps>

80107724 <vector118>:
.globl vector118
vector118:
  pushl $0
80107724:	6a 00                	push   $0x0
  pushl $118
80107726:	6a 76                	push   $0x76
  jmp alltraps
80107728:	e9 d7 f4 ff ff       	jmp    80106c04 <alltraps>

8010772d <vector119>:
.globl vector119
vector119:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $119
8010772f:	6a 77                	push   $0x77
  jmp alltraps
80107731:	e9 ce f4 ff ff       	jmp    80106c04 <alltraps>

80107736 <vector120>:
.globl vector120
vector120:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $120
80107738:	6a 78                	push   $0x78
  jmp alltraps
8010773a:	e9 c5 f4 ff ff       	jmp    80106c04 <alltraps>

8010773f <vector121>:
.globl vector121
vector121:
  pushl $0
8010773f:	6a 00                	push   $0x0
  pushl $121
80107741:	6a 79                	push   $0x79
  jmp alltraps
80107743:	e9 bc f4 ff ff       	jmp    80106c04 <alltraps>

80107748 <vector122>:
.globl vector122
vector122:
  pushl $0
80107748:	6a 00                	push   $0x0
  pushl $122
8010774a:	6a 7a                	push   $0x7a
  jmp alltraps
8010774c:	e9 b3 f4 ff ff       	jmp    80106c04 <alltraps>

80107751 <vector123>:
.globl vector123
vector123:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $123
80107753:	6a 7b                	push   $0x7b
  jmp alltraps
80107755:	e9 aa f4 ff ff       	jmp    80106c04 <alltraps>

8010775a <vector124>:
.globl vector124
vector124:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $124
8010775c:	6a 7c                	push   $0x7c
  jmp alltraps
8010775e:	e9 a1 f4 ff ff       	jmp    80106c04 <alltraps>

80107763 <vector125>:
.globl vector125
vector125:
  pushl $0
80107763:	6a 00                	push   $0x0
  pushl $125
80107765:	6a 7d                	push   $0x7d
  jmp alltraps
80107767:	e9 98 f4 ff ff       	jmp    80106c04 <alltraps>

8010776c <vector126>:
.globl vector126
vector126:
  pushl $0
8010776c:	6a 00                	push   $0x0
  pushl $126
8010776e:	6a 7e                	push   $0x7e
  jmp alltraps
80107770:	e9 8f f4 ff ff       	jmp    80106c04 <alltraps>

80107775 <vector127>:
.globl vector127
vector127:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $127
80107777:	6a 7f                	push   $0x7f
  jmp alltraps
80107779:	e9 86 f4 ff ff       	jmp    80106c04 <alltraps>

8010777e <vector128>:
.globl vector128
vector128:
  pushl $0
8010777e:	6a 00                	push   $0x0
  pushl $128
80107780:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107785:	e9 7a f4 ff ff       	jmp    80106c04 <alltraps>

8010778a <vector129>:
.globl vector129
vector129:
  pushl $0
8010778a:	6a 00                	push   $0x0
  pushl $129
8010778c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107791:	e9 6e f4 ff ff       	jmp    80106c04 <alltraps>

80107796 <vector130>:
.globl vector130
vector130:
  pushl $0
80107796:	6a 00                	push   $0x0
  pushl $130
80107798:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010779d:	e9 62 f4 ff ff       	jmp    80106c04 <alltraps>

801077a2 <vector131>:
.globl vector131
vector131:
  pushl $0
801077a2:	6a 00                	push   $0x0
  pushl $131
801077a4:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801077a9:	e9 56 f4 ff ff       	jmp    80106c04 <alltraps>

801077ae <vector132>:
.globl vector132
vector132:
  pushl $0
801077ae:	6a 00                	push   $0x0
  pushl $132
801077b0:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801077b5:	e9 4a f4 ff ff       	jmp    80106c04 <alltraps>

801077ba <vector133>:
.globl vector133
vector133:
  pushl $0
801077ba:	6a 00                	push   $0x0
  pushl $133
801077bc:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801077c1:	e9 3e f4 ff ff       	jmp    80106c04 <alltraps>

801077c6 <vector134>:
.globl vector134
vector134:
  pushl $0
801077c6:	6a 00                	push   $0x0
  pushl $134
801077c8:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801077cd:	e9 32 f4 ff ff       	jmp    80106c04 <alltraps>

801077d2 <vector135>:
.globl vector135
vector135:
  pushl $0
801077d2:	6a 00                	push   $0x0
  pushl $135
801077d4:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801077d9:	e9 26 f4 ff ff       	jmp    80106c04 <alltraps>

801077de <vector136>:
.globl vector136
vector136:
  pushl $0
801077de:	6a 00                	push   $0x0
  pushl $136
801077e0:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801077e5:	e9 1a f4 ff ff       	jmp    80106c04 <alltraps>

801077ea <vector137>:
.globl vector137
vector137:
  pushl $0
801077ea:	6a 00                	push   $0x0
  pushl $137
801077ec:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801077f1:	e9 0e f4 ff ff       	jmp    80106c04 <alltraps>

801077f6 <vector138>:
.globl vector138
vector138:
  pushl $0
801077f6:	6a 00                	push   $0x0
  pushl $138
801077f8:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801077fd:	e9 02 f4 ff ff       	jmp    80106c04 <alltraps>

80107802 <vector139>:
.globl vector139
vector139:
  pushl $0
80107802:	6a 00                	push   $0x0
  pushl $139
80107804:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107809:	e9 f6 f3 ff ff       	jmp    80106c04 <alltraps>

8010780e <vector140>:
.globl vector140
vector140:
  pushl $0
8010780e:	6a 00                	push   $0x0
  pushl $140
80107810:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107815:	e9 ea f3 ff ff       	jmp    80106c04 <alltraps>

8010781a <vector141>:
.globl vector141
vector141:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $141
8010781c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107821:	e9 de f3 ff ff       	jmp    80106c04 <alltraps>

80107826 <vector142>:
.globl vector142
vector142:
  pushl $0
80107826:	6a 00                	push   $0x0
  pushl $142
80107828:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010782d:	e9 d2 f3 ff ff       	jmp    80106c04 <alltraps>

80107832 <vector143>:
.globl vector143
vector143:
  pushl $0
80107832:	6a 00                	push   $0x0
  pushl $143
80107834:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107839:	e9 c6 f3 ff ff       	jmp    80106c04 <alltraps>

8010783e <vector144>:
.globl vector144
vector144:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $144
80107840:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107845:	e9 ba f3 ff ff       	jmp    80106c04 <alltraps>

8010784a <vector145>:
.globl vector145
vector145:
  pushl $0
8010784a:	6a 00                	push   $0x0
  pushl $145
8010784c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107851:	e9 ae f3 ff ff       	jmp    80106c04 <alltraps>

80107856 <vector146>:
.globl vector146
vector146:
  pushl $0
80107856:	6a 00                	push   $0x0
  pushl $146
80107858:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010785d:	e9 a2 f3 ff ff       	jmp    80106c04 <alltraps>

80107862 <vector147>:
.globl vector147
vector147:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $147
80107864:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107869:	e9 96 f3 ff ff       	jmp    80106c04 <alltraps>

8010786e <vector148>:
.globl vector148
vector148:
  pushl $0
8010786e:	6a 00                	push   $0x0
  pushl $148
80107870:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107875:	e9 8a f3 ff ff       	jmp    80106c04 <alltraps>

8010787a <vector149>:
.globl vector149
vector149:
  pushl $0
8010787a:	6a 00                	push   $0x0
  pushl $149
8010787c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107881:	e9 7e f3 ff ff       	jmp    80106c04 <alltraps>

80107886 <vector150>:
.globl vector150
vector150:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $150
80107888:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010788d:	e9 72 f3 ff ff       	jmp    80106c04 <alltraps>

80107892 <vector151>:
.globl vector151
vector151:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $151
80107894:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107899:	e9 66 f3 ff ff       	jmp    80106c04 <alltraps>

8010789e <vector152>:
.globl vector152
vector152:
  pushl $0
8010789e:	6a 00                	push   $0x0
  pushl $152
801078a0:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801078a5:	e9 5a f3 ff ff       	jmp    80106c04 <alltraps>

801078aa <vector153>:
.globl vector153
vector153:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $153
801078ac:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801078b1:	e9 4e f3 ff ff       	jmp    80106c04 <alltraps>

801078b6 <vector154>:
.globl vector154
vector154:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $154
801078b8:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801078bd:	e9 42 f3 ff ff       	jmp    80106c04 <alltraps>

801078c2 <vector155>:
.globl vector155
vector155:
  pushl $0
801078c2:	6a 00                	push   $0x0
  pushl $155
801078c4:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801078c9:	e9 36 f3 ff ff       	jmp    80106c04 <alltraps>

801078ce <vector156>:
.globl vector156
vector156:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $156
801078d0:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801078d5:	e9 2a f3 ff ff       	jmp    80106c04 <alltraps>

801078da <vector157>:
.globl vector157
vector157:
  pushl $0
801078da:	6a 00                	push   $0x0
  pushl $157
801078dc:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801078e1:	e9 1e f3 ff ff       	jmp    80106c04 <alltraps>

801078e6 <vector158>:
.globl vector158
vector158:
  pushl $0
801078e6:	6a 00                	push   $0x0
  pushl $158
801078e8:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801078ed:	e9 12 f3 ff ff       	jmp    80106c04 <alltraps>

801078f2 <vector159>:
.globl vector159
vector159:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $159
801078f4:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801078f9:	e9 06 f3 ff ff       	jmp    80106c04 <alltraps>

801078fe <vector160>:
.globl vector160
vector160:
  pushl $0
801078fe:	6a 00                	push   $0x0
  pushl $160
80107900:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107905:	e9 fa f2 ff ff       	jmp    80106c04 <alltraps>

8010790a <vector161>:
.globl vector161
vector161:
  pushl $0
8010790a:	6a 00                	push   $0x0
  pushl $161
8010790c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107911:	e9 ee f2 ff ff       	jmp    80106c04 <alltraps>

80107916 <vector162>:
.globl vector162
vector162:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $162
80107918:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010791d:	e9 e2 f2 ff ff       	jmp    80106c04 <alltraps>

80107922 <vector163>:
.globl vector163
vector163:
  pushl $0
80107922:	6a 00                	push   $0x0
  pushl $163
80107924:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107929:	e9 d6 f2 ff ff       	jmp    80106c04 <alltraps>

8010792e <vector164>:
.globl vector164
vector164:
  pushl $0
8010792e:	6a 00                	push   $0x0
  pushl $164
80107930:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107935:	e9 ca f2 ff ff       	jmp    80106c04 <alltraps>

8010793a <vector165>:
.globl vector165
vector165:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $165
8010793c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107941:	e9 be f2 ff ff       	jmp    80106c04 <alltraps>

80107946 <vector166>:
.globl vector166
vector166:
  pushl $0
80107946:	6a 00                	push   $0x0
  pushl $166
80107948:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010794d:	e9 b2 f2 ff ff       	jmp    80106c04 <alltraps>

80107952 <vector167>:
.globl vector167
vector167:
  pushl $0
80107952:	6a 00                	push   $0x0
  pushl $167
80107954:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107959:	e9 a6 f2 ff ff       	jmp    80106c04 <alltraps>

8010795e <vector168>:
.globl vector168
vector168:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $168
80107960:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107965:	e9 9a f2 ff ff       	jmp    80106c04 <alltraps>

8010796a <vector169>:
.globl vector169
vector169:
  pushl $0
8010796a:	6a 00                	push   $0x0
  pushl $169
8010796c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107971:	e9 8e f2 ff ff       	jmp    80106c04 <alltraps>

80107976 <vector170>:
.globl vector170
vector170:
  pushl $0
80107976:	6a 00                	push   $0x0
  pushl $170
80107978:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010797d:	e9 82 f2 ff ff       	jmp    80106c04 <alltraps>

80107982 <vector171>:
.globl vector171
vector171:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $171
80107984:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107989:	e9 76 f2 ff ff       	jmp    80106c04 <alltraps>

8010798e <vector172>:
.globl vector172
vector172:
  pushl $0
8010798e:	6a 00                	push   $0x0
  pushl $172
80107990:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107995:	e9 6a f2 ff ff       	jmp    80106c04 <alltraps>

8010799a <vector173>:
.globl vector173
vector173:
  pushl $0
8010799a:	6a 00                	push   $0x0
  pushl $173
8010799c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801079a1:	e9 5e f2 ff ff       	jmp    80106c04 <alltraps>

801079a6 <vector174>:
.globl vector174
vector174:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $174
801079a8:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801079ad:	e9 52 f2 ff ff       	jmp    80106c04 <alltraps>

801079b2 <vector175>:
.globl vector175
vector175:
  pushl $0
801079b2:	6a 00                	push   $0x0
  pushl $175
801079b4:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801079b9:	e9 46 f2 ff ff       	jmp    80106c04 <alltraps>

801079be <vector176>:
.globl vector176
vector176:
  pushl $0
801079be:	6a 00                	push   $0x0
  pushl $176
801079c0:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801079c5:	e9 3a f2 ff ff       	jmp    80106c04 <alltraps>

801079ca <vector177>:
.globl vector177
vector177:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $177
801079cc:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801079d1:	e9 2e f2 ff ff       	jmp    80106c04 <alltraps>

801079d6 <vector178>:
.globl vector178
vector178:
  pushl $0
801079d6:	6a 00                	push   $0x0
  pushl $178
801079d8:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801079dd:	e9 22 f2 ff ff       	jmp    80106c04 <alltraps>

801079e2 <vector179>:
.globl vector179
vector179:
  pushl $0
801079e2:	6a 00                	push   $0x0
  pushl $179
801079e4:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801079e9:	e9 16 f2 ff ff       	jmp    80106c04 <alltraps>

801079ee <vector180>:
.globl vector180
vector180:
  pushl $0
801079ee:	6a 00                	push   $0x0
  pushl $180
801079f0:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801079f5:	e9 0a f2 ff ff       	jmp    80106c04 <alltraps>

801079fa <vector181>:
.globl vector181
vector181:
  pushl $0
801079fa:	6a 00                	push   $0x0
  pushl $181
801079fc:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107a01:	e9 fe f1 ff ff       	jmp    80106c04 <alltraps>

80107a06 <vector182>:
.globl vector182
vector182:
  pushl $0
80107a06:	6a 00                	push   $0x0
  pushl $182
80107a08:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107a0d:	e9 f2 f1 ff ff       	jmp    80106c04 <alltraps>

80107a12 <vector183>:
.globl vector183
vector183:
  pushl $0
80107a12:	6a 00                	push   $0x0
  pushl $183
80107a14:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107a19:	e9 e6 f1 ff ff       	jmp    80106c04 <alltraps>

80107a1e <vector184>:
.globl vector184
vector184:
  pushl $0
80107a1e:	6a 00                	push   $0x0
  pushl $184
80107a20:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107a25:	e9 da f1 ff ff       	jmp    80106c04 <alltraps>

80107a2a <vector185>:
.globl vector185
vector185:
  pushl $0
80107a2a:	6a 00                	push   $0x0
  pushl $185
80107a2c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107a31:	e9 ce f1 ff ff       	jmp    80106c04 <alltraps>

80107a36 <vector186>:
.globl vector186
vector186:
  pushl $0
80107a36:	6a 00                	push   $0x0
  pushl $186
80107a38:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107a3d:	e9 c2 f1 ff ff       	jmp    80106c04 <alltraps>

80107a42 <vector187>:
.globl vector187
vector187:
  pushl $0
80107a42:	6a 00                	push   $0x0
  pushl $187
80107a44:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107a49:	e9 b6 f1 ff ff       	jmp    80106c04 <alltraps>

80107a4e <vector188>:
.globl vector188
vector188:
  pushl $0
80107a4e:	6a 00                	push   $0x0
  pushl $188
80107a50:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107a55:	e9 aa f1 ff ff       	jmp    80106c04 <alltraps>

80107a5a <vector189>:
.globl vector189
vector189:
  pushl $0
80107a5a:	6a 00                	push   $0x0
  pushl $189
80107a5c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107a61:	e9 9e f1 ff ff       	jmp    80106c04 <alltraps>

80107a66 <vector190>:
.globl vector190
vector190:
  pushl $0
80107a66:	6a 00                	push   $0x0
  pushl $190
80107a68:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107a6d:	e9 92 f1 ff ff       	jmp    80106c04 <alltraps>

80107a72 <vector191>:
.globl vector191
vector191:
  pushl $0
80107a72:	6a 00                	push   $0x0
  pushl $191
80107a74:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107a79:	e9 86 f1 ff ff       	jmp    80106c04 <alltraps>

80107a7e <vector192>:
.globl vector192
vector192:
  pushl $0
80107a7e:	6a 00                	push   $0x0
  pushl $192
80107a80:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107a85:	e9 7a f1 ff ff       	jmp    80106c04 <alltraps>

80107a8a <vector193>:
.globl vector193
vector193:
  pushl $0
80107a8a:	6a 00                	push   $0x0
  pushl $193
80107a8c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107a91:	e9 6e f1 ff ff       	jmp    80106c04 <alltraps>

80107a96 <vector194>:
.globl vector194
vector194:
  pushl $0
80107a96:	6a 00                	push   $0x0
  pushl $194
80107a98:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107a9d:	e9 62 f1 ff ff       	jmp    80106c04 <alltraps>

80107aa2 <vector195>:
.globl vector195
vector195:
  pushl $0
80107aa2:	6a 00                	push   $0x0
  pushl $195
80107aa4:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107aa9:	e9 56 f1 ff ff       	jmp    80106c04 <alltraps>

80107aae <vector196>:
.globl vector196
vector196:
  pushl $0
80107aae:	6a 00                	push   $0x0
  pushl $196
80107ab0:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107ab5:	e9 4a f1 ff ff       	jmp    80106c04 <alltraps>

80107aba <vector197>:
.globl vector197
vector197:
  pushl $0
80107aba:	6a 00                	push   $0x0
  pushl $197
80107abc:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107ac1:	e9 3e f1 ff ff       	jmp    80106c04 <alltraps>

80107ac6 <vector198>:
.globl vector198
vector198:
  pushl $0
80107ac6:	6a 00                	push   $0x0
  pushl $198
80107ac8:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107acd:	e9 32 f1 ff ff       	jmp    80106c04 <alltraps>

80107ad2 <vector199>:
.globl vector199
vector199:
  pushl $0
80107ad2:	6a 00                	push   $0x0
  pushl $199
80107ad4:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107ad9:	e9 26 f1 ff ff       	jmp    80106c04 <alltraps>

80107ade <vector200>:
.globl vector200
vector200:
  pushl $0
80107ade:	6a 00                	push   $0x0
  pushl $200
80107ae0:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107ae5:	e9 1a f1 ff ff       	jmp    80106c04 <alltraps>

80107aea <vector201>:
.globl vector201
vector201:
  pushl $0
80107aea:	6a 00                	push   $0x0
  pushl $201
80107aec:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107af1:	e9 0e f1 ff ff       	jmp    80106c04 <alltraps>

80107af6 <vector202>:
.globl vector202
vector202:
  pushl $0
80107af6:	6a 00                	push   $0x0
  pushl $202
80107af8:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107afd:	e9 02 f1 ff ff       	jmp    80106c04 <alltraps>

80107b02 <vector203>:
.globl vector203
vector203:
  pushl $0
80107b02:	6a 00                	push   $0x0
  pushl $203
80107b04:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107b09:	e9 f6 f0 ff ff       	jmp    80106c04 <alltraps>

80107b0e <vector204>:
.globl vector204
vector204:
  pushl $0
80107b0e:	6a 00                	push   $0x0
  pushl $204
80107b10:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107b15:	e9 ea f0 ff ff       	jmp    80106c04 <alltraps>

80107b1a <vector205>:
.globl vector205
vector205:
  pushl $0
80107b1a:	6a 00                	push   $0x0
  pushl $205
80107b1c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107b21:	e9 de f0 ff ff       	jmp    80106c04 <alltraps>

80107b26 <vector206>:
.globl vector206
vector206:
  pushl $0
80107b26:	6a 00                	push   $0x0
  pushl $206
80107b28:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107b2d:	e9 d2 f0 ff ff       	jmp    80106c04 <alltraps>

80107b32 <vector207>:
.globl vector207
vector207:
  pushl $0
80107b32:	6a 00                	push   $0x0
  pushl $207
80107b34:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107b39:	e9 c6 f0 ff ff       	jmp    80106c04 <alltraps>

80107b3e <vector208>:
.globl vector208
vector208:
  pushl $0
80107b3e:	6a 00                	push   $0x0
  pushl $208
80107b40:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107b45:	e9 ba f0 ff ff       	jmp    80106c04 <alltraps>

80107b4a <vector209>:
.globl vector209
vector209:
  pushl $0
80107b4a:	6a 00                	push   $0x0
  pushl $209
80107b4c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107b51:	e9 ae f0 ff ff       	jmp    80106c04 <alltraps>

80107b56 <vector210>:
.globl vector210
vector210:
  pushl $0
80107b56:	6a 00                	push   $0x0
  pushl $210
80107b58:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107b5d:	e9 a2 f0 ff ff       	jmp    80106c04 <alltraps>

80107b62 <vector211>:
.globl vector211
vector211:
  pushl $0
80107b62:	6a 00                	push   $0x0
  pushl $211
80107b64:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107b69:	e9 96 f0 ff ff       	jmp    80106c04 <alltraps>

80107b6e <vector212>:
.globl vector212
vector212:
  pushl $0
80107b6e:	6a 00                	push   $0x0
  pushl $212
80107b70:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107b75:	e9 8a f0 ff ff       	jmp    80106c04 <alltraps>

80107b7a <vector213>:
.globl vector213
vector213:
  pushl $0
80107b7a:	6a 00                	push   $0x0
  pushl $213
80107b7c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107b81:	e9 7e f0 ff ff       	jmp    80106c04 <alltraps>

80107b86 <vector214>:
.globl vector214
vector214:
  pushl $0
80107b86:	6a 00                	push   $0x0
  pushl $214
80107b88:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107b8d:	e9 72 f0 ff ff       	jmp    80106c04 <alltraps>

80107b92 <vector215>:
.globl vector215
vector215:
  pushl $0
80107b92:	6a 00                	push   $0x0
  pushl $215
80107b94:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107b99:	e9 66 f0 ff ff       	jmp    80106c04 <alltraps>

80107b9e <vector216>:
.globl vector216
vector216:
  pushl $0
80107b9e:	6a 00                	push   $0x0
  pushl $216
80107ba0:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107ba5:	e9 5a f0 ff ff       	jmp    80106c04 <alltraps>

80107baa <vector217>:
.globl vector217
vector217:
  pushl $0
80107baa:	6a 00                	push   $0x0
  pushl $217
80107bac:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107bb1:	e9 4e f0 ff ff       	jmp    80106c04 <alltraps>

80107bb6 <vector218>:
.globl vector218
vector218:
  pushl $0
80107bb6:	6a 00                	push   $0x0
  pushl $218
80107bb8:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107bbd:	e9 42 f0 ff ff       	jmp    80106c04 <alltraps>

80107bc2 <vector219>:
.globl vector219
vector219:
  pushl $0
80107bc2:	6a 00                	push   $0x0
  pushl $219
80107bc4:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107bc9:	e9 36 f0 ff ff       	jmp    80106c04 <alltraps>

80107bce <vector220>:
.globl vector220
vector220:
  pushl $0
80107bce:	6a 00                	push   $0x0
  pushl $220
80107bd0:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107bd5:	e9 2a f0 ff ff       	jmp    80106c04 <alltraps>

80107bda <vector221>:
.globl vector221
vector221:
  pushl $0
80107bda:	6a 00                	push   $0x0
  pushl $221
80107bdc:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107be1:	e9 1e f0 ff ff       	jmp    80106c04 <alltraps>

80107be6 <vector222>:
.globl vector222
vector222:
  pushl $0
80107be6:	6a 00                	push   $0x0
  pushl $222
80107be8:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107bed:	e9 12 f0 ff ff       	jmp    80106c04 <alltraps>

80107bf2 <vector223>:
.globl vector223
vector223:
  pushl $0
80107bf2:	6a 00                	push   $0x0
  pushl $223
80107bf4:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107bf9:	e9 06 f0 ff ff       	jmp    80106c04 <alltraps>

80107bfe <vector224>:
.globl vector224
vector224:
  pushl $0
80107bfe:	6a 00                	push   $0x0
  pushl $224
80107c00:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107c05:	e9 fa ef ff ff       	jmp    80106c04 <alltraps>

80107c0a <vector225>:
.globl vector225
vector225:
  pushl $0
80107c0a:	6a 00                	push   $0x0
  pushl $225
80107c0c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107c11:	e9 ee ef ff ff       	jmp    80106c04 <alltraps>

80107c16 <vector226>:
.globl vector226
vector226:
  pushl $0
80107c16:	6a 00                	push   $0x0
  pushl $226
80107c18:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107c1d:	e9 e2 ef ff ff       	jmp    80106c04 <alltraps>

80107c22 <vector227>:
.globl vector227
vector227:
  pushl $0
80107c22:	6a 00                	push   $0x0
  pushl $227
80107c24:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107c29:	e9 d6 ef ff ff       	jmp    80106c04 <alltraps>

80107c2e <vector228>:
.globl vector228
vector228:
  pushl $0
80107c2e:	6a 00                	push   $0x0
  pushl $228
80107c30:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107c35:	e9 ca ef ff ff       	jmp    80106c04 <alltraps>

80107c3a <vector229>:
.globl vector229
vector229:
  pushl $0
80107c3a:	6a 00                	push   $0x0
  pushl $229
80107c3c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107c41:	e9 be ef ff ff       	jmp    80106c04 <alltraps>

80107c46 <vector230>:
.globl vector230
vector230:
  pushl $0
80107c46:	6a 00                	push   $0x0
  pushl $230
80107c48:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107c4d:	e9 b2 ef ff ff       	jmp    80106c04 <alltraps>

80107c52 <vector231>:
.globl vector231
vector231:
  pushl $0
80107c52:	6a 00                	push   $0x0
  pushl $231
80107c54:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107c59:	e9 a6 ef ff ff       	jmp    80106c04 <alltraps>

80107c5e <vector232>:
.globl vector232
vector232:
  pushl $0
80107c5e:	6a 00                	push   $0x0
  pushl $232
80107c60:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107c65:	e9 9a ef ff ff       	jmp    80106c04 <alltraps>

80107c6a <vector233>:
.globl vector233
vector233:
  pushl $0
80107c6a:	6a 00                	push   $0x0
  pushl $233
80107c6c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107c71:	e9 8e ef ff ff       	jmp    80106c04 <alltraps>

80107c76 <vector234>:
.globl vector234
vector234:
  pushl $0
80107c76:	6a 00                	push   $0x0
  pushl $234
80107c78:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107c7d:	e9 82 ef ff ff       	jmp    80106c04 <alltraps>

80107c82 <vector235>:
.globl vector235
vector235:
  pushl $0
80107c82:	6a 00                	push   $0x0
  pushl $235
80107c84:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107c89:	e9 76 ef ff ff       	jmp    80106c04 <alltraps>

80107c8e <vector236>:
.globl vector236
vector236:
  pushl $0
80107c8e:	6a 00                	push   $0x0
  pushl $236
80107c90:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107c95:	e9 6a ef ff ff       	jmp    80106c04 <alltraps>

80107c9a <vector237>:
.globl vector237
vector237:
  pushl $0
80107c9a:	6a 00                	push   $0x0
  pushl $237
80107c9c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107ca1:	e9 5e ef ff ff       	jmp    80106c04 <alltraps>

80107ca6 <vector238>:
.globl vector238
vector238:
  pushl $0
80107ca6:	6a 00                	push   $0x0
  pushl $238
80107ca8:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107cad:	e9 52 ef ff ff       	jmp    80106c04 <alltraps>

80107cb2 <vector239>:
.globl vector239
vector239:
  pushl $0
80107cb2:	6a 00                	push   $0x0
  pushl $239
80107cb4:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107cb9:	e9 46 ef ff ff       	jmp    80106c04 <alltraps>

80107cbe <vector240>:
.globl vector240
vector240:
  pushl $0
80107cbe:	6a 00                	push   $0x0
  pushl $240
80107cc0:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107cc5:	e9 3a ef ff ff       	jmp    80106c04 <alltraps>

80107cca <vector241>:
.globl vector241
vector241:
  pushl $0
80107cca:	6a 00                	push   $0x0
  pushl $241
80107ccc:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107cd1:	e9 2e ef ff ff       	jmp    80106c04 <alltraps>

80107cd6 <vector242>:
.globl vector242
vector242:
  pushl $0
80107cd6:	6a 00                	push   $0x0
  pushl $242
80107cd8:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107cdd:	e9 22 ef ff ff       	jmp    80106c04 <alltraps>

80107ce2 <vector243>:
.globl vector243
vector243:
  pushl $0
80107ce2:	6a 00                	push   $0x0
  pushl $243
80107ce4:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107ce9:	e9 16 ef ff ff       	jmp    80106c04 <alltraps>

80107cee <vector244>:
.globl vector244
vector244:
  pushl $0
80107cee:	6a 00                	push   $0x0
  pushl $244
80107cf0:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107cf5:	e9 0a ef ff ff       	jmp    80106c04 <alltraps>

80107cfa <vector245>:
.globl vector245
vector245:
  pushl $0
80107cfa:	6a 00                	push   $0x0
  pushl $245
80107cfc:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107d01:	e9 fe ee ff ff       	jmp    80106c04 <alltraps>

80107d06 <vector246>:
.globl vector246
vector246:
  pushl $0
80107d06:	6a 00                	push   $0x0
  pushl $246
80107d08:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107d0d:	e9 f2 ee ff ff       	jmp    80106c04 <alltraps>

80107d12 <vector247>:
.globl vector247
vector247:
  pushl $0
80107d12:	6a 00                	push   $0x0
  pushl $247
80107d14:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107d19:	e9 e6 ee ff ff       	jmp    80106c04 <alltraps>

80107d1e <vector248>:
.globl vector248
vector248:
  pushl $0
80107d1e:	6a 00                	push   $0x0
  pushl $248
80107d20:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107d25:	e9 da ee ff ff       	jmp    80106c04 <alltraps>

80107d2a <vector249>:
.globl vector249
vector249:
  pushl $0
80107d2a:	6a 00                	push   $0x0
  pushl $249
80107d2c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107d31:	e9 ce ee ff ff       	jmp    80106c04 <alltraps>

80107d36 <vector250>:
.globl vector250
vector250:
  pushl $0
80107d36:	6a 00                	push   $0x0
  pushl $250
80107d38:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107d3d:	e9 c2 ee ff ff       	jmp    80106c04 <alltraps>

80107d42 <vector251>:
.globl vector251
vector251:
  pushl $0
80107d42:	6a 00                	push   $0x0
  pushl $251
80107d44:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107d49:	e9 b6 ee ff ff       	jmp    80106c04 <alltraps>

80107d4e <vector252>:
.globl vector252
vector252:
  pushl $0
80107d4e:	6a 00                	push   $0x0
  pushl $252
80107d50:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107d55:	e9 aa ee ff ff       	jmp    80106c04 <alltraps>

80107d5a <vector253>:
.globl vector253
vector253:
  pushl $0
80107d5a:	6a 00                	push   $0x0
  pushl $253
80107d5c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107d61:	e9 9e ee ff ff       	jmp    80106c04 <alltraps>

80107d66 <vector254>:
.globl vector254
vector254:
  pushl $0
80107d66:	6a 00                	push   $0x0
  pushl $254
80107d68:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107d6d:	e9 92 ee ff ff       	jmp    80106c04 <alltraps>

80107d72 <vector255>:
.globl vector255
vector255:
  pushl $0
80107d72:	6a 00                	push   $0x0
  pushl $255
80107d74:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107d79:	e9 86 ee ff ff       	jmp    80106c04 <alltraps>
	...

80107d80 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107d80:	55                   	push   %ebp
80107d81:	89 e5                	mov    %esp,%ebp
80107d83:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107d86:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d89:	83 e8 01             	sub    $0x1,%eax
80107d8c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107d90:	8b 45 08             	mov    0x8(%ebp),%eax
80107d93:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107d97:	8b 45 08             	mov    0x8(%ebp),%eax
80107d9a:	c1 e8 10             	shr    $0x10,%eax
80107d9d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107da1:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107da4:	0f 01 10             	lgdtl  (%eax)
}
80107da7:	c9                   	leave  
80107da8:	c3                   	ret    

80107da9 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107da9:	55                   	push   %ebp
80107daa:	89 e5                	mov    %esp,%ebp
80107dac:	83 ec 04             	sub    $0x4,%esp
80107daf:	8b 45 08             	mov    0x8(%ebp),%eax
80107db2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107db6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107dba:	0f 00 d8             	ltr    %ax
}
80107dbd:	c9                   	leave  
80107dbe:	c3                   	ret    

80107dbf <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107dbf:	55                   	push   %ebp
80107dc0:	89 e5                	mov    %esp,%ebp
80107dc2:	83 ec 04             	sub    $0x4,%esp
80107dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80107dc8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107dcc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107dd0:	8e e8                	mov    %eax,%gs
}
80107dd2:	c9                   	leave  
80107dd3:	c3                   	ret    

80107dd4 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107dd4:	55                   	push   %ebp
80107dd5:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80107dda:	0f 22 d8             	mov    %eax,%cr3
}
80107ddd:	5d                   	pop    %ebp
80107dde:	c3                   	ret    

80107ddf <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107ddf:	55                   	push   %ebp
80107de0:	89 e5                	mov    %esp,%ebp
80107de2:	8b 45 08             	mov    0x8(%ebp),%eax
80107de5:	05 00 00 00 80       	add    $0x80000000,%eax
80107dea:	5d                   	pop    %ebp
80107deb:	c3                   	ret    

80107dec <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107dec:	55                   	push   %ebp
80107ded:	89 e5                	mov    %esp,%ebp
80107def:	8b 45 08             	mov    0x8(%ebp),%eax
80107df2:	05 00 00 00 80       	add    $0x80000000,%eax
80107df7:	5d                   	pop    %ebp
80107df8:	c3                   	ret    

80107df9 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107df9:	55                   	push   %ebp
80107dfa:	89 e5                	mov    %esp,%ebp
80107dfc:	53                   	push   %ebx
80107dfd:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107e00:	e8 1a b1 ff ff       	call   80102f1f <cpunum>
80107e05:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107e0b:	05 80 33 11 80       	add    $0x80113380,%eax
80107e10:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e16:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e28:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e2f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e33:	83 e2 f0             	and    $0xfffffff0,%edx
80107e36:	83 ca 0a             	or     $0xa,%edx
80107e39:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e3f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e43:	83 ca 10             	or     $0x10,%edx
80107e46:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e50:	83 e2 9f             	and    $0xffffff9f,%edx
80107e53:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e59:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107e5d:	83 ca 80             	or     $0xffffff80,%edx
80107e60:	88 50 7d             	mov    %dl,0x7d(%eax)
80107e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e66:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e6a:	83 ca 0f             	or     $0xf,%edx
80107e6d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e73:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e77:	83 e2 ef             	and    $0xffffffef,%edx
80107e7a:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e80:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e84:	83 e2 df             	and    $0xffffffdf,%edx
80107e87:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8d:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e91:	83 ca 40             	or     $0x40,%edx
80107e94:	88 50 7e             	mov    %dl,0x7e(%eax)
80107e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107e9e:	83 ca 80             	or     $0xffffff80,%edx
80107ea1:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ea4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea7:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eae:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107eb5:	ff ff 
80107eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eba:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107ec1:	00 00 
80107ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec6:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ed7:	83 e2 f0             	and    $0xfffffff0,%edx
80107eda:	83 ca 02             	or     $0x2,%edx
80107edd:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee6:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107eed:	83 ca 10             	or     $0x10,%edx
80107ef0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef9:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f00:	83 e2 9f             	and    $0xffffff9f,%edx
80107f03:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107f13:	83 ca 80             	or     $0xffffff80,%edx
80107f16:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f1f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f26:	83 ca 0f             	or     $0xf,%edx
80107f29:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f32:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f39:	83 e2 ef             	and    $0xffffffef,%edx
80107f3c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f45:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f4c:	83 e2 df             	and    $0xffffffdf,%edx
80107f4f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f58:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f5f:	83 ca 40             	or     $0x40,%edx
80107f62:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107f72:	83 ca 80             	or     $0xffffff80,%edx
80107f75:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7e:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f88:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107f8f:	ff ff 
80107f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f94:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107f9b:	00 00 
80107f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107fa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107faa:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107fb1:	83 e2 f0             	and    $0xfffffff0,%edx
80107fb4:	83 ca 0a             	or     $0xa,%edx
80107fb7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107fc7:	83 ca 10             	or     $0x10,%edx
80107fca:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd3:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107fda:	83 ca 60             	or     $0x60,%edx
80107fdd:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe6:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107fed:	83 ca 80             	or     $0xffffff80,%edx
80107ff0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108000:	83 ca 0f             	or     $0xf,%edx
80108003:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010800c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108013:	83 e2 ef             	and    $0xffffffef,%edx
80108016:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010801c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108026:	83 e2 df             	and    $0xffffffdf,%edx
80108029:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010802f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108032:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108039:	83 ca 40             	or     $0x40,%edx
8010803c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108045:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010804c:	83 ca 80             	or     $0xffffff80,%edx
8010804f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108058:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010805f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108062:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108069:	ff ff 
8010806b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010806e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108075:	00 00 
80108077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807a:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80108081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108084:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010808b:	83 e2 f0             	and    $0xfffffff0,%edx
8010808e:	83 ca 02             	or     $0x2,%edx
80108091:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809a:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801080a1:	83 ca 10             	or     $0x10,%edx
801080a4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801080aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ad:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801080b4:	83 ca 60             	or     $0x60,%edx
801080b7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801080bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801080c7:	83 ca 80             	or     $0xffffff80,%edx
801080ca:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801080d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801080da:	83 ca 0f             	or     $0xf,%edx
801080dd:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801080e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e6:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801080ed:	83 e2 ef             	and    $0xffffffef,%edx
801080f0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801080f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f9:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108100:	83 e2 df             	and    $0xffffffdf,%edx
80108103:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108113:	83 ca 40             	or     $0x40,%edx
80108116:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010811c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108126:	83 ca 80             	or     $0xffffff80,%edx
80108129:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010812f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108132:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010813c:	05 b4 00 00 00       	add    $0xb4,%eax
80108141:	89 c3                	mov    %eax,%ebx
80108143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108146:	05 b4 00 00 00       	add    $0xb4,%eax
8010814b:	c1 e8 10             	shr    $0x10,%eax
8010814e:	89 c1                	mov    %eax,%ecx
80108150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108153:	05 b4 00 00 00       	add    $0xb4,%eax
80108158:	c1 e8 18             	shr    $0x18,%eax
8010815b:	89 c2                	mov    %eax,%edx
8010815d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108160:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108167:	00 00 
80108169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108176:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
8010817c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010817f:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80108186:	83 e1 f0             	and    $0xfffffff0,%ecx
80108189:	83 c9 02             	or     $0x2,%ecx
8010818c:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80108192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108195:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
8010819c:	83 c9 10             	or     $0x10,%ecx
8010819f:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801081a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a8:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801081af:	83 e1 9f             	and    $0xffffff9f,%ecx
801081b2:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801081b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081bb:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
801081c2:	83 c9 80             	or     $0xffffff80,%ecx
801081c5:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
801081cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ce:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801081d5:	83 e1 f0             	and    $0xfffffff0,%ecx
801081d8:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801081de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e1:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801081e8:	83 e1 ef             	and    $0xffffffef,%ecx
801081eb:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801081f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f4:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
801081fb:	83 e1 df             	and    $0xffffffdf,%ecx
801081fe:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108207:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
8010820e:	83 c9 40             	or     $0x40,%ecx
80108211:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80108217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80108221:	83 c9 80             	or     $0xffffff80,%ecx
80108224:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010822a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822d:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108233:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108236:	83 c0 70             	add    $0x70,%eax
80108239:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80108240:	00 
80108241:	89 04 24             	mov    %eax,(%esp)
80108244:	e8 37 fb ff ff       	call   80107d80 <lgdt>
  loadgs(SEG_KCPU << 3);
80108249:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80108250:	e8 6a fb ff ff       	call   80107dbf <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80108255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108258:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
8010825e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108265:	00 00 00 00 
}
80108269:	83 c4 24             	add    $0x24,%esp
8010826c:	5b                   	pop    %ebx
8010826d:	5d                   	pop    %ebp
8010826e:	c3                   	ret    

8010826f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010826f:	55                   	push   %ebp
80108270:	89 e5                	mov    %esp,%ebp
80108272:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108275:	8b 45 0c             	mov    0xc(%ebp),%eax
80108278:	c1 e8 16             	shr    $0x16,%eax
8010827b:	c1 e0 02             	shl    $0x2,%eax
8010827e:	03 45 08             	add    0x8(%ebp),%eax
80108281:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108284:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108287:	8b 00                	mov    (%eax),%eax
80108289:	83 e0 01             	and    $0x1,%eax
8010828c:	84 c0                	test   %al,%al
8010828e:	74 17                	je     801082a7 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108290:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108293:	8b 00                	mov    (%eax),%eax
80108295:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010829a:	89 04 24             	mov    %eax,(%esp)
8010829d:	e8 4a fb ff ff       	call   80107dec <p2v>
801082a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082a5:	eb 4b                	jmp    801082f2 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801082a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801082ab:	74 0e                	je     801082bb <walkpgdir+0x4c>
801082ad:	e8 b5 a8 ff ff       	call   80102b67 <kalloc>
801082b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801082b9:	75 07                	jne    801082c2 <walkpgdir+0x53>
      return 0;
801082bb:	b8 00 00 00 00       	mov    $0x0,%eax
801082c0:	eb 41                	jmp    80108303 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801082c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082c9:	00 
801082ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082d1:	00 
801082d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d5:	89 04 24             	mov    %eax,(%esp)
801082d8:	e8 19 d3 ff ff       	call   801055f6 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
801082dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e0:	89 04 24             	mov    %eax,(%esp)
801082e3:	e8 f7 fa ff ff       	call   80107ddf <v2p>
801082e8:	89 c2                	mov    %eax,%edx
801082ea:	83 ca 07             	or     $0x7,%edx
801082ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f0:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801082f2:	8b 45 0c             	mov    0xc(%ebp),%eax
801082f5:	c1 e8 0c             	shr    $0xc,%eax
801082f8:	25 ff 03 00 00       	and    $0x3ff,%eax
801082fd:	c1 e0 02             	shl    $0x2,%eax
80108300:	03 45 f4             	add    -0xc(%ebp),%eax
}
80108303:	c9                   	leave  
80108304:	c3                   	ret    

80108305 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108305:	55                   	push   %ebp
80108306:	89 e5                	mov    %esp,%ebp
80108308:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010830b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010830e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108313:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108316:	8b 45 0c             	mov    0xc(%ebp),%eax
80108319:	03 45 10             	add    0x10(%ebp),%eax
8010831c:	83 e8 01             	sub    $0x1,%eax
8010831f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108324:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108327:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010832e:	00 
8010832f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108332:	89 44 24 04          	mov    %eax,0x4(%esp)
80108336:	8b 45 08             	mov    0x8(%ebp),%eax
80108339:	89 04 24             	mov    %eax,(%esp)
8010833c:	e8 2e ff ff ff       	call   8010826f <walkpgdir>
80108341:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108344:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108348:	75 07                	jne    80108351 <mappages+0x4c>
      return -1;
8010834a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010834f:	eb 46                	jmp    80108397 <mappages+0x92>
    if(*pte & PTE_P)
80108351:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108354:	8b 00                	mov    (%eax),%eax
80108356:	83 e0 01             	and    $0x1,%eax
80108359:	84 c0                	test   %al,%al
8010835b:	74 0c                	je     80108369 <mappages+0x64>
      panic("remap");
8010835d:	c7 04 24 a0 91 10 80 	movl   $0x801091a0,(%esp)
80108364:	e8 d4 81 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80108369:	8b 45 18             	mov    0x18(%ebp),%eax
8010836c:	0b 45 14             	or     0x14(%ebp),%eax
8010836f:	89 c2                	mov    %eax,%edx
80108371:	83 ca 01             	or     $0x1,%edx
80108374:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108377:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010837f:	74 10                	je     80108391 <mappages+0x8c>
      break;
    a += PGSIZE;
80108381:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108388:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010838f:	eb 96                	jmp    80108327 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108391:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108392:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108397:	c9                   	leave  
80108398:	c3                   	ret    

80108399 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108399:	55                   	push   %ebp
8010839a:	89 e5                	mov    %esp,%ebp
8010839c:	53                   	push   %ebx
8010839d:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801083a0:	e8 c2 a7 ff ff       	call   80102b67 <kalloc>
801083a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083ac:	75 0a                	jne    801083b8 <setupkvm+0x1f>
    return 0;
801083ae:	b8 00 00 00 00       	mov    $0x0,%eax
801083b3:	e9 98 00 00 00       	jmp    80108450 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
801083b8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083bf:	00 
801083c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801083c7:	00 
801083c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083cb:	89 04 24             	mov    %eax,(%esp)
801083ce:	e8 23 d2 ff ff       	call   801055f6 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801083d3:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801083da:	e8 0d fa ff ff       	call   80107dec <p2v>
801083df:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801083e4:	76 0c                	jbe    801083f2 <setupkvm+0x59>
    panic("PHYSTOP too high");
801083e6:	c7 04 24 a6 91 10 80 	movl   $0x801091a6,(%esp)
801083ed:	e8 4b 81 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801083f2:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
801083f9:	eb 49                	jmp    80108444 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
801083fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801083fe:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108401:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108404:	8b 50 04             	mov    0x4(%eax),%edx
80108407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840a:	8b 58 08             	mov    0x8(%eax),%ebx
8010840d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108410:	8b 40 04             	mov    0x4(%eax),%eax
80108413:	29 c3                	sub    %eax,%ebx
80108415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108418:	8b 00                	mov    (%eax),%eax
8010841a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010841e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108422:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108426:	89 44 24 04          	mov    %eax,0x4(%esp)
8010842a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010842d:	89 04 24             	mov    %eax,(%esp)
80108430:	e8 d0 fe ff ff       	call   80108305 <mappages>
80108435:	85 c0                	test   %eax,%eax
80108437:	79 07                	jns    80108440 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108439:	b8 00 00 00 00       	mov    $0x0,%eax
8010843e:	eb 10                	jmp    80108450 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108440:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108444:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
8010844b:	72 ae                	jb     801083fb <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
8010844d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108450:	83 c4 34             	add    $0x34,%esp
80108453:	5b                   	pop    %ebx
80108454:	5d                   	pop    %ebp
80108455:	c3                   	ret    

80108456 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108456:	55                   	push   %ebp
80108457:	89 e5                	mov    %esp,%ebp
80108459:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010845c:	e8 38 ff ff ff       	call   80108399 <setupkvm>
80108461:	a3 58 68 11 80       	mov    %eax,0x80116858
  switchkvm();
80108466:	e8 02 00 00 00       	call   8010846d <switchkvm>
}
8010846b:	c9                   	leave  
8010846c:	c3                   	ret    

8010846d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010846d:	55                   	push   %ebp
8010846e:	89 e5                	mov    %esp,%ebp
80108470:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108473:	a1 58 68 11 80       	mov    0x80116858,%eax
80108478:	89 04 24             	mov    %eax,(%esp)
8010847b:	e8 5f f9 ff ff       	call   80107ddf <v2p>
80108480:	89 04 24             	mov    %eax,(%esp)
80108483:	e8 4c f9 ff ff       	call   80107dd4 <lcr3>
}
80108488:	c9                   	leave  
80108489:	c3                   	ret    

8010848a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010848a:	55                   	push   %ebp
8010848b:	89 e5                	mov    %esp,%ebp
8010848d:	53                   	push   %ebx
8010848e:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80108491:	e8 59 d0 ff ff       	call   801054ef <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108496:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010849c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801084a3:	83 c2 08             	add    $0x8,%edx
801084a6:	89 d3                	mov    %edx,%ebx
801084a8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801084af:	83 c2 08             	add    $0x8,%edx
801084b2:	c1 ea 10             	shr    $0x10,%edx
801084b5:	89 d1                	mov    %edx,%ecx
801084b7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801084be:	83 c2 08             	add    $0x8,%edx
801084c1:	c1 ea 18             	shr    $0x18,%edx
801084c4:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
801084cb:	67 00 
801084cd:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
801084d4:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
801084da:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801084e1:	83 e1 f0             	and    $0xfffffff0,%ecx
801084e4:	83 c9 09             	or     $0x9,%ecx
801084e7:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801084ed:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
801084f4:	83 c9 10             	or     $0x10,%ecx
801084f7:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
801084fd:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108504:	83 e1 9f             	and    $0xffffff9f,%ecx
80108507:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010850d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108514:	83 c9 80             	or     $0xffffff80,%ecx
80108517:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010851d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108524:	83 e1 f0             	and    $0xfffffff0,%ecx
80108527:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010852d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108534:	83 e1 ef             	and    $0xffffffef,%ecx
80108537:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010853d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108544:	83 e1 df             	and    $0xffffffdf,%ecx
80108547:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010854d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108554:	83 c9 40             	or     $0x40,%ecx
80108557:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010855d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108564:	83 e1 7f             	and    $0x7f,%ecx
80108567:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010856d:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108573:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108579:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108580:	83 e2 ef             	and    $0xffffffef,%edx
80108583:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108589:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010858f:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108595:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010859b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801085a2:	8b 52 08             	mov    0x8(%edx),%edx
801085a5:	81 c2 00 10 00 00    	add    $0x1000,%edx
801085ab:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801085ae:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801085b5:	e8 ef f7 ff ff       	call   80107da9 <ltr>
  if(p->pgdir == 0)
801085ba:	8b 45 08             	mov    0x8(%ebp),%eax
801085bd:	8b 40 04             	mov    0x4(%eax),%eax
801085c0:	85 c0                	test   %eax,%eax
801085c2:	75 0c                	jne    801085d0 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801085c4:	c7 04 24 b7 91 10 80 	movl   $0x801091b7,(%esp)
801085cb:	e8 6d 7f ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801085d0:	8b 45 08             	mov    0x8(%ebp),%eax
801085d3:	8b 40 04             	mov    0x4(%eax),%eax
801085d6:	89 04 24             	mov    %eax,(%esp)
801085d9:	e8 01 f8 ff ff       	call   80107ddf <v2p>
801085de:	89 04 24             	mov    %eax,(%esp)
801085e1:	e8 ee f7 ff ff       	call   80107dd4 <lcr3>
  popcli();
801085e6:	e8 4c cf ff ff       	call   80105537 <popcli>
}
801085eb:	83 c4 14             	add    $0x14,%esp
801085ee:	5b                   	pop    %ebx
801085ef:	5d                   	pop    %ebp
801085f0:	c3                   	ret    

801085f1 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801085f1:	55                   	push   %ebp
801085f2:	89 e5                	mov    %esp,%ebp
801085f4:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801085f7:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801085fe:	76 0c                	jbe    8010860c <inituvm+0x1b>
    panic("inituvm: more than a page");
80108600:	c7 04 24 cb 91 10 80 	movl   $0x801091cb,(%esp)
80108607:	e8 31 7f ff ff       	call   8010053d <panic>
  mem = kalloc();
8010860c:	e8 56 a5 ff ff       	call   80102b67 <kalloc>
80108611:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108614:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010861b:	00 
8010861c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108623:	00 
80108624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108627:	89 04 24             	mov    %eax,(%esp)
8010862a:	e8 c7 cf ff ff       	call   801055f6 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010862f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108632:	89 04 24             	mov    %eax,(%esp)
80108635:	e8 a5 f7 ff ff       	call   80107ddf <v2p>
8010863a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108641:	00 
80108642:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108646:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010864d:	00 
8010864e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108655:	00 
80108656:	8b 45 08             	mov    0x8(%ebp),%eax
80108659:	89 04 24             	mov    %eax,(%esp)
8010865c:	e8 a4 fc ff ff       	call   80108305 <mappages>
  memmove(mem, init, sz);
80108661:	8b 45 10             	mov    0x10(%ebp),%eax
80108664:	89 44 24 08          	mov    %eax,0x8(%esp)
80108668:	8b 45 0c             	mov    0xc(%ebp),%eax
8010866b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010866f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108672:	89 04 24             	mov    %eax,(%esp)
80108675:	e8 4f d0 ff ff       	call   801056c9 <memmove>
}
8010867a:	c9                   	leave  
8010867b:	c3                   	ret    

8010867c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010867c:	55                   	push   %ebp
8010867d:	89 e5                	mov    %esp,%ebp
8010867f:	53                   	push   %ebx
80108680:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108683:	8b 45 0c             	mov    0xc(%ebp),%eax
80108686:	25 ff 0f 00 00       	and    $0xfff,%eax
8010868b:	85 c0                	test   %eax,%eax
8010868d:	74 0c                	je     8010869b <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
8010868f:	c7 04 24 e8 91 10 80 	movl   $0x801091e8,(%esp)
80108696:	e8 a2 7e ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010869b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086a2:	e9 ad 00 00 00       	jmp    80108754 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801086a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801086ad:	01 d0                	add    %edx,%eax
801086af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086b6:	00 
801086b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801086bb:	8b 45 08             	mov    0x8(%ebp),%eax
801086be:	89 04 24             	mov    %eax,(%esp)
801086c1:	e8 a9 fb ff ff       	call   8010826f <walkpgdir>
801086c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086cd:	75 0c                	jne    801086db <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801086cf:	c7 04 24 0b 92 10 80 	movl   $0x8010920b,(%esp)
801086d6:	e8 62 7e ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801086db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086de:	8b 00                	mov    (%eax),%eax
801086e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086e5:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801086e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086eb:	8b 55 18             	mov    0x18(%ebp),%edx
801086ee:	89 d1                	mov    %edx,%ecx
801086f0:	29 c1                	sub    %eax,%ecx
801086f2:	89 c8                	mov    %ecx,%eax
801086f4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801086f9:	77 11                	ja     8010870c <loaduvm+0x90>
      n = sz - i;
801086fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fe:	8b 55 18             	mov    0x18(%ebp),%edx
80108701:	89 d1                	mov    %edx,%ecx
80108703:	29 c1                	sub    %eax,%ecx
80108705:	89 c8                	mov    %ecx,%eax
80108707:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010870a:	eb 07                	jmp    80108713 <loaduvm+0x97>
    else
      n = PGSIZE;
8010870c:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108716:	8b 55 14             	mov    0x14(%ebp),%edx
80108719:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010871c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010871f:	89 04 24             	mov    %eax,(%esp)
80108722:	e8 c5 f6 ff ff       	call   80107dec <p2v>
80108727:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010872a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010872e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108732:	89 44 24 04          	mov    %eax,0x4(%esp)
80108736:	8b 45 10             	mov    0x10(%ebp),%eax
80108739:	89 04 24             	mov    %eax,(%esp)
8010873c:	e8 85 96 ff ff       	call   80101dc6 <readi>
80108741:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108744:	74 07                	je     8010874d <loaduvm+0xd1>
      return -1;
80108746:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010874b:	eb 18                	jmp    80108765 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010874d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108757:	3b 45 18             	cmp    0x18(%ebp),%eax
8010875a:	0f 82 47 ff ff ff    	jb     801086a7 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108760:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108765:	83 c4 24             	add    $0x24,%esp
80108768:	5b                   	pop    %ebx
80108769:	5d                   	pop    %ebp
8010876a:	c3                   	ret    

8010876b <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010876b:	55                   	push   %ebp
8010876c:	89 e5                	mov    %esp,%ebp
8010876e:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108771:	8b 45 10             	mov    0x10(%ebp),%eax
80108774:	85 c0                	test   %eax,%eax
80108776:	79 0a                	jns    80108782 <allocuvm+0x17>
    return 0;
80108778:	b8 00 00 00 00       	mov    $0x0,%eax
8010877d:	e9 c1 00 00 00       	jmp    80108843 <allocuvm+0xd8>
  if(newsz < oldsz)
80108782:	8b 45 10             	mov    0x10(%ebp),%eax
80108785:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108788:	73 08                	jae    80108792 <allocuvm+0x27>
    return oldsz;
8010878a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010878d:	e9 b1 00 00 00       	jmp    80108843 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108792:	8b 45 0c             	mov    0xc(%ebp),%eax
80108795:	05 ff 0f 00 00       	add    $0xfff,%eax
8010879a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010879f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801087a2:	e9 8d 00 00 00       	jmp    80108834 <allocuvm+0xc9>
    mem = kalloc();
801087a7:	e8 bb a3 ff ff       	call   80102b67 <kalloc>
801087ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801087af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801087b3:	75 2c                	jne    801087e1 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801087b5:	c7 04 24 29 92 10 80 	movl   $0x80109229,(%esp)
801087bc:	e8 e0 7b ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801087c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801087c4:	89 44 24 08          	mov    %eax,0x8(%esp)
801087c8:	8b 45 10             	mov    0x10(%ebp),%eax
801087cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801087cf:	8b 45 08             	mov    0x8(%ebp),%eax
801087d2:	89 04 24             	mov    %eax,(%esp)
801087d5:	e8 6b 00 00 00       	call   80108845 <deallocuvm>
      return 0;
801087da:	b8 00 00 00 00       	mov    $0x0,%eax
801087df:	eb 62                	jmp    80108843 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801087e1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087e8:	00 
801087e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801087f0:	00 
801087f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f4:	89 04 24             	mov    %eax,(%esp)
801087f7:	e8 fa cd ff ff       	call   801055f6 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801087fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087ff:	89 04 24             	mov    %eax,(%esp)
80108802:	e8 d8 f5 ff ff       	call   80107ddf <v2p>
80108807:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010880a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108811:	00 
80108812:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108816:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010881d:	00 
8010881e:	89 54 24 04          	mov    %edx,0x4(%esp)
80108822:	8b 45 08             	mov    0x8(%ebp),%eax
80108825:	89 04 24             	mov    %eax,(%esp)
80108828:	e8 d8 fa ff ff       	call   80108305 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010882d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108837:	3b 45 10             	cmp    0x10(%ebp),%eax
8010883a:	0f 82 67 ff ff ff    	jb     801087a7 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108840:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108843:	c9                   	leave  
80108844:	c3                   	ret    

80108845 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108845:	55                   	push   %ebp
80108846:	89 e5                	mov    %esp,%ebp
80108848:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010884b:	8b 45 10             	mov    0x10(%ebp),%eax
8010884e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108851:	72 08                	jb     8010885b <deallocuvm+0x16>
    return oldsz;
80108853:	8b 45 0c             	mov    0xc(%ebp),%eax
80108856:	e9 a4 00 00 00       	jmp    801088ff <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010885b:	8b 45 10             	mov    0x10(%ebp),%eax
8010885e:	05 ff 0f 00 00       	add    $0xfff,%eax
80108863:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108868:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010886b:	e9 80 00 00 00       	jmp    801088f0 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108873:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010887a:	00 
8010887b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010887f:	8b 45 08             	mov    0x8(%ebp),%eax
80108882:	89 04 24             	mov    %eax,(%esp)
80108885:	e8 e5 f9 ff ff       	call   8010826f <walkpgdir>
8010888a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010888d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108891:	75 09                	jne    8010889c <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108893:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010889a:	eb 4d                	jmp    801088e9 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
8010889c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010889f:	8b 00                	mov    (%eax),%eax
801088a1:	83 e0 01             	and    $0x1,%eax
801088a4:	84 c0                	test   %al,%al
801088a6:	74 41                	je     801088e9 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801088a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ab:	8b 00                	mov    (%eax),%eax
801088ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801088b5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801088b9:	75 0c                	jne    801088c7 <deallocuvm+0x82>
        panic("kfree");
801088bb:	c7 04 24 41 92 10 80 	movl   $0x80109241,(%esp)
801088c2:	e8 76 7c ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
801088c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088ca:	89 04 24             	mov    %eax,(%esp)
801088cd:	e8 1a f5 ff ff       	call   80107dec <p2v>
801088d2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801088d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801088d8:	89 04 24             	mov    %eax,(%esp)
801088db:	e8 ee a1 ff ff       	call   80102ace <kfree>
      *pte = 0;
801088e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801088e9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088f6:	0f 82 74 ff ff ff    	jb     80108870 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801088fc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801088ff:	c9                   	leave  
80108900:	c3                   	ret    

80108901 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108901:	55                   	push   %ebp
80108902:	89 e5                	mov    %esp,%ebp
80108904:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108907:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010890b:	75 0c                	jne    80108919 <freevm+0x18>
    panic("freevm: no pgdir");
8010890d:	c7 04 24 47 92 10 80 	movl   $0x80109247,(%esp)
80108914:	e8 24 7c ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108919:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108920:	00 
80108921:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108928:	80 
80108929:	8b 45 08             	mov    0x8(%ebp),%eax
8010892c:	89 04 24             	mov    %eax,(%esp)
8010892f:	e8 11 ff ff ff       	call   80108845 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108934:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010893b:	eb 3c                	jmp    80108979 <freevm+0x78>
    if(pgdir[i] & PTE_P){
8010893d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108940:	c1 e0 02             	shl    $0x2,%eax
80108943:	03 45 08             	add    0x8(%ebp),%eax
80108946:	8b 00                	mov    (%eax),%eax
80108948:	83 e0 01             	and    $0x1,%eax
8010894b:	84 c0                	test   %al,%al
8010894d:	74 26                	je     80108975 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010894f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108952:	c1 e0 02             	shl    $0x2,%eax
80108955:	03 45 08             	add    0x8(%ebp),%eax
80108958:	8b 00                	mov    (%eax),%eax
8010895a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010895f:	89 04 24             	mov    %eax,(%esp)
80108962:	e8 85 f4 ff ff       	call   80107dec <p2v>
80108967:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010896a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010896d:	89 04 24             	mov    %eax,(%esp)
80108970:	e8 59 a1 ff ff       	call   80102ace <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108975:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108979:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108980:	76 bb                	jbe    8010893d <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108982:	8b 45 08             	mov    0x8(%ebp),%eax
80108985:	89 04 24             	mov    %eax,(%esp)
80108988:	e8 41 a1 ff ff       	call   80102ace <kfree>
}
8010898d:	c9                   	leave  
8010898e:	c3                   	ret    

8010898f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010898f:	55                   	push   %ebp
80108990:	89 e5                	mov    %esp,%ebp
80108992:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108995:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010899c:	00 
8010899d:	8b 45 0c             	mov    0xc(%ebp),%eax
801089a0:	89 44 24 04          	mov    %eax,0x4(%esp)
801089a4:	8b 45 08             	mov    0x8(%ebp),%eax
801089a7:	89 04 24             	mov    %eax,(%esp)
801089aa:	e8 c0 f8 ff ff       	call   8010826f <walkpgdir>
801089af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801089b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801089b6:	75 0c                	jne    801089c4 <clearpteu+0x35>
    panic("clearpteu");
801089b8:	c7 04 24 58 92 10 80 	movl   $0x80109258,(%esp)
801089bf:	e8 79 7b ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
801089c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c7:	8b 00                	mov    (%eax),%eax
801089c9:	89 c2                	mov    %eax,%edx
801089cb:	83 e2 fb             	and    $0xfffffffb,%edx
801089ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d1:	89 10                	mov    %edx,(%eax)
}
801089d3:	c9                   	leave  
801089d4:	c3                   	ret    

801089d5 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801089d5:	55                   	push   %ebp
801089d6:	89 e5                	mov    %esp,%ebp
801089d8:	53                   	push   %ebx
801089d9:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801089dc:	e8 b8 f9 ff ff       	call   80108399 <setupkvm>
801089e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801089e4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801089e8:	75 0a                	jne    801089f4 <copyuvm+0x1f>
    return 0;
801089ea:	b8 00 00 00 00       	mov    $0x0,%eax
801089ef:	e9 fd 00 00 00       	jmp    80108af1 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801089f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801089fb:	e9 cc 00 00 00       	jmp    80108acc <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a0a:	00 
80108a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80108a12:	89 04 24             	mov    %eax,(%esp)
80108a15:	e8 55 f8 ff ff       	call   8010826f <walkpgdir>
80108a1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a21:	75 0c                	jne    80108a2f <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108a23:	c7 04 24 62 92 10 80 	movl   $0x80109262,(%esp)
80108a2a:	e8 0e 7b ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108a2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a32:	8b 00                	mov    (%eax),%eax
80108a34:	83 e0 01             	and    $0x1,%eax
80108a37:	85 c0                	test   %eax,%eax
80108a39:	75 0c                	jne    80108a47 <copyuvm+0x72>
      panic("copyuvm: page not present");
80108a3b:	c7 04 24 7c 92 10 80 	movl   $0x8010927c,(%esp)
80108a42:	e8 f6 7a ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108a47:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a4a:	8b 00                	mov    (%eax),%eax
80108a4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a51:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108a54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a57:	8b 00                	mov    (%eax),%eax
80108a59:	25 ff 0f 00 00       	and    $0xfff,%eax
80108a5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108a61:	e8 01 a1 ff ff       	call   80102b67 <kalloc>
80108a66:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108a69:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108a6d:	74 6e                	je     80108add <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108a6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a72:	89 04 24             	mov    %eax,(%esp)
80108a75:	e8 72 f3 ff ff       	call   80107dec <p2v>
80108a7a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108a81:	00 
80108a82:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a86:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a89:	89 04 24             	mov    %eax,(%esp)
80108a8c:	e8 38 cc ff ff       	call   801056c9 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108a91:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108a94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108a97:	89 04 24             	mov    %eax,(%esp)
80108a9a:	e8 40 f3 ff ff       	call   80107ddf <v2p>
80108a9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108aa2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80108aa6:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108aaa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ab1:	00 
80108ab2:	89 54 24 04          	mov    %edx,0x4(%esp)
80108ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ab9:	89 04 24             	mov    %eax,(%esp)
80108abc:	e8 44 f8 ff ff       	call   80108305 <mappages>
80108ac1:	85 c0                	test   %eax,%eax
80108ac3:	78 1b                	js     80108ae0 <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108ac5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108acf:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ad2:	0f 82 28 ff ff ff    	jb     80108a00 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108ad8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108adb:	eb 14                	jmp    80108af1 <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108add:	90                   	nop
80108ade:	eb 01                	jmp    80108ae1 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108ae0:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ae4:	89 04 24             	mov    %eax,(%esp)
80108ae7:	e8 15 fe ff ff       	call   80108901 <freevm>
  return 0;
80108aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108af1:	83 c4 44             	add    $0x44,%esp
80108af4:	5b                   	pop    %ebx
80108af5:	5d                   	pop    %ebp
80108af6:	c3                   	ret    

80108af7 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108af7:	55                   	push   %ebp
80108af8:	89 e5                	mov    %esp,%ebp
80108afa:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108afd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b04:	00 
80108b05:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b08:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80108b0f:	89 04 24             	mov    %eax,(%esp)
80108b12:	e8 58 f7 ff ff       	call   8010826f <walkpgdir>
80108b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b1d:	8b 00                	mov    (%eax),%eax
80108b1f:	83 e0 01             	and    $0x1,%eax
80108b22:	85 c0                	test   %eax,%eax
80108b24:	75 07                	jne    80108b2d <uva2ka+0x36>
    return 0;
80108b26:	b8 00 00 00 00       	mov    $0x0,%eax
80108b2b:	eb 25                	jmp    80108b52 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b30:	8b 00                	mov    (%eax),%eax
80108b32:	83 e0 04             	and    $0x4,%eax
80108b35:	85 c0                	test   %eax,%eax
80108b37:	75 07                	jne    80108b40 <uva2ka+0x49>
    return 0;
80108b39:	b8 00 00 00 00       	mov    $0x0,%eax
80108b3e:	eb 12                	jmp    80108b52 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b43:	8b 00                	mov    (%eax),%eax
80108b45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b4a:	89 04 24             	mov    %eax,(%esp)
80108b4d:	e8 9a f2 ff ff       	call   80107dec <p2v>
}
80108b52:	c9                   	leave  
80108b53:	c3                   	ret    

80108b54 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108b54:	55                   	push   %ebp
80108b55:	89 e5                	mov    %esp,%ebp
80108b57:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108b5a:	8b 45 10             	mov    0x10(%ebp),%eax
80108b5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108b60:	e9 8b 00 00 00       	jmp    80108bf0 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108b65:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b68:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108b70:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b73:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b77:	8b 45 08             	mov    0x8(%ebp),%eax
80108b7a:	89 04 24             	mov    %eax,(%esp)
80108b7d:	e8 75 ff ff ff       	call   80108af7 <uva2ka>
80108b82:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108b85:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108b89:	75 07                	jne    80108b92 <copyout+0x3e>
      return -1;
80108b8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b90:	eb 6d                	jmp    80108bff <copyout+0xab>
    n = PGSIZE - (va - va0);
80108b92:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b95:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108b98:	89 d1                	mov    %edx,%ecx
80108b9a:	29 c1                	sub    %eax,%ecx
80108b9c:	89 c8                	mov    %ecx,%eax
80108b9e:	05 00 10 00 00       	add    $0x1000,%eax
80108ba3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108ba6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ba9:	3b 45 14             	cmp    0x14(%ebp),%eax
80108bac:	76 06                	jbe    80108bb4 <copyout+0x60>
      n = len;
80108bae:	8b 45 14             	mov    0x14(%ebp),%eax
80108bb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108bb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
80108bba:	89 d1                	mov    %edx,%ecx
80108bbc:	29 c1                	sub    %eax,%ecx
80108bbe:	89 c8                	mov    %ecx,%eax
80108bc0:	03 45 e8             	add    -0x18(%ebp),%eax
80108bc3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108bc6:	89 54 24 08          	mov    %edx,0x8(%esp)
80108bca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108bcd:	89 54 24 04          	mov    %edx,0x4(%esp)
80108bd1:	89 04 24             	mov    %eax,(%esp)
80108bd4:	e8 f0 ca ff ff       	call   801056c9 <memmove>
    len -= n;
80108bd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bdc:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108bdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108be2:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108be5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108be8:	05 00 10 00 00       	add    $0x1000,%eax
80108bed:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108bf0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108bf4:	0f 85 6b ff ff ff    	jne    80108b65 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108bfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108bff:	c9                   	leave  
80108c00:	c3                   	ret    
80108c01:	00 00                	add    %al,(%eax)
	...

80108c04 <implicit_exit>:
.code32
.globl implicit_exit
.globl implicit_exit_end

implicit_exit:
	push %eax
80108c04:	50                   	push   %eax
	push $0xffffffff #fake address
80108c05:	6a ff                	push   $0xffffffff

	movl $2, %eax;
80108c07:	b8 02 00 00 00       	mov    $0x2,%eax
	int $64;
80108c0c:	cd 40                	int    $0x40
