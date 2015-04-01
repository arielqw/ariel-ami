
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
8010002d:	b8 87 37 10 80       	mov    $0x80103787,%eax
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
8010003a:	c7 44 24 04 f8 86 10 	movl   $0x801086f8,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
80100049:	e8 bc 4f 00 00       	call   8010500a <initlock>

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
801000bd:	e8 69 4f 00 00       	call   8010502b <acquire>

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
80100104:	e8 84 4f 00 00       	call   8010508d <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 c6 10 	movl   $0x8010c660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 2a 4c 00 00       	call   80104d4e <sleep>
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
8010017c:	e8 0c 4f 00 00       	call   8010508d <release>
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
80100198:	c7 04 24 ff 86 10 80 	movl   $0x801086ff,(%esp)
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
801001d3:	e8 00 26 00 00       	call   801027d8 <iderw>
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
801001ef:	c7 04 24 10 87 10 80 	movl   $0x80108710,(%esp)
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
80100210:	e8 c3 25 00 00       	call   801027d8 <iderw>
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
80100229:	c7 04 24 17 87 10 80 	movl   $0x80108717,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
8010023c:	e8 ea 4d 00 00       	call   8010502b <acquire>

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
8010029d:	e8 85 4b 00 00       	call   80104e27 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 c6 10 80 	movl   $0x8010c660,(%esp)
801002a9:	e8 df 4d 00 00       	call   8010508d <release>
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
801003bc:	e8 6a 4c 00 00       	call   8010502b <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 1e 87 10 80 	movl   $0x8010871e,(%esp)
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
801004af:	c7 45 ec 27 87 10 80 	movl   $0x80108727,-0x14(%ebp)
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
80100536:	e8 52 4b 00 00       	call   8010508d <release>
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
80100562:	c7 04 24 2e 87 10 80 	movl   $0x8010872e,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 3d 87 10 80 	movl   $0x8010873d,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 45 4b 00 00       	call   801050dc <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 3f 87 10 80 	movl   $0x8010873f,(%esp)
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
801006b2:	e8 96 4c 00 00       	call   8010534d <memmove>
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
801006e1:	e8 94 4b 00 00       	call   8010527a <memset>
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
80100776:	e8 ce 65 00 00       	call   80106d49 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 c2 65 00 00       	call   80106d49 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 b6 65 00 00       	call   80106d49 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 a9 65 00 00       	call   80106d49 <uartputc>
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
801007ba:	e8 6c 48 00 00       	call   8010502b <acquire>
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
801007ea:	e8 db 46 00 00       	call   80104eca <procdump>
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
801008f7:	e8 2b 45 00 00       	call   80104e27 <wakeup>
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
8010091e:	e8 6a 47 00 00       	call   8010508d <release>
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
80100931:	e8 a4 10 00 00       	call   801019da <iunlock>
  target = n;
80100936:	8b 45 10             	mov    0x10(%ebp),%eax
80100939:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
8010093c:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100943:	e8 e3 46 00 00       	call   8010502b <acquire>
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
80100961:	e8 27 47 00 00       	call   8010508d <release>
        ilock(ip);
80100966:	8b 45 08             	mov    0x8(%ebp),%eax
80100969:	89 04 24             	mov    %eax,(%esp)
8010096c:	e8 1b 0f 00 00       	call   8010188c <ilock>
        return -1;
80100971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100976:	e9 a9 00 00 00       	jmp    80100a24 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010097b:	c7 44 24 04 80 07 11 	movl   $0x80110780,0x4(%esp)
80100982:	80 
80100983:	c7 04 24 34 08 11 80 	movl   $0x80110834,(%esp)
8010098a:	e8 bf 43 00 00       	call   80104d4e <sleep>
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
80100a08:	e8 80 46 00 00       	call   8010508d <release>
  ilock(ip);
80100a0d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a10:	89 04 24             	mov    %eax,(%esp)
80100a13:	e8 74 0e 00 00       	call   8010188c <ilock>

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
80100a32:	e8 a3 0f 00 00       	call   801019da <iunlock>
  acquire(&cons.lock);
80100a37:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100a3e:	e8 e8 45 00 00       	call   8010502b <acquire>
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
80100a78:	e8 10 46 00 00       	call   8010508d <release>
  ilock(ip);
80100a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a80:	89 04 24             	mov    %eax,(%esp)
80100a83:	e8 04 0e 00 00       	call   8010188c <ilock>

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
80100a93:	c7 44 24 04 43 87 10 	movl   $0x80108743,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100aa2:	e8 63 45 00 00       	call   8010500a <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 4b 87 10 	movl   $0x8010874b,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 80 07 11 80 	movl   $0x80110780,(%esp)
80100ab6:	e8 4f 45 00 00       	call   8010500a <initlock>

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
80100ae0:	e8 4c 33 00 00       	call   80103e31 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ae5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100aec:	00 
80100aed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100af4:	e8 a1 1e 00 00       	call   8010299a <ioapicenable>
}
80100af9:	c9                   	leave  
80100afa:	c3                   	ret    
	...

80100afc <implicit_exit>:
#include "proc.h"
#include "defs.h"
#include "x86.h"
#include "elf.h"

void implicit_exit(void){
80100afc:	55                   	push   %ebp
80100afd:	89 e5                	mov    %esp,%ebp
80100aff:	83 ec 18             	sub    $0x18,%esp
	exit(0);
80100b02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80100b09:	e8 c8 3c 00 00       	call   801047d6 <exit>
}
80100b0e:	c9                   	leave  
80100b0f:	c3                   	ret    

80100b10 <exec>:

int
exec(char *path, char **argv)
{
80100b10:	55                   	push   %ebp
80100b11:	89 e5                	mov    %esp,%ebp
80100b13:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b19:	e8 5b 29 00 00       	call   80103479 <begin_op>
  if((ip = namei(path)) == 0){
80100b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80100b21:	89 04 24             	mov    %eax,(%esp)
80100b24:	e8 05 19 00 00       	call   8010242e <namei>
80100b29:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b2c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b30:	75 0f                	jne    80100b41 <exec+0x31>
    end_op();
80100b32:	e8 c3 29 00 00       	call   801034fa <end_op>
    return -1;
80100b37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b3c:	e9 de 03 00 00       	jmp    80100f1f <exec+0x40f>
  }
  ilock(ip);
80100b41:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b44:	89 04 24             	mov    %eax,(%esp)
80100b47:	e8 40 0d 00 00       	call   8010188c <ilock>
  pgdir = 0;
80100b4c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b53:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b5a:	00 
80100b5b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b62:	00 
80100b63:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b69:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b6d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b70:	89 04 24             	mov    %eax,(%esp)
80100b73:	e8 0a 12 00 00       	call   80101d82 <readi>
80100b78:	83 f8 33             	cmp    $0x33,%eax
80100b7b:	0f 86 53 03 00 00    	jbe    80100ed4 <exec+0x3c4>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b81:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b87:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b8c:	0f 85 45 03 00 00    	jne    80100ed7 <exec+0x3c7>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100b92:	e8 f6 72 00 00       	call   80107e8d <setupkvm>
80100b97:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b9a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b9e:	0f 84 36 03 00 00    	je     80100eda <exec+0x3ca>
    goto bad;

  // Load program into memory.
  sz = 0;
80100ba4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bb2:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bb8:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bbb:	e9 c5 00 00 00       	jmp    80100c85 <exec+0x175>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bc0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100bc3:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100bca:	00 
80100bcb:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bcf:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bd9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bdc:	89 04 24             	mov    %eax,(%esp)
80100bdf:	e8 9e 11 00 00       	call   80101d82 <readi>
80100be4:	83 f8 20             	cmp    $0x20,%eax
80100be7:	0f 85 f0 02 00 00    	jne    80100edd <exec+0x3cd>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100bed:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bf3:	83 f8 01             	cmp    $0x1,%eax
80100bf6:	75 7f                	jne    80100c77 <exec+0x167>
      continue;
    if(ph.memsz < ph.filesz)
80100bf8:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100bfe:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c04:	39 c2                	cmp    %eax,%edx
80100c06:	0f 82 d4 02 00 00    	jb     80100ee0 <exec+0x3d0>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c0c:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c12:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c18:	01 d0                	add    %edx,%eax
80100c1a:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c21:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c28:	89 04 24             	mov    %eax,(%esp)
80100c2b:	e8 2f 76 00 00       	call   8010825f <allocuvm>
80100c30:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c33:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c37:	0f 84 a6 02 00 00    	je     80100ee3 <exec+0x3d3>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c3d:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c43:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c49:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c4f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c53:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c57:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c5a:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c65:	89 04 24             	mov    %eax,(%esp)
80100c68:	e8 03 75 00 00       	call   80108170 <loaduvm>
80100c6d:	85 c0                	test   %eax,%eax
80100c6f:	0f 88 71 02 00 00    	js     80100ee6 <exec+0x3d6>
80100c75:	eb 01                	jmp    80100c78 <exec+0x168>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c77:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c78:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c7f:	83 c0 20             	add    $0x20,%eax
80100c82:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c85:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c8c:	0f b7 c0             	movzwl %ax,%eax
80100c8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c92:	0f 8f 28 ff ff ff    	jg     80100bc0 <exec+0xb0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c98:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c9b:	89 04 24             	mov    %eax,(%esp)
80100c9e:	e8 6d 0e 00 00       	call   80101b10 <iunlockput>
  end_op();
80100ca3:	e8 52 28 00 00       	call   801034fa <end_op>
  ip = 0;
80100ca8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100caf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cb2:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cb7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cbc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100cbf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc2:	05 00 20 00 00       	add    $0x2000,%eax
80100cc7:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ccb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cce:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cd5:	89 04 24             	mov    %eax,(%esp)
80100cd8:	e8 82 75 00 00       	call   8010825f <allocuvm>
80100cdd:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce4:	0f 84 ff 01 00 00    	je     80100ee9 <exec+0x3d9>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cea:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ced:	2d 00 20 00 00       	sub    $0x2000,%eax
80100cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cf6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cf9:	89 04 24             	mov    %eax,(%esp)
80100cfc:	e8 82 77 00 00       	call   80108483 <clearpteu>
  sp = sz;
80100d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d04:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d07:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d0e:	e9 81 00 00 00       	jmp    80100d94 <exec+0x284>
    if(argc >= MAXARG)
80100d13:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d17:	0f 87 cf 01 00 00    	ja     80100eec <exec+0x3dc>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d20:	c1 e0 02             	shl    $0x2,%eax
80100d23:	03 45 0c             	add    0xc(%ebp),%eax
80100d26:	8b 00                	mov    (%eax),%eax
80100d28:	89 04 24             	mov    %eax,(%esp)
80100d2b:	e8 c8 47 00 00       	call   801054f8 <strlen>
80100d30:	f7 d0                	not    %eax
80100d32:	03 45 dc             	add    -0x24(%ebp),%eax
80100d35:	83 e0 fc             	and    $0xfffffffc,%eax
80100d38:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d3e:	c1 e0 02             	shl    $0x2,%eax
80100d41:	03 45 0c             	add    0xc(%ebp),%eax
80100d44:	8b 00                	mov    (%eax),%eax
80100d46:	89 04 24             	mov    %eax,(%esp)
80100d49:	e8 aa 47 00 00       	call   801054f8 <strlen>
80100d4e:	83 c0 01             	add    $0x1,%eax
80100d51:	89 c2                	mov    %eax,%edx
80100d53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d56:	c1 e0 02             	shl    $0x2,%eax
80100d59:	03 45 0c             	add    0xc(%ebp),%eax
80100d5c:	8b 00                	mov    (%eax),%eax
80100d5e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d62:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d66:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d69:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d6d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d70:	89 04 24             	mov    %eax,(%esp)
80100d73:	e8 d0 78 00 00       	call   80108648 <copyout>
80100d78:	85 c0                	test   %eax,%eax
80100d7a:	0f 88 6f 01 00 00    	js     80100eef <exec+0x3df>
      goto bad;
    ustack[3+argc] = sp;
80100d80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d83:	8d 50 03             	lea    0x3(%eax),%edx
80100d86:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d89:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d90:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d97:	c1 e0 02             	shl    $0x2,%eax
80100d9a:	03 45 0c             	add    0xc(%ebp),%eax
80100d9d:	8b 00                	mov    (%eax),%eax
80100d9f:	85 c0                	test   %eax,%eax
80100da1:	0f 85 6c ff ff ff    	jne    80100d13 <exec+0x203>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100daa:	83 c0 03             	add    $0x3,%eax
80100dad:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100db4:	00 00 00 00 

  ustack[0] = (int)implicit_exit;  // fake return PC
80100db8:	b8 fc 0a 10 80       	mov    $0x80100afc,%eax
80100dbd:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[1] = argc;
80100dc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc6:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dcf:	83 c0 01             	add    $0x1,%eax
80100dd2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddc:	29 d0                	sub    %edx,%eax
80100dde:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de7:	83 c0 04             	add    $0x4,%eax
80100dea:	c1 e0 02             	shl    $0x2,%eax
80100ded:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100df0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df3:	83 c0 04             	add    $0x4,%eax
80100df6:	c1 e0 02             	shl    $0x2,%eax
80100df9:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100dfd:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e03:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e07:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e11:	89 04 24             	mov    %eax,(%esp)
80100e14:	e8 2f 78 00 00       	call   80108648 <copyout>
80100e19:	85 c0                	test   %eax,%eax
80100e1b:	0f 88 d1 00 00 00    	js     80100ef2 <exec+0x3e2>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e21:	8b 45 08             	mov    0x8(%ebp),%eax
80100e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e2d:	eb 17                	jmp    80100e46 <exec+0x336>
    if(*s == '/')
80100e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e32:	0f b6 00             	movzbl (%eax),%eax
80100e35:	3c 2f                	cmp    $0x2f,%al
80100e37:	75 09                	jne    80100e42 <exec+0x332>
      last = s+1;
80100e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e3c:	83 c0 01             	add    $0x1,%eax
80100e3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e42:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e49:	0f b6 00             	movzbl (%eax),%eax
80100e4c:	84 c0                	test   %al,%al
80100e4e:	75 df                	jne    80100e2f <exec+0x31f>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e56:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e59:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e60:	00 
80100e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e64:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e68:	89 14 24             	mov    %edx,(%esp)
80100e6b:	e8 3a 46 00 00       	call   801054aa <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e76:	8b 40 04             	mov    0x4(%eax),%eax
80100e79:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e7c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e82:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e85:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e8e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e91:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e99:	8b 40 18             	mov    0x18(%eax),%eax
80100e9c:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ea2:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ea5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eab:	8b 40 18             	mov    0x18(%eax),%eax
80100eae:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb1:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100eb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eba:	89 04 24             	mov    %eax,(%esp)
80100ebd:	e8 bc 70 00 00       	call   80107f7e <switchuvm>
  freevm(oldpgdir);
80100ec2:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ec5:	89 04 24             	mov    %eax,(%esp)
80100ec8:	e8 28 75 00 00       	call   801083f5 <freevm>
  return 0;
80100ecd:	b8 00 00 00 00       	mov    $0x0,%eax
80100ed2:	eb 4b                	jmp    80100f1f <exec+0x40f>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100ed4:	90                   	nop
80100ed5:	eb 1c                	jmp    80100ef3 <exec+0x3e3>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100ed7:	90                   	nop
80100ed8:	eb 19                	jmp    80100ef3 <exec+0x3e3>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100eda:	90                   	nop
80100edb:	eb 16                	jmp    80100ef3 <exec+0x3e3>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100edd:	90                   	nop
80100ede:	eb 13                	jmp    80100ef3 <exec+0x3e3>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100ee0:	90                   	nop
80100ee1:	eb 10                	jmp    80100ef3 <exec+0x3e3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100ee3:	90                   	nop
80100ee4:	eb 0d                	jmp    80100ef3 <exec+0x3e3>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100ee6:	90                   	nop
80100ee7:	eb 0a                	jmp    80100ef3 <exec+0x3e3>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100ee9:	90                   	nop
80100eea:	eb 07                	jmp    80100ef3 <exec+0x3e3>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100eec:	90                   	nop
80100eed:	eb 04                	jmp    80100ef3 <exec+0x3e3>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100eef:	90                   	nop
80100ef0:	eb 01                	jmp    80100ef3 <exec+0x3e3>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100ef2:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100ef3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ef7:	74 0b                	je     80100f04 <exec+0x3f4>
    freevm(pgdir);
80100ef9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100efc:	89 04 24             	mov    %eax,(%esp)
80100eff:	e8 f1 74 00 00       	call   801083f5 <freevm>
  if(ip){
80100f04:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f08:	74 10                	je     80100f1a <exec+0x40a>
    iunlockput(ip);
80100f0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100f0d:	89 04 24             	mov    %eax,(%esp)
80100f10:	e8 fb 0b 00 00       	call   80101b10 <iunlockput>
    end_op();
80100f15:	e8 e0 25 00 00       	call   801034fa <end_op>
  }
  return -1;
80100f1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f1f:	c9                   	leave  
80100f20:	c3                   	ret    
80100f21:	00 00                	add    %al,(%eax)
	...

80100f24 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f24:	55                   	push   %ebp
80100f25:	89 e5                	mov    %esp,%ebp
80100f27:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100f2a:	c7 44 24 04 51 87 10 	movl   $0x80108751,0x4(%esp)
80100f31:	80 
80100f32:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f39:	e8 cc 40 00 00       	call   8010500a <initlock>
}
80100f3e:	c9                   	leave  
80100f3f:	c3                   	ret    

80100f40 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f40:	55                   	push   %ebp
80100f41:	89 e5                	mov    %esp,%ebp
80100f43:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f46:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f4d:	e8 d9 40 00 00       	call   8010502b <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f52:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100f59:	eb 29                	jmp    80100f84 <filealloc+0x44>
    if(f->ref == 0){
80100f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f5e:	8b 40 04             	mov    0x4(%eax),%eax
80100f61:	85 c0                	test   %eax,%eax
80100f63:	75 1b                	jne    80100f80 <filealloc+0x40>
      f->ref = 1;
80100f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f68:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f6f:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f76:	e8 12 41 00 00       	call   8010508d <release>
      return f;
80100f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f7e:	eb 1e                	jmp    80100f9e <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f80:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f84:	81 7d f4 d4 11 11 80 	cmpl   $0x801111d4,-0xc(%ebp)
80100f8b:	72 ce                	jb     80100f5b <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f8d:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100f94:	e8 f4 40 00 00       	call   8010508d <release>
  return 0;
80100f99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f9e:	c9                   	leave  
80100f9f:	c3                   	ret    

80100fa0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fa0:	55                   	push   %ebp
80100fa1:	89 e5                	mov    %esp,%ebp
80100fa3:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100fa6:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fad:	e8 79 40 00 00       	call   8010502b <acquire>
  if(f->ref < 1)
80100fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb5:	8b 40 04             	mov    0x4(%eax),%eax
80100fb8:	85 c0                	test   %eax,%eax
80100fba:	7f 0c                	jg     80100fc8 <filedup+0x28>
    panic("filedup");
80100fbc:	c7 04 24 58 87 10 80 	movl   $0x80108758,(%esp)
80100fc3:	e8 75 f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100fc8:	8b 45 08             	mov    0x8(%ebp),%eax
80100fcb:	8b 40 04             	mov    0x4(%eax),%eax
80100fce:	8d 50 01             	lea    0x1(%eax),%edx
80100fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd4:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fd7:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100fde:	e8 aa 40 00 00       	call   8010508d <release>
  return f;
80100fe3:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fe6:	c9                   	leave  
80100fe7:	c3                   	ret    

80100fe8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fe8:	55                   	push   %ebp
80100fe9:	89 e5                	mov    %esp,%ebp
80100feb:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fee:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80100ff5:	e8 31 40 00 00       	call   8010502b <acquire>
  if(f->ref < 1)
80100ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffd:	8b 40 04             	mov    0x4(%eax),%eax
80101000:	85 c0                	test   %eax,%eax
80101002:	7f 0c                	jg     80101010 <fileclose+0x28>
    panic("fileclose");
80101004:	c7 04 24 60 87 10 80 	movl   $0x80108760,(%esp)
8010100b:	e8 2d f5 ff ff       	call   8010053d <panic>
  if(--f->ref > 0){
80101010:	8b 45 08             	mov    0x8(%ebp),%eax
80101013:	8b 40 04             	mov    0x4(%eax),%eax
80101016:	8d 50 ff             	lea    -0x1(%eax),%edx
80101019:	8b 45 08             	mov    0x8(%ebp),%eax
8010101c:	89 50 04             	mov    %edx,0x4(%eax)
8010101f:	8b 45 08             	mov    0x8(%ebp),%eax
80101022:	8b 40 04             	mov    0x4(%eax),%eax
80101025:	85 c0                	test   %eax,%eax
80101027:	7e 11                	jle    8010103a <fileclose+0x52>
    release(&ftable.lock);
80101029:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
80101030:	e8 58 40 00 00       	call   8010508d <release>
    return;
80101035:	e9 82 00 00 00       	jmp    801010bc <fileclose+0xd4>
  }
  ff = *f;
8010103a:	8b 45 08             	mov    0x8(%ebp),%eax
8010103d:	8b 10                	mov    (%eax),%edx
8010103f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101042:	8b 50 04             	mov    0x4(%eax),%edx
80101045:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101048:	8b 50 08             	mov    0x8(%eax),%edx
8010104b:	89 55 e8             	mov    %edx,-0x18(%ebp)
8010104e:	8b 50 0c             	mov    0xc(%eax),%edx
80101051:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101054:	8b 50 10             	mov    0x10(%eax),%edx
80101057:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010105a:	8b 40 14             	mov    0x14(%eax),%eax
8010105d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101060:	8b 45 08             	mov    0x8(%ebp),%eax
80101063:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101073:	c7 04 24 40 08 11 80 	movl   $0x80110840,(%esp)
8010107a:	e8 0e 40 00 00       	call   8010508d <release>
  
  if(ff.type == FD_PIPE)
8010107f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101082:	83 f8 01             	cmp    $0x1,%eax
80101085:	75 18                	jne    8010109f <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101087:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010108b:	0f be d0             	movsbl %al,%edx
8010108e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101091:	89 54 24 04          	mov    %edx,0x4(%esp)
80101095:	89 04 24             	mov    %eax,(%esp)
80101098:	e8 4e 30 00 00       	call   801040eb <pipeclose>
8010109d:	eb 1d                	jmp    801010bc <fileclose+0xd4>
  else if(ff.type == FD_INODE){
8010109f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010a2:	83 f8 02             	cmp    $0x2,%eax
801010a5:	75 15                	jne    801010bc <fileclose+0xd4>
    begin_op();
801010a7:	e8 cd 23 00 00       	call   80103479 <begin_op>
    iput(ff.ip);
801010ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801010af:	89 04 24             	mov    %eax,(%esp)
801010b2:	e8 88 09 00 00       	call   80101a3f <iput>
    end_op();
801010b7:	e8 3e 24 00 00       	call   801034fa <end_op>
  }
}
801010bc:	c9                   	leave  
801010bd:	c3                   	ret    

801010be <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010be:	55                   	push   %ebp
801010bf:	89 e5                	mov    %esp,%ebp
801010c1:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801010c4:	8b 45 08             	mov    0x8(%ebp),%eax
801010c7:	8b 00                	mov    (%eax),%eax
801010c9:	83 f8 02             	cmp    $0x2,%eax
801010cc:	75 38                	jne    80101106 <filestat+0x48>
    ilock(f->ip);
801010ce:	8b 45 08             	mov    0x8(%ebp),%eax
801010d1:	8b 40 10             	mov    0x10(%eax),%eax
801010d4:	89 04 24             	mov    %eax,(%esp)
801010d7:	e8 b0 07 00 00       	call   8010188c <ilock>
    stati(f->ip, st);
801010dc:	8b 45 08             	mov    0x8(%ebp),%eax
801010df:	8b 40 10             	mov    0x10(%eax),%eax
801010e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801010e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801010e9:	89 04 24             	mov    %eax,(%esp)
801010ec:	e8 4c 0c 00 00       	call   80101d3d <stati>
    iunlock(f->ip);
801010f1:	8b 45 08             	mov    0x8(%ebp),%eax
801010f4:	8b 40 10             	mov    0x10(%eax),%eax
801010f7:	89 04 24             	mov    %eax,(%esp)
801010fa:	e8 db 08 00 00       	call   801019da <iunlock>
    return 0;
801010ff:	b8 00 00 00 00       	mov    $0x0,%eax
80101104:	eb 05                	jmp    8010110b <filestat+0x4d>
  }
  return -1;
80101106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010110b:	c9                   	leave  
8010110c:	c3                   	ret    

8010110d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010110d:	55                   	push   %ebp
8010110e:	89 e5                	mov    %esp,%ebp
80101110:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
80101113:	8b 45 08             	mov    0x8(%ebp),%eax
80101116:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010111a:	84 c0                	test   %al,%al
8010111c:	75 0a                	jne    80101128 <fileread+0x1b>
    return -1;
8010111e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101123:	e9 9f 00 00 00       	jmp    801011c7 <fileread+0xba>
  if(f->type == FD_PIPE)
80101128:	8b 45 08             	mov    0x8(%ebp),%eax
8010112b:	8b 00                	mov    (%eax),%eax
8010112d:	83 f8 01             	cmp    $0x1,%eax
80101130:	75 1e                	jne    80101150 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101132:	8b 45 08             	mov    0x8(%ebp),%eax
80101135:	8b 40 0c             	mov    0xc(%eax),%eax
80101138:	8b 55 10             	mov    0x10(%ebp),%edx
8010113b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010113f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101142:	89 54 24 04          	mov    %edx,0x4(%esp)
80101146:	89 04 24             	mov    %eax,(%esp)
80101149:	e8 1f 31 00 00       	call   8010426d <piperead>
8010114e:	eb 77                	jmp    801011c7 <fileread+0xba>
  if(f->type == FD_INODE){
80101150:	8b 45 08             	mov    0x8(%ebp),%eax
80101153:	8b 00                	mov    (%eax),%eax
80101155:	83 f8 02             	cmp    $0x2,%eax
80101158:	75 61                	jne    801011bb <fileread+0xae>
    ilock(f->ip);
8010115a:	8b 45 08             	mov    0x8(%ebp),%eax
8010115d:	8b 40 10             	mov    0x10(%eax),%eax
80101160:	89 04 24             	mov    %eax,(%esp)
80101163:	e8 24 07 00 00       	call   8010188c <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101168:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010116b:	8b 45 08             	mov    0x8(%ebp),%eax
8010116e:	8b 50 14             	mov    0x14(%eax),%edx
80101171:	8b 45 08             	mov    0x8(%ebp),%eax
80101174:	8b 40 10             	mov    0x10(%eax),%eax
80101177:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010117b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010117f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101182:	89 54 24 04          	mov    %edx,0x4(%esp)
80101186:	89 04 24             	mov    %eax,(%esp)
80101189:	e8 f4 0b 00 00       	call   80101d82 <readi>
8010118e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101191:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101195:	7e 11                	jle    801011a8 <fileread+0x9b>
      f->off += r;
80101197:	8b 45 08             	mov    0x8(%ebp),%eax
8010119a:	8b 50 14             	mov    0x14(%eax),%edx
8010119d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011a0:	01 c2                	add    %eax,%edx
801011a2:	8b 45 08             	mov    0x8(%ebp),%eax
801011a5:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801011a8:	8b 45 08             	mov    0x8(%ebp),%eax
801011ab:	8b 40 10             	mov    0x10(%eax),%eax
801011ae:	89 04 24             	mov    %eax,(%esp)
801011b1:	e8 24 08 00 00       	call   801019da <iunlock>
    return r;
801011b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011b9:	eb 0c                	jmp    801011c7 <fileread+0xba>
  }
  panic("fileread");
801011bb:	c7 04 24 6a 87 10 80 	movl   $0x8010876a,(%esp)
801011c2:	e8 76 f3 ff ff       	call   8010053d <panic>
}
801011c7:	c9                   	leave  
801011c8:	c3                   	ret    

801011c9 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801011c9:	55                   	push   %ebp
801011ca:	89 e5                	mov    %esp,%ebp
801011cc:	53                   	push   %ebx
801011cd:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011d0:	8b 45 08             	mov    0x8(%ebp),%eax
801011d3:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011d7:	84 c0                	test   %al,%al
801011d9:	75 0a                	jne    801011e5 <filewrite+0x1c>
    return -1;
801011db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011e0:	e9 23 01 00 00       	jmp    80101308 <filewrite+0x13f>
  if(f->type == FD_PIPE)
801011e5:	8b 45 08             	mov    0x8(%ebp),%eax
801011e8:	8b 00                	mov    (%eax),%eax
801011ea:	83 f8 01             	cmp    $0x1,%eax
801011ed:	75 21                	jne    80101210 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011ef:	8b 45 08             	mov    0x8(%ebp),%eax
801011f2:	8b 40 0c             	mov    0xc(%eax),%eax
801011f5:	8b 55 10             	mov    0x10(%ebp),%edx
801011f8:	89 54 24 08          	mov    %edx,0x8(%esp)
801011fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801011ff:	89 54 24 04          	mov    %edx,0x4(%esp)
80101203:	89 04 24             	mov    %eax,(%esp)
80101206:	e8 72 2f 00 00       	call   8010417d <pipewrite>
8010120b:	e9 f8 00 00 00       	jmp    80101308 <filewrite+0x13f>
  if(f->type == FD_INODE){
80101210:	8b 45 08             	mov    0x8(%ebp),%eax
80101213:	8b 00                	mov    (%eax),%eax
80101215:	83 f8 02             	cmp    $0x2,%eax
80101218:	0f 85 de 00 00 00    	jne    801012fc <filewrite+0x133>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010121e:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101225:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010122c:	e9 a8 00 00 00       	jmp    801012d9 <filewrite+0x110>
      int n1 = n - i;
80101231:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101234:	8b 55 10             	mov    0x10(%ebp),%edx
80101237:	89 d1                	mov    %edx,%ecx
80101239:	29 c1                	sub    %eax,%ecx
8010123b:	89 c8                	mov    %ecx,%eax
8010123d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101240:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101243:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101246:	7e 06                	jle    8010124e <filewrite+0x85>
        n1 = max;
80101248:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010124b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
8010124e:	e8 26 22 00 00       	call   80103479 <begin_op>
      ilock(f->ip);
80101253:	8b 45 08             	mov    0x8(%ebp),%eax
80101256:	8b 40 10             	mov    0x10(%eax),%eax
80101259:	89 04 24             	mov    %eax,(%esp)
8010125c:	e8 2b 06 00 00       	call   8010188c <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101261:	8b 5d f0             	mov    -0x10(%ebp),%ebx
80101264:	8b 45 08             	mov    0x8(%ebp),%eax
80101267:	8b 48 14             	mov    0x14(%eax),%ecx
8010126a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126d:	89 c2                	mov    %eax,%edx
8010126f:	03 55 0c             	add    0xc(%ebp),%edx
80101272:	8b 45 08             	mov    0x8(%ebp),%eax
80101275:	8b 40 10             	mov    0x10(%eax),%eax
80101278:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
8010127c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80101280:	89 54 24 04          	mov    %edx,0x4(%esp)
80101284:	89 04 24             	mov    %eax,(%esp)
80101287:	e8 61 0c 00 00       	call   80101eed <writei>
8010128c:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010128f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101293:	7e 11                	jle    801012a6 <filewrite+0xdd>
        f->off += r;
80101295:	8b 45 08             	mov    0x8(%ebp),%eax
80101298:	8b 50 14             	mov    0x14(%eax),%edx
8010129b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010129e:	01 c2                	add    %eax,%edx
801012a0:	8b 45 08             	mov    0x8(%ebp),%eax
801012a3:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012a6:	8b 45 08             	mov    0x8(%ebp),%eax
801012a9:	8b 40 10             	mov    0x10(%eax),%eax
801012ac:	89 04 24             	mov    %eax,(%esp)
801012af:	e8 26 07 00 00       	call   801019da <iunlock>
      end_op();
801012b4:	e8 41 22 00 00       	call   801034fa <end_op>

      if(r < 0)
801012b9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012bd:	78 28                	js     801012e7 <filewrite+0x11e>
        break;
      if(r != n1)
801012bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012c2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801012c5:	74 0c                	je     801012d3 <filewrite+0x10a>
        panic("short filewrite");
801012c7:	c7 04 24 73 87 10 80 	movl   $0x80108773,(%esp)
801012ce:	e8 6a f2 ff ff       	call   8010053d <panic>
      i += r;
801012d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012d6:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012dc:	3b 45 10             	cmp    0x10(%ebp),%eax
801012df:	0f 8c 4c ff ff ff    	jl     80101231 <filewrite+0x68>
801012e5:	eb 01                	jmp    801012e8 <filewrite+0x11f>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
801012e7:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012eb:	3b 45 10             	cmp    0x10(%ebp),%eax
801012ee:	75 05                	jne    801012f5 <filewrite+0x12c>
801012f0:	8b 45 10             	mov    0x10(%ebp),%eax
801012f3:	eb 05                	jmp    801012fa <filewrite+0x131>
801012f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012fa:	eb 0c                	jmp    80101308 <filewrite+0x13f>
  }
  panic("filewrite");
801012fc:	c7 04 24 83 87 10 80 	movl   $0x80108783,(%esp)
80101303:	e8 35 f2 ff ff       	call   8010053d <panic>
}
80101308:	83 c4 24             	add    $0x24,%esp
8010130b:	5b                   	pop    %ebx
8010130c:	5d                   	pop    %ebp
8010130d:	c3                   	ret    
	...

80101310 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101310:	55                   	push   %ebp
80101311:	89 e5                	mov    %esp,%ebp
80101313:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101320:	00 
80101321:	89 04 24             	mov    %eax,(%esp)
80101324:	e8 7d ee ff ff       	call   801001a6 <bread>
80101329:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010132c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132f:	83 c0 18             	add    $0x18,%eax
80101332:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101339:	00 
8010133a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010133e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101341:	89 04 24             	mov    %eax,(%esp)
80101344:	e8 04 40 00 00       	call   8010534d <memmove>
  brelse(bp);
80101349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010134c:	89 04 24             	mov    %eax,(%esp)
8010134f:	e8 c3 ee ff ff       	call   80100217 <brelse>
}
80101354:	c9                   	leave  
80101355:	c3                   	ret    

80101356 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101356:	55                   	push   %ebp
80101357:	89 e5                	mov    %esp,%ebp
80101359:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010135c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010135f:	8b 45 08             	mov    0x8(%ebp),%eax
80101362:	89 54 24 04          	mov    %edx,0x4(%esp)
80101366:	89 04 24             	mov    %eax,(%esp)
80101369:	e8 38 ee ff ff       	call   801001a6 <bread>
8010136e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101374:	83 c0 18             	add    $0x18,%eax
80101377:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010137e:	00 
8010137f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101386:	00 
80101387:	89 04 24             	mov    %eax,(%esp)
8010138a:	e8 eb 3e 00 00       	call   8010527a <memset>
  log_write(bp);
8010138f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101392:	89 04 24             	mov    %eax,(%esp)
80101395:	e8 e4 22 00 00       	call   8010367e <log_write>
  brelse(bp);
8010139a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010139d:	89 04 24             	mov    %eax,(%esp)
801013a0:	e8 72 ee ff ff       	call   80100217 <brelse>
}
801013a5:	c9                   	leave  
801013a6:	c3                   	ret    

801013a7 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013a7:	55                   	push   %ebp
801013a8:	89 e5                	mov    %esp,%ebp
801013aa:	53                   	push   %ebx
801013ab:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
801013ae:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
801013b5:	8b 45 08             	mov    0x8(%ebp),%eax
801013b8:	8d 55 d8             	lea    -0x28(%ebp),%edx
801013bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801013bf:	89 04 24             	mov    %eax,(%esp)
801013c2:	e8 49 ff ff ff       	call   80101310 <readsb>
  for(b = 0; b < sb.size; b += BPB){
801013c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801013ce:	e9 11 01 00 00       	jmp    801014e4 <balloc+0x13d>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
801013d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013dc:	85 c0                	test   %eax,%eax
801013de:	0f 48 c2             	cmovs  %edx,%eax
801013e1:	c1 f8 0c             	sar    $0xc,%eax
801013e4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013e7:	c1 ea 03             	shr    $0x3,%edx
801013ea:	01 d0                	add    %edx,%eax
801013ec:	83 c0 03             	add    $0x3,%eax
801013ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801013f3:	8b 45 08             	mov    0x8(%ebp),%eax
801013f6:	89 04 24             	mov    %eax,(%esp)
801013f9:	e8 a8 ed ff ff       	call   801001a6 <bread>
801013fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101401:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101408:	e9 a7 00 00 00       	jmp    801014b4 <balloc+0x10d>
      m = 1 << (bi % 8);
8010140d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101410:	89 c2                	mov    %eax,%edx
80101412:	c1 fa 1f             	sar    $0x1f,%edx
80101415:	c1 ea 1d             	shr    $0x1d,%edx
80101418:	01 d0                	add    %edx,%eax
8010141a:	83 e0 07             	and    $0x7,%eax
8010141d:	29 d0                	sub    %edx,%eax
8010141f:	ba 01 00 00 00       	mov    $0x1,%edx
80101424:	89 d3                	mov    %edx,%ebx
80101426:	89 c1                	mov    %eax,%ecx
80101428:	d3 e3                	shl    %cl,%ebx
8010142a:	89 d8                	mov    %ebx,%eax
8010142c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010142f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101432:	8d 50 07             	lea    0x7(%eax),%edx
80101435:	85 c0                	test   %eax,%eax
80101437:	0f 48 c2             	cmovs  %edx,%eax
8010143a:	c1 f8 03             	sar    $0x3,%eax
8010143d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101440:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
80101445:	0f b6 c0             	movzbl %al,%eax
80101448:	23 45 e8             	and    -0x18(%ebp),%eax
8010144b:	85 c0                	test   %eax,%eax
8010144d:	75 61                	jne    801014b0 <balloc+0x109>
        bp->data[bi/8] |= m;  // Mark block in use.
8010144f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101452:	8d 50 07             	lea    0x7(%eax),%edx
80101455:	85 c0                	test   %eax,%eax
80101457:	0f 48 c2             	cmovs  %edx,%eax
8010145a:	c1 f8 03             	sar    $0x3,%eax
8010145d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101460:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101465:	89 d1                	mov    %edx,%ecx
80101467:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010146a:	09 ca                	or     %ecx,%edx
8010146c:	89 d1                	mov    %edx,%ecx
8010146e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101471:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101475:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101478:	89 04 24             	mov    %eax,(%esp)
8010147b:	e8 fe 21 00 00       	call   8010367e <log_write>
        brelse(bp);
80101480:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101483:	89 04 24             	mov    %eax,(%esp)
80101486:	e8 8c ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
8010148b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101491:	01 c2                	add    %eax,%edx
80101493:	8b 45 08             	mov    0x8(%ebp),%eax
80101496:	89 54 24 04          	mov    %edx,0x4(%esp)
8010149a:	89 04 24             	mov    %eax,(%esp)
8010149d:	e8 b4 fe ff ff       	call   80101356 <bzero>
        return b + bi;
801014a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a8:	01 d0                	add    %edx,%eax
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801014aa:	83 c4 34             	add    $0x34,%esp
801014ad:	5b                   	pop    %ebx
801014ae:	5d                   	pop    %ebp
801014af:	c3                   	ret    

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014b0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014b4:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014bb:	7f 15                	jg     801014d2 <balloc+0x12b>
801014bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014c3:	01 d0                	add    %edx,%eax
801014c5:	89 c2                	mov    %eax,%edx
801014c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014ca:	39 c2                	cmp    %eax,%edx
801014cc:	0f 82 3b ff ff ff    	jb     8010140d <balloc+0x66>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801014d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014d5:	89 04 24             	mov    %eax,(%esp)
801014d8:	e8 3a ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
801014dd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014ea:	39 c2                	cmp    %eax,%edx
801014ec:	0f 82 e1 fe ff ff    	jb     801013d3 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014f2:	c7 04 24 8d 87 10 80 	movl   $0x8010878d,(%esp)
801014f9:	e8 3f f0 ff ff       	call   8010053d <panic>

801014fe <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014fe:	55                   	push   %ebp
801014ff:	89 e5                	mov    %esp,%ebp
80101501:	53                   	push   %ebx
80101502:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101505:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101508:	89 44 24 04          	mov    %eax,0x4(%esp)
8010150c:	8b 45 08             	mov    0x8(%ebp),%eax
8010150f:	89 04 24             	mov    %eax,(%esp)
80101512:	e8 f9 fd ff ff       	call   80101310 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101517:	8b 45 0c             	mov    0xc(%ebp),%eax
8010151a:	89 c2                	mov    %eax,%edx
8010151c:	c1 ea 0c             	shr    $0xc,%edx
8010151f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101522:	c1 e8 03             	shr    $0x3,%eax
80101525:	01 d0                	add    %edx,%eax
80101527:	8d 50 03             	lea    0x3(%eax),%edx
8010152a:	8b 45 08             	mov    0x8(%ebp),%eax
8010152d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101531:	89 04 24             	mov    %eax,(%esp)
80101534:	e8 6d ec ff ff       	call   801001a6 <bread>
80101539:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010153c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010153f:	25 ff 0f 00 00       	and    $0xfff,%eax
80101544:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154a:	89 c2                	mov    %eax,%edx
8010154c:	c1 fa 1f             	sar    $0x1f,%edx
8010154f:	c1 ea 1d             	shr    $0x1d,%edx
80101552:	01 d0                	add    %edx,%eax
80101554:	83 e0 07             	and    $0x7,%eax
80101557:	29 d0                	sub    %edx,%eax
80101559:	ba 01 00 00 00       	mov    $0x1,%edx
8010155e:	89 d3                	mov    %edx,%ebx
80101560:	89 c1                	mov    %eax,%ecx
80101562:	d3 e3                	shl    %cl,%ebx
80101564:	89 d8                	mov    %ebx,%eax
80101566:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156c:	8d 50 07             	lea    0x7(%eax),%edx
8010156f:	85 c0                	test   %eax,%eax
80101571:	0f 48 c2             	cmovs  %edx,%eax
80101574:	c1 f8 03             	sar    $0x3,%eax
80101577:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010157a:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010157f:	0f b6 c0             	movzbl %al,%eax
80101582:	23 45 ec             	and    -0x14(%ebp),%eax
80101585:	85 c0                	test   %eax,%eax
80101587:	75 0c                	jne    80101595 <bfree+0x97>
    panic("freeing free block");
80101589:	c7 04 24 a3 87 10 80 	movl   $0x801087a3,(%esp)
80101590:	e8 a8 ef ff ff       	call   8010053d <panic>
  bp->data[bi/8] &= ~m;
80101595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101598:	8d 50 07             	lea    0x7(%eax),%edx
8010159b:	85 c0                	test   %eax,%eax
8010159d:	0f 48 c2             	cmovs  %edx,%eax
801015a0:	c1 f8 03             	sar    $0x3,%eax
801015a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a6:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015ab:	8b 4d ec             	mov    -0x14(%ebp),%ecx
801015ae:	f7 d1                	not    %ecx
801015b0:	21 ca                	and    %ecx,%edx
801015b2:	89 d1                	mov    %edx,%ecx
801015b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b7:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015be:	89 04 24             	mov    %eax,(%esp)
801015c1:	e8 b8 20 00 00       	call   8010367e <log_write>
  brelse(bp);
801015c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c9:	89 04 24             	mov    %eax,(%esp)
801015cc:	e8 46 ec ff ff       	call   80100217 <brelse>
}
801015d1:	83 c4 34             	add    $0x34,%esp
801015d4:	5b                   	pop    %ebx
801015d5:	5d                   	pop    %ebp
801015d6:	c3                   	ret    

801015d7 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
801015d7:	55                   	push   %ebp
801015d8:	89 e5                	mov    %esp,%ebp
801015da:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
801015dd:	c7 44 24 04 b6 87 10 	movl   $0x801087b6,0x4(%esp)
801015e4:	80 
801015e5:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801015ec:	e8 19 3a 00 00       	call   8010500a <initlock>
}
801015f1:	c9                   	leave  
801015f2:	c3                   	ret    

801015f3 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015f3:	55                   	push   %ebp
801015f4:	89 e5                	mov    %esp,%ebp
801015f6:	83 ec 48             	sub    $0x48,%esp
801015f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801015fc:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101600:	8b 45 08             	mov    0x8(%ebp),%eax
80101603:	8d 55 dc             	lea    -0x24(%ebp),%edx
80101606:	89 54 24 04          	mov    %edx,0x4(%esp)
8010160a:	89 04 24             	mov    %eax,(%esp)
8010160d:	e8 fe fc ff ff       	call   80101310 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
80101612:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101619:	e9 98 00 00 00       	jmp    801016b6 <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
8010161e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101621:	c1 e8 03             	shr    $0x3,%eax
80101624:	83 c0 02             	add    $0x2,%eax
80101627:	89 44 24 04          	mov    %eax,0x4(%esp)
8010162b:	8b 45 08             	mov    0x8(%ebp),%eax
8010162e:	89 04 24             	mov    %eax,(%esp)
80101631:	e8 70 eb ff ff       	call   801001a6 <bread>
80101636:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101639:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163c:	8d 50 18             	lea    0x18(%eax),%edx
8010163f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101642:	83 e0 07             	and    $0x7,%eax
80101645:	c1 e0 06             	shl    $0x6,%eax
80101648:	01 d0                	add    %edx,%eax
8010164a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010164d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101650:	0f b7 00             	movzwl (%eax),%eax
80101653:	66 85 c0             	test   %ax,%ax
80101656:	75 4f                	jne    801016a7 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101658:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010165f:	00 
80101660:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101667:	00 
80101668:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010166b:	89 04 24             	mov    %eax,(%esp)
8010166e:	e8 07 3c 00 00       	call   8010527a <memset>
      dip->type = type;
80101673:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101676:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
8010167a:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010167d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101680:	89 04 24             	mov    %eax,(%esp)
80101683:	e8 f6 1f 00 00       	call   8010367e <log_write>
      brelse(bp);
80101688:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168b:	89 04 24             	mov    %eax,(%esp)
8010168e:	e8 84 eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
80101693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101696:	89 44 24 04          	mov    %eax,0x4(%esp)
8010169a:	8b 45 08             	mov    0x8(%ebp),%eax
8010169d:	89 04 24             	mov    %eax,(%esp)
801016a0:	e8 e3 00 00 00       	call   80101788 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
801016a5:	c9                   	leave  
801016a6:	c3                   	ret    
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
801016a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016aa:	89 04 24             	mov    %eax,(%esp)
801016ad:	e8 65 eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
801016b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801016b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801016bc:	39 c2                	cmp    %eax,%edx
801016be:	0f 82 5a ff ff ff    	jb     8010161e <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801016c4:	c7 04 24 bd 87 10 80 	movl   $0x801087bd,(%esp)
801016cb:	e8 6d ee ff ff       	call   8010053d <panic>

801016d0 <iupdate>:
}

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801016d0:	55                   	push   %ebp
801016d1:	89 e5                	mov    %esp,%ebp
801016d3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
801016d6:	8b 45 08             	mov    0x8(%ebp),%eax
801016d9:	8b 40 04             	mov    0x4(%eax),%eax
801016dc:	c1 e8 03             	shr    $0x3,%eax
801016df:	8d 50 02             	lea    0x2(%eax),%edx
801016e2:	8b 45 08             	mov    0x8(%ebp),%eax
801016e5:	8b 00                	mov    (%eax),%eax
801016e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801016eb:	89 04 24             	mov    %eax,(%esp)
801016ee:	e8 b3 ea ff ff       	call   801001a6 <bread>
801016f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f9:	8d 50 18             	lea    0x18(%eax),%edx
801016fc:	8b 45 08             	mov    0x8(%ebp),%eax
801016ff:	8b 40 04             	mov    0x4(%eax),%eax
80101702:	83 e0 07             	and    $0x7,%eax
80101705:	c1 e0 06             	shl    $0x6,%eax
80101708:	01 d0                	add    %edx,%eax
8010170a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010170d:	8b 45 08             	mov    0x8(%ebp),%eax
80101710:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101714:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101717:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010171a:	8b 45 08             	mov    0x8(%ebp),%eax
8010171d:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101721:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101724:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101728:	8b 45 08             	mov    0x8(%ebp),%eax
8010172b:	0f b7 50 14          	movzwl 0x14(%eax),%edx
8010172f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101732:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101736:	8b 45 08             	mov    0x8(%ebp),%eax
80101739:	0f b7 50 16          	movzwl 0x16(%eax),%edx
8010173d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101740:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101744:	8b 45 08             	mov    0x8(%ebp),%eax
80101747:	8b 50 18             	mov    0x18(%eax),%edx
8010174a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010174d:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101750:	8b 45 08             	mov    0x8(%ebp),%eax
80101753:	8d 50 1c             	lea    0x1c(%eax),%edx
80101756:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101759:	83 c0 0c             	add    $0xc,%eax
8010175c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101763:	00 
80101764:	89 54 24 04          	mov    %edx,0x4(%esp)
80101768:	89 04 24             	mov    %eax,(%esp)
8010176b:	e8 dd 3b 00 00       	call   8010534d <memmove>
  log_write(bp);
80101770:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101773:	89 04 24             	mov    %eax,(%esp)
80101776:	e8 03 1f 00 00       	call   8010367e <log_write>
  brelse(bp);
8010177b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177e:	89 04 24             	mov    %eax,(%esp)
80101781:	e8 91 ea ff ff       	call   80100217 <brelse>
}
80101786:	c9                   	leave  
80101787:	c3                   	ret    

80101788 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101788:	55                   	push   %ebp
80101789:	89 e5                	mov    %esp,%ebp
8010178b:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010178e:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101795:	e8 91 38 00 00       	call   8010502b <acquire>

  // Is the inode already cached?
  empty = 0;
8010179a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017a1:	c7 45 f4 74 12 11 80 	movl   $0x80111274,-0xc(%ebp)
801017a8:	eb 59                	jmp    80101803 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801017aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ad:	8b 40 08             	mov    0x8(%eax),%eax
801017b0:	85 c0                	test   %eax,%eax
801017b2:	7e 35                	jle    801017e9 <iget+0x61>
801017b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b7:	8b 00                	mov    (%eax),%eax
801017b9:	3b 45 08             	cmp    0x8(%ebp),%eax
801017bc:	75 2b                	jne    801017e9 <iget+0x61>
801017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c1:	8b 40 04             	mov    0x4(%eax),%eax
801017c4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801017c7:	75 20                	jne    801017e9 <iget+0x61>
      ip->ref++;
801017c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017cc:	8b 40 08             	mov    0x8(%eax),%eax
801017cf:	8d 50 01             	lea    0x1(%eax),%edx
801017d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d5:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801017d8:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801017df:	e8 a9 38 00 00       	call   8010508d <release>
      return ip;
801017e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e7:	eb 6f                	jmp    80101858 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017ed:	75 10                	jne    801017ff <iget+0x77>
801017ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f2:	8b 40 08             	mov    0x8(%eax),%eax
801017f5:	85 c0                	test   %eax,%eax
801017f7:	75 06                	jne    801017ff <iget+0x77>
      empty = ip;
801017f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fc:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017ff:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101803:	81 7d f4 14 22 11 80 	cmpl   $0x80112214,-0xc(%ebp)
8010180a:	72 9e                	jb     801017aa <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010180c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101810:	75 0c                	jne    8010181e <iget+0x96>
    panic("iget: no inodes");
80101812:	c7 04 24 cf 87 10 80 	movl   $0x801087cf,(%esp)
80101819:	e8 1f ed ff ff       	call   8010053d <panic>

  ip = empty;
8010181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101821:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101827:	8b 55 08             	mov    0x8(%ebp),%edx
8010182a:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101832:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101835:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101838:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010183f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101842:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101849:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101850:	e8 38 38 00 00       	call   8010508d <release>

  return ip;
80101855:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101858:	c9                   	leave  
80101859:	c3                   	ret    

8010185a <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010185a:	55                   	push   %ebp
8010185b:	89 e5                	mov    %esp,%ebp
8010185d:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101860:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101867:	e8 bf 37 00 00       	call   8010502b <acquire>
  ip->ref++;
8010186c:	8b 45 08             	mov    0x8(%ebp),%eax
8010186f:	8b 40 08             	mov    0x8(%eax),%eax
80101872:	8d 50 01             	lea    0x1(%eax),%edx
80101875:	8b 45 08             	mov    0x8(%ebp),%eax
80101878:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010187b:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101882:	e8 06 38 00 00       	call   8010508d <release>
  return ip;
80101887:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010188a:	c9                   	leave  
8010188b:	c3                   	ret    

8010188c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010188c:	55                   	push   %ebp
8010188d:	89 e5                	mov    %esp,%ebp
8010188f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101892:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101896:	74 0a                	je     801018a2 <ilock+0x16>
80101898:	8b 45 08             	mov    0x8(%ebp),%eax
8010189b:	8b 40 08             	mov    0x8(%eax),%eax
8010189e:	85 c0                	test   %eax,%eax
801018a0:	7f 0c                	jg     801018ae <ilock+0x22>
    panic("ilock");
801018a2:	c7 04 24 df 87 10 80 	movl   $0x801087df,(%esp)
801018a9:	e8 8f ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801018ae:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801018b5:	e8 71 37 00 00       	call   8010502b <acquire>
  while(ip->flags & I_BUSY)
801018ba:	eb 13                	jmp    801018cf <ilock+0x43>
    sleep(ip, &icache.lock);
801018bc:	c7 44 24 04 40 12 11 	movl   $0x80111240,0x4(%esp)
801018c3:	80 
801018c4:	8b 45 08             	mov    0x8(%ebp),%eax
801018c7:	89 04 24             	mov    %eax,(%esp)
801018ca:	e8 7f 34 00 00       	call   80104d4e <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801018cf:	8b 45 08             	mov    0x8(%ebp),%eax
801018d2:	8b 40 0c             	mov    0xc(%eax),%eax
801018d5:	83 e0 01             	and    $0x1,%eax
801018d8:	84 c0                	test   %al,%al
801018da:	75 e0                	jne    801018bc <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801018dc:	8b 45 08             	mov    0x8(%ebp),%eax
801018df:	8b 40 0c             	mov    0xc(%eax),%eax
801018e2:	89 c2                	mov    %eax,%edx
801018e4:	83 ca 01             	or     $0x1,%edx
801018e7:	8b 45 08             	mov    0x8(%ebp),%eax
801018ea:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018ed:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
801018f4:	e8 94 37 00 00       	call   8010508d <release>

  if(!(ip->flags & I_VALID)){
801018f9:	8b 45 08             	mov    0x8(%ebp),%eax
801018fc:	8b 40 0c             	mov    0xc(%eax),%eax
801018ff:	83 e0 02             	and    $0x2,%eax
80101902:	85 c0                	test   %eax,%eax
80101904:	0f 85 ce 00 00 00    	jne    801019d8 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
8010190a:	8b 45 08             	mov    0x8(%ebp),%eax
8010190d:	8b 40 04             	mov    0x4(%eax),%eax
80101910:	c1 e8 03             	shr    $0x3,%eax
80101913:	8d 50 02             	lea    0x2(%eax),%edx
80101916:	8b 45 08             	mov    0x8(%ebp),%eax
80101919:	8b 00                	mov    (%eax),%eax
8010191b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010191f:	89 04 24             	mov    %eax,(%esp)
80101922:	e8 7f e8 ff ff       	call   801001a6 <bread>
80101927:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010192a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192d:	8d 50 18             	lea    0x18(%eax),%edx
80101930:	8b 45 08             	mov    0x8(%ebp),%eax
80101933:	8b 40 04             	mov    0x4(%eax),%eax
80101936:	83 e0 07             	and    $0x7,%eax
80101939:	c1 e0 06             	shl    $0x6,%eax
8010193c:	01 d0                	add    %edx,%eax
8010193e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101941:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101944:	0f b7 10             	movzwl (%eax),%edx
80101947:	8b 45 08             	mov    0x8(%ebp),%eax
8010194a:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
8010194e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101951:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101955:	8b 45 08             	mov    0x8(%ebp),%eax
80101958:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
8010195c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195f:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101963:	8b 45 08             	mov    0x8(%ebp),%eax
80101966:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
8010196a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010196d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101971:	8b 45 08             	mov    0x8(%ebp),%eax
80101974:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197b:	8b 50 08             	mov    0x8(%eax),%edx
8010197e:	8b 45 08             	mov    0x8(%ebp),%eax
80101981:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101984:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101987:	8d 50 0c             	lea    0xc(%eax),%edx
8010198a:	8b 45 08             	mov    0x8(%ebp),%eax
8010198d:	83 c0 1c             	add    $0x1c,%eax
80101990:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101997:	00 
80101998:	89 54 24 04          	mov    %edx,0x4(%esp)
8010199c:	89 04 24             	mov    %eax,(%esp)
8010199f:	e8 a9 39 00 00       	call   8010534d <memmove>
    brelse(bp);
801019a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a7:	89 04 24             	mov    %eax,(%esp)
801019aa:	e8 68 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
801019af:	8b 45 08             	mov    0x8(%ebp),%eax
801019b2:	8b 40 0c             	mov    0xc(%eax),%eax
801019b5:	89 c2                	mov    %eax,%edx
801019b7:	83 ca 02             	or     $0x2,%edx
801019ba:	8b 45 08             	mov    0x8(%ebp),%eax
801019bd:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
801019c0:	8b 45 08             	mov    0x8(%ebp),%eax
801019c3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801019c7:	66 85 c0             	test   %ax,%ax
801019ca:	75 0c                	jne    801019d8 <ilock+0x14c>
      panic("ilock: no type");
801019cc:	c7 04 24 e5 87 10 80 	movl   $0x801087e5,(%esp)
801019d3:	e8 65 eb ff ff       	call   8010053d <panic>
  }
}
801019d8:	c9                   	leave  
801019d9:	c3                   	ret    

801019da <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801019da:	55                   	push   %ebp
801019db:	89 e5                	mov    %esp,%ebp
801019dd:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
801019e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019e4:	74 17                	je     801019fd <iunlock+0x23>
801019e6:	8b 45 08             	mov    0x8(%ebp),%eax
801019e9:	8b 40 0c             	mov    0xc(%eax),%eax
801019ec:	83 e0 01             	and    $0x1,%eax
801019ef:	85 c0                	test   %eax,%eax
801019f1:	74 0a                	je     801019fd <iunlock+0x23>
801019f3:	8b 45 08             	mov    0x8(%ebp),%eax
801019f6:	8b 40 08             	mov    0x8(%eax),%eax
801019f9:	85 c0                	test   %eax,%eax
801019fb:	7f 0c                	jg     80101a09 <iunlock+0x2f>
    panic("iunlock");
801019fd:	c7 04 24 f4 87 10 80 	movl   $0x801087f4,(%esp)
80101a04:	e8 34 eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101a09:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a10:	e8 16 36 00 00       	call   8010502b <acquire>
  ip->flags &= ~I_BUSY;
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	8b 40 0c             	mov    0xc(%eax),%eax
80101a1b:	89 c2                	mov    %eax,%edx
80101a1d:	83 e2 fe             	and    $0xfffffffe,%edx
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101a26:	8b 45 08             	mov    0x8(%ebp),%eax
80101a29:	89 04 24             	mov    %eax,(%esp)
80101a2c:	e8 f6 33 00 00       	call   80104e27 <wakeup>
  release(&icache.lock);
80101a31:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a38:	e8 50 36 00 00       	call   8010508d <release>
}
80101a3d:	c9                   	leave  
80101a3e:	c3                   	ret    

80101a3f <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101a3f:	55                   	push   %ebp
80101a40:	89 e5                	mov    %esp,%ebp
80101a42:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a45:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101a4c:	e8 da 35 00 00       	call   8010502b <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	8b 40 08             	mov    0x8(%eax),%eax
80101a57:	83 f8 01             	cmp    $0x1,%eax
80101a5a:	0f 85 93 00 00 00    	jne    80101af3 <iput+0xb4>
80101a60:	8b 45 08             	mov    0x8(%ebp),%eax
80101a63:	8b 40 0c             	mov    0xc(%eax),%eax
80101a66:	83 e0 02             	and    $0x2,%eax
80101a69:	85 c0                	test   %eax,%eax
80101a6b:	0f 84 82 00 00 00    	je     80101af3 <iput+0xb4>
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a78:	66 85 c0             	test   %ax,%ax
80101a7b:	75 76                	jne    80101af3 <iput+0xb4>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a80:	8b 40 0c             	mov    0xc(%eax),%eax
80101a83:	83 e0 01             	and    $0x1,%eax
80101a86:	84 c0                	test   %al,%al
80101a88:	74 0c                	je     80101a96 <iput+0x57>
      panic("iput busy");
80101a8a:	c7 04 24 fc 87 10 80 	movl   $0x801087fc,(%esp)
80101a91:	e8 a7 ea ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101a96:	8b 45 08             	mov    0x8(%ebp),%eax
80101a99:	8b 40 0c             	mov    0xc(%eax),%eax
80101a9c:	89 c2                	mov    %eax,%edx
80101a9e:	83 ca 01             	or     $0x1,%edx
80101aa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa4:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101aa7:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101aae:	e8 da 35 00 00       	call   8010508d <release>
    itrunc(ip);
80101ab3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab6:	89 04 24             	mov    %eax,(%esp)
80101ab9:	e8 72 01 00 00       	call   80101c30 <itrunc>
    ip->type = 0;
80101abe:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101ac7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aca:	89 04 24             	mov    %eax,(%esp)
80101acd:	e8 fe fb ff ff       	call   801016d0 <iupdate>
    acquire(&icache.lock);
80101ad2:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101ad9:	e8 4d 35 00 00       	call   8010502b <acquire>
    ip->flags = 0;
80101ade:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aeb:	89 04 24             	mov    %eax,(%esp)
80101aee:	e8 34 33 00 00       	call   80104e27 <wakeup>
  }
  ip->ref--;
80101af3:	8b 45 08             	mov    0x8(%ebp),%eax
80101af6:	8b 40 08             	mov    0x8(%eax),%eax
80101af9:	8d 50 ff             	lea    -0x1(%eax),%edx
80101afc:	8b 45 08             	mov    0x8(%ebp),%eax
80101aff:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b02:	c7 04 24 40 12 11 80 	movl   $0x80111240,(%esp)
80101b09:	e8 7f 35 00 00       	call   8010508d <release>
}
80101b0e:	c9                   	leave  
80101b0f:	c3                   	ret    

80101b10 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101b10:	55                   	push   %ebp
80101b11:	89 e5                	mov    %esp,%ebp
80101b13:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101b16:	8b 45 08             	mov    0x8(%ebp),%eax
80101b19:	89 04 24             	mov    %eax,(%esp)
80101b1c:	e8 b9 fe ff ff       	call   801019da <iunlock>
  iput(ip);
80101b21:	8b 45 08             	mov    0x8(%ebp),%eax
80101b24:	89 04 24             	mov    %eax,(%esp)
80101b27:	e8 13 ff ff ff       	call   80101a3f <iput>
}
80101b2c:	c9                   	leave  
80101b2d:	c3                   	ret    

80101b2e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101b2e:	55                   	push   %ebp
80101b2f:	89 e5                	mov    %esp,%ebp
80101b31:	53                   	push   %ebx
80101b32:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101b35:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101b39:	77 3e                	ja     80101b79 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b41:	83 c2 04             	add    $0x4,%edx
80101b44:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b4f:	75 20                	jne    80101b71 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	8b 00                	mov    (%eax),%eax
80101b56:	89 04 24             	mov    %eax,(%esp)
80101b59:	e8 49 f8 ff ff       	call   801013a7 <balloc>
80101b5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b61:	8b 45 08             	mov    0x8(%ebp),%eax
80101b64:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b67:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b6d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b74:	e9 b1 00 00 00       	jmp    80101c2a <bmap+0xfc>
  }
  bn -= NDIRECT;
80101b79:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b7d:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b81:	0f 87 97 00 00 00    	ja     80101c1e <bmap+0xf0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b87:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b94:	75 19                	jne    80101baf <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b96:	8b 45 08             	mov    0x8(%ebp),%eax
80101b99:	8b 00                	mov    (%eax),%eax
80101b9b:	89 04 24             	mov    %eax,(%esp)
80101b9e:	e8 04 f8 ff ff       	call   801013a7 <balloc>
80101ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ba6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bac:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101baf:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb2:	8b 00                	mov    (%eax),%eax
80101bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bb7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bbb:	89 04 24             	mov    %eax,(%esp)
80101bbe:	e8 e3 e5 ff ff       	call   801001a6 <bread>
80101bc3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bc9:	83 c0 18             	add    $0x18,%eax
80101bcc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bd2:	c1 e0 02             	shl    $0x2,%eax
80101bd5:	03 45 ec             	add    -0x14(%ebp),%eax
80101bd8:	8b 00                	mov    (%eax),%eax
80101bda:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bdd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101be1:	75 2b                	jne    80101c0e <bmap+0xe0>
      a[bn] = addr = balloc(ip->dev);
80101be3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101be6:	c1 e0 02             	shl    $0x2,%eax
80101be9:	89 c3                	mov    %eax,%ebx
80101beb:	03 5d ec             	add    -0x14(%ebp),%ebx
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	8b 00                	mov    (%eax),%eax
80101bf3:	89 04 24             	mov    %eax,(%esp)
80101bf6:	e8 ac f7 ff ff       	call   801013a7 <balloc>
80101bfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c01:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101c03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 70 1a 00 00       	call   8010367e <log_write>
    }
    brelse(bp);
80101c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c11:	89 04 24             	mov    %eax,(%esp)
80101c14:	e8 fe e5 ff ff       	call   80100217 <brelse>
    return addr;
80101c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c1c:	eb 0c                	jmp    80101c2a <bmap+0xfc>
  }

  panic("bmap: out of range");
80101c1e:	c7 04 24 06 88 10 80 	movl   $0x80108806,(%esp)
80101c25:	e8 13 e9 ff ff       	call   8010053d <panic>
}
80101c2a:	83 c4 24             	add    $0x24,%esp
80101c2d:	5b                   	pop    %ebx
80101c2e:	5d                   	pop    %ebp
80101c2f:	c3                   	ret    

80101c30 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101c30:	55                   	push   %ebp
80101c31:	89 e5                	mov    %esp,%ebp
80101c33:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101c3d:	eb 44                	jmp    80101c83 <itrunc+0x53>
    if(ip->addrs[i]){
80101c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c42:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c45:	83 c2 04             	add    $0x4,%edx
80101c48:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c4c:	85 c0                	test   %eax,%eax
80101c4e:	74 2f                	je     80101c7f <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101c50:	8b 45 08             	mov    0x8(%ebp),%eax
80101c53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c56:	83 c2 04             	add    $0x4,%edx
80101c59:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c60:	8b 00                	mov    (%eax),%eax
80101c62:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c66:	89 04 24             	mov    %eax,(%esp)
80101c69:	e8 90 f8 ff ff       	call   801014fe <bfree>
      ip->addrs[i] = 0;
80101c6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c74:	83 c2 04             	add    $0x4,%edx
80101c77:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c7e:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c7f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101c83:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c87:	7e b6                	jle    80101c3f <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c89:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c8f:	85 c0                	test   %eax,%eax
80101c91:	0f 84 8f 00 00 00    	je     80101d26 <itrunc+0xf6>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c97:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9a:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca0:	8b 00                	mov    (%eax),%eax
80101ca2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ca6:	89 04 24             	mov    %eax,(%esp)
80101ca9:	e8 f8 e4 ff ff       	call   801001a6 <bread>
80101cae:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101cb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cb4:	83 c0 18             	add    $0x18,%eax
80101cb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101cba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101cc1:	eb 2f                	jmp    80101cf2 <itrunc+0xc2>
      if(a[j])
80101cc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cc6:	c1 e0 02             	shl    $0x2,%eax
80101cc9:	03 45 e8             	add    -0x18(%ebp),%eax
80101ccc:	8b 00                	mov    (%eax),%eax
80101cce:	85 c0                	test   %eax,%eax
80101cd0:	74 1c                	je     80101cee <itrunc+0xbe>
        bfree(ip->dev, a[j]);
80101cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd5:	c1 e0 02             	shl    $0x2,%eax
80101cd8:	03 45 e8             	add    -0x18(%ebp),%eax
80101cdb:	8b 10                	mov    (%eax),%edx
80101cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce0:	8b 00                	mov    (%eax),%eax
80101ce2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ce6:	89 04 24             	mov    %eax,(%esp)
80101ce9:	e8 10 f8 ff ff       	call   801014fe <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101cee:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101cf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf5:	83 f8 7f             	cmp    $0x7f,%eax
80101cf8:	76 c9                	jbe    80101cc3 <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101cfa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cfd:	89 04 24             	mov    %eax,(%esp)
80101d00:	e8 12 e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101d05:	8b 45 08             	mov    0x8(%ebp),%eax
80101d08:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0e:	8b 00                	mov    (%eax),%eax
80101d10:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d14:	89 04 24             	mov    %eax,(%esp)
80101d17:	e8 e2 f7 ff ff       	call   801014fe <bfree>
    ip->addrs[NDIRECT] = 0;
80101d1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	89 04 24             	mov    %eax,(%esp)
80101d36:	e8 95 f9 ff ff       	call   801016d0 <iupdate>
}
80101d3b:	c9                   	leave  
80101d3c:	c3                   	ret    

80101d3d <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101d3d:	55                   	push   %ebp
80101d3e:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101d40:	8b 45 08             	mov    0x8(%ebp),%eax
80101d43:	8b 00                	mov    (%eax),%eax
80101d45:	89 c2                	mov    %eax,%edx
80101d47:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d4a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101d4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d50:	8b 50 04             	mov    0x4(%eax),%edx
80101d53:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d56:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d59:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d63:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101d66:	8b 45 08             	mov    0x8(%ebp),%eax
80101d69:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d70:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101d74:	8b 45 08             	mov    0x8(%ebp),%eax
80101d77:	8b 50 18             	mov    0x18(%eax),%edx
80101d7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d7d:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d80:	5d                   	pop    %ebp
80101d81:	c3                   	ret    

80101d82 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d82:	55                   	push   %ebp
80101d83:	89 e5                	mov    %esp,%ebp
80101d85:	53                   	push   %ebx
80101d86:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d89:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101d90:	66 83 f8 03          	cmp    $0x3,%ax
80101d94:	75 60                	jne    80101df6 <readi+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d96:	8b 45 08             	mov    0x8(%ebp),%eax
80101d99:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101d9d:	66 85 c0             	test   %ax,%ax
80101da0:	78 20                	js     80101dc2 <readi+0x40>
80101da2:	8b 45 08             	mov    0x8(%ebp),%eax
80101da5:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101da9:	66 83 f8 09          	cmp    $0x9,%ax
80101dad:	7f 13                	jg     80101dc2 <readi+0x40>
80101daf:	8b 45 08             	mov    0x8(%ebp),%eax
80101db2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101db6:	98                   	cwtl   
80101db7:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101dbe:	85 c0                	test   %eax,%eax
80101dc0:	75 0a                	jne    80101dcc <readi+0x4a>
      return -1;
80101dc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101dc7:	e9 1b 01 00 00       	jmp    80101ee7 <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcf:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dd3:	98                   	cwtl   
80101dd4:	8b 14 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%edx
80101ddb:	8b 45 14             	mov    0x14(%ebp),%eax
80101dde:	89 44 24 08          	mov    %eax,0x8(%esp)
80101de2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101de5:	89 44 24 04          	mov    %eax,0x4(%esp)
80101de9:	8b 45 08             	mov    0x8(%ebp),%eax
80101dec:	89 04 24             	mov    %eax,(%esp)
80101def:	ff d2                	call   *%edx
80101df1:	e9 f1 00 00 00       	jmp    80101ee7 <readi+0x165>
  }

  if(off > ip->size || off + n < off)
80101df6:	8b 45 08             	mov    0x8(%ebp),%eax
80101df9:	8b 40 18             	mov    0x18(%eax),%eax
80101dfc:	3b 45 10             	cmp    0x10(%ebp),%eax
80101dff:	72 0d                	jb     80101e0e <readi+0x8c>
80101e01:	8b 45 14             	mov    0x14(%ebp),%eax
80101e04:	8b 55 10             	mov    0x10(%ebp),%edx
80101e07:	01 d0                	add    %edx,%eax
80101e09:	3b 45 10             	cmp    0x10(%ebp),%eax
80101e0c:	73 0a                	jae    80101e18 <readi+0x96>
    return -1;
80101e0e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101e13:	e9 cf 00 00 00       	jmp    80101ee7 <readi+0x165>
  if(off + n > ip->size)
80101e18:	8b 45 14             	mov    0x14(%ebp),%eax
80101e1b:	8b 55 10             	mov    0x10(%ebp),%edx
80101e1e:	01 c2                	add    %eax,%edx
80101e20:	8b 45 08             	mov    0x8(%ebp),%eax
80101e23:	8b 40 18             	mov    0x18(%eax),%eax
80101e26:	39 c2                	cmp    %eax,%edx
80101e28:	76 0c                	jbe    80101e36 <readi+0xb4>
    n = ip->size - off;
80101e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e2d:	8b 40 18             	mov    0x18(%eax),%eax
80101e30:	2b 45 10             	sub    0x10(%ebp),%eax
80101e33:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e3d:	e9 96 00 00 00       	jmp    80101ed8 <readi+0x156>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101e42:	8b 45 10             	mov    0x10(%ebp),%eax
80101e45:	c1 e8 09             	shr    $0x9,%eax
80101e48:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4f:	89 04 24             	mov    %eax,(%esp)
80101e52:	e8 d7 fc ff ff       	call   80101b2e <bmap>
80101e57:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5a:	8b 12                	mov    (%edx),%edx
80101e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e60:	89 14 24             	mov    %edx,(%esp)
80101e63:	e8 3e e3 ff ff       	call   801001a6 <bread>
80101e68:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e6b:	8b 45 10             	mov    0x10(%ebp),%eax
80101e6e:	89 c2                	mov    %eax,%edx
80101e70:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101e76:	b8 00 02 00 00       	mov    $0x200,%eax
80101e7b:	89 c1                	mov    %eax,%ecx
80101e7d:	29 d1                	sub    %edx,%ecx
80101e7f:	89 ca                	mov    %ecx,%edx
80101e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e84:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101e87:	89 cb                	mov    %ecx,%ebx
80101e89:	29 c3                	sub    %eax,%ebx
80101e8b:	89 d8                	mov    %ebx,%eax
80101e8d:	39 c2                	cmp    %eax,%edx
80101e8f:	0f 46 c2             	cmovbe %edx,%eax
80101e92:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e98:	8d 50 18             	lea    0x18(%eax),%edx
80101e9b:	8b 45 10             	mov    0x10(%ebp),%eax
80101e9e:	25 ff 01 00 00       	and    $0x1ff,%eax
80101ea3:	01 c2                	add    %eax,%edx
80101ea5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea8:	89 44 24 08          	mov    %eax,0x8(%esp)
80101eac:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb3:	89 04 24             	mov    %eax,(%esp)
80101eb6:	e8 92 34 00 00       	call   8010534d <memmove>
    brelse(bp);
80101ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ebe:	89 04 24             	mov    %eax,(%esp)
80101ec1:	e8 51 e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ec6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ec9:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ecf:	01 45 10             	add    %eax,0x10(%ebp)
80101ed2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ed5:	01 45 0c             	add    %eax,0xc(%ebp)
80101ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101edb:	3b 45 14             	cmp    0x14(%ebp),%eax
80101ede:	0f 82 5e ff ff ff    	jb     80101e42 <readi+0xc0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101ee4:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101ee7:	83 c4 24             	add    $0x24,%esp
80101eea:	5b                   	pop    %ebx
80101eeb:	5d                   	pop    %ebp
80101eec:	c3                   	ret    

80101eed <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101eed:	55                   	push   %ebp
80101eee:	89 e5                	mov    %esp,%ebp
80101ef0:	53                   	push   %ebx
80101ef1:	83 ec 24             	sub    $0x24,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef7:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101efb:	66 83 f8 03          	cmp    $0x3,%ax
80101eff:	75 60                	jne    80101f61 <writei+0x74>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101f01:	8b 45 08             	mov    0x8(%ebp),%eax
80101f04:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f08:	66 85 c0             	test   %ax,%ax
80101f0b:	78 20                	js     80101f2d <writei+0x40>
80101f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f10:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f14:	66 83 f8 09          	cmp    $0x9,%ax
80101f18:	7f 13                	jg     80101f2d <writei+0x40>
80101f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f21:	98                   	cwtl   
80101f22:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
80101f29:	85 c0                	test   %eax,%eax
80101f2b:	75 0a                	jne    80101f37 <writei+0x4a>
      return -1;
80101f2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f32:	e9 46 01 00 00       	jmp    8010207d <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80101f37:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f3e:	98                   	cwtl   
80101f3f:	8b 14 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%edx
80101f46:	8b 45 14             	mov    0x14(%ebp),%eax
80101f49:	89 44 24 08          	mov    %eax,0x8(%esp)
80101f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f50:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f54:	8b 45 08             	mov    0x8(%ebp),%eax
80101f57:	89 04 24             	mov    %eax,(%esp)
80101f5a:	ff d2                	call   *%edx
80101f5c:	e9 1c 01 00 00       	jmp    8010207d <writei+0x190>
  }

  if(off > ip->size || off + n < off)
80101f61:	8b 45 08             	mov    0x8(%ebp),%eax
80101f64:	8b 40 18             	mov    0x18(%eax),%eax
80101f67:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f6a:	72 0d                	jb     80101f79 <writei+0x8c>
80101f6c:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f72:	01 d0                	add    %edx,%eax
80101f74:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f77:	73 0a                	jae    80101f83 <writei+0x96>
    return -1;
80101f79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7e:	e9 fa 00 00 00       	jmp    8010207d <writei+0x190>
  if(off + n > MAXFILE*BSIZE)
80101f83:	8b 45 14             	mov    0x14(%ebp),%eax
80101f86:	8b 55 10             	mov    0x10(%ebp),%edx
80101f89:	01 d0                	add    %edx,%eax
80101f8b:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f90:	76 0a                	jbe    80101f9c <writei+0xaf>
    return -1;
80101f92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f97:	e9 e1 00 00 00       	jmp    8010207d <writei+0x190>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f9c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fa3:	e9 a1 00 00 00       	jmp    80102049 <writei+0x15c>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fa8:	8b 45 10             	mov    0x10(%ebp),%eax
80101fab:	c1 e8 09             	shr    $0x9,%eax
80101fae:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb5:	89 04 24             	mov    %eax,(%esp)
80101fb8:	e8 71 fb ff ff       	call   80101b2e <bmap>
80101fbd:	8b 55 08             	mov    0x8(%ebp),%edx
80101fc0:	8b 12                	mov    (%edx),%edx
80101fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fc6:	89 14 24             	mov    %edx,(%esp)
80101fc9:	e8 d8 e1 ff ff       	call   801001a6 <bread>
80101fce:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fd1:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd4:	89 c2                	mov    %eax,%edx
80101fd6:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101fdc:	b8 00 02 00 00       	mov    $0x200,%eax
80101fe1:	89 c1                	mov    %eax,%ecx
80101fe3:	29 d1                	sub    %edx,%ecx
80101fe5:	89 ca                	mov    %ecx,%edx
80101fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fea:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fed:	89 cb                	mov    %ecx,%ebx
80101fef:	29 c3                	sub    %eax,%ebx
80101ff1:	89 d8                	mov    %ebx,%eax
80101ff3:	39 c2                	cmp    %eax,%edx
80101ff5:	0f 46 c2             	cmovbe %edx,%eax
80101ff8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101ffb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ffe:	8d 50 18             	lea    0x18(%eax),%edx
80102001:	8b 45 10             	mov    0x10(%ebp),%eax
80102004:	25 ff 01 00 00       	and    $0x1ff,%eax
80102009:	01 c2                	add    %eax,%edx
8010200b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102012:	8b 45 0c             	mov    0xc(%ebp),%eax
80102015:	89 44 24 04          	mov    %eax,0x4(%esp)
80102019:	89 14 24             	mov    %edx,(%esp)
8010201c:	e8 2c 33 00 00       	call   8010534d <memmove>
    log_write(bp);
80102021:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102024:	89 04 24             	mov    %eax,(%esp)
80102027:	e8 52 16 00 00       	call   8010367e <log_write>
    brelse(bp);
8010202c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010202f:	89 04 24             	mov    %eax,(%esp)
80102032:	e8 e0 e1 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102037:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010203a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010203d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102040:	01 45 10             	add    %eax,0x10(%ebp)
80102043:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102046:	01 45 0c             	add    %eax,0xc(%ebp)
80102049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010204c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010204f:	0f 82 53 ff ff ff    	jb     80101fa8 <writei+0xbb>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102055:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102059:	74 1f                	je     8010207a <writei+0x18d>
8010205b:	8b 45 08             	mov    0x8(%ebp),%eax
8010205e:	8b 40 18             	mov    0x18(%eax),%eax
80102061:	3b 45 10             	cmp    0x10(%ebp),%eax
80102064:	73 14                	jae    8010207a <writei+0x18d>
    ip->size = off;
80102066:	8b 45 08             	mov    0x8(%ebp),%eax
80102069:	8b 55 10             	mov    0x10(%ebp),%edx
8010206c:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010206f:	8b 45 08             	mov    0x8(%ebp),%eax
80102072:	89 04 24             	mov    %eax,(%esp)
80102075:	e8 56 f6 ff ff       	call   801016d0 <iupdate>
  }
  return n;
8010207a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010207d:	83 c4 24             	add    $0x24,%esp
80102080:	5b                   	pop    %ebx
80102081:	5d                   	pop    %ebp
80102082:	c3                   	ret    

80102083 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102083:	55                   	push   %ebp
80102084:	89 e5                	mov    %esp,%ebp
80102086:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102089:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102090:	00 
80102091:	8b 45 0c             	mov    0xc(%ebp),%eax
80102094:	89 44 24 04          	mov    %eax,0x4(%esp)
80102098:	8b 45 08             	mov    0x8(%ebp),%eax
8010209b:	89 04 24             	mov    %eax,(%esp)
8010209e:	e8 4e 33 00 00       	call   801053f1 <strncmp>
}
801020a3:	c9                   	leave  
801020a4:	c3                   	ret    

801020a5 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801020a5:	55                   	push   %ebp
801020a6:	89 e5                	mov    %esp,%ebp
801020a8:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801020ab:	8b 45 08             	mov    0x8(%ebp),%eax
801020ae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020b2:	66 83 f8 01          	cmp    $0x1,%ax
801020b6:	74 0c                	je     801020c4 <dirlookup+0x1f>
    panic("dirlookup not DIR");
801020b8:	c7 04 24 19 88 10 80 	movl   $0x80108819,(%esp)
801020bf:	e8 79 e4 ff ff       	call   8010053d <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801020c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020cb:	e9 87 00 00 00       	jmp    80102157 <dirlookup+0xb2>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020d0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801020d7:	00 
801020d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020db:	89 44 24 08          	mov    %eax,0x8(%esp)
801020df:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801020e6:	8b 45 08             	mov    0x8(%ebp),%eax
801020e9:	89 04 24             	mov    %eax,(%esp)
801020ec:	e8 91 fc ff ff       	call   80101d82 <readi>
801020f1:	83 f8 10             	cmp    $0x10,%eax
801020f4:	74 0c                	je     80102102 <dirlookup+0x5d>
      panic("dirlink read");
801020f6:	c7 04 24 2b 88 10 80 	movl   $0x8010882b,(%esp)
801020fd:	e8 3b e4 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
80102102:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102106:	66 85 c0             	test   %ax,%ax
80102109:	74 47                	je     80102152 <dirlookup+0xad>
      continue;
    if(namecmp(name, de.name) == 0){
8010210b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010210e:	83 c0 02             	add    $0x2,%eax
80102111:	89 44 24 04          	mov    %eax,0x4(%esp)
80102115:	8b 45 0c             	mov    0xc(%ebp),%eax
80102118:	89 04 24             	mov    %eax,(%esp)
8010211b:	e8 63 ff ff ff       	call   80102083 <namecmp>
80102120:	85 c0                	test   %eax,%eax
80102122:	75 2f                	jne    80102153 <dirlookup+0xae>
      // entry matches path element
      if(poff)
80102124:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102128:	74 08                	je     80102132 <dirlookup+0x8d>
        *poff = off;
8010212a:	8b 45 10             	mov    0x10(%ebp),%eax
8010212d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102130:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102132:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102136:	0f b7 c0             	movzwl %ax,%eax
80102139:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010213c:	8b 45 08             	mov    0x8(%ebp),%eax
8010213f:	8b 00                	mov    (%eax),%eax
80102141:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102144:	89 54 24 04          	mov    %edx,0x4(%esp)
80102148:	89 04 24             	mov    %eax,(%esp)
8010214b:	e8 38 f6 ff ff       	call   80101788 <iget>
80102150:	eb 19                	jmp    8010216b <dirlookup+0xc6>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102152:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102153:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102157:	8b 45 08             	mov    0x8(%ebp),%eax
8010215a:	8b 40 18             	mov    0x18(%eax),%eax
8010215d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102160:	0f 87 6a ff ff ff    	ja     801020d0 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102166:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010216b:	c9                   	leave  
8010216c:	c3                   	ret    

8010216d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010216d:	55                   	push   %ebp
8010216e:	89 e5                	mov    %esp,%ebp
80102170:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102173:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010217a:	00 
8010217b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010217e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102182:	8b 45 08             	mov    0x8(%ebp),%eax
80102185:	89 04 24             	mov    %eax,(%esp)
80102188:	e8 18 ff ff ff       	call   801020a5 <dirlookup>
8010218d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102190:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102194:	74 15                	je     801021ab <dirlink+0x3e>
    iput(ip);
80102196:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102199:	89 04 24             	mov    %eax,(%esp)
8010219c:	e8 9e f8 ff ff       	call   80101a3f <iput>
    return -1;
801021a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021a6:	e9 b8 00 00 00       	jmp    80102263 <dirlink+0xf6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021b2:	eb 44                	jmp    801021f8 <dirlink+0x8b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021b7:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021be:	00 
801021bf:	89 44 24 08          	mov    %eax,0x8(%esp)
801021c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ca:	8b 45 08             	mov    0x8(%ebp),%eax
801021cd:	89 04 24             	mov    %eax,(%esp)
801021d0:	e8 ad fb ff ff       	call   80101d82 <readi>
801021d5:	83 f8 10             	cmp    $0x10,%eax
801021d8:	74 0c                	je     801021e6 <dirlink+0x79>
      panic("dirlink read");
801021da:	c7 04 24 2b 88 10 80 	movl   $0x8010882b,(%esp)
801021e1:	e8 57 e3 ff ff       	call   8010053d <panic>
    if(de.inum == 0)
801021e6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021ea:	66 85 c0             	test   %ax,%ax
801021ed:	74 18                	je     80102207 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801021ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021f2:	83 c0 10             	add    $0x10,%eax
801021f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801021f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021fb:	8b 45 08             	mov    0x8(%ebp),%eax
801021fe:	8b 40 18             	mov    0x18(%eax),%eax
80102201:	39 c2                	cmp    %eax,%edx
80102203:	72 af                	jb     801021b4 <dirlink+0x47>
80102205:	eb 01                	jmp    80102208 <dirlink+0x9b>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102207:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102208:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010220f:	00 
80102210:	8b 45 0c             	mov    0xc(%ebp),%eax
80102213:	89 44 24 04          	mov    %eax,0x4(%esp)
80102217:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221a:	83 c0 02             	add    $0x2,%eax
8010221d:	89 04 24             	mov    %eax,(%esp)
80102220:	e8 24 32 00 00       	call   80105449 <strncpy>
  de.inum = inum;
80102225:	8b 45 10             	mov    0x10(%ebp),%eax
80102228:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010222c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010222f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102236:	00 
80102237:	89 44 24 08          	mov    %eax,0x8(%esp)
8010223b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010223e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102242:	8b 45 08             	mov    0x8(%ebp),%eax
80102245:	89 04 24             	mov    %eax,(%esp)
80102248:	e8 a0 fc ff ff       	call   80101eed <writei>
8010224d:	83 f8 10             	cmp    $0x10,%eax
80102250:	74 0c                	je     8010225e <dirlink+0xf1>
    panic("dirlink");
80102252:	c7 04 24 38 88 10 80 	movl   $0x80108838,(%esp)
80102259:	e8 df e2 ff ff       	call   8010053d <panic>
  
  return 0;
8010225e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102263:	c9                   	leave  
80102264:	c3                   	ret    

80102265 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102265:	55                   	push   %ebp
80102266:	89 e5                	mov    %esp,%ebp
80102268:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010226b:	eb 04                	jmp    80102271 <skipelem+0xc>
    path++;
8010226d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	0f b6 00             	movzbl (%eax),%eax
80102277:	3c 2f                	cmp    $0x2f,%al
80102279:	74 f2                	je     8010226d <skipelem+0x8>
    path++;
  if(*path == 0)
8010227b:	8b 45 08             	mov    0x8(%ebp),%eax
8010227e:	0f b6 00             	movzbl (%eax),%eax
80102281:	84 c0                	test   %al,%al
80102283:	75 0a                	jne    8010228f <skipelem+0x2a>
    return 0;
80102285:	b8 00 00 00 00       	mov    $0x0,%eax
8010228a:	e9 86 00 00 00       	jmp    80102315 <skipelem+0xb0>
  s = path;
8010228f:	8b 45 08             	mov    0x8(%ebp),%eax
80102292:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102295:	eb 04                	jmp    8010229b <skipelem+0x36>
    path++;
80102297:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010229b:	8b 45 08             	mov    0x8(%ebp),%eax
8010229e:	0f b6 00             	movzbl (%eax),%eax
801022a1:	3c 2f                	cmp    $0x2f,%al
801022a3:	74 0a                	je     801022af <skipelem+0x4a>
801022a5:	8b 45 08             	mov    0x8(%ebp),%eax
801022a8:	0f b6 00             	movzbl (%eax),%eax
801022ab:	84 c0                	test   %al,%al
801022ad:	75 e8                	jne    80102297 <skipelem+0x32>
    path++;
  len = path - s;
801022af:	8b 55 08             	mov    0x8(%ebp),%edx
801022b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b5:	89 d1                	mov    %edx,%ecx
801022b7:	29 c1                	sub    %eax,%ecx
801022b9:	89 c8                	mov    %ecx,%eax
801022bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801022be:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801022c2:	7e 1c                	jle    801022e0 <skipelem+0x7b>
    memmove(name, s, DIRSIZ);
801022c4:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801022cb:	00 
801022cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801022d6:	89 04 24             	mov    %eax,(%esp)
801022d9:	e8 6f 30 00 00       	call   8010534d <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801022de:	eb 28                	jmp    80102308 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801022e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e3:	89 44 24 08          	mov    %eax,0x8(%esp)
801022e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801022f1:	89 04 24             	mov    %eax,(%esp)
801022f4:	e8 54 30 00 00       	call   8010534d <memmove>
    name[len] = 0;
801022f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022fc:	03 45 0c             	add    0xc(%ebp),%eax
801022ff:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102302:	eb 04                	jmp    80102308 <skipelem+0xa3>
    path++;
80102304:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102308:	8b 45 08             	mov    0x8(%ebp),%eax
8010230b:	0f b6 00             	movzbl (%eax),%eax
8010230e:	3c 2f                	cmp    $0x2f,%al
80102310:	74 f2                	je     80102304 <skipelem+0x9f>
    path++;
  return path;
80102312:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102315:	c9                   	leave  
80102316:	c3                   	ret    

80102317 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102317:	55                   	push   %ebp
80102318:	89 e5                	mov    %esp,%ebp
8010231a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010231d:	8b 45 08             	mov    0x8(%ebp),%eax
80102320:	0f b6 00             	movzbl (%eax),%eax
80102323:	3c 2f                	cmp    $0x2f,%al
80102325:	75 1c                	jne    80102343 <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
80102327:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010232e:	00 
8010232f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102336:	e8 4d f4 ff ff       	call   80101788 <iget>
8010233b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010233e:	e9 af 00 00 00       	jmp    801023f2 <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
80102343:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102349:	8b 40 68             	mov    0x68(%eax),%eax
8010234c:	89 04 24             	mov    %eax,(%esp)
8010234f:	e8 06 f5 ff ff       	call   8010185a <idup>
80102354:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102357:	e9 96 00 00 00       	jmp    801023f2 <namex+0xdb>
    ilock(ip);
8010235c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235f:	89 04 24             	mov    %eax,(%esp)
80102362:	e8 25 f5 ff ff       	call   8010188c <ilock>
    if(ip->type != T_DIR){
80102367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010236a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010236e:	66 83 f8 01          	cmp    $0x1,%ax
80102372:	74 15                	je     80102389 <namex+0x72>
      iunlockput(ip);
80102374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102377:	89 04 24             	mov    %eax,(%esp)
8010237a:	e8 91 f7 ff ff       	call   80101b10 <iunlockput>
      return 0;
8010237f:	b8 00 00 00 00       	mov    $0x0,%eax
80102384:	e9 a3 00 00 00       	jmp    8010242c <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
80102389:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010238d:	74 1d                	je     801023ac <namex+0x95>
8010238f:	8b 45 08             	mov    0x8(%ebp),%eax
80102392:	0f b6 00             	movzbl (%eax),%eax
80102395:	84 c0                	test   %al,%al
80102397:	75 13                	jne    801023ac <namex+0x95>
      // Stop one level early.
      iunlock(ip);
80102399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010239c:	89 04 24             	mov    %eax,(%esp)
8010239f:	e8 36 f6 ff ff       	call   801019da <iunlock>
      return ip;
801023a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a7:	e9 80 00 00 00       	jmp    8010242c <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801023ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801023b3:	00 
801023b4:	8b 45 10             	mov    0x10(%ebp),%eax
801023b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023be:	89 04 24             	mov    %eax,(%esp)
801023c1:	e8 df fc ff ff       	call   801020a5 <dirlookup>
801023c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801023c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801023cd:	75 12                	jne    801023e1 <namex+0xca>
      iunlockput(ip);
801023cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d2:	89 04 24             	mov    %eax,(%esp)
801023d5:	e8 36 f7 ff ff       	call   80101b10 <iunlockput>
      return 0;
801023da:	b8 00 00 00 00       	mov    $0x0,%eax
801023df:	eb 4b                	jmp    8010242c <namex+0x115>
    }
    iunlockput(ip);
801023e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023e4:	89 04 24             	mov    %eax,(%esp)
801023e7:	e8 24 f7 ff ff       	call   80101b10 <iunlockput>
    ip = next;
801023ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801023f2:	8b 45 10             	mov    0x10(%ebp),%eax
801023f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
801023fc:	89 04 24             	mov    %eax,(%esp)
801023ff:	e8 61 fe ff ff       	call   80102265 <skipelem>
80102404:	89 45 08             	mov    %eax,0x8(%ebp)
80102407:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010240b:	0f 85 4b ff ff ff    	jne    8010235c <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102411:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102415:	74 12                	je     80102429 <namex+0x112>
    iput(ip);
80102417:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010241a:	89 04 24             	mov    %eax,(%esp)
8010241d:	e8 1d f6 ff ff       	call   80101a3f <iput>
    return 0;
80102422:	b8 00 00 00 00       	mov    $0x0,%eax
80102427:	eb 03                	jmp    8010242c <namex+0x115>
  }
  return ip;
80102429:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010242c:	c9                   	leave  
8010242d:	c3                   	ret    

8010242e <namei>:

struct inode*
namei(char *path)
{
8010242e:	55                   	push   %ebp
8010242f:	89 e5                	mov    %esp,%ebp
80102431:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102434:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102437:	89 44 24 08          	mov    %eax,0x8(%esp)
8010243b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102442:	00 
80102443:	8b 45 08             	mov    0x8(%ebp),%eax
80102446:	89 04 24             	mov    %eax,(%esp)
80102449:	e8 c9 fe ff ff       	call   80102317 <namex>
}
8010244e:	c9                   	leave  
8010244f:	c3                   	ret    

80102450 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102450:	55                   	push   %ebp
80102451:	89 e5                	mov    %esp,%ebp
80102453:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102456:	8b 45 0c             	mov    0xc(%ebp),%eax
80102459:	89 44 24 08          	mov    %eax,0x8(%esp)
8010245d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102464:	00 
80102465:	8b 45 08             	mov    0x8(%ebp),%eax
80102468:	89 04 24             	mov    %eax,(%esp)
8010246b:	e8 a7 fe ff ff       	call   80102317 <namex>
}
80102470:	c9                   	leave  
80102471:	c3                   	ret    
	...

80102474 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102474:	55                   	push   %ebp
80102475:	89 e5                	mov    %esp,%ebp
80102477:	53                   	push   %ebx
80102478:	83 ec 14             	sub    $0x14,%esp
8010247b:	8b 45 08             	mov    0x8(%ebp),%eax
8010247e:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102482:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102486:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010248a:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
8010248e:	ec                   	in     (%dx),%al
8010248f:	89 c3                	mov    %eax,%ebx
80102491:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102494:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102498:	83 c4 14             	add    $0x14,%esp
8010249b:	5b                   	pop    %ebx
8010249c:	5d                   	pop    %ebp
8010249d:	c3                   	ret    

8010249e <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010249e:	55                   	push   %ebp
8010249f:	89 e5                	mov    %esp,%ebp
801024a1:	57                   	push   %edi
801024a2:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801024a3:	8b 55 08             	mov    0x8(%ebp),%edx
801024a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024a9:	8b 45 10             	mov    0x10(%ebp),%eax
801024ac:	89 cb                	mov    %ecx,%ebx
801024ae:	89 df                	mov    %ebx,%edi
801024b0:	89 c1                	mov    %eax,%ecx
801024b2:	fc                   	cld    
801024b3:	f3 6d                	rep insl (%dx),%es:(%edi)
801024b5:	89 c8                	mov    %ecx,%eax
801024b7:	89 fb                	mov    %edi,%ebx
801024b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024bc:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801024bf:	5b                   	pop    %ebx
801024c0:	5f                   	pop    %edi
801024c1:	5d                   	pop    %ebp
801024c2:	c3                   	ret    

801024c3 <outb>:

static inline void
outb(ushort port, uchar data)
{
801024c3:	55                   	push   %ebp
801024c4:	89 e5                	mov    %esp,%ebp
801024c6:	83 ec 08             	sub    $0x8,%esp
801024c9:	8b 55 08             	mov    0x8(%ebp),%edx
801024cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801024cf:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801024d3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024d6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801024da:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801024de:	ee                   	out    %al,(%dx)
}
801024df:	c9                   	leave  
801024e0:	c3                   	ret    

801024e1 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801024e1:	55                   	push   %ebp
801024e2:	89 e5                	mov    %esp,%ebp
801024e4:	56                   	push   %esi
801024e5:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801024e6:	8b 55 08             	mov    0x8(%ebp),%edx
801024e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801024ec:	8b 45 10             	mov    0x10(%ebp),%eax
801024ef:	89 cb                	mov    %ecx,%ebx
801024f1:	89 de                	mov    %ebx,%esi
801024f3:	89 c1                	mov    %eax,%ecx
801024f5:	fc                   	cld    
801024f6:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801024f8:	89 c8                	mov    %ecx,%eax
801024fa:	89 f3                	mov    %esi,%ebx
801024fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801024ff:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102502:	5b                   	pop    %ebx
80102503:	5e                   	pop    %esi
80102504:	5d                   	pop    %ebp
80102505:	c3                   	ret    

80102506 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102506:	55                   	push   %ebp
80102507:	89 e5                	mov    %esp,%ebp
80102509:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010250c:	90                   	nop
8010250d:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102514:	e8 5b ff ff ff       	call   80102474 <inb>
80102519:	0f b6 c0             	movzbl %al,%eax
8010251c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010251f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102522:	25 c0 00 00 00       	and    $0xc0,%eax
80102527:	83 f8 40             	cmp    $0x40,%eax
8010252a:	75 e1                	jne    8010250d <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010252c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102530:	74 11                	je     80102543 <idewait+0x3d>
80102532:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102535:	83 e0 21             	and    $0x21,%eax
80102538:	85 c0                	test   %eax,%eax
8010253a:	74 07                	je     80102543 <idewait+0x3d>
    return -1;
8010253c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102541:	eb 05                	jmp    80102548 <idewait+0x42>
  return 0;
80102543:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102548:	c9                   	leave  
80102549:	c3                   	ret    

8010254a <ideinit>:

void
ideinit(void)
{
8010254a:	55                   	push   %ebp
8010254b:	89 e5                	mov    %esp,%ebp
8010254d:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102550:	c7 44 24 04 40 88 10 	movl   $0x80108840,0x4(%esp)
80102557:	80 
80102558:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010255f:	e8 a6 2a 00 00       	call   8010500a <initlock>
  picenable(IRQ_IDE);
80102564:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
8010256b:	e8 c1 18 00 00       	call   80103e31 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102570:	a1 40 29 11 80       	mov    0x80112940,%eax
80102575:	83 e8 01             	sub    $0x1,%eax
80102578:	89 44 24 04          	mov    %eax,0x4(%esp)
8010257c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102583:	e8 12 04 00 00       	call   8010299a <ioapicenable>
  idewait(0);
80102588:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010258f:	e8 72 ff ff ff       	call   80102506 <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102594:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010259b:	00 
8010259c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025a3:	e8 1b ff ff ff       	call   801024c3 <outb>
  for(i=0; i<1000; i++){
801025a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025af:	eb 20                	jmp    801025d1 <ideinit+0x87>
    if(inb(0x1f7) != 0){
801025b1:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801025b8:	e8 b7 fe ff ff       	call   80102474 <inb>
801025bd:	84 c0                	test   %al,%al
801025bf:	74 0c                	je     801025cd <ideinit+0x83>
      havedisk1 = 1;
801025c1:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
801025c8:	00 00 00 
      break;
801025cb:	eb 0d                	jmp    801025da <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801025cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801025d1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801025d8:	7e d7                	jle    801025b1 <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801025da:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801025e1:	00 
801025e2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801025e9:	e8 d5 fe ff ff       	call   801024c3 <outb>
}
801025ee:	c9                   	leave  
801025ef:	c3                   	ret    

801025f0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801025f0:	55                   	push   %ebp
801025f1:	89 e5                	mov    %esp,%ebp
801025f3:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801025f6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025fa:	75 0c                	jne    80102608 <idestart+0x18>
    panic("idestart");
801025fc:	c7 04 24 44 88 10 80 	movl   $0x80108844,(%esp)
80102603:	e8 35 df ff ff       	call   8010053d <panic>

  idewait(0);
80102608:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010260f:	e8 f2 fe ff ff       	call   80102506 <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102614:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010261b:	00 
8010261c:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102623:	e8 9b fe ff ff       	call   801024c3 <outb>
  outb(0x1f2, 1);  // number of sectors
80102628:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010262f:	00 
80102630:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102637:	e8 87 fe ff ff       	call   801024c3 <outb>
  outb(0x1f3, b->sector & 0xff);
8010263c:	8b 45 08             	mov    0x8(%ebp),%eax
8010263f:	8b 40 08             	mov    0x8(%eax),%eax
80102642:	0f b6 c0             	movzbl %al,%eax
80102645:	89 44 24 04          	mov    %eax,0x4(%esp)
80102649:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102650:	e8 6e fe ff ff       	call   801024c3 <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
80102655:	8b 45 08             	mov    0x8(%ebp),%eax
80102658:	8b 40 08             	mov    0x8(%eax),%eax
8010265b:	c1 e8 08             	shr    $0x8,%eax
8010265e:	0f b6 c0             	movzbl %al,%eax
80102661:	89 44 24 04          	mov    %eax,0x4(%esp)
80102665:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010266c:	e8 52 fe ff ff       	call   801024c3 <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
80102671:	8b 45 08             	mov    0x8(%ebp),%eax
80102674:	8b 40 08             	mov    0x8(%eax),%eax
80102677:	c1 e8 10             	shr    $0x10,%eax
8010267a:	0f b6 c0             	movzbl %al,%eax
8010267d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102681:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102688:	e8 36 fe ff ff       	call   801024c3 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
8010268d:	8b 45 08             	mov    0x8(%ebp),%eax
80102690:	8b 40 04             	mov    0x4(%eax),%eax
80102693:	83 e0 01             	and    $0x1,%eax
80102696:	89 c2                	mov    %eax,%edx
80102698:	c1 e2 04             	shl    $0x4,%edx
8010269b:	8b 45 08             	mov    0x8(%ebp),%eax
8010269e:	8b 40 08             	mov    0x8(%eax),%eax
801026a1:	c1 e8 18             	shr    $0x18,%eax
801026a4:	83 e0 0f             	and    $0xf,%eax
801026a7:	09 d0                	or     %edx,%eax
801026a9:	83 c8 e0             	or     $0xffffffe0,%eax
801026ac:	0f b6 c0             	movzbl %al,%eax
801026af:	89 44 24 04          	mov    %eax,0x4(%esp)
801026b3:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026ba:	e8 04 fe ff ff       	call   801024c3 <outb>
  if(b->flags & B_DIRTY){
801026bf:	8b 45 08             	mov    0x8(%ebp),%eax
801026c2:	8b 00                	mov    (%eax),%eax
801026c4:	83 e0 04             	and    $0x4,%eax
801026c7:	85 c0                	test   %eax,%eax
801026c9:	74 34                	je     801026ff <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801026cb:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801026d2:	00 
801026d3:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026da:	e8 e4 fd ff ff       	call   801024c3 <outb>
    outsl(0x1f0, b->data, 512/4);
801026df:	8b 45 08             	mov    0x8(%ebp),%eax
801026e2:	83 c0 18             	add    $0x18,%eax
801026e5:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026ec:	00 
801026ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801026f1:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801026f8:	e8 e4 fd ff ff       	call   801024e1 <outsl>
801026fd:	eb 14                	jmp    80102713 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
801026ff:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80102706:	00 
80102707:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010270e:	e8 b0 fd ff ff       	call   801024c3 <outb>
  }
}
80102713:	c9                   	leave  
80102714:	c3                   	ret    

80102715 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102715:	55                   	push   %ebp
80102716:	89 e5                	mov    %esp,%ebp
80102718:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010271b:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102722:	e8 04 29 00 00       	call   8010502b <acquire>
  if((b = idequeue) == 0){
80102727:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010272c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010272f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102733:	75 11                	jne    80102746 <ideintr+0x31>
    release(&idelock);
80102735:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
8010273c:	e8 4c 29 00 00       	call   8010508d <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102741:	e9 90 00 00 00       	jmp    801027d6 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102746:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102749:	8b 40 14             	mov    0x14(%eax),%eax
8010274c:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102754:	8b 00                	mov    (%eax),%eax
80102756:	83 e0 04             	and    $0x4,%eax
80102759:	85 c0                	test   %eax,%eax
8010275b:	75 2e                	jne    8010278b <ideintr+0x76>
8010275d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102764:	e8 9d fd ff ff       	call   80102506 <idewait>
80102769:	85 c0                	test   %eax,%eax
8010276b:	78 1e                	js     8010278b <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
8010276d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102770:	83 c0 18             	add    $0x18,%eax
80102773:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010277a:	00 
8010277b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010277f:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102786:	e8 13 fd ff ff       	call   8010249e <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010278b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010278e:	8b 00                	mov    (%eax),%eax
80102790:	89 c2                	mov    %eax,%edx
80102792:	83 ca 02             	or     $0x2,%edx
80102795:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102798:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010279a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010279d:	8b 00                	mov    (%eax),%eax
8010279f:	89 c2                	mov    %eax,%edx
801027a1:	83 e2 fb             	and    $0xfffffffb,%edx
801027a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027a7:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801027a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027ac:	89 04 24             	mov    %eax,(%esp)
801027af:	e8 73 26 00 00       	call   80104e27 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801027b4:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801027b9:	85 c0                	test   %eax,%eax
801027bb:	74 0d                	je     801027ca <ideintr+0xb5>
    idestart(idequeue);
801027bd:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801027c2:	89 04 24             	mov    %eax,(%esp)
801027c5:	e8 26 fe ff ff       	call   801025f0 <idestart>

  release(&idelock);
801027ca:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801027d1:	e8 b7 28 00 00       	call   8010508d <release>
}
801027d6:	c9                   	leave  
801027d7:	c3                   	ret    

801027d8 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801027d8:	55                   	push   %ebp
801027d9:	89 e5                	mov    %esp,%ebp
801027db:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801027de:	8b 45 08             	mov    0x8(%ebp),%eax
801027e1:	8b 00                	mov    (%eax),%eax
801027e3:	83 e0 01             	and    $0x1,%eax
801027e6:	85 c0                	test   %eax,%eax
801027e8:	75 0c                	jne    801027f6 <iderw+0x1e>
    panic("iderw: buf not busy");
801027ea:	c7 04 24 4d 88 10 80 	movl   $0x8010884d,(%esp)
801027f1:	e8 47 dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027f6:	8b 45 08             	mov    0x8(%ebp),%eax
801027f9:	8b 00                	mov    (%eax),%eax
801027fb:	83 e0 06             	and    $0x6,%eax
801027fe:	83 f8 02             	cmp    $0x2,%eax
80102801:	75 0c                	jne    8010280f <iderw+0x37>
    panic("iderw: nothing to do");
80102803:	c7 04 24 61 88 10 80 	movl   $0x80108861,(%esp)
8010280a:	e8 2e dd ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
8010280f:	8b 45 08             	mov    0x8(%ebp),%eax
80102812:	8b 40 04             	mov    0x4(%eax),%eax
80102815:	85 c0                	test   %eax,%eax
80102817:	74 15                	je     8010282e <iderw+0x56>
80102819:	a1 38 b6 10 80       	mov    0x8010b638,%eax
8010281e:	85 c0                	test   %eax,%eax
80102820:	75 0c                	jne    8010282e <iderw+0x56>
    panic("iderw: ide disk 1 not present");
80102822:	c7 04 24 76 88 10 80 	movl   $0x80108876,(%esp)
80102829:	e8 0f dd ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010282e:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
80102835:	e8 f1 27 00 00       	call   8010502b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
8010283a:	8b 45 08             	mov    0x8(%ebp),%eax
8010283d:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102844:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
8010284b:	eb 0b                	jmp    80102858 <iderw+0x80>
8010284d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102850:	8b 00                	mov    (%eax),%eax
80102852:	83 c0 14             	add    $0x14,%eax
80102855:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102858:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010285b:	8b 00                	mov    (%eax),%eax
8010285d:	85 c0                	test   %eax,%eax
8010285f:	75 ec                	jne    8010284d <iderw+0x75>
    ;
  *pp = b;
80102861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102864:	8b 55 08             	mov    0x8(%ebp),%edx
80102867:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102869:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010286e:	3b 45 08             	cmp    0x8(%ebp),%eax
80102871:	75 22                	jne    80102895 <iderw+0xbd>
    idestart(b);
80102873:	8b 45 08             	mov    0x8(%ebp),%eax
80102876:	89 04 24             	mov    %eax,(%esp)
80102879:	e8 72 fd ff ff       	call   801025f0 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010287e:	eb 15                	jmp    80102895 <iderw+0xbd>
    sleep(b, &idelock);
80102880:	c7 44 24 04 00 b6 10 	movl   $0x8010b600,0x4(%esp)
80102887:	80 
80102888:	8b 45 08             	mov    0x8(%ebp),%eax
8010288b:	89 04 24             	mov    %eax,(%esp)
8010288e:	e8 bb 24 00 00       	call   80104d4e <sleep>
80102893:	eb 01                	jmp    80102896 <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102895:	90                   	nop
80102896:	8b 45 08             	mov    0x8(%ebp),%eax
80102899:	8b 00                	mov    (%eax),%eax
8010289b:	83 e0 06             	and    $0x6,%eax
8010289e:	83 f8 02             	cmp    $0x2,%eax
801028a1:	75 dd                	jne    80102880 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
801028a3:	c7 04 24 00 b6 10 80 	movl   $0x8010b600,(%esp)
801028aa:	e8 de 27 00 00       	call   8010508d <release>
}
801028af:	c9                   	leave  
801028b0:	c3                   	ret    
801028b1:	00 00                	add    %al,(%eax)
	...

801028b4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801028b4:	55                   	push   %ebp
801028b5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028b7:	a1 14 22 11 80       	mov    0x80112214,%eax
801028bc:	8b 55 08             	mov    0x8(%ebp),%edx
801028bf:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801028c1:	a1 14 22 11 80       	mov    0x80112214,%eax
801028c6:	8b 40 10             	mov    0x10(%eax),%eax
}
801028c9:	5d                   	pop    %ebp
801028ca:	c3                   	ret    

801028cb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801028cb:	55                   	push   %ebp
801028cc:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801028ce:	a1 14 22 11 80       	mov    0x80112214,%eax
801028d3:	8b 55 08             	mov    0x8(%ebp),%edx
801028d6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028d8:	a1 14 22 11 80       	mov    0x80112214,%eax
801028dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801028e0:	89 50 10             	mov    %edx,0x10(%eax)
}
801028e3:	5d                   	pop    %ebp
801028e4:	c3                   	ret    

801028e5 <ioapicinit>:

void
ioapicinit(void)
{
801028e5:	55                   	push   %ebp
801028e6:	89 e5                	mov    %esp,%ebp
801028e8:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
801028eb:	a1 44 23 11 80       	mov    0x80112344,%eax
801028f0:	85 c0                	test   %eax,%eax
801028f2:	0f 84 9f 00 00 00    	je     80102997 <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801028f8:	c7 05 14 22 11 80 00 	movl   $0xfec00000,0x80112214
801028ff:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102902:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102909:	e8 a6 ff ff ff       	call   801028b4 <ioapicread>
8010290e:	c1 e8 10             	shr    $0x10,%eax
80102911:	25 ff 00 00 00       	and    $0xff,%eax
80102916:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102919:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102920:	e8 8f ff ff ff       	call   801028b4 <ioapicread>
80102925:	c1 e8 18             	shr    $0x18,%eax
80102928:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
8010292b:	0f b6 05 40 23 11 80 	movzbl 0x80112340,%eax
80102932:	0f b6 c0             	movzbl %al,%eax
80102935:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102938:	74 0c                	je     80102946 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
8010293a:	c7 04 24 94 88 10 80 	movl   $0x80108894,(%esp)
80102941:	e8 5b da ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102946:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010294d:	eb 3e                	jmp    8010298d <ioapicinit+0xa8>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010294f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102952:	83 c0 20             	add    $0x20,%eax
80102955:	0d 00 00 01 00       	or     $0x10000,%eax
8010295a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010295d:	83 c2 08             	add    $0x8,%edx
80102960:	01 d2                	add    %edx,%edx
80102962:	89 44 24 04          	mov    %eax,0x4(%esp)
80102966:	89 14 24             	mov    %edx,(%esp)
80102969:	e8 5d ff ff ff       	call   801028cb <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010296e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102971:	83 c0 08             	add    $0x8,%eax
80102974:	01 c0                	add    %eax,%eax
80102976:	83 c0 01             	add    $0x1,%eax
80102979:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102980:	00 
80102981:	89 04 24             	mov    %eax,(%esp)
80102984:	e8 42 ff ff ff       	call   801028cb <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102989:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010298d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102990:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102993:	7e ba                	jle    8010294f <ioapicinit+0x6a>
80102995:	eb 01                	jmp    80102998 <ioapicinit+0xb3>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102997:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102998:	c9                   	leave  
80102999:	c3                   	ret    

8010299a <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
8010299a:	55                   	push   %ebp
8010299b:	89 e5                	mov    %esp,%ebp
8010299d:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
801029a0:	a1 44 23 11 80       	mov    0x80112344,%eax
801029a5:	85 c0                	test   %eax,%eax
801029a7:	74 39                	je     801029e2 <ioapicenable+0x48>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
801029a9:	8b 45 08             	mov    0x8(%ebp),%eax
801029ac:	83 c0 20             	add    $0x20,%eax
801029af:	8b 55 08             	mov    0x8(%ebp),%edx
801029b2:	83 c2 08             	add    $0x8,%edx
801029b5:	01 d2                	add    %edx,%edx
801029b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801029bb:	89 14 24             	mov    %edx,(%esp)
801029be:	e8 08 ff ff ff       	call   801028cb <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801029c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801029c6:	c1 e0 18             	shl    $0x18,%eax
801029c9:	8b 55 08             	mov    0x8(%ebp),%edx
801029cc:	83 c2 08             	add    $0x8,%edx
801029cf:	01 d2                	add    %edx,%edx
801029d1:	83 c2 01             	add    $0x1,%edx
801029d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801029d8:	89 14 24             	mov    %edx,(%esp)
801029db:	e8 eb fe ff ff       	call   801028cb <ioapicwrite>
801029e0:	eb 01                	jmp    801029e3 <ioapicenable+0x49>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
801029e2:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
801029e3:	c9                   	leave  
801029e4:	c3                   	ret    
801029e5:	00 00                	add    %al,(%eax)
	...

801029e8 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801029e8:	55                   	push   %ebp
801029e9:	89 e5                	mov    %esp,%ebp
801029eb:	8b 45 08             	mov    0x8(%ebp),%eax
801029ee:	05 00 00 00 80       	add    $0x80000000,%eax
801029f3:	5d                   	pop    %ebp
801029f4:	c3                   	ret    

801029f5 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801029f5:	55                   	push   %ebp
801029f6:	89 e5                	mov    %esp,%ebp
801029f8:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
801029fb:	c7 44 24 04 c6 88 10 	movl   $0x801088c6,0x4(%esp)
80102a02:	80 
80102a03:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102a0a:	e8 fb 25 00 00       	call   8010500a <initlock>
  kmem.use_lock = 0;
80102a0f:	c7 05 54 22 11 80 00 	movl   $0x0,0x80112254
80102a16:	00 00 00 
  freerange(vstart, vend);
80102a19:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a20:	8b 45 08             	mov    0x8(%ebp),%eax
80102a23:	89 04 24             	mov    %eax,(%esp)
80102a26:	e8 26 00 00 00       	call   80102a51 <freerange>
}
80102a2b:	c9                   	leave  
80102a2c:	c3                   	ret    

80102a2d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102a2d:	55                   	push   %ebp
80102a2e:	89 e5                	mov    %esp,%ebp
80102a30:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102a33:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a36:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a3a:	8b 45 08             	mov    0x8(%ebp),%eax
80102a3d:	89 04 24             	mov    %eax,(%esp)
80102a40:	e8 0c 00 00 00       	call   80102a51 <freerange>
  kmem.use_lock = 1;
80102a45:	c7 05 54 22 11 80 01 	movl   $0x1,0x80112254
80102a4c:	00 00 00 
}
80102a4f:	c9                   	leave  
80102a50:	c3                   	ret    

80102a51 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102a51:	55                   	push   %ebp
80102a52:	89 e5                	mov    %esp,%ebp
80102a54:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102a57:	8b 45 08             	mov    0x8(%ebp),%eax
80102a5a:	05 ff 0f 00 00       	add    $0xfff,%eax
80102a5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102a64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a67:	eb 12                	jmp    80102a7b <freerange+0x2a>
    kfree(p);
80102a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6c:	89 04 24             	mov    %eax,(%esp)
80102a6f:	e8 16 00 00 00       	call   80102a8a <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102a74:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7e:	05 00 10 00 00       	add    $0x1000,%eax
80102a83:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a86:	76 e1                	jbe    80102a69 <freerange+0x18>
    kfree(p);
}
80102a88:	c9                   	leave  
80102a89:	c3                   	ret    

80102a8a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a8a:	55                   	push   %ebp
80102a8b:	89 e5                	mov    %esp,%ebp
80102a8d:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a90:	8b 45 08             	mov    0x8(%ebp),%eax
80102a93:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a98:	85 c0                	test   %eax,%eax
80102a9a:	75 1b                	jne    80102ab7 <kfree+0x2d>
80102a9c:	81 7d 08 3c 52 11 80 	cmpl   $0x8011523c,0x8(%ebp)
80102aa3:	72 12                	jb     80102ab7 <kfree+0x2d>
80102aa5:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa8:	89 04 24             	mov    %eax,(%esp)
80102aab:	e8 38 ff ff ff       	call   801029e8 <v2p>
80102ab0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102ab5:	76 0c                	jbe    80102ac3 <kfree+0x39>
    panic("kfree");
80102ab7:	c7 04 24 cb 88 10 80 	movl   $0x801088cb,(%esp)
80102abe:	e8 7a da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ac3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102aca:	00 
80102acb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102ad2:	00 
80102ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad6:	89 04 24             	mov    %eax,(%esp)
80102ad9:	e8 9c 27 00 00       	call   8010527a <memset>

  if(kmem.use_lock)
80102ade:	a1 54 22 11 80       	mov    0x80112254,%eax
80102ae3:	85 c0                	test   %eax,%eax
80102ae5:	74 0c                	je     80102af3 <kfree+0x69>
    acquire(&kmem.lock);
80102ae7:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102aee:	e8 38 25 00 00       	call   8010502b <acquire>
  r = (struct run*)v;
80102af3:	8b 45 08             	mov    0x8(%ebp),%eax
80102af6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102af9:	8b 15 58 22 11 80    	mov    0x80112258,%edx
80102aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b02:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b07:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102b0c:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b11:	85 c0                	test   %eax,%eax
80102b13:	74 0c                	je     80102b21 <kfree+0x97>
    release(&kmem.lock);
80102b15:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b1c:	e8 6c 25 00 00       	call   8010508d <release>
}
80102b21:	c9                   	leave  
80102b22:	c3                   	ret    

80102b23 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102b23:	55                   	push   %ebp
80102b24:	89 e5                	mov    %esp,%ebp
80102b26:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102b29:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b2e:	85 c0                	test   %eax,%eax
80102b30:	74 0c                	je     80102b3e <kalloc+0x1b>
    acquire(&kmem.lock);
80102b32:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b39:	e8 ed 24 00 00       	call   8010502b <acquire>
  r = kmem.freelist;
80102b3e:	a1 58 22 11 80       	mov    0x80112258,%eax
80102b43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b4a:	74 0a                	je     80102b56 <kalloc+0x33>
    kmem.freelist = r->next;
80102b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4f:	8b 00                	mov    (%eax),%eax
80102b51:	a3 58 22 11 80       	mov    %eax,0x80112258
  if(kmem.use_lock)
80102b56:	a1 54 22 11 80       	mov    0x80112254,%eax
80102b5b:	85 c0                	test   %eax,%eax
80102b5d:	74 0c                	je     80102b6b <kalloc+0x48>
    release(&kmem.lock);
80102b5f:	c7 04 24 20 22 11 80 	movl   $0x80112220,(%esp)
80102b66:	e8 22 25 00 00       	call   8010508d <release>
  return (char*)r;
80102b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102b6e:	c9                   	leave  
80102b6f:	c3                   	ret    

80102b70 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102b70:	55                   	push   %ebp
80102b71:	89 e5                	mov    %esp,%ebp
80102b73:	53                   	push   %ebx
80102b74:	83 ec 14             	sub    $0x14,%esp
80102b77:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102b7e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102b82:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102b86:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102b8a:	ec                   	in     (%dx),%al
80102b8b:	89 c3                	mov    %eax,%ebx
80102b8d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102b90:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102b94:	83 c4 14             	add    $0x14,%esp
80102b97:	5b                   	pop    %ebx
80102b98:	5d                   	pop    %ebp
80102b99:	c3                   	ret    

80102b9a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b9a:	55                   	push   %ebp
80102b9b:	89 e5                	mov    %esp,%ebp
80102b9d:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ba0:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102ba7:	e8 c4 ff ff ff       	call   80102b70 <inb>
80102bac:	0f b6 c0             	movzbl %al,%eax
80102baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb5:	83 e0 01             	and    $0x1,%eax
80102bb8:	85 c0                	test   %eax,%eax
80102bba:	75 0a                	jne    80102bc6 <kbdgetc+0x2c>
    return -1;
80102bbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102bc1:	e9 23 01 00 00       	jmp    80102ce9 <kbdgetc+0x14f>
  data = inb(KBDATAP);
80102bc6:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102bcd:	e8 9e ff ff ff       	call   80102b70 <inb>
80102bd2:	0f b6 c0             	movzbl %al,%eax
80102bd5:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102bd8:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102bdf:	75 17                	jne    80102bf8 <kbdgetc+0x5e>
    shift |= E0ESC;
80102be1:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102be6:	83 c8 40             	or     $0x40,%eax
80102be9:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102bee:	b8 00 00 00 00       	mov    $0x0,%eax
80102bf3:	e9 f1 00 00 00       	jmp    80102ce9 <kbdgetc+0x14f>
  } else if(data & 0x80){
80102bf8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bfb:	25 80 00 00 00       	and    $0x80,%eax
80102c00:	85 c0                	test   %eax,%eax
80102c02:	74 45                	je     80102c49 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c04:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c09:	83 e0 40             	and    $0x40,%eax
80102c0c:	85 c0                	test   %eax,%eax
80102c0e:	75 08                	jne    80102c18 <kbdgetc+0x7e>
80102c10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c13:	83 e0 7f             	and    $0x7f,%eax
80102c16:	eb 03                	jmp    80102c1b <kbdgetc+0x81>
80102c18:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c1b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102c1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c21:	05 20 90 10 80       	add    $0x80109020,%eax
80102c26:	0f b6 00             	movzbl (%eax),%eax
80102c29:	83 c8 40             	or     $0x40,%eax
80102c2c:	0f b6 c0             	movzbl %al,%eax
80102c2f:	f7 d0                	not    %eax
80102c31:	89 c2                	mov    %eax,%edx
80102c33:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c38:	21 d0                	and    %edx,%eax
80102c3a:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102c3f:	b8 00 00 00 00       	mov    $0x0,%eax
80102c44:	e9 a0 00 00 00       	jmp    80102ce9 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102c49:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c4e:	83 e0 40             	and    $0x40,%eax
80102c51:	85 c0                	test   %eax,%eax
80102c53:	74 14                	je     80102c69 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c55:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c5c:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c61:	83 e0 bf             	and    $0xffffffbf,%eax
80102c64:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102c69:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6c:	05 20 90 10 80       	add    $0x80109020,%eax
80102c71:	0f b6 00             	movzbl (%eax),%eax
80102c74:	0f b6 d0             	movzbl %al,%edx
80102c77:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c7c:	09 d0                	or     %edx,%eax
80102c7e:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102c83:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c86:	05 20 91 10 80       	add    $0x80109120,%eax
80102c8b:	0f b6 00             	movzbl (%eax),%eax
80102c8e:	0f b6 d0             	movzbl %al,%edx
80102c91:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102c96:	31 d0                	xor    %edx,%eax
80102c98:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c9d:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102ca2:	83 e0 03             	and    $0x3,%eax
80102ca5:	8b 04 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%eax
80102cac:	03 45 fc             	add    -0x4(%ebp),%eax
80102caf:	0f b6 00             	movzbl (%eax),%eax
80102cb2:	0f b6 c0             	movzbl %al,%eax
80102cb5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102cb8:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102cbd:	83 e0 08             	and    $0x8,%eax
80102cc0:	85 c0                	test   %eax,%eax
80102cc2:	74 22                	je     80102ce6 <kbdgetc+0x14c>
    if('a' <= c && c <= 'z')
80102cc4:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102cc8:	76 0c                	jbe    80102cd6 <kbdgetc+0x13c>
80102cca:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102cce:	77 06                	ja     80102cd6 <kbdgetc+0x13c>
      c += 'A' - 'a';
80102cd0:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102cd4:	eb 10                	jmp    80102ce6 <kbdgetc+0x14c>
    else if('A' <= c && c <= 'Z')
80102cd6:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102cda:	76 0a                	jbe    80102ce6 <kbdgetc+0x14c>
80102cdc:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ce0:	77 04                	ja     80102ce6 <kbdgetc+0x14c>
      c += 'a' - 'A';
80102ce2:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ce6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ce9:	c9                   	leave  
80102cea:	c3                   	ret    

80102ceb <kbdintr>:

void
kbdintr(void)
{
80102ceb:	55                   	push   %ebp
80102cec:	89 e5                	mov    %esp,%ebp
80102cee:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102cf1:	c7 04 24 9a 2b 10 80 	movl   $0x80102b9a,(%esp)
80102cf8:	e8 b0 da ff ff       	call   801007ad <consoleintr>
}
80102cfd:	c9                   	leave  
80102cfe:	c3                   	ret    
	...

80102d00 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d00:	55                   	push   %ebp
80102d01:	89 e5                	mov    %esp,%ebp
80102d03:	53                   	push   %ebx
80102d04:	83 ec 14             	sub    $0x14,%esp
80102d07:	8b 45 08             	mov    0x8(%ebp),%eax
80102d0a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d0e:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80102d12:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102d16:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80102d1a:	ec                   	in     (%dx),%al
80102d1b:	89 c3                	mov    %eax,%ebx
80102d1d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102d20:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80102d24:	83 c4 14             	add    $0x14,%esp
80102d27:	5b                   	pop    %ebx
80102d28:	5d                   	pop    %ebp
80102d29:	c3                   	ret    

80102d2a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102d2a:	55                   	push   %ebp
80102d2b:	89 e5                	mov    %esp,%ebp
80102d2d:	83 ec 08             	sub    $0x8,%esp
80102d30:	8b 55 08             	mov    0x8(%ebp),%edx
80102d33:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d36:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102d3a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d3d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102d41:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102d45:	ee                   	out    %al,(%dx)
}
80102d46:	c9                   	leave  
80102d47:	c3                   	ret    

80102d48 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102d48:	55                   	push   %ebp
80102d49:	89 e5                	mov    %esp,%ebp
80102d4b:	53                   	push   %ebx
80102d4c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102d4f:	9c                   	pushf  
80102d50:	5b                   	pop    %ebx
80102d51:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102d54:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d57:	83 c4 10             	add    $0x10,%esp
80102d5a:	5b                   	pop    %ebx
80102d5b:	5d                   	pop    %ebp
80102d5c:	c3                   	ret    

80102d5d <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102d5d:	55                   	push   %ebp
80102d5e:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102d60:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d65:	8b 55 08             	mov    0x8(%ebp),%edx
80102d68:	c1 e2 02             	shl    $0x2,%edx
80102d6b:	01 c2                	add    %eax,%edx
80102d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d70:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d72:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d77:	83 c0 20             	add    $0x20,%eax
80102d7a:	8b 00                	mov    (%eax),%eax
}
80102d7c:	5d                   	pop    %ebp
80102d7d:	c3                   	ret    

80102d7e <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102d7e:	55                   	push   %ebp
80102d7f:	89 e5                	mov    %esp,%ebp
80102d81:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102d84:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102d89:	85 c0                	test   %eax,%eax
80102d8b:	0f 84 47 01 00 00    	je     80102ed8 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102d91:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102d98:	00 
80102d99:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102da0:	e8 b8 ff ff ff       	call   80102d5d <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102da5:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102dac:	00 
80102dad:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102db4:	e8 a4 ff ff ff       	call   80102d5d <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102db9:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102dc0:	00 
80102dc1:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102dc8:	e8 90 ff ff ff       	call   80102d5d <lapicw>
  lapicw(TICR, 10000000); 
80102dcd:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102dd4:	00 
80102dd5:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102ddc:	e8 7c ff ff ff       	call   80102d5d <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102de1:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102de8:	00 
80102de9:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102df0:	e8 68 ff ff ff       	call   80102d5d <lapicw>
  lapicw(LINT1, MASKED);
80102df5:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102dfc:	00 
80102dfd:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102e04:	e8 54 ff ff ff       	call   80102d5d <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e09:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102e0e:	83 c0 30             	add    $0x30,%eax
80102e11:	8b 00                	mov    (%eax),%eax
80102e13:	c1 e8 10             	shr    $0x10,%eax
80102e16:	25 ff 00 00 00       	and    $0xff,%eax
80102e1b:	83 f8 03             	cmp    $0x3,%eax
80102e1e:	76 14                	jbe    80102e34 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80102e20:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102e27:	00 
80102e28:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102e2f:	e8 29 ff ff ff       	call   80102d5d <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102e34:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102e3b:	00 
80102e3c:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102e43:	e8 15 ff ff ff       	call   80102d5d <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102e48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e4f:	00 
80102e50:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e57:	e8 01 ff ff ff       	call   80102d5d <lapicw>
  lapicw(ESR, 0);
80102e5c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e63:	00 
80102e64:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102e6b:	e8 ed fe ff ff       	call   80102d5d <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102e70:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e77:	00 
80102e78:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e7f:	e8 d9 fe ff ff       	call   80102d5d <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102e84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e8b:	00 
80102e8c:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102e93:	e8 c5 fe ff ff       	call   80102d5d <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102e98:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102e9f:	00 
80102ea0:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ea7:	e8 b1 fe ff ff       	call   80102d5d <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102eac:	90                   	nop
80102ead:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102eb2:	05 00 03 00 00       	add    $0x300,%eax
80102eb7:	8b 00                	mov    (%eax),%eax
80102eb9:	25 00 10 00 00       	and    $0x1000,%eax
80102ebe:	85 c0                	test   %eax,%eax
80102ec0:	75 eb                	jne    80102ead <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102ec2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ec9:	00 
80102eca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102ed1:	e8 87 fe ff ff       	call   80102d5d <lapicw>
80102ed6:	eb 01                	jmp    80102ed9 <lapicinit+0x15b>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102ed8:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102ed9:	c9                   	leave  
80102eda:	c3                   	ret    

80102edb <cpunum>:

int
cpunum(void)
{
80102edb:	55                   	push   %ebp
80102edc:	89 e5                	mov    %esp,%ebp
80102ede:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102ee1:	e8 62 fe ff ff       	call   80102d48 <readeflags>
80102ee6:	25 00 02 00 00       	and    $0x200,%eax
80102eeb:	85 c0                	test   %eax,%eax
80102eed:	74 29                	je     80102f18 <cpunum+0x3d>
    static int n;
    if(n++ == 0)
80102eef:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102ef4:	85 c0                	test   %eax,%eax
80102ef6:	0f 94 c2             	sete   %dl
80102ef9:	83 c0 01             	add    $0x1,%eax
80102efc:	a3 40 b6 10 80       	mov    %eax,0x8010b640
80102f01:	84 d2                	test   %dl,%dl
80102f03:	74 13                	je     80102f18 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f05:	8b 45 04             	mov    0x4(%ebp),%eax
80102f08:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f0c:	c7 04 24 d4 88 10 80 	movl   $0x801088d4,(%esp)
80102f13:	e8 89 d4 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f18:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f1d:	85 c0                	test   %eax,%eax
80102f1f:	74 0f                	je     80102f30 <cpunum+0x55>
    return lapic[ID]>>24;
80102f21:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f26:	83 c0 20             	add    $0x20,%eax
80102f29:	8b 00                	mov    (%eax),%eax
80102f2b:	c1 e8 18             	shr    $0x18,%eax
80102f2e:	eb 05                	jmp    80102f35 <cpunum+0x5a>
  return 0;
80102f30:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f35:	c9                   	leave  
80102f36:	c3                   	ret    

80102f37 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f37:	55                   	push   %ebp
80102f38:	89 e5                	mov    %esp,%ebp
80102f3a:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102f3d:	a1 5c 22 11 80       	mov    0x8011225c,%eax
80102f42:	85 c0                	test   %eax,%eax
80102f44:	74 14                	je     80102f5a <lapiceoi+0x23>
    lapicw(EOI, 0);
80102f46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f4d:	00 
80102f4e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f55:	e8 03 fe ff ff       	call   80102d5d <lapicw>
}
80102f5a:	c9                   	leave  
80102f5b:	c3                   	ret    

80102f5c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f5c:	55                   	push   %ebp
80102f5d:	89 e5                	mov    %esp,%ebp
}
80102f5f:	5d                   	pop    %ebp
80102f60:	c3                   	ret    

80102f61 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102f61:	55                   	push   %ebp
80102f62:	89 e5                	mov    %esp,%ebp
80102f64:	83 ec 1c             	sub    $0x1c,%esp
80102f67:	8b 45 08             	mov    0x8(%ebp),%eax
80102f6a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102f6d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102f74:	00 
80102f75:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102f7c:	e8 a9 fd ff ff       	call   80102d2a <outb>
  outb(CMOS_PORT+1, 0x0A);
80102f81:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102f88:	00 
80102f89:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102f90:	e8 95 fd ff ff       	call   80102d2a <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102f95:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102f9c:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102f9f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102fa4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fa7:	8d 50 02             	lea    0x2(%eax),%edx
80102faa:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fad:	c1 e8 04             	shr    $0x4,%eax
80102fb0:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fb3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102fb7:	c1 e0 18             	shl    $0x18,%eax
80102fba:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fbe:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fc5:	e8 93 fd ff ff       	call   80102d5d <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102fca:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102fd1:	00 
80102fd2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fd9:	e8 7f fd ff ff       	call   80102d5d <lapicw>
  microdelay(200);
80102fde:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102fe5:	e8 72 ff ff ff       	call   80102f5c <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102fea:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102ff1:	00 
80102ff2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102ff9:	e8 5f fd ff ff       	call   80102d5d <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102ffe:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103005:	e8 52 ff ff ff       	call   80102f5c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010300a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103011:	eb 40                	jmp    80103053 <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
80103013:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103017:	c1 e0 18             	shl    $0x18,%eax
8010301a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010301e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103025:	e8 33 fd ff ff       	call   80102d5d <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010302a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010302d:	c1 e8 0c             	shr    $0xc,%eax
80103030:	80 cc 06             	or     $0x6,%ah
80103033:	89 44 24 04          	mov    %eax,0x4(%esp)
80103037:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010303e:	e8 1a fd ff ff       	call   80102d5d <lapicw>
    microdelay(200);
80103043:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010304a:	e8 0d ff ff ff       	call   80102f5c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010304f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103053:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103057:	7e ba                	jle    80103013 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103059:	c9                   	leave  
8010305a:	c3                   	ret    

8010305b <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010305b:	55                   	push   %ebp
8010305c:	89 e5                	mov    %esp,%ebp
8010305e:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103061:	8b 45 08             	mov    0x8(%ebp),%eax
80103064:	0f b6 c0             	movzbl %al,%eax
80103067:	89 44 24 04          	mov    %eax,0x4(%esp)
8010306b:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103072:	e8 b3 fc ff ff       	call   80102d2a <outb>
  microdelay(200);
80103077:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010307e:	e8 d9 fe ff ff       	call   80102f5c <microdelay>

  return inb(CMOS_RETURN);
80103083:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010308a:	e8 71 fc ff ff       	call   80102d00 <inb>
8010308f:	0f b6 c0             	movzbl %al,%eax
}
80103092:	c9                   	leave  
80103093:	c3                   	ret    

80103094 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103094:	55                   	push   %ebp
80103095:	89 e5                	mov    %esp,%ebp
80103097:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010309a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801030a1:	e8 b5 ff ff ff       	call   8010305b <cmos_read>
801030a6:	8b 55 08             	mov    0x8(%ebp),%edx
801030a9:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801030ab:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801030b2:	e8 a4 ff ff ff       	call   8010305b <cmos_read>
801030b7:	8b 55 08             	mov    0x8(%ebp),%edx
801030ba:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801030bd:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801030c4:	e8 92 ff ff ff       	call   8010305b <cmos_read>
801030c9:	8b 55 08             	mov    0x8(%ebp),%edx
801030cc:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801030cf:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801030d6:	e8 80 ff ff ff       	call   8010305b <cmos_read>
801030db:	8b 55 08             	mov    0x8(%ebp),%edx
801030de:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801030e1:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801030e8:	e8 6e ff ff ff       	call   8010305b <cmos_read>
801030ed:	8b 55 08             	mov    0x8(%ebp),%edx
801030f0:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801030f3:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801030fa:	e8 5c ff ff ff       	call   8010305b <cmos_read>
801030ff:	8b 55 08             	mov    0x8(%ebp),%edx
80103102:	89 42 14             	mov    %eax,0x14(%edx)
}
80103105:	c9                   	leave  
80103106:	c3                   	ret    

80103107 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103107:	55                   	push   %ebp
80103108:	89 e5                	mov    %esp,%ebp
8010310a:	83 ec 58             	sub    $0x58,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010310d:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103114:	e8 42 ff ff ff       	call   8010305b <cmos_read>
80103119:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010311c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010311f:	83 e0 04             	and    $0x4,%eax
80103122:	85 c0                	test   %eax,%eax
80103124:	0f 94 c0             	sete   %al
80103127:	0f b6 c0             	movzbl %al,%eax
8010312a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010312d:	eb 01                	jmp    80103130 <cmostime+0x29>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010312f:	90                   	nop

  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103130:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103133:	89 04 24             	mov    %eax,(%esp)
80103136:	e8 59 ff ff ff       	call   80103094 <fill_rtcdate>
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
8010313b:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103142:	e8 14 ff ff ff       	call   8010305b <cmos_read>
80103147:	25 80 00 00 00       	and    $0x80,%eax
8010314c:	85 c0                	test   %eax,%eax
8010314e:	75 2b                	jne    8010317b <cmostime+0x74>
        continue;
    fill_rtcdate(&t2);
80103150:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103153:	89 04 24             	mov    %eax,(%esp)
80103156:	e8 39 ff ff ff       	call   80103094 <fill_rtcdate>
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010315b:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103162:	00 
80103163:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103166:	89 44 24 04          	mov    %eax,0x4(%esp)
8010316a:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010316d:	89 04 24             	mov    %eax,(%esp)
80103170:	e8 7c 21 00 00       	call   801052f1 <memcmp>
80103175:	85 c0                	test   %eax,%eax
80103177:	75 b6                	jne    8010312f <cmostime+0x28>
      break;
80103179:	eb 03                	jmp    8010317e <cmostime+0x77>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
8010317b:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010317c:	eb b1                	jmp    8010312f <cmostime+0x28>

  // convert
  if (bcd) {
8010317e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103182:	0f 84 a8 00 00 00    	je     80103230 <cmostime+0x129>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103188:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010318b:	89 c2                	mov    %eax,%edx
8010318d:	c1 ea 04             	shr    $0x4,%edx
80103190:	89 d0                	mov    %edx,%eax
80103192:	c1 e0 02             	shl    $0x2,%eax
80103195:	01 d0                	add    %edx,%eax
80103197:	01 c0                	add    %eax,%eax
80103199:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010319c:	83 e2 0f             	and    $0xf,%edx
8010319f:	01 d0                	add    %edx,%eax
801031a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031a7:	89 c2                	mov    %eax,%edx
801031a9:	c1 ea 04             	shr    $0x4,%edx
801031ac:	89 d0                	mov    %edx,%eax
801031ae:	c1 e0 02             	shl    $0x2,%eax
801031b1:	01 d0                	add    %edx,%eax
801031b3:	01 c0                	add    %eax,%eax
801031b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
801031b8:	83 e2 0f             	and    $0xf,%edx
801031bb:	01 d0                	add    %edx,%eax
801031bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031c3:	89 c2                	mov    %eax,%edx
801031c5:	c1 ea 04             	shr    $0x4,%edx
801031c8:	89 d0                	mov    %edx,%eax
801031ca:	c1 e0 02             	shl    $0x2,%eax
801031cd:	01 d0                	add    %edx,%eax
801031cf:	01 c0                	add    %eax,%eax
801031d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801031d4:	83 e2 0f             	and    $0xf,%edx
801031d7:	01 d0                	add    %edx,%eax
801031d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801031dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801031df:	89 c2                	mov    %eax,%edx
801031e1:	c1 ea 04             	shr    $0x4,%edx
801031e4:	89 d0                	mov    %edx,%eax
801031e6:	c1 e0 02             	shl    $0x2,%eax
801031e9:	01 d0                	add    %edx,%eax
801031eb:	01 c0                	add    %eax,%eax
801031ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801031f0:	83 e2 0f             	and    $0xf,%edx
801031f3:	01 d0                	add    %edx,%eax
801031f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801031f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801031fb:	89 c2                	mov    %eax,%edx
801031fd:	c1 ea 04             	shr    $0x4,%edx
80103200:	89 d0                	mov    %edx,%eax
80103202:	c1 e0 02             	shl    $0x2,%eax
80103205:	01 d0                	add    %edx,%eax
80103207:	01 c0                	add    %eax,%eax
80103209:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010320c:	83 e2 0f             	and    $0xf,%edx
8010320f:	01 d0                	add    %edx,%eax
80103211:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103214:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103217:	89 c2                	mov    %eax,%edx
80103219:	c1 ea 04             	shr    $0x4,%edx
8010321c:	89 d0                	mov    %edx,%eax
8010321e:	c1 e0 02             	shl    $0x2,%eax
80103221:	01 d0                	add    %edx,%eax
80103223:	01 c0                	add    %eax,%eax
80103225:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103228:	83 e2 0f             	and    $0xf,%edx
8010322b:	01 d0                	add    %edx,%eax
8010322d:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103230:	8b 45 08             	mov    0x8(%ebp),%eax
80103233:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103236:	89 10                	mov    %edx,(%eax)
80103238:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010323b:	89 50 04             	mov    %edx,0x4(%eax)
8010323e:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103241:	89 50 08             	mov    %edx,0x8(%eax)
80103244:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103247:	89 50 0c             	mov    %edx,0xc(%eax)
8010324a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010324d:	89 50 10             	mov    %edx,0x10(%eax)
80103250:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103253:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103256:	8b 45 08             	mov    0x8(%ebp),%eax
80103259:	8b 40 14             	mov    0x14(%eax),%eax
8010325c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103262:	8b 45 08             	mov    0x8(%ebp),%eax
80103265:	89 50 14             	mov    %edx,0x14(%eax)
}
80103268:	c9                   	leave  
80103269:	c3                   	ret    
	...

8010326c <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
8010326c:	55                   	push   %ebp
8010326d:	89 e5                	mov    %esp,%ebp
8010326f:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103272:	c7 44 24 04 00 89 10 	movl   $0x80108900,0x4(%esp)
80103279:	80 
8010327a:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103281:	e8 84 1d 00 00       	call   8010500a <initlock>
  readsb(ROOTDEV, &sb);
80103286:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103289:	89 44 24 04          	mov    %eax,0x4(%esp)
8010328d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103294:	e8 77 e0 ff ff       	call   80101310 <readsb>
  log.start = sb.size - sb.nlog;
80103299:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010329c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010329f:	89 d1                	mov    %edx,%ecx
801032a1:	29 c1                	sub    %eax,%ecx
801032a3:	89 c8                	mov    %ecx,%eax
801032a5:	a3 94 22 11 80       	mov    %eax,0x80112294
  log.size = sb.nlog;
801032aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ad:	a3 98 22 11 80       	mov    %eax,0x80112298
  log.dev = ROOTDEV;
801032b2:	c7 05 a4 22 11 80 01 	movl   $0x1,0x801122a4
801032b9:	00 00 00 
  recover_from_log();
801032bc:	e8 97 01 00 00       	call   80103458 <recover_from_log>
}
801032c1:	c9                   	leave  
801032c2:	c3                   	ret    

801032c3 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801032c3:	55                   	push   %ebp
801032c4:	89 e5                	mov    %esp,%ebp
801032c6:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d0:	e9 89 00 00 00       	jmp    8010335e <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032d5:	a1 94 22 11 80       	mov    0x80112294,%eax
801032da:	03 45 f4             	add    -0xc(%ebp),%eax
801032dd:	83 c0 01             	add    $0x1,%eax
801032e0:	89 c2                	mov    %eax,%edx
801032e2:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801032e7:	89 54 24 04          	mov    %edx,0x4(%esp)
801032eb:	89 04 24             	mov    %eax,(%esp)
801032ee:	e8 b3 ce ff ff       	call   801001a6 <bread>
801032f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801032f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032f9:	83 c0 10             	add    $0x10,%eax
801032fc:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	a1 a4 22 11 80       	mov    0x801122a4,%eax
8010330a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010330e:	89 04 24             	mov    %eax,(%esp)
80103311:	e8 90 ce ff ff       	call   801001a6 <bread>
80103316:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103319:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010331c:	8d 50 18             	lea    0x18(%eax),%edx
8010331f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103322:	83 c0 18             	add    $0x18,%eax
80103325:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010332c:	00 
8010332d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103331:	89 04 24             	mov    %eax,(%esp)
80103334:	e8 14 20 00 00       	call   8010534d <memmove>
    bwrite(dbuf);  // write dst to disk
80103339:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010333c:	89 04 24             	mov    %eax,(%esp)
8010333f:	e8 99 ce ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103344:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103347:	89 04 24             	mov    %eax,(%esp)
8010334a:	e8 c8 ce ff ff       	call   80100217 <brelse>
    brelse(dbuf);
8010334f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103352:	89 04 24             	mov    %eax,(%esp)
80103355:	e8 bd ce ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010335a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010335e:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103363:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103366:	0f 8f 69 ff ff ff    	jg     801032d5 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
8010336c:	c9                   	leave  
8010336d:	c3                   	ret    

8010336e <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010336e:	55                   	push   %ebp
8010336f:	89 e5                	mov    %esp,%ebp
80103371:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103374:	a1 94 22 11 80       	mov    0x80112294,%eax
80103379:	89 c2                	mov    %eax,%edx
8010337b:	a1 a4 22 11 80       	mov    0x801122a4,%eax
80103380:	89 54 24 04          	mov    %edx,0x4(%esp)
80103384:	89 04 24             	mov    %eax,(%esp)
80103387:	e8 1a ce ff ff       	call   801001a6 <bread>
8010338c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010338f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103392:	83 c0 18             	add    $0x18,%eax
80103395:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103398:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010339b:	8b 00                	mov    (%eax),%eax
8010339d:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  for (i = 0; i < log.lh.n; i++) {
801033a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033a9:	eb 1b                	jmp    801033c6 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
801033ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033b1:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033b8:	83 c2 10             	add    $0x10,%edx
801033bb:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033c6:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801033cb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033ce:	7f db                	jg     801033ab <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801033d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033d3:	89 04 24             	mov    %eax,(%esp)
801033d6:	e8 3c ce ff ff       	call   80100217 <brelse>
}
801033db:	c9                   	leave  
801033dc:	c3                   	ret    

801033dd <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801033dd:	55                   	push   %ebp
801033de:	89 e5                	mov    %esp,%ebp
801033e0:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801033e3:	a1 94 22 11 80       	mov    0x80112294,%eax
801033e8:	89 c2                	mov    %eax,%edx
801033ea:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801033ef:	89 54 24 04          	mov    %edx,0x4(%esp)
801033f3:	89 04 24             	mov    %eax,(%esp)
801033f6:	e8 ab cd ff ff       	call   801001a6 <bread>
801033fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801033fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103401:	83 c0 18             	add    $0x18,%eax
80103404:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103407:	8b 15 a8 22 11 80    	mov    0x801122a8,%edx
8010340d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103410:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103412:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103419:	eb 1b                	jmp    80103436 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
8010341b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010341e:	83 c0 10             	add    $0x10,%eax
80103421:	8b 0c 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%ecx
80103428:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010342b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010342e:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103432:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103436:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010343b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010343e:	7f db                	jg     8010341b <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103440:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103443:	89 04 24             	mov    %eax,(%esp)
80103446:	e8 92 cd ff ff       	call   801001dd <bwrite>
  brelse(buf);
8010344b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010344e:	89 04 24             	mov    %eax,(%esp)
80103451:	e8 c1 cd ff ff       	call   80100217 <brelse>
}
80103456:	c9                   	leave  
80103457:	c3                   	ret    

80103458 <recover_from_log>:

static void
recover_from_log(void)
{
80103458:	55                   	push   %ebp
80103459:	89 e5                	mov    %esp,%ebp
8010345b:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010345e:	e8 0b ff ff ff       	call   8010336e <read_head>
  install_trans(); // if committed, copy from log to disk
80103463:	e8 5b fe ff ff       	call   801032c3 <install_trans>
  log.lh.n = 0;
80103468:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
8010346f:	00 00 00 
  write_head(); // clear the log
80103472:	e8 66 ff ff ff       	call   801033dd <write_head>
}
80103477:	c9                   	leave  
80103478:	c3                   	ret    

80103479 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103479:	55                   	push   %ebp
8010347a:	89 e5                	mov    %esp,%ebp
8010347c:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010347f:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103486:	e8 a0 1b 00 00       	call   8010502b <acquire>
  while(1){
    if(log.committing){
8010348b:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103490:	85 c0                	test   %eax,%eax
80103492:	74 16                	je     801034aa <begin_op+0x31>
      sleep(&log, &log.lock);
80103494:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
8010349b:	80 
8010349c:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034a3:	e8 a6 18 00 00       	call   80104d4e <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
801034a8:	eb e1                	jmp    8010348b <begin_op+0x12>
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034aa:	8b 0d a8 22 11 80    	mov    0x801122a8,%ecx
801034b0:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034b5:	8d 50 01             	lea    0x1(%eax),%edx
801034b8:	89 d0                	mov    %edx,%eax
801034ba:	c1 e0 02             	shl    $0x2,%eax
801034bd:	01 d0                	add    %edx,%eax
801034bf:	01 c0                	add    %eax,%eax
801034c1:	01 c8                	add    %ecx,%eax
801034c3:	83 f8 1e             	cmp    $0x1e,%eax
801034c6:	7e 16                	jle    801034de <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801034c8:	c7 44 24 04 60 22 11 	movl   $0x80112260,0x4(%esp)
801034cf:	80 
801034d0:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034d7:	e8 72 18 00 00       	call   80104d4e <sleep>
    } else {
      log.outstanding += 1;
      release(&log.lock);
      break;
    }
  }
801034dc:	eb ad                	jmp    8010348b <begin_op+0x12>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
801034de:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801034e3:	83 c0 01             	add    $0x1,%eax
801034e6:	a3 9c 22 11 80       	mov    %eax,0x8011229c
      release(&log.lock);
801034eb:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801034f2:	e8 96 1b 00 00       	call   8010508d <release>
      break;
801034f7:	90                   	nop
    }
  }
}
801034f8:	c9                   	leave  
801034f9:	c3                   	ret    

801034fa <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801034fa:	55                   	push   %ebp
801034fb:	89 e5                	mov    %esp,%ebp
801034fd:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103500:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103507:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010350e:	e8 18 1b 00 00       	call   8010502b <acquire>
  log.outstanding -= 1;
80103513:	a1 9c 22 11 80       	mov    0x8011229c,%eax
80103518:	83 e8 01             	sub    $0x1,%eax
8010351b:	a3 9c 22 11 80       	mov    %eax,0x8011229c
  if(log.committing)
80103520:	a1 a0 22 11 80       	mov    0x801122a0,%eax
80103525:	85 c0                	test   %eax,%eax
80103527:	74 0c                	je     80103535 <end_op+0x3b>
    panic("log.committing");
80103529:	c7 04 24 04 89 10 80 	movl   $0x80108904,(%esp)
80103530:	e8 08 d0 ff ff       	call   8010053d <panic>
  if(log.outstanding == 0){
80103535:	a1 9c 22 11 80       	mov    0x8011229c,%eax
8010353a:	85 c0                	test   %eax,%eax
8010353c:	75 13                	jne    80103551 <end_op+0x57>
    do_commit = 1;
8010353e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103545:	c7 05 a0 22 11 80 01 	movl   $0x1,0x801122a0
8010354c:	00 00 00 
8010354f:	eb 0c                	jmp    8010355d <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103551:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103558:	e8 ca 18 00 00       	call   80104e27 <wakeup>
  }
  release(&log.lock);
8010355d:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103564:	e8 24 1b 00 00       	call   8010508d <release>

  if(do_commit){
80103569:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010356d:	74 33                	je     801035a2 <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010356f:	e8 db 00 00 00       	call   8010364f <commit>
    acquire(&log.lock);
80103574:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010357b:	e8 ab 1a 00 00       	call   8010502b <acquire>
    log.committing = 0;
80103580:	c7 05 a0 22 11 80 00 	movl   $0x0,0x801122a0
80103587:	00 00 00 
    wakeup(&log);
8010358a:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103591:	e8 91 18 00 00       	call   80104e27 <wakeup>
    release(&log.lock);
80103596:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
8010359d:	e8 eb 1a 00 00       	call   8010508d <release>
  }
}
801035a2:	c9                   	leave  
801035a3:	c3                   	ret    

801035a4 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801035a4:	55                   	push   %ebp
801035a5:	89 e5                	mov    %esp,%ebp
801035a7:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035b1:	e9 89 00 00 00       	jmp    8010363f <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801035b6:	a1 94 22 11 80       	mov    0x80112294,%eax
801035bb:	03 45 f4             	add    -0xc(%ebp),%eax
801035be:	83 c0 01             	add    $0x1,%eax
801035c1:	89 c2                	mov    %eax,%edx
801035c3:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801035c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801035cc:	89 04 24             	mov    %eax,(%esp)
801035cf:	e8 d2 cb ff ff       	call   801001a6 <bread>
801035d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
801035d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035da:	83 c0 10             	add    $0x10,%eax
801035dd:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801035e4:	89 c2                	mov    %eax,%edx
801035e6:	a1 a4 22 11 80       	mov    0x801122a4,%eax
801035eb:	89 54 24 04          	mov    %edx,0x4(%esp)
801035ef:	89 04 24             	mov    %eax,(%esp)
801035f2:	e8 af cb ff ff       	call   801001a6 <bread>
801035f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801035fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035fd:	8d 50 18             	lea    0x18(%eax),%edx
80103600:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103603:	83 c0 18             	add    $0x18,%eax
80103606:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010360d:	00 
8010360e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103612:	89 04 24             	mov    %eax,(%esp)
80103615:	e8 33 1d 00 00       	call   8010534d <memmove>
    bwrite(to);  // write the log
8010361a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010361d:	89 04 24             	mov    %eax,(%esp)
80103620:	e8 b8 cb ff ff       	call   801001dd <bwrite>
    brelse(from); 
80103625:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103628:	89 04 24             	mov    %eax,(%esp)
8010362b:	e8 e7 cb ff ff       	call   80100217 <brelse>
    brelse(to);
80103630:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103633:	89 04 24             	mov    %eax,(%esp)
80103636:	e8 dc cb ff ff       	call   80100217 <brelse>
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010363b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010363f:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103644:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103647:	0f 8f 69 ff ff ff    	jg     801035b6 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
8010364d:	c9                   	leave  
8010364e:	c3                   	ret    

8010364f <commit>:

static void
commit()
{
8010364f:	55                   	push   %ebp
80103650:	89 e5                	mov    %esp,%ebp
80103652:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103655:	a1 a8 22 11 80       	mov    0x801122a8,%eax
8010365a:	85 c0                	test   %eax,%eax
8010365c:	7e 1e                	jle    8010367c <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010365e:	e8 41 ff ff ff       	call   801035a4 <write_log>
    write_head();    // Write header to disk -- the real commit
80103663:	e8 75 fd ff ff       	call   801033dd <write_head>
    install_trans(); // Now install writes to home locations
80103668:	e8 56 fc ff ff       	call   801032c3 <install_trans>
    log.lh.n = 0; 
8010366d:	c7 05 a8 22 11 80 00 	movl   $0x0,0x801122a8
80103674:	00 00 00 
    write_head();    // Erase the transaction from the log
80103677:	e8 61 fd ff ff       	call   801033dd <write_head>
  }
}
8010367c:	c9                   	leave  
8010367d:	c3                   	ret    

8010367e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010367e:	55                   	push   %ebp
8010367f:	89 e5                	mov    %esp,%ebp
80103681:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103684:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103689:	83 f8 1d             	cmp    $0x1d,%eax
8010368c:	7f 12                	jg     801036a0 <log_write+0x22>
8010368e:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103693:	8b 15 98 22 11 80    	mov    0x80112298,%edx
80103699:	83 ea 01             	sub    $0x1,%edx
8010369c:	39 d0                	cmp    %edx,%eax
8010369e:	7c 0c                	jl     801036ac <log_write+0x2e>
    panic("too big a transaction");
801036a0:	c7 04 24 13 89 10 80 	movl   $0x80108913,(%esp)
801036a7:	e8 91 ce ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
801036ac:	a1 9c 22 11 80       	mov    0x8011229c,%eax
801036b1:	85 c0                	test   %eax,%eax
801036b3:	7f 0c                	jg     801036c1 <log_write+0x43>
    panic("log_write outside of trans");
801036b5:	c7 04 24 29 89 10 80 	movl   $0x80108929,(%esp)
801036bc:	e8 7c ce ff ff       	call   8010053d <panic>

  acquire(&log.lock);
801036c1:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
801036c8:	e8 5e 19 00 00       	call   8010502b <acquire>
  for (i = 0; i < log.lh.n; i++) {
801036cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036d4:	eb 1d                	jmp    801036f3 <log_write+0x75>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
801036d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d9:	83 c0 10             	add    $0x10,%eax
801036dc:	8b 04 85 6c 22 11 80 	mov    -0x7feedd94(,%eax,4),%eax
801036e3:	89 c2                	mov    %eax,%edx
801036e5:	8b 45 08             	mov    0x8(%ebp),%eax
801036e8:	8b 40 08             	mov    0x8(%eax),%eax
801036eb:	39 c2                	cmp    %eax,%edx
801036ed:	74 10                	je     801036ff <log_write+0x81>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801036ef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036f3:	a1 a8 22 11 80       	mov    0x801122a8,%eax
801036f8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036fb:	7f d9                	jg     801036d6 <log_write+0x58>
801036fd:	eb 01                	jmp    80103700 <log_write+0x82>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
801036ff:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103700:	8b 45 08             	mov    0x8(%ebp),%eax
80103703:	8b 40 08             	mov    0x8(%eax),%eax
80103706:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103709:	83 c2 10             	add    $0x10,%edx
8010370c:	89 04 95 6c 22 11 80 	mov    %eax,-0x7feedd94(,%edx,4)
  if (i == log.lh.n)
80103713:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103718:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010371b:	75 0d                	jne    8010372a <log_write+0xac>
    log.lh.n++;
8010371d:	a1 a8 22 11 80       	mov    0x801122a8,%eax
80103722:	83 c0 01             	add    $0x1,%eax
80103725:	a3 a8 22 11 80       	mov    %eax,0x801122a8
  b->flags |= B_DIRTY; // prevent eviction
8010372a:	8b 45 08             	mov    0x8(%ebp),%eax
8010372d:	8b 00                	mov    (%eax),%eax
8010372f:	89 c2                	mov    %eax,%edx
80103731:	83 ca 04             	or     $0x4,%edx
80103734:	8b 45 08             	mov    0x8(%ebp),%eax
80103737:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103739:	c7 04 24 60 22 11 80 	movl   $0x80112260,(%esp)
80103740:	e8 48 19 00 00       	call   8010508d <release>
}
80103745:	c9                   	leave  
80103746:	c3                   	ret    
	...

80103748 <v2p>:
80103748:	55                   	push   %ebp
80103749:	89 e5                	mov    %esp,%ebp
8010374b:	8b 45 08             	mov    0x8(%ebp),%eax
8010374e:	05 00 00 00 80       	add    $0x80000000,%eax
80103753:	5d                   	pop    %ebp
80103754:	c3                   	ret    

80103755 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103755:	55                   	push   %ebp
80103756:	89 e5                	mov    %esp,%ebp
80103758:	8b 45 08             	mov    0x8(%ebp),%eax
8010375b:	05 00 00 00 80       	add    $0x80000000,%eax
80103760:	5d                   	pop    %ebp
80103761:	c3                   	ret    

80103762 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103762:	55                   	push   %ebp
80103763:	89 e5                	mov    %esp,%ebp
80103765:	53                   	push   %ebx
80103766:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103769:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010376c:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
8010376f:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103772:	89 c3                	mov    %eax,%ebx
80103774:	89 d8                	mov    %ebx,%eax
80103776:	f0 87 02             	lock xchg %eax,(%edx)
80103779:	89 c3                	mov    %eax,%ebx
8010377b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010377e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103781:	83 c4 10             	add    $0x10,%esp
80103784:	5b                   	pop    %ebx
80103785:	5d                   	pop    %ebp
80103786:	c3                   	ret    

80103787 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103787:	55                   	push   %ebp
80103788:	89 e5                	mov    %esp,%ebp
8010378a:	83 e4 f0             	and    $0xfffffff0,%esp
8010378d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103790:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103797:	80 
80103798:	c7 04 24 3c 52 11 80 	movl   $0x8011523c,(%esp)
8010379f:	e8 51 f2 ff ff       	call   801029f5 <kinit1>
  kvmalloc();      // kernel page table
801037a4:	e8 a1 47 00 00       	call   80107f4a <kvmalloc>
  mpinit();        // collect info about this machine
801037a9:	e8 53 04 00 00       	call   80103c01 <mpinit>
  lapicinit();
801037ae:	e8 cb f5 ff ff       	call   80102d7e <lapicinit>
  seginit();       // set up segments
801037b3:	e8 35 41 00 00       	call   801078ed <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037b8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037be:	0f b6 00             	movzbl (%eax),%eax
801037c1:	0f b6 c0             	movzbl %al,%eax
801037c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801037c8:	c7 04 24 44 89 10 80 	movl   $0x80108944,(%esp)
801037cf:	e8 cd cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037d4:	e8 8d 06 00 00       	call   80103e66 <picinit>
  ioapicinit();    // another interrupt controller
801037d9:	e8 07 f1 ff ff       	call   801028e5 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037de:	e8 aa d2 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
801037e3:	e8 50 34 00 00       	call   80106c38 <uartinit>
  pinit();         // process table
801037e8:	e8 8e 0b 00 00       	call   8010437b <pinit>
  tvinit();        // trap vectors
801037ed:	e8 cd 2f 00 00       	call   801067bf <tvinit>
  binit();         // buffer cache
801037f2:	e8 3d c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037f7:	e8 28 d7 ff ff       	call   80100f24 <fileinit>
  iinit();         // inode cache
801037fc:	e8 d6 dd ff ff       	call   801015d7 <iinit>
  ideinit();       // disk
80103801:	e8 44 ed ff ff       	call   8010254a <ideinit>
  if(!ismp)
80103806:	a1 44 23 11 80       	mov    0x80112344,%eax
8010380b:	85 c0                	test   %eax,%eax
8010380d:	75 05                	jne    80103814 <main+0x8d>
    timerinit();   // uniprocessor timer
8010380f:	e8 ee 2e 00 00       	call   80106702 <timerinit>
  startothers();   // start other processors
80103814:	e8 7f 00 00 00       	call   80103898 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103819:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103820:	8e 
80103821:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103828:	e8 00 f2 ff ff       	call   80102a2d <kinit2>
  userinit();      // first user process
8010382d:	e8 64 0c 00 00       	call   80104496 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103832:	e8 1a 00 00 00       	call   80103851 <mpmain>

80103837 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103837:	55                   	push   %ebp
80103838:	89 e5                	mov    %esp,%ebp
8010383a:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010383d:	e8 1f 47 00 00       	call   80107f61 <switchkvm>
  seginit();
80103842:	e8 a6 40 00 00       	call   801078ed <seginit>
  lapicinit();
80103847:	e8 32 f5 ff ff       	call   80102d7e <lapicinit>
  mpmain();
8010384c:	e8 00 00 00 00       	call   80103851 <mpmain>

80103851 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103851:	55                   	push   %ebp
80103852:	89 e5                	mov    %esp,%ebp
80103854:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103857:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010385d:	0f b6 00             	movzbl (%eax),%eax
80103860:	0f b6 c0             	movzbl %al,%eax
80103863:	89 44 24 04          	mov    %eax,0x4(%esp)
80103867:	c7 04 24 5b 89 10 80 	movl   $0x8010895b,(%esp)
8010386e:	e8 2e cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103873:	e8 bb 30 00 00       	call   80106933 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103878:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010387e:	05 a8 00 00 00       	add    $0xa8,%eax
80103883:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010388a:	00 
8010388b:	89 04 24             	mov    %eax,(%esp)
8010388e:	e8 cf fe ff ff       	call   80103762 <xchg>
  scheduler();     // start running processes
80103893:	e8 0d 13 00 00       	call   80104ba5 <scheduler>

80103898 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103898:	55                   	push   %ebp
80103899:	89 e5                	mov    %esp,%ebp
8010389b:	53                   	push   %ebx
8010389c:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010389f:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801038a6:	e8 aa fe ff ff       	call   80103755 <p2v>
801038ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038ae:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801038b7:	c7 44 24 04 0c b5 10 	movl   $0x8010b50c,0x4(%esp)
801038be:	80 
801038bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c2:	89 04 24             	mov    %eax,(%esp)
801038c5:	e8 83 1a 00 00       	call   8010534d <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038ca:	c7 45 f4 60 23 11 80 	movl   $0x80112360,-0xc(%ebp)
801038d1:	e9 86 00 00 00       	jmp    8010395c <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038d6:	e8 00 f6 ff ff       	call   80102edb <cpunum>
801038db:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801038e1:	05 60 23 11 80       	add    $0x80112360,%eax
801038e6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038e9:	74 69                	je     80103954 <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038eb:	e8 33 f2 ff ff       	call   80102b23 <kalloc>
801038f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038f6:	83 e8 04             	sub    $0x4,%eax
801038f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801038fc:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103902:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103907:	83 e8 08             	sub    $0x8,%eax
8010390a:	c7 00 37 38 10 80    	movl   $0x80103837,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103913:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103916:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
8010391d:	e8 26 fe ff ff       	call   80103748 <v2p>
80103922:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103924:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103927:	89 04 24             	mov    %eax,(%esp)
8010392a:	e8 19 fe ff ff       	call   80103748 <v2p>
8010392f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103932:	0f b6 12             	movzbl (%edx),%edx
80103935:	0f b6 d2             	movzbl %dl,%edx
80103938:	89 44 24 04          	mov    %eax,0x4(%esp)
8010393c:	89 14 24             	mov    %edx,(%esp)
8010393f:	e8 1d f6 ff ff       	call   80102f61 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103944:	90                   	nop
80103945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103948:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010394e:	85 c0                	test   %eax,%eax
80103950:	74 f3                	je     80103945 <startothers+0xad>
80103952:	eb 01                	jmp    80103955 <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103954:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103955:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010395c:	a1 40 29 11 80       	mov    0x80112940,%eax
80103961:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103967:	05 60 23 11 80       	add    $0x80112360,%eax
8010396c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010396f:	0f 87 61 ff ff ff    	ja     801038d6 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103975:	83 c4 24             	add    $0x24,%esp
80103978:	5b                   	pop    %ebx
80103979:	5d                   	pop    %ebp
8010397a:	c3                   	ret    
	...

8010397c <p2v>:
8010397c:	55                   	push   %ebp
8010397d:	89 e5                	mov    %esp,%ebp
8010397f:	8b 45 08             	mov    0x8(%ebp),%eax
80103982:	05 00 00 00 80       	add    $0x80000000,%eax
80103987:	5d                   	pop    %ebp
80103988:	c3                   	ret    

80103989 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103989:	55                   	push   %ebp
8010398a:	89 e5                	mov    %esp,%ebp
8010398c:	53                   	push   %ebx
8010398d:	83 ec 14             	sub    $0x14,%esp
80103990:	8b 45 08             	mov    0x8(%ebp),%eax
80103993:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103997:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
8010399b:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
8010399f:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801039a3:	ec                   	in     (%dx),%al
801039a4:	89 c3                	mov    %eax,%ebx
801039a6:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801039a9:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801039ad:	83 c4 14             	add    $0x14,%esp
801039b0:	5b                   	pop    %ebx
801039b1:	5d                   	pop    %ebp
801039b2:	c3                   	ret    

801039b3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039b3:	55                   	push   %ebp
801039b4:	89 e5                	mov    %esp,%ebp
801039b6:	83 ec 08             	sub    $0x8,%esp
801039b9:	8b 55 08             	mov    0x8(%ebp),%edx
801039bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801039bf:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039c3:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039c6:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039ca:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039ce:	ee                   	out    %al,(%dx)
}
801039cf:	c9                   	leave  
801039d0:	c3                   	ret    

801039d1 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039d1:	55                   	push   %ebp
801039d2:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039d4:	a1 44 b6 10 80       	mov    0x8010b644,%eax
801039d9:	89 c2                	mov    %eax,%edx
801039db:	b8 60 23 11 80       	mov    $0x80112360,%eax
801039e0:	89 d1                	mov    %edx,%ecx
801039e2:	29 c1                	sub    %eax,%ecx
801039e4:	89 c8                	mov    %ecx,%eax
801039e6:	c1 f8 02             	sar    $0x2,%eax
801039e9:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801039ef:	5d                   	pop    %ebp
801039f0:	c3                   	ret    

801039f1 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039f1:	55                   	push   %ebp
801039f2:	89 e5                	mov    %esp,%ebp
801039f4:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039f7:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a05:	eb 13                	jmp    80103a1a <sum+0x29>
    sum += addr[i];
80103a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a0a:	03 45 08             	add    0x8(%ebp),%eax
80103a0d:	0f b6 00             	movzbl (%eax),%eax
80103a10:	0f b6 c0             	movzbl %al,%eax
80103a13:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a16:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a1d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a20:	7c e5                	jl     80103a07 <sum+0x16>
    sum += addr[i];
  return sum;
80103a22:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a25:	c9                   	leave  
80103a26:	c3                   	ret    

80103a27 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a27:	55                   	push   %ebp
80103a28:	89 e5                	mov    %esp,%ebp
80103a2a:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a2d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a30:	89 04 24             	mov    %eax,(%esp)
80103a33:	e8 44 ff ff ff       	call   8010397c <p2v>
80103a38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a3e:	03 45 f0             	add    -0x10(%ebp),%eax
80103a41:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a44:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a4a:	eb 3f                	jmp    80103a8b <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a4c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a53:	00 
80103a54:	c7 44 24 04 6c 89 10 	movl   $0x8010896c,0x4(%esp)
80103a5b:	80 
80103a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5f:	89 04 24             	mov    %eax,(%esp)
80103a62:	e8 8a 18 00 00       	call   801052f1 <memcmp>
80103a67:	85 c0                	test   %eax,%eax
80103a69:	75 1c                	jne    80103a87 <mpsearch1+0x60>
80103a6b:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a72:	00 
80103a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a76:	89 04 24             	mov    %eax,(%esp)
80103a79:	e8 73 ff ff ff       	call   801039f1 <sum>
80103a7e:	84 c0                	test   %al,%al
80103a80:	75 05                	jne    80103a87 <mpsearch1+0x60>
      return (struct mp*)p;
80103a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a85:	eb 11                	jmp    80103a98 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a87:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a91:	72 b9                	jb     80103a4c <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a98:	c9                   	leave  
80103a99:	c3                   	ret    

80103a9a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a9a:	55                   	push   %ebp
80103a9b:	89 e5                	mov    %esp,%ebp
80103a9d:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103aa0:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aaa:	83 c0 0f             	add    $0xf,%eax
80103aad:	0f b6 00             	movzbl (%eax),%eax
80103ab0:	0f b6 c0             	movzbl %al,%eax
80103ab3:	89 c2                	mov    %eax,%edx
80103ab5:	c1 e2 08             	shl    $0x8,%edx
80103ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abb:	83 c0 0e             	add    $0xe,%eax
80103abe:	0f b6 00             	movzbl (%eax),%eax
80103ac1:	0f b6 c0             	movzbl %al,%eax
80103ac4:	09 d0                	or     %edx,%eax
80103ac6:	c1 e0 04             	shl    $0x4,%eax
80103ac9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103acc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ad0:	74 21                	je     80103af3 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103ad2:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ad9:	00 
80103ada:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103add:	89 04 24             	mov    %eax,(%esp)
80103ae0:	e8 42 ff ff ff       	call   80103a27 <mpsearch1>
80103ae5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ae8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aec:	74 50                	je     80103b3e <mpsearch+0xa4>
      return mp;
80103aee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103af1:	eb 5f                	jmp    80103b52 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af6:	83 c0 14             	add    $0x14,%eax
80103af9:	0f b6 00             	movzbl (%eax),%eax
80103afc:	0f b6 c0             	movzbl %al,%eax
80103aff:	89 c2                	mov    %eax,%edx
80103b01:	c1 e2 08             	shl    $0x8,%edx
80103b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b07:	83 c0 13             	add    $0x13,%eax
80103b0a:	0f b6 00             	movzbl (%eax),%eax
80103b0d:	0f b6 c0             	movzbl %al,%eax
80103b10:	09 d0                	or     %edx,%eax
80103b12:	c1 e0 0a             	shl    $0xa,%eax
80103b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b1b:	2d 00 04 00 00       	sub    $0x400,%eax
80103b20:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b27:	00 
80103b28:	89 04 24             	mov    %eax,(%esp)
80103b2b:	e8 f7 fe ff ff       	call   80103a27 <mpsearch1>
80103b30:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b33:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b37:	74 05                	je     80103b3e <mpsearch+0xa4>
      return mp;
80103b39:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b3c:	eb 14                	jmp    80103b52 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b3e:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b45:	00 
80103b46:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b4d:	e8 d5 fe ff ff       	call   80103a27 <mpsearch1>
}
80103b52:	c9                   	leave  
80103b53:	c3                   	ret    

80103b54 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b54:	55                   	push   %ebp
80103b55:	89 e5                	mov    %esp,%ebp
80103b57:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b5a:	e8 3b ff ff ff       	call   80103a9a <mpsearch>
80103b5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b66:	74 0a                	je     80103b72 <mpconfig+0x1e>
80103b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6b:	8b 40 04             	mov    0x4(%eax),%eax
80103b6e:	85 c0                	test   %eax,%eax
80103b70:	75 0a                	jne    80103b7c <mpconfig+0x28>
    return 0;
80103b72:	b8 00 00 00 00       	mov    $0x0,%eax
80103b77:	e9 83 00 00 00       	jmp    80103bff <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b7f:	8b 40 04             	mov    0x4(%eax),%eax
80103b82:	89 04 24             	mov    %eax,(%esp)
80103b85:	e8 f2 fd ff ff       	call   8010397c <p2v>
80103b8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b8d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b94:	00 
80103b95:	c7 44 24 04 71 89 10 	movl   $0x80108971,0x4(%esp)
80103b9c:	80 
80103b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba0:	89 04 24             	mov    %eax,(%esp)
80103ba3:	e8 49 17 00 00       	call   801052f1 <memcmp>
80103ba8:	85 c0                	test   %eax,%eax
80103baa:	74 07                	je     80103bb3 <mpconfig+0x5f>
    return 0;
80103bac:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb1:	eb 4c                	jmp    80103bff <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb6:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bba:	3c 01                	cmp    $0x1,%al
80103bbc:	74 12                	je     80103bd0 <mpconfig+0x7c>
80103bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc1:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bc5:	3c 04                	cmp    $0x4,%al
80103bc7:	74 07                	je     80103bd0 <mpconfig+0x7c>
    return 0;
80103bc9:	b8 00 00 00 00       	mov    $0x0,%eax
80103bce:	eb 2f                	jmp    80103bff <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bd7:	0f b7 c0             	movzwl %ax,%eax
80103bda:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be1:	89 04 24             	mov    %eax,(%esp)
80103be4:	e8 08 fe ff ff       	call   801039f1 <sum>
80103be9:	84 c0                	test   %al,%al
80103beb:	74 07                	je     80103bf4 <mpconfig+0xa0>
    return 0;
80103bed:	b8 00 00 00 00       	mov    $0x0,%eax
80103bf2:	eb 0b                	jmp    80103bff <mpconfig+0xab>
  *pmp = mp;
80103bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bfa:	89 10                	mov    %edx,(%eax)
  return conf;
80103bfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bff:	c9                   	leave  
80103c00:	c3                   	ret    

80103c01 <mpinit>:

void
mpinit(void)
{
80103c01:	55                   	push   %ebp
80103c02:	89 e5                	mov    %esp,%ebp
80103c04:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c07:	c7 05 44 b6 10 80 60 	movl   $0x80112360,0x8010b644
80103c0e:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c11:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c14:	89 04 24             	mov    %eax,(%esp)
80103c17:	e8 38 ff ff ff       	call   80103b54 <mpconfig>
80103c1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c23:	0f 84 9c 01 00 00    	je     80103dc5 <mpinit+0x1c4>
    return;
  ismp = 1;
80103c29:	c7 05 44 23 11 80 01 	movl   $0x1,0x80112344
80103c30:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c36:	8b 40 24             	mov    0x24(%eax),%eax
80103c39:	a3 5c 22 11 80       	mov    %eax,0x8011225c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c41:	83 c0 2c             	add    $0x2c,%eax
80103c44:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c4a:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c4e:	0f b7 c0             	movzwl %ax,%eax
80103c51:	03 45 f0             	add    -0x10(%ebp),%eax
80103c54:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c57:	e9 f4 00 00 00       	jmp    80103d50 <mpinit+0x14f>
    switch(*p){
80103c5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5f:	0f b6 00             	movzbl (%eax),%eax
80103c62:	0f b6 c0             	movzbl %al,%eax
80103c65:	83 f8 04             	cmp    $0x4,%eax
80103c68:	0f 87 bf 00 00 00    	ja     80103d2d <mpinit+0x12c>
80103c6e:	8b 04 85 b4 89 10 80 	mov    -0x7fef764c(,%eax,4),%eax
80103c75:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c80:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c84:	0f b6 d0             	movzbl %al,%edx
80103c87:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c8c:	39 c2                	cmp    %eax,%edx
80103c8e:	74 2d                	je     80103cbd <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c90:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c93:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c97:	0f b6 d0             	movzbl %al,%edx
80103c9a:	a1 40 29 11 80       	mov    0x80112940,%eax
80103c9f:	89 54 24 08          	mov    %edx,0x8(%esp)
80103ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ca7:	c7 04 24 76 89 10 80 	movl   $0x80108976,(%esp)
80103cae:	e8 ee c6 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103cb3:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103cba:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103cbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cc0:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103cc4:	0f b6 c0             	movzbl %al,%eax
80103cc7:	83 e0 02             	and    $0x2,%eax
80103cca:	85 c0                	test   %eax,%eax
80103ccc:	74 15                	je     80103ce3 <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103cce:	a1 40 29 11 80       	mov    0x80112940,%eax
80103cd3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103cd9:	05 60 23 11 80       	add    $0x80112360,%eax
80103cde:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103ce3:	8b 15 40 29 11 80    	mov    0x80112940,%edx
80103ce9:	a1 40 29 11 80       	mov    0x80112940,%eax
80103cee:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103cf4:	81 c2 60 23 11 80    	add    $0x80112360,%edx
80103cfa:	88 02                	mov    %al,(%edx)
      ncpu++;
80103cfc:	a1 40 29 11 80       	mov    0x80112940,%eax
80103d01:	83 c0 01             	add    $0x1,%eax
80103d04:	a3 40 29 11 80       	mov    %eax,0x80112940
      p += sizeof(struct mpproc);
80103d09:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d0d:	eb 41                	jmp    80103d50 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d18:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d1c:	a2 40 23 11 80       	mov    %al,0x80112340
      p += sizeof(struct mpioapic);
80103d21:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d25:	eb 29                	jmp    80103d50 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d27:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d2b:	eb 23                	jmp    80103d50 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d30:	0f b6 00             	movzbl (%eax),%eax
80103d33:	0f b6 c0             	movzbl %al,%eax
80103d36:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d3a:	c7 04 24 94 89 10 80 	movl   $0x80108994,(%esp)
80103d41:	e8 5b c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d46:	c7 05 44 23 11 80 00 	movl   $0x0,0x80112344
80103d4d:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d53:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d56:	0f 82 00 ff ff ff    	jb     80103c5c <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d5c:	a1 44 23 11 80       	mov    0x80112344,%eax
80103d61:	85 c0                	test   %eax,%eax
80103d63:	75 1d                	jne    80103d82 <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d65:	c7 05 40 29 11 80 01 	movl   $0x1,0x80112940
80103d6c:	00 00 00 
    lapic = 0;
80103d6f:	c7 05 5c 22 11 80 00 	movl   $0x0,0x8011225c
80103d76:	00 00 00 
    ioapicid = 0;
80103d79:	c6 05 40 23 11 80 00 	movb   $0x0,0x80112340
    return;
80103d80:	eb 44                	jmp    80103dc6 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d85:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d89:	84 c0                	test   %al,%al
80103d8b:	74 39                	je     80103dc6 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d8d:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d94:	00 
80103d95:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d9c:	e8 12 fc ff ff       	call   801039b3 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103da1:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103da8:	e8 dc fb ff ff       	call   80103989 <inb>
80103dad:	83 c8 01             	or     $0x1,%eax
80103db0:	0f b6 c0             	movzbl %al,%eax
80103db3:	89 44 24 04          	mov    %eax,0x4(%esp)
80103db7:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103dbe:	e8 f0 fb ff ff       	call   801039b3 <outb>
80103dc3:	eb 01                	jmp    80103dc6 <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103dc5:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103dc6:	c9                   	leave  
80103dc7:	c3                   	ret    

80103dc8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103dc8:	55                   	push   %ebp
80103dc9:	89 e5                	mov    %esp,%ebp
80103dcb:	83 ec 08             	sub    $0x8,%esp
80103dce:	8b 55 08             	mov    0x8(%ebp),%edx
80103dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dd4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103dd8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ddb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ddf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103de3:	ee                   	out    %al,(%dx)
}
80103de4:	c9                   	leave  
80103de5:	c3                   	ret    

80103de6 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103de6:	55                   	push   %ebp
80103de7:	89 e5                	mov    %esp,%ebp
80103de9:	83 ec 0c             	sub    $0xc,%esp
80103dec:	8b 45 08             	mov    0x8(%ebp),%eax
80103def:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103df3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103df7:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103dfd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e01:	0f b6 c0             	movzbl %al,%eax
80103e04:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e08:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e0f:	e8 b4 ff ff ff       	call   80103dc8 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e14:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e18:	66 c1 e8 08          	shr    $0x8,%ax
80103e1c:	0f b6 c0             	movzbl %al,%eax
80103e1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e23:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e2a:	e8 99 ff ff ff       	call   80103dc8 <outb>
}
80103e2f:	c9                   	leave  
80103e30:	c3                   	ret    

80103e31 <picenable>:

void
picenable(int irq)
{
80103e31:	55                   	push   %ebp
80103e32:	89 e5                	mov    %esp,%ebp
80103e34:	53                   	push   %ebx
80103e35:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e38:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3b:	ba 01 00 00 00       	mov    $0x1,%edx
80103e40:	89 d3                	mov    %edx,%ebx
80103e42:	89 c1                	mov    %eax,%ecx
80103e44:	d3 e3                	shl    %cl,%ebx
80103e46:	89 d8                	mov    %ebx,%eax
80103e48:	89 c2                	mov    %eax,%edx
80103e4a:	f7 d2                	not    %edx
80103e4c:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103e53:	21 d0                	and    %edx,%eax
80103e55:	0f b7 c0             	movzwl %ax,%eax
80103e58:	89 04 24             	mov    %eax,(%esp)
80103e5b:	e8 86 ff ff ff       	call   80103de6 <picsetmask>
}
80103e60:	83 c4 04             	add    $0x4,%esp
80103e63:	5b                   	pop    %ebx
80103e64:	5d                   	pop    %ebp
80103e65:	c3                   	ret    

80103e66 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e66:	55                   	push   %ebp
80103e67:	89 e5                	mov    %esp,%ebp
80103e69:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e6c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e73:	00 
80103e74:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e7b:	e8 48 ff ff ff       	call   80103dc8 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e80:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e87:	00 
80103e88:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e8f:	e8 34 ff ff ff       	call   80103dc8 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e94:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103e9b:	00 
80103e9c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ea3:	e8 20 ff ff ff       	call   80103dc8 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103ea8:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103eaf:	00 
80103eb0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103eb7:	e8 0c ff ff ff       	call   80103dc8 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103ebc:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ec3:	00 
80103ec4:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ecb:	e8 f8 fe ff ff       	call   80103dc8 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ed0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103ed7:	00 
80103ed8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103edf:	e8 e4 fe ff ff       	call   80103dc8 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103ee4:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103eeb:	00 
80103eec:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103ef3:	e8 d0 fe ff ff       	call   80103dc8 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103ef8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103eff:	00 
80103f00:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f07:	e8 bc fe ff ff       	call   80103dc8 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f0c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f13:	00 
80103f14:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f1b:	e8 a8 fe ff ff       	call   80103dc8 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f20:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f27:	00 
80103f28:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f2f:	e8 94 fe ff ff       	call   80103dc8 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f34:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f3b:	00 
80103f3c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f43:	e8 80 fe ff ff       	call   80103dc8 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f48:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f4f:	00 
80103f50:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f57:	e8 6c fe ff ff       	call   80103dc8 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f5c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f63:	00 
80103f64:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f6b:	e8 58 fe ff ff       	call   80103dc8 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f70:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f77:	00 
80103f78:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f7f:	e8 44 fe ff ff       	call   80103dc8 <outb>

  if(irqmask != 0xFFFF)
80103f84:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f8b:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f8f:	74 12                	je     80103fa3 <picinit+0x13d>
    picsetmask(irqmask);
80103f91:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f98:	0f b7 c0             	movzwl %ax,%eax
80103f9b:	89 04 24             	mov    %eax,(%esp)
80103f9e:	e8 43 fe ff ff       	call   80103de6 <picsetmask>
}
80103fa3:	c9                   	leave  
80103fa4:	c3                   	ret    
80103fa5:	00 00                	add    %al,(%eax)
	...

80103fa8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fa8:	55                   	push   %ebp
80103fa9:	89 e5                	mov    %esp,%ebp
80103fab:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc1:	8b 10                	mov    (%eax),%edx
80103fc3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fc8:	e8 73 cf ff ff       	call   80100f40 <filealloc>
80103fcd:	8b 55 08             	mov    0x8(%ebp),%edx
80103fd0:	89 02                	mov    %eax,(%edx)
80103fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd5:	8b 00                	mov    (%eax),%eax
80103fd7:	85 c0                	test   %eax,%eax
80103fd9:	0f 84 c8 00 00 00    	je     801040a7 <pipealloc+0xff>
80103fdf:	e8 5c cf ff ff       	call   80100f40 <filealloc>
80103fe4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fe7:	89 02                	mov    %eax,(%edx)
80103fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fec:	8b 00                	mov    (%eax),%eax
80103fee:	85 c0                	test   %eax,%eax
80103ff0:	0f 84 b1 00 00 00    	je     801040a7 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103ff6:	e8 28 eb ff ff       	call   80102b23 <kalloc>
80103ffb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ffe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104002:	0f 84 9e 00 00 00    	je     801040a6 <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80104008:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400b:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104012:	00 00 00 
  p->writeopen = 1;
80104015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104018:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010401f:	00 00 00 
  p->nwrite = 0;
80104022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104025:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010402c:	00 00 00 
  p->nread = 0;
8010402f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104032:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104039:	00 00 00 
  initlock(&p->lock, "pipe");
8010403c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403f:	c7 44 24 04 c8 89 10 	movl   $0x801089c8,0x4(%esp)
80104046:	80 
80104047:	89 04 24             	mov    %eax,(%esp)
8010404a:	e8 bb 0f 00 00       	call   8010500a <initlock>
  (*f0)->type = FD_PIPE;
8010404f:	8b 45 08             	mov    0x8(%ebp),%eax
80104052:	8b 00                	mov    (%eax),%eax
80104054:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010405a:	8b 45 08             	mov    0x8(%ebp),%eax
8010405d:	8b 00                	mov    (%eax),%eax
8010405f:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104063:	8b 45 08             	mov    0x8(%ebp),%eax
80104066:	8b 00                	mov    (%eax),%eax
80104068:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010406c:	8b 45 08             	mov    0x8(%ebp),%eax
8010406f:	8b 00                	mov    (%eax),%eax
80104071:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104074:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104077:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407a:	8b 00                	mov    (%eax),%eax
8010407c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104082:	8b 45 0c             	mov    0xc(%ebp),%eax
80104085:	8b 00                	mov    (%eax),%eax
80104087:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010408b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408e:	8b 00                	mov    (%eax),%eax
80104090:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104094:	8b 45 0c             	mov    0xc(%ebp),%eax
80104097:	8b 00                	mov    (%eax),%eax
80104099:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010409c:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010409f:	b8 00 00 00 00       	mov    $0x0,%eax
801040a4:	eb 43                	jmp    801040e9 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801040a6:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801040a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040ab:	74 0b                	je     801040b8 <pipealloc+0x110>
    kfree((char*)p);
801040ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b0:	89 04 24             	mov    %eax,(%esp)
801040b3:	e8 d2 e9 ff ff       	call   80102a8a <kfree>
  if(*f0)
801040b8:	8b 45 08             	mov    0x8(%ebp),%eax
801040bb:	8b 00                	mov    (%eax),%eax
801040bd:	85 c0                	test   %eax,%eax
801040bf:	74 0d                	je     801040ce <pipealloc+0x126>
    fileclose(*f0);
801040c1:	8b 45 08             	mov    0x8(%ebp),%eax
801040c4:	8b 00                	mov    (%eax),%eax
801040c6:	89 04 24             	mov    %eax,(%esp)
801040c9:	e8 1a cf ff ff       	call   80100fe8 <fileclose>
  if(*f1)
801040ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d1:	8b 00                	mov    (%eax),%eax
801040d3:	85 c0                	test   %eax,%eax
801040d5:	74 0d                	je     801040e4 <pipealloc+0x13c>
    fileclose(*f1);
801040d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801040da:	8b 00                	mov    (%eax),%eax
801040dc:	89 04 24             	mov    %eax,(%esp)
801040df:	e8 04 cf ff ff       	call   80100fe8 <fileclose>
  return -1;
801040e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040e9:	c9                   	leave  
801040ea:	c3                   	ret    

801040eb <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040eb:	55                   	push   %ebp
801040ec:	89 e5                	mov    %esp,%ebp
801040ee:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040f1:	8b 45 08             	mov    0x8(%ebp),%eax
801040f4:	89 04 24             	mov    %eax,(%esp)
801040f7:	e8 2f 0f 00 00       	call   8010502b <acquire>
  if(writable){
801040fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104100:	74 1f                	je     80104121 <pipeclose+0x36>
    p->writeopen = 0;
80104102:	8b 45 08             	mov    0x8(%ebp),%eax
80104105:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010410c:	00 00 00 
    wakeup(&p->nread);
8010410f:	8b 45 08             	mov    0x8(%ebp),%eax
80104112:	05 34 02 00 00       	add    $0x234,%eax
80104117:	89 04 24             	mov    %eax,(%esp)
8010411a:	e8 08 0d 00 00       	call   80104e27 <wakeup>
8010411f:	eb 1d                	jmp    8010413e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104121:	8b 45 08             	mov    0x8(%ebp),%eax
80104124:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010412b:	00 00 00 
    wakeup(&p->nwrite);
8010412e:	8b 45 08             	mov    0x8(%ebp),%eax
80104131:	05 38 02 00 00       	add    $0x238,%eax
80104136:	89 04 24             	mov    %eax,(%esp)
80104139:	e8 e9 0c 00 00       	call   80104e27 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010413e:	8b 45 08             	mov    0x8(%ebp),%eax
80104141:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104147:	85 c0                	test   %eax,%eax
80104149:	75 25                	jne    80104170 <pipeclose+0x85>
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104154:	85 c0                	test   %eax,%eax
80104156:	75 18                	jne    80104170 <pipeclose+0x85>
    release(&p->lock);
80104158:	8b 45 08             	mov    0x8(%ebp),%eax
8010415b:	89 04 24             	mov    %eax,(%esp)
8010415e:	e8 2a 0f 00 00       	call   8010508d <release>
    kfree((char*)p);
80104163:	8b 45 08             	mov    0x8(%ebp),%eax
80104166:	89 04 24             	mov    %eax,(%esp)
80104169:	e8 1c e9 ff ff       	call   80102a8a <kfree>
8010416e:	eb 0b                	jmp    8010417b <pipeclose+0x90>
  } else
    release(&p->lock);
80104170:	8b 45 08             	mov    0x8(%ebp),%eax
80104173:	89 04 24             	mov    %eax,(%esp)
80104176:	e8 12 0f 00 00       	call   8010508d <release>
}
8010417b:	c9                   	leave  
8010417c:	c3                   	ret    

8010417d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010417d:	55                   	push   %ebp
8010417e:	89 e5                	mov    %esp,%ebp
80104180:	53                   	push   %ebx
80104181:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104184:	8b 45 08             	mov    0x8(%ebp),%eax
80104187:	89 04 24             	mov    %eax,(%esp)
8010418a:	e8 9c 0e 00 00       	call   8010502b <acquire>
  for(i = 0; i < n; i++){
8010418f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104196:	e9 a6 00 00 00       	jmp    80104241 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010419b:	8b 45 08             	mov    0x8(%ebp),%eax
8010419e:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041a4:	85 c0                	test   %eax,%eax
801041a6:	74 0d                	je     801041b5 <pipewrite+0x38>
801041a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041ae:	8b 40 24             	mov    0x24(%eax),%eax
801041b1:	85 c0                	test   %eax,%eax
801041b3:	74 15                	je     801041ca <pipewrite+0x4d>
        release(&p->lock);
801041b5:	8b 45 08             	mov    0x8(%ebp),%eax
801041b8:	89 04 24             	mov    %eax,(%esp)
801041bb:	e8 cd 0e 00 00       	call   8010508d <release>
        return -1;
801041c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c5:	e9 9d 00 00 00       	jmp    80104267 <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041ca:	8b 45 08             	mov    0x8(%ebp),%eax
801041cd:	05 34 02 00 00       	add    $0x234,%eax
801041d2:	89 04 24             	mov    %eax,(%esp)
801041d5:	e8 4d 0c 00 00       	call   80104e27 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041da:	8b 45 08             	mov    0x8(%ebp),%eax
801041dd:	8b 55 08             	mov    0x8(%ebp),%edx
801041e0:	81 c2 38 02 00 00    	add    $0x238,%edx
801041e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801041ea:	89 14 24             	mov    %edx,(%esp)
801041ed:	e8 5c 0b 00 00       	call   80104d4e <sleep>
801041f2:	eb 01                	jmp    801041f5 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041f4:	90                   	nop
801041f5:	8b 45 08             	mov    0x8(%ebp),%eax
801041f8:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104201:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104207:	05 00 02 00 00       	add    $0x200,%eax
8010420c:	39 c2                	cmp    %eax,%edx
8010420e:	74 8b                	je     8010419b <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104210:	8b 45 08             	mov    0x8(%ebp),%eax
80104213:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104219:	89 c3                	mov    %eax,%ebx
8010421b:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104221:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104224:	03 55 0c             	add    0xc(%ebp),%edx
80104227:	0f b6 0a             	movzbl (%edx),%ecx
8010422a:	8b 55 08             	mov    0x8(%ebp),%edx
8010422d:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104231:	8d 50 01             	lea    0x1(%eax),%edx
80104234:	8b 45 08             	mov    0x8(%ebp),%eax
80104237:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010423d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104241:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104244:	3b 45 10             	cmp    0x10(%ebp),%eax
80104247:	7c ab                	jl     801041f4 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104249:	8b 45 08             	mov    0x8(%ebp),%eax
8010424c:	05 34 02 00 00       	add    $0x234,%eax
80104251:	89 04 24             	mov    %eax,(%esp)
80104254:	e8 ce 0b 00 00       	call   80104e27 <wakeup>
  release(&p->lock);
80104259:	8b 45 08             	mov    0x8(%ebp),%eax
8010425c:	89 04 24             	mov    %eax,(%esp)
8010425f:	e8 29 0e 00 00       	call   8010508d <release>
  return n;
80104264:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104267:	83 c4 24             	add    $0x24,%esp
8010426a:	5b                   	pop    %ebx
8010426b:	5d                   	pop    %ebp
8010426c:	c3                   	ret    

8010426d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010426d:	55                   	push   %ebp
8010426e:	89 e5                	mov    %esp,%ebp
80104270:	53                   	push   %ebx
80104271:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104274:	8b 45 08             	mov    0x8(%ebp),%eax
80104277:	89 04 24             	mov    %eax,(%esp)
8010427a:	e8 ac 0d 00 00       	call   8010502b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010427f:	eb 3a                	jmp    801042bb <piperead+0x4e>
    if(proc->killed){
80104281:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104287:	8b 40 24             	mov    0x24(%eax),%eax
8010428a:	85 c0                	test   %eax,%eax
8010428c:	74 15                	je     801042a3 <piperead+0x36>
      release(&p->lock);
8010428e:	8b 45 08             	mov    0x8(%ebp),%eax
80104291:	89 04 24             	mov    %eax,(%esp)
80104294:	e8 f4 0d 00 00       	call   8010508d <release>
      return -1;
80104299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010429e:	e9 b6 00 00 00       	jmp    80104359 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042a3:	8b 45 08             	mov    0x8(%ebp),%eax
801042a6:	8b 55 08             	mov    0x8(%ebp),%edx
801042a9:	81 c2 34 02 00 00    	add    $0x234,%edx
801042af:	89 44 24 04          	mov    %eax,0x4(%esp)
801042b3:	89 14 24             	mov    %edx,(%esp)
801042b6:	e8 93 0a 00 00       	call   80104d4e <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042bb:	8b 45 08             	mov    0x8(%ebp),%eax
801042be:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042c4:	8b 45 08             	mov    0x8(%ebp),%eax
801042c7:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042cd:	39 c2                	cmp    %eax,%edx
801042cf:	75 0d                	jne    801042de <piperead+0x71>
801042d1:	8b 45 08             	mov    0x8(%ebp),%eax
801042d4:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042da:	85 c0                	test   %eax,%eax
801042dc:	75 a3                	jne    80104281 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042e5:	eb 49                	jmp    80104330 <piperead+0xc3>
    if(p->nread == p->nwrite)
801042e7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ea:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042f0:	8b 45 08             	mov    0x8(%ebp),%eax
801042f3:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042f9:	39 c2                	cmp    %eax,%edx
801042fb:	74 3d                	je     8010433a <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104300:	89 c2                	mov    %eax,%edx
80104302:	03 55 0c             	add    0xc(%ebp),%edx
80104305:	8b 45 08             	mov    0x8(%ebp),%eax
80104308:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010430e:	89 c3                	mov    %eax,%ebx
80104310:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104316:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104319:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
8010431e:	88 0a                	mov    %cl,(%edx)
80104320:	8d 50 01             	lea    0x1(%eax),%edx
80104323:	8b 45 08             	mov    0x8(%ebp),%eax
80104326:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010432c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104330:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104333:	3b 45 10             	cmp    0x10(%ebp),%eax
80104336:	7c af                	jl     801042e7 <piperead+0x7a>
80104338:	eb 01                	jmp    8010433b <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
8010433a:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010433b:	8b 45 08             	mov    0x8(%ebp),%eax
8010433e:	05 38 02 00 00       	add    $0x238,%eax
80104343:	89 04 24             	mov    %eax,(%esp)
80104346:	e8 dc 0a 00 00       	call   80104e27 <wakeup>
  release(&p->lock);
8010434b:	8b 45 08             	mov    0x8(%ebp),%eax
8010434e:	89 04 24             	mov    %eax,(%esp)
80104351:	e8 37 0d 00 00       	call   8010508d <release>
  return i;
80104356:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104359:	83 c4 24             	add    $0x24,%esp
8010435c:	5b                   	pop    %ebx
8010435d:	5d                   	pop    %ebp
8010435e:	c3                   	ret    
	...

80104360 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104360:	55                   	push   %ebp
80104361:	89 e5                	mov    %esp,%ebp
80104363:	53                   	push   %ebx
80104364:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104367:	9c                   	pushf  
80104368:	5b                   	pop    %ebx
80104369:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
8010436c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010436f:	83 c4 10             	add    $0x10,%esp
80104372:	5b                   	pop    %ebx
80104373:	5d                   	pop    %ebp
80104374:	c3                   	ret    

80104375 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104375:	55                   	push   %ebp
80104376:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104378:	fb                   	sti    
}
80104379:	5d                   	pop    %ebp
8010437a:	c3                   	ret    

8010437b <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010437b:	55                   	push   %ebp
8010437c:	89 e5                	mov    %esp,%ebp
8010437e:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104381:	c7 44 24 04 cd 89 10 	movl   $0x801089cd,0x4(%esp)
80104388:	80 
80104389:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104390:	e8 75 0c 00 00       	call   8010500a <initlock>
}
80104395:	c9                   	leave  
80104396:	c3                   	ret    

80104397 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104397:	55                   	push   %ebp
80104398:	89 e5                	mov    %esp,%ebp
8010439a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010439d:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801043a4:	e8 82 0c 00 00       	call   8010502b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043a9:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801043b0:	eb 0e                	jmp    801043c0 <allocproc+0x29>
    if(p->state == UNUSED)
801043b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b5:	8b 40 0c             	mov    0xc(%eax),%eax
801043b8:	85 c0                	test   %eax,%eax
801043ba:	74 23                	je     801043df <allocproc+0x48>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043bc:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801043c0:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
801043c7:	72 e9                	jb     801043b2 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043c9:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801043d0:	e8 b8 0c 00 00       	call   8010508d <release>
  return 0;
801043d5:	b8 00 00 00 00       	mov    $0x0,%eax
801043da:	e9 b5 00 00 00       	jmp    80104494 <allocproc+0xfd>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043df:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e3:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043ea:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801043ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043f2:	89 42 10             	mov    %eax,0x10(%edx)
801043f5:	83 c0 01             	add    $0x1,%eax
801043f8:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
801043fd:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104404:	e8 84 0c 00 00       	call   8010508d <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104409:	e8 15 e7 ff ff       	call   80102b23 <kalloc>
8010440e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104411:	89 42 08             	mov    %eax,0x8(%edx)
80104414:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104417:	8b 40 08             	mov    0x8(%eax),%eax
8010441a:	85 c0                	test   %eax,%eax
8010441c:	75 11                	jne    8010442f <allocproc+0x98>
    p->state = UNUSED;
8010441e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104421:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104428:	b8 00 00 00 00       	mov    $0x0,%eax
8010442d:	eb 65                	jmp    80104494 <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
8010442f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104432:	8b 40 08             	mov    0x8(%eax),%eax
80104435:	05 00 10 00 00       	add    $0x1000,%eax
8010443a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010443d:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104444:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104447:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010444a:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
8010444e:	ba 74 67 10 80       	mov    $0x80106774,%edx
80104453:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104456:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104458:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010445c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104462:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104468:	8b 40 1c             	mov    0x1c(%eax),%eax
8010446b:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104472:	00 
80104473:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010447a:	00 
8010447b:	89 04 24             	mov    %eax,(%esp)
8010447e:	e8 f7 0d 00 00       	call   8010527a <memset>
  p->context->eip = (uint)forkret;
80104483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104486:	8b 40 1c             	mov    0x1c(%eax),%eax
80104489:	ba 22 4d 10 80       	mov    $0x80104d22,%edx
8010448e:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104491:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104494:	c9                   	leave  
80104495:	c3                   	ret    

80104496 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104496:	55                   	push   %ebp
80104497:	89 e5                	mov    %esp,%ebp
80104499:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010449c:	e8 f6 fe ff ff       	call   80104397 <allocproc>
801044a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801044a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a7:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
801044ac:	e8 dc 39 00 00       	call   80107e8d <setupkvm>
801044b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044b4:	89 42 04             	mov    %eax,0x4(%edx)
801044b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ba:	8b 40 04             	mov    0x4(%eax),%eax
801044bd:	85 c0                	test   %eax,%eax
801044bf:	75 0c                	jne    801044cd <userinit+0x37>
    panic("userinit: out of memory?");
801044c1:	c7 04 24 d4 89 10 80 	movl   $0x801089d4,(%esp)
801044c8:	e8 70 c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044cd:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d5:	8b 40 04             	mov    0x4(%eax),%eax
801044d8:	89 54 24 08          	mov    %edx,0x8(%esp)
801044dc:	c7 44 24 04 e0 b4 10 	movl   $0x8010b4e0,0x4(%esp)
801044e3:	80 
801044e4:	89 04 24             	mov    %eax,(%esp)
801044e7:	e8 f9 3b 00 00       	call   801080e5 <inituvm>
  p->sz = PGSIZE;
801044ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ef:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f8:	8b 40 18             	mov    0x18(%eax),%eax
801044fb:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104502:	00 
80104503:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010450a:	00 
8010450b:	89 04 24             	mov    %eax,(%esp)
8010450e:	e8 67 0d 00 00       	call   8010527a <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104516:	8b 40 18             	mov    0x18(%eax),%eax
80104519:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010451f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104522:	8b 40 18             	mov    0x18(%eax),%eax
80104525:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010452b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452e:	8b 40 18             	mov    0x18(%eax),%eax
80104531:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104534:	8b 52 18             	mov    0x18(%edx),%edx
80104537:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010453b:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010453f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104542:	8b 40 18             	mov    0x18(%eax),%eax
80104545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104548:	8b 52 18             	mov    0x18(%edx),%edx
8010454b:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010454f:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104556:	8b 40 18             	mov    0x18(%eax),%eax
80104559:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104563:	8b 40 18             	mov    0x18(%eax),%eax
80104566:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010456d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104570:	8b 40 18             	mov    0x18(%eax),%eax
80104573:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010457a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457d:	83 c0 6c             	add    $0x6c,%eax
80104580:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104587:	00 
80104588:	c7 44 24 04 ed 89 10 	movl   $0x801089ed,0x4(%esp)
8010458f:	80 
80104590:	89 04 24             	mov    %eax,(%esp)
80104593:	e8 12 0f 00 00       	call   801054aa <safestrcpy>
  p->cwd = namei("/");
80104598:	c7 04 24 f6 89 10 80 	movl   $0x801089f6,(%esp)
8010459f:	e8 8a de ff ff       	call   8010242e <namei>
801045a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045a7:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801045aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ad:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045b4:	c9                   	leave  
801045b5:	c3                   	ret    

801045b6 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045b6:	55                   	push   %ebp
801045b7:	89 e5                	mov    %esp,%ebp
801045b9:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045bc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045c2:	8b 00                	mov    (%eax),%eax
801045c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045c7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045cb:	7e 34                	jle    80104601 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045cd:	8b 45 08             	mov    0x8(%ebp),%eax
801045d0:	89 c2                	mov    %eax,%edx
801045d2:	03 55 f4             	add    -0xc(%ebp),%edx
801045d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045db:	8b 40 04             	mov    0x4(%eax),%eax
801045de:	89 54 24 08          	mov    %edx,0x8(%esp)
801045e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801045e9:	89 04 24             	mov    %eax,(%esp)
801045ec:	e8 6e 3c 00 00       	call   8010825f <allocuvm>
801045f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045f8:	75 41                	jne    8010463b <growproc+0x85>
      return -1;
801045fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045ff:	eb 58                	jmp    80104659 <growproc+0xa3>
  } else if(n < 0){
80104601:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104605:	79 34                	jns    8010463b <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104607:	8b 45 08             	mov    0x8(%ebp),%eax
8010460a:	89 c2                	mov    %eax,%edx
8010460c:	03 55 f4             	add    -0xc(%ebp),%edx
8010460f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104615:	8b 40 04             	mov    0x4(%eax),%eax
80104618:	89 54 24 08          	mov    %edx,0x8(%esp)
8010461c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010461f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104623:	89 04 24             	mov    %eax,(%esp)
80104626:	e8 0e 3d 00 00       	call   80108339 <deallocuvm>
8010462b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010462e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104632:	75 07                	jne    8010463b <growproc+0x85>
      return -1;
80104634:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104639:	eb 1e                	jmp    80104659 <growproc+0xa3>
  }
  proc->sz = sz;
8010463b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104641:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104644:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104646:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010464c:	89 04 24             	mov    %eax,(%esp)
8010464f:	e8 2a 39 00 00       	call   80107f7e <switchuvm>
  return 0;
80104654:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104659:	c9                   	leave  
8010465a:	c3                   	ret    

8010465b <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010465b:	55                   	push   %ebp
8010465c:	89 e5                	mov    %esp,%ebp
8010465e:	57                   	push   %edi
8010465f:	56                   	push   %esi
80104660:	53                   	push   %ebx
80104661:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104664:	e8 2e fd ff ff       	call   80104397 <allocproc>
80104669:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010466c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104670:	75 0a                	jne    8010467c <fork+0x21>
    return -1;
80104672:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104677:	e9 52 01 00 00       	jmp    801047ce <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010467c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104682:	8b 10                	mov    (%eax),%edx
80104684:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468a:	8b 40 04             	mov    0x4(%eax),%eax
8010468d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104691:	89 04 24             	mov    %eax,(%esp)
80104694:	e8 30 3e 00 00       	call   801084c9 <copyuvm>
80104699:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010469c:	89 42 04             	mov    %eax,0x4(%edx)
8010469f:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a2:	8b 40 04             	mov    0x4(%eax),%eax
801046a5:	85 c0                	test   %eax,%eax
801046a7:	75 2c                	jne    801046d5 <fork+0x7a>
    kfree(np->kstack);
801046a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ac:	8b 40 08             	mov    0x8(%eax),%eax
801046af:	89 04 24             	mov    %eax,(%esp)
801046b2:	e8 d3 e3 ff ff       	call   80102a8a <kfree>
    np->kstack = 0;
801046b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d0:	e9 f9 00 00 00       	jmp    801047ce <fork+0x173>
  }
  np->sz = proc->sz;
801046d5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046db:	8b 10                	mov    (%eax),%edx
801046dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e0:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046e2:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ec:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f2:	8b 50 18             	mov    0x18(%eax),%edx
801046f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046fb:	8b 40 18             	mov    0x18(%eax),%eax
801046fe:	89 c3                	mov    %eax,%ebx
80104700:	b8 13 00 00 00       	mov    $0x13,%eax
80104705:	89 d7                	mov    %edx,%edi
80104707:	89 de                	mov    %ebx,%esi
80104709:	89 c1                	mov    %eax,%ecx
8010470b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010470d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104710:	8b 40 18             	mov    0x18(%eax),%eax
80104713:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010471a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104721:	eb 3d                	jmp    80104760 <fork+0x105>
    if(proc->ofile[i])
80104723:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104729:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010472c:	83 c2 08             	add    $0x8,%edx
8010472f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104733:	85 c0                	test   %eax,%eax
80104735:	74 25                	je     8010475c <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
80104737:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104740:	83 c2 08             	add    $0x8,%edx
80104743:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104747:	89 04 24             	mov    %eax,(%esp)
8010474a:	e8 51 c8 ff ff       	call   80100fa0 <filedup>
8010474f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104752:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104755:	83 c1 08             	add    $0x8,%ecx
80104758:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010475c:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104760:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104764:	7e bd                	jle    80104723 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104766:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476c:	8b 40 68             	mov    0x68(%eax),%eax
8010476f:	89 04 24             	mov    %eax,(%esp)
80104772:	e8 e3 d0 ff ff       	call   8010185a <idup>
80104777:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010477a:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010477d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104783:	8d 50 6c             	lea    0x6c(%eax),%edx
80104786:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104789:	83 c0 6c             	add    $0x6c,%eax
8010478c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104793:	00 
80104794:	89 54 24 04          	mov    %edx,0x4(%esp)
80104798:	89 04 24             	mov    %eax,(%esp)
8010479b:	e8 0a 0d 00 00       	call   801054aa <safestrcpy>
 
  pid = np->pid;
801047a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a3:	8b 40 10             	mov    0x10(%eax),%eax
801047a6:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801047a9:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047b0:	e8 76 08 00 00       	call   8010502b <acquire>
  np->state = RUNNABLE;
801047b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801047bf:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801047c6:	e8 c2 08 00 00       	call   8010508d <release>
  
  return pid;
801047cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047ce:	83 c4 2c             	add    $0x2c,%esp
801047d1:	5b                   	pop    %ebx
801047d2:	5e                   	pop    %esi
801047d3:	5f                   	pop    %edi
801047d4:	5d                   	pop    %ebp
801047d5:	c3                   	ret    

801047d6 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(int status)
{
801047d6:	55                   	push   %ebp
801047d7:	89 e5                	mov    %esp,%ebp
801047d9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047dc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047e3:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801047e8:	39 c2                	cmp    %eax,%edx
801047ea:	75 0c                	jne    801047f8 <exit+0x22>
    panic("init exiting");
801047ec:	c7 04 24 f8 89 10 80 	movl   $0x801089f8,(%esp)
801047f3:	e8 45 bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801047f8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801047ff:	eb 44                	jmp    80104845 <exit+0x6f>
    if(proc->ofile[fd]){
80104801:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104807:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010480a:	83 c2 08             	add    $0x8,%edx
8010480d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104811:	85 c0                	test   %eax,%eax
80104813:	74 2c                	je     80104841 <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104815:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010481b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010481e:	83 c2 08             	add    $0x8,%edx
80104821:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104825:	89 04 24             	mov    %eax,(%esp)
80104828:	e8 bb c7 ff ff       	call   80100fe8 <fileclose>
      proc->ofile[fd] = 0;
8010482d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104833:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104836:	83 c2 08             	add    $0x8,%edx
80104839:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104840:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104841:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104845:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104849:	7e b6                	jle    80104801 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
8010484b:	e8 29 ec ff ff       	call   80103479 <begin_op>
  iput(proc->cwd);
80104850:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104856:	8b 40 68             	mov    0x68(%eax),%eax
80104859:	89 04 24             	mov    %eax,(%esp)
8010485c:	e8 de d1 ff ff       	call   80101a3f <iput>
  end_op();
80104861:	e8 94 ec ff ff       	call   801034fa <end_op>
  proc->cwd = 0;
80104866:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010486c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  proc->status = status;
80104873:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104879:	8b 55 08             	mov    0x8(%ebp),%edx
8010487c:	89 50 7c             	mov    %edx,0x7c(%eax)
  acquire(&ptable.lock);
8010487f:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104886:	e8 a0 07 00 00       	call   8010502b <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010488b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104891:	8b 40 14             	mov    0x14(%eax),%eax
80104894:	89 04 24             	mov    %eax,(%esp)
80104897:	e8 4d 05 00 00       	call   80104de9 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010489c:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
801048a3:	eb 38                	jmp    801048dd <exit+0x107>
    if(p->parent == proc){
801048a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a8:	8b 50 14             	mov    0x14(%eax),%edx
801048ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b1:	39 c2                	cmp    %eax,%edx
801048b3:	75 24                	jne    801048d9 <exit+0x103>
      p->parent = initproc;
801048b5:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801048bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048be:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c4:	8b 40 0c             	mov    0xc(%eax),%eax
801048c7:	83 f8 05             	cmp    $0x5,%eax
801048ca:	75 0d                	jne    801048d9 <exit+0x103>
        wakeup1(initproc);
801048cc:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048d1:	89 04 24             	mov    %eax,(%esp)
801048d4:	e8 10 05 00 00       	call   80104de9 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048d9:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801048dd:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
801048e4:	72 bf                	jb     801048a5 <exit+0xcf>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801048e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ec:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048f3:	e8 46 03 00 00       	call   80104c3e <sched>
  panic("zombie exit");
801048f8:	c7 04 24 05 8a 10 80 	movl   $0x80108a05,(%esp)
801048ff:	e8 39 bc ff ff       	call   8010053d <panic>

80104904 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(int* status)
{
80104904:	55                   	push   %ebp
80104905:	89 e5                	mov    %esp,%ebp
80104907:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010490a:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104911:	e8 15 07 00 00       	call   8010502b <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104916:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010491d:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104924:	e9 af 00 00 00       	jmp    801049d8 <wait+0xd4>
      if(p->parent != proc)
80104929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010492c:	8b 50 14             	mov    0x14(%eax),%edx
8010492f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104935:	39 c2                	cmp    %eax,%edx
80104937:	0f 85 96 00 00 00    	jne    801049d3 <wait+0xcf>
        continue;
      havekids = 1;
8010493d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104944:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104947:	8b 40 0c             	mov    0xc(%eax),%eax
8010494a:	83 f8 05             	cmp    $0x5,%eax
8010494d:	0f 85 81 00 00 00    	jne    801049d4 <wait+0xd0>
        // Found one.
        pid = p->pid;
80104953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104956:	8b 40 10             	mov    0x10(%eax),%eax
80104959:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
8010495c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010495f:	8b 40 08             	mov    0x8(%eax),%eax
80104962:	89 04 24             	mov    %eax,(%esp)
80104965:	e8 20 e1 ff ff       	call   80102a8a <kfree>
        p->kstack = 0;
8010496a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104974:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104977:	8b 40 04             	mov    0x4(%eax),%eax
8010497a:	89 04 24             	mov    %eax,(%esp)
8010497d:	e8 73 3a 00 00       	call   801083f5 <freevm>
        p->state = UNUSED;
80104982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104985:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
8010498c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010498f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104996:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104999:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a3:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049aa:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

        if(status){ // if user did not send status=0 (do not care)
801049b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801049b5:	74 0b                	je     801049c2 <wait+0xbe>
            *status = p->status; //return status to caller
801049b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ba:	8b 50 7c             	mov    0x7c(%eax),%edx
801049bd:	8b 45 08             	mov    0x8(%ebp),%eax
801049c0:	89 10                	mov    %edx,(%eax)
        }

        release(&ptable.lock);
801049c2:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801049c9:	e8 bf 06 00 00       	call   8010508d <release>

        return pid;
801049ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049d1:	eb 53                	jmp    80104a26 <wait+0x122>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049d3:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049d4:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801049d8:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
801049df:	0f 82 44 ff ff ff    	jb     80104929 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049e9:	74 0d                	je     801049f8 <wait+0xf4>
801049eb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f1:	8b 40 24             	mov    0x24(%eax),%eax
801049f4:	85 c0                	test   %eax,%eax
801049f6:	74 13                	je     80104a0b <wait+0x107>
      release(&ptable.lock);
801049f8:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
801049ff:	e8 89 06 00 00       	call   8010508d <release>
      return -1;
80104a04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a09:	eb 1b                	jmp    80104a26 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104a0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a11:	c7 44 24 04 60 29 11 	movl   $0x80112960,0x4(%esp)
80104a18:	80 
80104a19:	89 04 24             	mov    %eax,(%esp)
80104a1c:	e8 2d 03 00 00       	call   80104d4e <sleep>
  }
80104a21:	e9 f0 fe ff ff       	jmp    80104916 <wait+0x12>
}
80104a26:	c9                   	leave  
80104a27:	c3                   	ret    

80104a28 <waitpid>:

// Wait for a child process *with a specific pid* to exit and return its pid.
// Return -1 if this process has no children.
int
waitpid(int childPid, int* status, int options)
{
80104a28:	55                   	push   %ebp
80104a29:	89 e5                	mov    %esp,%ebp
80104a2b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid, isMyChild;

  acquire(&ptable.lock);
80104a2e:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104a35:	e8 f1 05 00 00       	call   8010502b <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    isMyChild = 0;
80104a41:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a48:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104a4f:	e9 c8 00 00 00       	jmp    80104b1c <waitpid+0xf4>
      if(p->parent != proc)
80104a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a57:	8b 50 14             	mov    0x14(%eax),%edx
80104a5a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a60:	39 c2                	cmp    %eax,%edx
80104a62:	0f 85 af 00 00 00    	jne    80104b17 <waitpid+0xef>
        continue;
      havekids = 1;
80104a68:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if( p->pid == childPid ){
80104a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a72:	8b 40 10             	mov    0x10(%eax),%eax
80104a75:	3b 45 08             	cmp    0x8(%ebp),%eax
80104a78:	0f 85 9a 00 00 00    	jne    80104b18 <waitpid+0xf0>
    	 isMyChild = 1;
80104a7e:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
		 if(p->state == ZOMBIE ){
80104a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a88:	8b 40 0c             	mov    0xc(%eax),%eax
80104a8b:	83 f8 05             	cmp    $0x5,%eax
80104a8e:	0f 85 84 00 00 00    	jne    80104b18 <waitpid+0xf0>
			// Found one.
			pid = p->pid;
80104a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a97:	8b 40 10             	mov    0x10(%eax),%eax
80104a9a:	89 45 e8             	mov    %eax,-0x18(%ebp)
			kfree(p->kstack);
80104a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa0:	8b 40 08             	mov    0x8(%eax),%eax
80104aa3:	89 04 24             	mov    %eax,(%esp)
80104aa6:	e8 df df ff ff       	call   80102a8a <kfree>
			p->kstack = 0;
80104aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
			freevm(p->pgdir);
80104ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab8:	8b 40 04             	mov    0x4(%eax),%eax
80104abb:	89 04 24             	mov    %eax,(%esp)
80104abe:	e8 32 39 00 00       	call   801083f5 <freevm>
			p->state = UNUSED;
80104ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
			p->pid = 0;
80104acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad0:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
			p->parent = 0;
80104ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ada:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
			p->name[0] = 0;
80104ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae4:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
			p->killed = 0;
80104ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aeb:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

			if(status){ // if user did not send status=0 (do not care)
80104af2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104af6:	74 0b                	je     80104b03 <waitpid+0xdb>
				*status = p->status; //return status to caller
80104af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afb:	8b 50 7c             	mov    0x7c(%eax),%edx
80104afe:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b01:	89 10                	mov    %edx,(%eax)
			}

			release(&ptable.lock);
80104b03:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b0a:	e8 7e 05 00 00       	call   8010508d <release>

			return pid;
80104b0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b12:	e9 8c 00 00 00       	jmp    80104ba3 <waitpid+0x17b>
    havekids = 0;
    isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b17:	90                   	nop
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    isMyChild = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b18:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104b1c:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
80104b23:	0f 82 2b ff ff ff    	jb     80104a54 <waitpid+0x2c>
      }

    }

    // No point waiting if we don't have any children.
    if(!havekids || !isMyChild || proc->killed){
80104b29:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b2d:	74 13                	je     80104b42 <waitpid+0x11a>
80104b2f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104b33:	74 0d                	je     80104b42 <waitpid+0x11a>
80104b35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b3b:	8b 40 24             	mov    0x24(%eax),%eax
80104b3e:	85 c0                	test   %eax,%eax
80104b40:	74 13                	je     80104b55 <waitpid+0x12d>
      release(&ptable.lock);
80104b42:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b49:	e8 3f 05 00 00       	call   8010508d <release>
      return -1;
80104b4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b53:	eb 4e                	jmp    80104ba3 <waitpid+0x17b>
    }

    switch (options) {
80104b55:	8b 45 10             	mov    0x10(%ebp),%eax
80104b58:	85 c0                	test   %eax,%eax
80104b5a:	74 07                	je     80104b63 <waitpid+0x13b>
80104b5c:	83 f8 01             	cmp    $0x1,%eax
80104b5f:	74 1e                	je     80104b7f <waitpid+0x157>
80104b61:	eb 2f                	jmp    80104b92 <waitpid+0x16a>
		case BLOCKING:
			sleep(proc, &ptable.lock);
80104b63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b69:	c7 44 24 04 60 29 11 	movl   $0x80112960,0x4(%esp)
80104b70:	80 
80104b71:	89 04 24             	mov    %eax,(%esp)
80104b74:	e8 d5 01 00 00       	call   80104d4e <sleep>
			break;
80104b79:	90                   	nop
			release(&ptable.lock);
			return -1;
			break;
	}

  }
80104b7a:	e9 bb fe ff ff       	jmp    80104a3a <waitpid+0x12>
    switch (options) {
		case BLOCKING:
			sleep(proc, &ptable.lock);
			break;
		case NONBLOCKING:
			release(&ptable.lock);
80104b7f:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b86:	e8 02 05 00 00       	call   8010508d <release>
			return -1;
80104b8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b90:	eb 11                	jmp    80104ba3 <waitpid+0x17b>
			break;
		default:
			release(&ptable.lock);
80104b92:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104b99:	e8 ef 04 00 00       	call   8010508d <release>
			return -1;
80104b9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
			break;
	}

  }
}
80104ba3:	c9                   	leave  
80104ba4:	c3                   	ret    

80104ba5 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104ba5:	55                   	push   %ebp
80104ba6:	89 e5                	mov    %esp,%ebp
80104ba8:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104bab:	e8 c5 f7 ff ff       	call   80104375 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104bb0:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104bb7:	e8 6f 04 00 00       	call   8010502b <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bbc:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104bc3:	eb 5f                	jmp    80104c24 <scheduler+0x7f>
      if(p->state != RUNNABLE)
80104bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc8:	8b 40 0c             	mov    0xc(%eax),%eax
80104bcb:	83 f8 03             	cmp    $0x3,%eax
80104bce:	75 4f                	jne    80104c1f <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd3:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdc:	89 04 24             	mov    %eax,(%esp)
80104bdf:	e8 9a 33 00 00       	call   80107f7e <switchuvm>
      p->state = RUNNING;
80104be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be7:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104bee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf4:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bf7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bfe:	83 c2 04             	add    $0x4,%edx
80104c01:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c05:	89 14 24             	mov    %edx,(%esp)
80104c08:	e8 13 09 00 00       	call   80105520 <swtch>
      switchkvm();
80104c0d:	e8 4f 33 00 00       	call   80107f61 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c12:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c19:	00 00 00 00 
80104c1d:	eb 01                	jmp    80104c20 <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104c1f:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c20:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104c24:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
80104c2b:	72 98                	jb     80104bc5 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104c2d:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c34:	e8 54 04 00 00       	call   8010508d <release>

  }
80104c39:	e9 6d ff ff ff       	jmp    80104bab <scheduler+0x6>

80104c3e <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c3e:	55                   	push   %ebp
80104c3f:	89 e5                	mov    %esp,%ebp
80104c41:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c44:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104c4b:	e8 f9 04 00 00       	call   80105149 <holding>
80104c50:	85 c0                	test   %eax,%eax
80104c52:	75 0c                	jne    80104c60 <sched+0x22>
    panic("sched ptable.lock");
80104c54:	c7 04 24 11 8a 10 80 	movl   $0x80108a11,(%esp)
80104c5b:	e8 dd b8 ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104c60:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c66:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c6c:	83 f8 01             	cmp    $0x1,%eax
80104c6f:	74 0c                	je     80104c7d <sched+0x3f>
    panic("sched locks");
80104c71:	c7 04 24 23 8a 10 80 	movl   $0x80108a23,(%esp)
80104c78:	e8 c0 b8 ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104c7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c83:	8b 40 0c             	mov    0xc(%eax),%eax
80104c86:	83 f8 04             	cmp    $0x4,%eax
80104c89:	75 0c                	jne    80104c97 <sched+0x59>
    panic("sched running");
80104c8b:	c7 04 24 2f 8a 10 80 	movl   $0x80108a2f,(%esp)
80104c92:	e8 a6 b8 ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104c97:	e8 c4 f6 ff ff       	call   80104360 <readeflags>
80104c9c:	25 00 02 00 00       	and    $0x200,%eax
80104ca1:	85 c0                	test   %eax,%eax
80104ca3:	74 0c                	je     80104cb1 <sched+0x73>
    panic("sched interruptible");
80104ca5:	c7 04 24 3d 8a 10 80 	movl   $0x80108a3d,(%esp)
80104cac:	e8 8c b8 ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104cb1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cb7:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104cbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104cc0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cc6:	8b 40 04             	mov    0x4(%eax),%eax
80104cc9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cd0:	83 c2 1c             	add    $0x1c,%edx
80104cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cd7:	89 14 24             	mov    %edx,(%esp)
80104cda:	e8 41 08 00 00       	call   80105520 <swtch>
  cpu->intena = intena;
80104cdf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ce5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ce8:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104cee:	c9                   	leave  
80104cef:	c3                   	ret    

80104cf0 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104cf0:	55                   	push   %ebp
80104cf1:	89 e5                	mov    %esp,%ebp
80104cf3:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104cf6:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104cfd:	e8 29 03 00 00       	call   8010502b <acquire>
  proc->state = RUNNABLE;
80104d02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d08:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d0f:	e8 2a ff ff ff       	call   80104c3e <sched>
  release(&ptable.lock);
80104d14:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d1b:	e8 6d 03 00 00       	call   8010508d <release>
}
80104d20:	c9                   	leave  
80104d21:	c3                   	ret    

80104d22 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d22:	55                   	push   %ebp
80104d23:	89 e5                	mov    %esp,%ebp
80104d25:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d28:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d2f:	e8 59 03 00 00       	call   8010508d <release>

  if (first) {
80104d34:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104d39:	85 c0                	test   %eax,%eax
80104d3b:	74 0f                	je     80104d4c <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d3d:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
80104d44:	00 00 00 
    initlog();
80104d47:	e8 20 e5 ff ff       	call   8010326c <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d4c:	c9                   	leave  
80104d4d:	c3                   	ret    

80104d4e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d4e:	55                   	push   %ebp
80104d4f:	89 e5                	mov    %esp,%ebp
80104d51:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104d54:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d5a:	85 c0                	test   %eax,%eax
80104d5c:	75 0c                	jne    80104d6a <sleep+0x1c>
    panic("sleep");
80104d5e:	c7 04 24 51 8a 10 80 	movl   $0x80108a51,(%esp)
80104d65:	e8 d3 b7 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104d6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d6e:	75 0c                	jne    80104d7c <sleep+0x2e>
    panic("sleep without lk");
80104d70:	c7 04 24 57 8a 10 80 	movl   $0x80108a57,(%esp)
80104d77:	e8 c1 b7 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d7c:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104d83:	74 17                	je     80104d9c <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d85:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104d8c:	e8 9a 02 00 00       	call   8010502b <acquire>
    release(lk);
80104d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d94:	89 04 24             	mov    %eax,(%esp)
80104d97:	e8 f1 02 00 00       	call   8010508d <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104d9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da2:	8b 55 08             	mov    0x8(%ebp),%edx
80104da5:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104da8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dae:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104db5:	e8 84 fe ff ff       	call   80104c3e <sched>

  // Tidy up.
  proc->chan = 0;
80104dba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc0:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104dc7:	81 7d 0c 60 29 11 80 	cmpl   $0x80112960,0xc(%ebp)
80104dce:	74 17                	je     80104de7 <sleep+0x99>
    release(&ptable.lock);
80104dd0:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104dd7:	e8 b1 02 00 00       	call   8010508d <release>
    acquire(lk);
80104ddc:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ddf:	89 04 24             	mov    %eax,(%esp)
80104de2:	e8 44 02 00 00       	call   8010502b <acquire>
  }
}
80104de7:	c9                   	leave  
80104de8:	c3                   	ret    

80104de9 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104de9:	55                   	push   %ebp
80104dea:	89 e5                	mov    %esp,%ebp
80104dec:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104def:	c7 45 fc 94 29 11 80 	movl   $0x80112994,-0x4(%ebp)
80104df6:	eb 24                	jmp    80104e1c <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104df8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104dfb:	8b 40 0c             	mov    0xc(%eax),%eax
80104dfe:	83 f8 02             	cmp    $0x2,%eax
80104e01:	75 15                	jne    80104e18 <wakeup1+0x2f>
80104e03:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e06:	8b 40 20             	mov    0x20(%eax),%eax
80104e09:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e0c:	75 0a                	jne    80104e18 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e11:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e18:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
80104e1c:	81 7d fc 94 49 11 80 	cmpl   $0x80114994,-0x4(%ebp)
80104e23:	72 d3                	jb     80104df8 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104e25:	c9                   	leave  
80104e26:	c3                   	ret    

80104e27 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e27:	55                   	push   %ebp
80104e28:	89 e5                	mov    %esp,%ebp
80104e2a:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104e2d:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e34:	e8 f2 01 00 00       	call   8010502b <acquire>
  wakeup1(chan);
80104e39:	8b 45 08             	mov    0x8(%ebp),%eax
80104e3c:	89 04 24             	mov    %eax,(%esp)
80104e3f:	e8 a5 ff ff ff       	call   80104de9 <wakeup1>
  release(&ptable.lock);
80104e44:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e4b:	e8 3d 02 00 00       	call   8010508d <release>
}
80104e50:	c9                   	leave  
80104e51:	c3                   	ret    

80104e52 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e52:	55                   	push   %ebp
80104e53:	89 e5                	mov    %esp,%ebp
80104e55:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e58:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e5f:	e8 c7 01 00 00       	call   8010502b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e64:	c7 45 f4 94 29 11 80 	movl   $0x80112994,-0xc(%ebp)
80104e6b:	eb 41                	jmp    80104eae <kill+0x5c>
    if(p->pid == pid){
80104e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e70:	8b 40 10             	mov    0x10(%eax),%eax
80104e73:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e76:	75 32                	jne    80104eaa <kill+0x58>
      p->killed = 1;
80104e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e85:	8b 40 0c             	mov    0xc(%eax),%eax
80104e88:	83 f8 02             	cmp    $0x2,%eax
80104e8b:	75 0a                	jne    80104e97 <kill+0x45>
        p->state = RUNNABLE;
80104e8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e90:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104e97:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104e9e:	e8 ea 01 00 00       	call   8010508d <release>
      return 0;
80104ea3:	b8 00 00 00 00       	mov    $0x0,%eax
80104ea8:	eb 1e                	jmp    80104ec8 <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104eaa:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104eae:	81 7d f4 94 49 11 80 	cmpl   $0x80114994,-0xc(%ebp)
80104eb5:	72 b6                	jb     80104e6d <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104eb7:	c7 04 24 60 29 11 80 	movl   $0x80112960,(%esp)
80104ebe:	e8 ca 01 00 00       	call   8010508d <release>
  return -1;
80104ec3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ec8:	c9                   	leave  
80104ec9:	c3                   	ret    

80104eca <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104eca:	55                   	push   %ebp
80104ecb:	89 e5                	mov    %esp,%ebp
80104ecd:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ed0:	c7 45 f0 94 29 11 80 	movl   $0x80112994,-0x10(%ebp)
80104ed7:	e9 d8 00 00 00       	jmp    80104fb4 <procdump+0xea>
    if(p->state == UNUSED)
80104edc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104edf:	8b 40 0c             	mov    0xc(%eax),%eax
80104ee2:	85 c0                	test   %eax,%eax
80104ee4:	0f 84 c5 00 00 00    	je     80104faf <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eed:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef0:	83 f8 05             	cmp    $0x5,%eax
80104ef3:	77 23                	ja     80104f18 <procdump+0x4e>
80104ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef8:	8b 40 0c             	mov    0xc(%eax),%eax
80104efb:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104f02:	85 c0                	test   %eax,%eax
80104f04:	74 12                	je     80104f18 <procdump+0x4e>
      state = states[p->state];
80104f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f09:	8b 40 0c             	mov    0xc(%eax),%eax
80104f0c:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104f13:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f16:	eb 07                	jmp    80104f1f <procdump+0x55>
    else
      state = "???";
80104f18:	c7 45 ec 68 8a 10 80 	movl   $0x80108a68,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f22:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f28:	8b 40 10             	mov    0x10(%eax),%eax
80104f2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104f2f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f32:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f36:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f3a:	c7 04 24 6c 8a 10 80 	movl   $0x80108a6c,(%esp)
80104f41:	e8 5b b4 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f49:	8b 40 0c             	mov    0xc(%eax),%eax
80104f4c:	83 f8 02             	cmp    $0x2,%eax
80104f4f:	75 50                	jne    80104fa1 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f54:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f57:	8b 40 0c             	mov    0xc(%eax),%eax
80104f5a:	83 c0 08             	add    $0x8,%eax
80104f5d:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104f60:	89 54 24 04          	mov    %edx,0x4(%esp)
80104f64:	89 04 24             	mov    %eax,(%esp)
80104f67:	e8 70 01 00 00       	call   801050dc <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104f6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f73:	eb 1b                	jmp    80104f90 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f78:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f80:	c7 04 24 75 8a 10 80 	movl   $0x80108a75,(%esp)
80104f87:	e8 15 b4 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104f8c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f90:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104f94:	7f 0b                	jg     80104fa1 <procdump+0xd7>
80104f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f99:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f9d:	85 c0                	test   %eax,%eax
80104f9f:	75 d4                	jne    80104f75 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104fa1:	c7 04 24 79 8a 10 80 	movl   $0x80108a79,(%esp)
80104fa8:	e8 f4 b3 ff ff       	call   801003a1 <cprintf>
80104fad:	eb 01                	jmp    80104fb0 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104faf:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fb0:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
80104fb4:	81 7d f0 94 49 11 80 	cmpl   $0x80114994,-0x10(%ebp)
80104fbb:	0f 82 1b ff ff ff    	jb     80104edc <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104fc1:	c9                   	leave  
80104fc2:	c3                   	ret    
	...

80104fc4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104fc4:	55                   	push   %ebp
80104fc5:	89 e5                	mov    %esp,%ebp
80104fc7:	53                   	push   %ebx
80104fc8:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104fcb:	9c                   	pushf  
80104fcc:	5b                   	pop    %ebx
80104fcd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104fd0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104fd3:	83 c4 10             	add    $0x10,%esp
80104fd6:	5b                   	pop    %ebx
80104fd7:	5d                   	pop    %ebp
80104fd8:	c3                   	ret    

80104fd9 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104fd9:	55                   	push   %ebp
80104fda:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104fdc:	fa                   	cli    
}
80104fdd:	5d                   	pop    %ebp
80104fde:	c3                   	ret    

80104fdf <sti>:

static inline void
sti(void)
{
80104fdf:	55                   	push   %ebp
80104fe0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104fe2:	fb                   	sti    
}
80104fe3:	5d                   	pop    %ebp
80104fe4:	c3                   	ret    

80104fe5 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104fe5:	55                   	push   %ebp
80104fe6:	89 e5                	mov    %esp,%ebp
80104fe8:	53                   	push   %ebx
80104fe9:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104fec:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104fef:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104ff2:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104ff5:	89 c3                	mov    %eax,%ebx
80104ff7:	89 d8                	mov    %ebx,%eax
80104ff9:	f0 87 02             	lock xchg %eax,(%edx)
80104ffc:	89 c3                	mov    %eax,%ebx
80104ffe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105001:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105004:	83 c4 10             	add    $0x10,%esp
80105007:	5b                   	pop    %ebx
80105008:	5d                   	pop    %ebp
80105009:	c3                   	ret    

8010500a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010500a:	55                   	push   %ebp
8010500b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010500d:	8b 45 08             	mov    0x8(%ebp),%eax
80105010:	8b 55 0c             	mov    0xc(%ebp),%edx
80105013:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105016:	8b 45 08             	mov    0x8(%ebp),%eax
80105019:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010501f:	8b 45 08             	mov    0x8(%ebp),%eax
80105022:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105029:	5d                   	pop    %ebp
8010502a:	c3                   	ret    

8010502b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010502b:	55                   	push   %ebp
8010502c:	89 e5                	mov    %esp,%ebp
8010502e:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105031:	e8 3d 01 00 00       	call   80105173 <pushcli>
  if(holding(lk))
80105036:	8b 45 08             	mov    0x8(%ebp),%eax
80105039:	89 04 24             	mov    %eax,(%esp)
8010503c:	e8 08 01 00 00       	call   80105149 <holding>
80105041:	85 c0                	test   %eax,%eax
80105043:	74 0c                	je     80105051 <acquire+0x26>
    panic("acquire");
80105045:	c7 04 24 a5 8a 10 80 	movl   $0x80108aa5,(%esp)
8010504c:	e8 ec b4 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105051:	90                   	nop
80105052:	8b 45 08             	mov    0x8(%ebp),%eax
80105055:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010505c:	00 
8010505d:	89 04 24             	mov    %eax,(%esp)
80105060:	e8 80 ff ff ff       	call   80104fe5 <xchg>
80105065:	85 c0                	test   %eax,%eax
80105067:	75 e9                	jne    80105052 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105069:	8b 45 08             	mov    0x8(%ebp),%eax
8010506c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105073:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105076:	8b 45 08             	mov    0x8(%ebp),%eax
80105079:	83 c0 0c             	add    $0xc,%eax
8010507c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105080:	8d 45 08             	lea    0x8(%ebp),%eax
80105083:	89 04 24             	mov    %eax,(%esp)
80105086:	e8 51 00 00 00       	call   801050dc <getcallerpcs>
}
8010508b:	c9                   	leave  
8010508c:	c3                   	ret    

8010508d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010508d:	55                   	push   %ebp
8010508e:	89 e5                	mov    %esp,%ebp
80105090:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105093:	8b 45 08             	mov    0x8(%ebp),%eax
80105096:	89 04 24             	mov    %eax,(%esp)
80105099:	e8 ab 00 00 00       	call   80105149 <holding>
8010509e:	85 c0                	test   %eax,%eax
801050a0:	75 0c                	jne    801050ae <release+0x21>
    panic("release");
801050a2:	c7 04 24 ad 8a 10 80 	movl   $0x80108aad,(%esp)
801050a9:	e8 8f b4 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
801050ae:	8b 45 08             	mov    0x8(%ebp),%eax
801050b1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050b8:	8b 45 08             	mov    0x8(%ebp),%eax
801050bb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801050c2:	8b 45 08             	mov    0x8(%ebp),%eax
801050c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801050cc:	00 
801050cd:	89 04 24             	mov    %eax,(%esp)
801050d0:	e8 10 ff ff ff       	call   80104fe5 <xchg>

  popcli();
801050d5:	e8 e1 00 00 00       	call   801051bb <popcli>
}
801050da:	c9                   	leave  
801050db:	c3                   	ret    

801050dc <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801050dc:	55                   	push   %ebp
801050dd:	89 e5                	mov    %esp,%ebp
801050df:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801050e2:	8b 45 08             	mov    0x8(%ebp),%eax
801050e5:	83 e8 08             	sub    $0x8,%eax
801050e8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801050eb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801050f2:	eb 32                	jmp    80105126 <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801050f4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801050f8:	74 47                	je     80105141 <getcallerpcs+0x65>
801050fa:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105101:	76 3e                	jbe    80105141 <getcallerpcs+0x65>
80105103:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105107:	74 38                	je     80105141 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105109:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010510c:	c1 e0 02             	shl    $0x2,%eax
8010510f:	03 45 0c             	add    0xc(%ebp),%eax
80105112:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105115:	8b 52 04             	mov    0x4(%edx),%edx
80105118:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
8010511a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010511d:	8b 00                	mov    (%eax),%eax
8010511f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105122:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105126:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010512a:	7e c8                	jle    801050f4 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010512c:	eb 13                	jmp    80105141 <getcallerpcs+0x65>
    pcs[i] = 0;
8010512e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105131:	c1 e0 02             	shl    $0x2,%eax
80105134:	03 45 0c             	add    0xc(%ebp),%eax
80105137:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010513d:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105141:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105145:	7e e7                	jle    8010512e <getcallerpcs+0x52>
    pcs[i] = 0;
}
80105147:	c9                   	leave  
80105148:	c3                   	ret    

80105149 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105149:	55                   	push   %ebp
8010514a:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010514c:	8b 45 08             	mov    0x8(%ebp),%eax
8010514f:	8b 00                	mov    (%eax),%eax
80105151:	85 c0                	test   %eax,%eax
80105153:	74 17                	je     8010516c <holding+0x23>
80105155:	8b 45 08             	mov    0x8(%ebp),%eax
80105158:	8b 50 08             	mov    0x8(%eax),%edx
8010515b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105161:	39 c2                	cmp    %eax,%edx
80105163:	75 07                	jne    8010516c <holding+0x23>
80105165:	b8 01 00 00 00       	mov    $0x1,%eax
8010516a:	eb 05                	jmp    80105171 <holding+0x28>
8010516c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105171:	5d                   	pop    %ebp
80105172:	c3                   	ret    

80105173 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105173:	55                   	push   %ebp
80105174:	89 e5                	mov    %esp,%ebp
80105176:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105179:	e8 46 fe ff ff       	call   80104fc4 <readeflags>
8010517e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105181:	e8 53 fe ff ff       	call   80104fd9 <cli>
  if(cpu->ncli++ == 0)
80105186:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010518c:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105192:	85 d2                	test   %edx,%edx
80105194:	0f 94 c1             	sete   %cl
80105197:	83 c2 01             	add    $0x1,%edx
8010519a:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801051a0:	84 c9                	test   %cl,%cl
801051a2:	74 15                	je     801051b9 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
801051a4:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051aa:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051ad:	81 e2 00 02 00 00    	and    $0x200,%edx
801051b3:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801051b9:	c9                   	leave  
801051ba:	c3                   	ret    

801051bb <popcli>:

void
popcli(void)
{
801051bb:	55                   	push   %ebp
801051bc:	89 e5                	mov    %esp,%ebp
801051be:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801051c1:	e8 fe fd ff ff       	call   80104fc4 <readeflags>
801051c6:	25 00 02 00 00       	and    $0x200,%eax
801051cb:	85 c0                	test   %eax,%eax
801051cd:	74 0c                	je     801051db <popcli+0x20>
    panic("popcli - interruptible");
801051cf:	c7 04 24 b5 8a 10 80 	movl   $0x80108ab5,(%esp)
801051d6:	e8 62 b3 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
801051db:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051e1:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801051e7:	83 ea 01             	sub    $0x1,%edx
801051ea:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801051f0:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801051f6:	85 c0                	test   %eax,%eax
801051f8:	79 0c                	jns    80105206 <popcli+0x4b>
    panic("popcli");
801051fa:	c7 04 24 cc 8a 10 80 	movl   $0x80108acc,(%esp)
80105201:	e8 37 b3 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105206:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010520c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105212:	85 c0                	test   %eax,%eax
80105214:	75 15                	jne    8010522b <popcli+0x70>
80105216:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010521c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105222:	85 c0                	test   %eax,%eax
80105224:	74 05                	je     8010522b <popcli+0x70>
    sti();
80105226:	e8 b4 fd ff ff       	call   80104fdf <sti>
}
8010522b:	c9                   	leave  
8010522c:	c3                   	ret    
8010522d:	00 00                	add    %al,(%eax)
	...

80105230 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105230:	55                   	push   %ebp
80105231:	89 e5                	mov    %esp,%ebp
80105233:	57                   	push   %edi
80105234:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105235:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105238:	8b 55 10             	mov    0x10(%ebp),%edx
8010523b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010523e:	89 cb                	mov    %ecx,%ebx
80105240:	89 df                	mov    %ebx,%edi
80105242:	89 d1                	mov    %edx,%ecx
80105244:	fc                   	cld    
80105245:	f3 aa                	rep stos %al,%es:(%edi)
80105247:	89 ca                	mov    %ecx,%edx
80105249:	89 fb                	mov    %edi,%ebx
8010524b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010524e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105251:	5b                   	pop    %ebx
80105252:	5f                   	pop    %edi
80105253:	5d                   	pop    %ebp
80105254:	c3                   	ret    

80105255 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105255:	55                   	push   %ebp
80105256:	89 e5                	mov    %esp,%ebp
80105258:	57                   	push   %edi
80105259:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010525a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010525d:	8b 55 10             	mov    0x10(%ebp),%edx
80105260:	8b 45 0c             	mov    0xc(%ebp),%eax
80105263:	89 cb                	mov    %ecx,%ebx
80105265:	89 df                	mov    %ebx,%edi
80105267:	89 d1                	mov    %edx,%ecx
80105269:	fc                   	cld    
8010526a:	f3 ab                	rep stos %eax,%es:(%edi)
8010526c:	89 ca                	mov    %ecx,%edx
8010526e:	89 fb                	mov    %edi,%ebx
80105270:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105273:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105276:	5b                   	pop    %ebx
80105277:	5f                   	pop    %edi
80105278:	5d                   	pop    %ebp
80105279:	c3                   	ret    

8010527a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010527a:	55                   	push   %ebp
8010527b:	89 e5                	mov    %esp,%ebp
8010527d:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105280:	8b 45 08             	mov    0x8(%ebp),%eax
80105283:	83 e0 03             	and    $0x3,%eax
80105286:	85 c0                	test   %eax,%eax
80105288:	75 49                	jne    801052d3 <memset+0x59>
8010528a:	8b 45 10             	mov    0x10(%ebp),%eax
8010528d:	83 e0 03             	and    $0x3,%eax
80105290:	85 c0                	test   %eax,%eax
80105292:	75 3f                	jne    801052d3 <memset+0x59>
    c &= 0xFF;
80105294:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010529b:	8b 45 10             	mov    0x10(%ebp),%eax
8010529e:	c1 e8 02             	shr    $0x2,%eax
801052a1:	89 c2                	mov    %eax,%edx
801052a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a6:	89 c1                	mov    %eax,%ecx
801052a8:	c1 e1 18             	shl    $0x18,%ecx
801052ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ae:	c1 e0 10             	shl    $0x10,%eax
801052b1:	09 c1                	or     %eax,%ecx
801052b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801052b6:	c1 e0 08             	shl    $0x8,%eax
801052b9:	09 c8                	or     %ecx,%eax
801052bb:	0b 45 0c             	or     0xc(%ebp),%eax
801052be:	89 54 24 08          	mov    %edx,0x8(%esp)
801052c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801052c6:	8b 45 08             	mov    0x8(%ebp),%eax
801052c9:	89 04 24             	mov    %eax,(%esp)
801052cc:	e8 84 ff ff ff       	call   80105255 <stosl>
801052d1:	eb 19                	jmp    801052ec <memset+0x72>
  } else
    stosb(dst, c, n);
801052d3:	8b 45 10             	mov    0x10(%ebp),%eax
801052d6:	89 44 24 08          	mov    %eax,0x8(%esp)
801052da:	8b 45 0c             	mov    0xc(%ebp),%eax
801052dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801052e1:	8b 45 08             	mov    0x8(%ebp),%eax
801052e4:	89 04 24             	mov    %eax,(%esp)
801052e7:	e8 44 ff ff ff       	call   80105230 <stosb>
  return dst;
801052ec:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052ef:	c9                   	leave  
801052f0:	c3                   	ret    

801052f1 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801052f1:	55                   	push   %ebp
801052f2:	89 e5                	mov    %esp,%ebp
801052f4:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801052f7:	8b 45 08             	mov    0x8(%ebp),%eax
801052fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801052fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105300:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105303:	eb 32                	jmp    80105337 <memcmp+0x46>
    if(*s1 != *s2)
80105305:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105308:	0f b6 10             	movzbl (%eax),%edx
8010530b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010530e:	0f b6 00             	movzbl (%eax),%eax
80105311:	38 c2                	cmp    %al,%dl
80105313:	74 1a                	je     8010532f <memcmp+0x3e>
      return *s1 - *s2;
80105315:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105318:	0f b6 00             	movzbl (%eax),%eax
8010531b:	0f b6 d0             	movzbl %al,%edx
8010531e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105321:	0f b6 00             	movzbl (%eax),%eax
80105324:	0f b6 c0             	movzbl %al,%eax
80105327:	89 d1                	mov    %edx,%ecx
80105329:	29 c1                	sub    %eax,%ecx
8010532b:	89 c8                	mov    %ecx,%eax
8010532d:	eb 1c                	jmp    8010534b <memcmp+0x5a>
    s1++, s2++;
8010532f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105333:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105337:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010533b:	0f 95 c0             	setne  %al
8010533e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105342:	84 c0                	test   %al,%al
80105344:	75 bf                	jne    80105305 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105346:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010534b:	c9                   	leave  
8010534c:	c3                   	ret    

8010534d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010534d:	55                   	push   %ebp
8010534e:	89 e5                	mov    %esp,%ebp
80105350:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105353:	8b 45 0c             	mov    0xc(%ebp),%eax
80105356:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105359:	8b 45 08             	mov    0x8(%ebp),%eax
8010535c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010535f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105362:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105365:	73 54                	jae    801053bb <memmove+0x6e>
80105367:	8b 45 10             	mov    0x10(%ebp),%eax
8010536a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010536d:	01 d0                	add    %edx,%eax
8010536f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105372:	76 47                	jbe    801053bb <memmove+0x6e>
    s += n;
80105374:	8b 45 10             	mov    0x10(%ebp),%eax
80105377:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010537a:	8b 45 10             	mov    0x10(%ebp),%eax
8010537d:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105380:	eb 13                	jmp    80105395 <memmove+0x48>
      *--d = *--s;
80105382:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105386:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010538a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010538d:	0f b6 10             	movzbl (%eax),%edx
80105390:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105393:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105395:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105399:	0f 95 c0             	setne  %al
8010539c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053a0:	84 c0                	test   %al,%al
801053a2:	75 de                	jne    80105382 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801053a4:	eb 25                	jmp    801053cb <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
801053a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053a9:	0f b6 10             	movzbl (%eax),%edx
801053ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053af:	88 10                	mov    %dl,(%eax)
801053b1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801053b5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801053b9:	eb 01                	jmp    801053bc <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053bb:	90                   	nop
801053bc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053c0:	0f 95 c0             	setne  %al
801053c3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053c7:	84 c0                	test   %al,%al
801053c9:	75 db                	jne    801053a6 <memmove+0x59>
      *d++ = *s++;

  return dst;
801053cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053ce:	c9                   	leave  
801053cf:	c3                   	ret    

801053d0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053d0:	55                   	push   %ebp
801053d1:	89 e5                	mov    %esp,%ebp
801053d3:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801053d6:	8b 45 10             	mov    0x10(%ebp),%eax
801053d9:	89 44 24 08          	mov    %eax,0x8(%esp)
801053dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801053e4:	8b 45 08             	mov    0x8(%ebp),%eax
801053e7:	89 04 24             	mov    %eax,(%esp)
801053ea:	e8 5e ff ff ff       	call   8010534d <memmove>
}
801053ef:	c9                   	leave  
801053f0:	c3                   	ret    

801053f1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801053f1:	55                   	push   %ebp
801053f2:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801053f4:	eb 0c                	jmp    80105402 <strncmp+0x11>
    n--, p++, q++;
801053f6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801053fe:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105402:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105406:	74 1a                	je     80105422 <strncmp+0x31>
80105408:	8b 45 08             	mov    0x8(%ebp),%eax
8010540b:	0f b6 00             	movzbl (%eax),%eax
8010540e:	84 c0                	test   %al,%al
80105410:	74 10                	je     80105422 <strncmp+0x31>
80105412:	8b 45 08             	mov    0x8(%ebp),%eax
80105415:	0f b6 10             	movzbl (%eax),%edx
80105418:	8b 45 0c             	mov    0xc(%ebp),%eax
8010541b:	0f b6 00             	movzbl (%eax),%eax
8010541e:	38 c2                	cmp    %al,%dl
80105420:	74 d4                	je     801053f6 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105422:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105426:	75 07                	jne    8010542f <strncmp+0x3e>
    return 0;
80105428:	b8 00 00 00 00       	mov    $0x0,%eax
8010542d:	eb 18                	jmp    80105447 <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
8010542f:	8b 45 08             	mov    0x8(%ebp),%eax
80105432:	0f b6 00             	movzbl (%eax),%eax
80105435:	0f b6 d0             	movzbl %al,%edx
80105438:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543b:	0f b6 00             	movzbl (%eax),%eax
8010543e:	0f b6 c0             	movzbl %al,%eax
80105441:	89 d1                	mov    %edx,%ecx
80105443:	29 c1                	sub    %eax,%ecx
80105445:	89 c8                	mov    %ecx,%eax
}
80105447:	5d                   	pop    %ebp
80105448:	c3                   	ret    

80105449 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105449:	55                   	push   %ebp
8010544a:	89 e5                	mov    %esp,%ebp
8010544c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010544f:	8b 45 08             	mov    0x8(%ebp),%eax
80105452:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105455:	90                   	nop
80105456:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010545a:	0f 9f c0             	setg   %al
8010545d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105461:	84 c0                	test   %al,%al
80105463:	74 30                	je     80105495 <strncpy+0x4c>
80105465:	8b 45 0c             	mov    0xc(%ebp),%eax
80105468:	0f b6 10             	movzbl (%eax),%edx
8010546b:	8b 45 08             	mov    0x8(%ebp),%eax
8010546e:	88 10                	mov    %dl,(%eax)
80105470:	8b 45 08             	mov    0x8(%ebp),%eax
80105473:	0f b6 00             	movzbl (%eax),%eax
80105476:	84 c0                	test   %al,%al
80105478:	0f 95 c0             	setne  %al
8010547b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010547f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80105483:	84 c0                	test   %al,%al
80105485:	75 cf                	jne    80105456 <strncpy+0xd>
    ;
  while(n-- > 0)
80105487:	eb 0c                	jmp    80105495 <strncpy+0x4c>
    *s++ = 0;
80105489:	8b 45 08             	mov    0x8(%ebp),%eax
8010548c:	c6 00 00             	movb   $0x0,(%eax)
8010548f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105493:	eb 01                	jmp    80105496 <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105495:	90                   	nop
80105496:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010549a:	0f 9f c0             	setg   %al
8010549d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054a1:	84 c0                	test   %al,%al
801054a3:	75 e4                	jne    80105489 <strncpy+0x40>
    *s++ = 0;
  return os;
801054a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054a8:	c9                   	leave  
801054a9:	c3                   	ret    

801054aa <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054aa:	55                   	push   %ebp
801054ab:	89 e5                	mov    %esp,%ebp
801054ad:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054b0:	8b 45 08             	mov    0x8(%ebp),%eax
801054b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054ba:	7f 05                	jg     801054c1 <safestrcpy+0x17>
    return os;
801054bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054bf:	eb 35                	jmp    801054f6 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801054c1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054c9:	7e 22                	jle    801054ed <safestrcpy+0x43>
801054cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ce:	0f b6 10             	movzbl (%eax),%edx
801054d1:	8b 45 08             	mov    0x8(%ebp),%eax
801054d4:	88 10                	mov    %dl,(%eax)
801054d6:	8b 45 08             	mov    0x8(%ebp),%eax
801054d9:	0f b6 00             	movzbl (%eax),%eax
801054dc:	84 c0                	test   %al,%al
801054de:	0f 95 c0             	setne  %al
801054e1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801054e5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801054e9:	84 c0                	test   %al,%al
801054eb:	75 d4                	jne    801054c1 <safestrcpy+0x17>
    ;
  *s = 0;
801054ed:	8b 45 08             	mov    0x8(%ebp),%eax
801054f0:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801054f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054f6:	c9                   	leave  
801054f7:	c3                   	ret    

801054f8 <strlen>:

int
strlen(const char *s)
{
801054f8:	55                   	push   %ebp
801054f9:	89 e5                	mov    %esp,%ebp
801054fb:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801054fe:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105505:	eb 04                	jmp    8010550b <strlen+0x13>
80105507:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010550b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010550e:	03 45 08             	add    0x8(%ebp),%eax
80105511:	0f b6 00             	movzbl (%eax),%eax
80105514:	84 c0                	test   %al,%al
80105516:	75 ef                	jne    80105507 <strlen+0xf>
    ;
  return n;
80105518:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010551b:	c9                   	leave  
8010551c:	c3                   	ret    
8010551d:	00 00                	add    %al,(%eax)
	...

80105520 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105520:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105524:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105528:	55                   	push   %ebp
  pushl %ebx
80105529:	53                   	push   %ebx
  pushl %esi
8010552a:	56                   	push   %esi
  pushl %edi
8010552b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010552c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010552e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105530:	5f                   	pop    %edi
  popl %esi
80105531:	5e                   	pop    %esi
  popl %ebx
80105532:	5b                   	pop    %ebx
  popl %ebp
80105533:	5d                   	pop    %ebp
  ret
80105534:	c3                   	ret    
80105535:	00 00                	add    %al,(%eax)
	...

80105538 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105538:	55                   	push   %ebp
80105539:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010553b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105541:	8b 00                	mov    (%eax),%eax
80105543:	3b 45 08             	cmp    0x8(%ebp),%eax
80105546:	76 12                	jbe    8010555a <fetchint+0x22>
80105548:	8b 45 08             	mov    0x8(%ebp),%eax
8010554b:	8d 50 04             	lea    0x4(%eax),%edx
8010554e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105554:	8b 00                	mov    (%eax),%eax
80105556:	39 c2                	cmp    %eax,%edx
80105558:	76 07                	jbe    80105561 <fetchint+0x29>
    return -1;
8010555a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010555f:	eb 0f                	jmp    80105570 <fetchint+0x38>
  *ip = *(int*)(addr);
80105561:	8b 45 08             	mov    0x8(%ebp),%eax
80105564:	8b 10                	mov    (%eax),%edx
80105566:	8b 45 0c             	mov    0xc(%ebp),%eax
80105569:	89 10                	mov    %edx,(%eax)
  return 0;
8010556b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105570:	5d                   	pop    %ebp
80105571:	c3                   	ret    

80105572 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105572:	55                   	push   %ebp
80105573:	89 e5                	mov    %esp,%ebp
80105575:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105578:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010557e:	8b 00                	mov    (%eax),%eax
80105580:	3b 45 08             	cmp    0x8(%ebp),%eax
80105583:	77 07                	ja     8010558c <fetchstr+0x1a>
    return -1;
80105585:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010558a:	eb 48                	jmp    801055d4 <fetchstr+0x62>
  *pp = (char*)addr;
8010558c:	8b 55 08             	mov    0x8(%ebp),%edx
8010558f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105592:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105594:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010559a:	8b 00                	mov    (%eax),%eax
8010559c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010559f:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a2:	8b 00                	mov    (%eax),%eax
801055a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055a7:	eb 1e                	jmp    801055c7 <fetchstr+0x55>
    if(*s == 0)
801055a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055ac:	0f b6 00             	movzbl (%eax),%eax
801055af:	84 c0                	test   %al,%al
801055b1:	75 10                	jne    801055c3 <fetchstr+0x51>
      return s - *pp;
801055b3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b9:	8b 00                	mov    (%eax),%eax
801055bb:	89 d1                	mov    %edx,%ecx
801055bd:	29 c1                	sub    %eax,%ecx
801055bf:	89 c8                	mov    %ecx,%eax
801055c1:	eb 11                	jmp    801055d4 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801055c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055ca:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055cd:	72 da                	jb     801055a9 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801055cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055d4:	c9                   	leave  
801055d5:	c3                   	ret    

801055d6 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055d6:	55                   	push   %ebp
801055d7:	89 e5                	mov    %esp,%ebp
801055d9:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801055dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055e2:	8b 40 18             	mov    0x18(%eax),%eax
801055e5:	8b 50 44             	mov    0x44(%eax),%edx
801055e8:	8b 45 08             	mov    0x8(%ebp),%eax
801055eb:	c1 e0 02             	shl    $0x2,%eax
801055ee:	01 d0                	add    %edx,%eax
801055f0:	8d 50 04             	lea    0x4(%eax),%edx
801055f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801055fa:	89 14 24             	mov    %edx,(%esp)
801055fd:	e8 36 ff ff ff       	call   80105538 <fetchint>
}
80105602:	c9                   	leave  
80105603:	c3                   	ret    

80105604 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105604:	55                   	push   %ebp
80105605:	89 e5                	mov    %esp,%ebp
80105607:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010560a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010560d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105611:	8b 45 08             	mov    0x8(%ebp),%eax
80105614:	89 04 24             	mov    %eax,(%esp)
80105617:	e8 ba ff ff ff       	call   801055d6 <argint>
8010561c:	85 c0                	test   %eax,%eax
8010561e:	79 07                	jns    80105627 <argptr+0x23>
    return -1;
80105620:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105625:	eb 3d                	jmp    80105664 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105627:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010562a:	89 c2                	mov    %eax,%edx
8010562c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105632:	8b 00                	mov    (%eax),%eax
80105634:	39 c2                	cmp    %eax,%edx
80105636:	73 16                	jae    8010564e <argptr+0x4a>
80105638:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010563b:	89 c2                	mov    %eax,%edx
8010563d:	8b 45 10             	mov    0x10(%ebp),%eax
80105640:	01 c2                	add    %eax,%edx
80105642:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105648:	8b 00                	mov    (%eax),%eax
8010564a:	39 c2                	cmp    %eax,%edx
8010564c:	76 07                	jbe    80105655 <argptr+0x51>
    return -1;
8010564e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105653:	eb 0f                	jmp    80105664 <argptr+0x60>
  *pp = (char*)i;
80105655:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105658:	89 c2                	mov    %eax,%edx
8010565a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010565d:	89 10                	mov    %edx,(%eax)
  return 0;
8010565f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105664:	c9                   	leave  
80105665:	c3                   	ret    

80105666 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105666:	55                   	push   %ebp
80105667:	89 e5                	mov    %esp,%ebp
80105669:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010566c:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010566f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105673:	8b 45 08             	mov    0x8(%ebp),%eax
80105676:	89 04 24             	mov    %eax,(%esp)
80105679:	e8 58 ff ff ff       	call   801055d6 <argint>
8010567e:	85 c0                	test   %eax,%eax
80105680:	79 07                	jns    80105689 <argstr+0x23>
    return -1;
80105682:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105687:	eb 12                	jmp    8010569b <argstr+0x35>
  return fetchstr(addr, pp);
80105689:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010568c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010568f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105693:	89 04 24             	mov    %eax,(%esp)
80105696:	e8 d7 fe ff ff       	call   80105572 <fetchstr>
}
8010569b:	c9                   	leave  
8010569c:	c3                   	ret    

8010569d <syscall>:
[SYS_waitpid]    sys_waitpid,
};

void
syscall(void)
{
8010569d:	55                   	push   %ebp
8010569e:	89 e5                	mov    %esp,%ebp
801056a0:	53                   	push   %ebx
801056a1:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801056a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056aa:	8b 40 18             	mov    0x18(%eax),%eax
801056ad:	8b 40 1c             	mov    0x1c(%eax),%eax
801056b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056b3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056b7:	7e 30                	jle    801056e9 <syscall+0x4c>
801056b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056bc:	83 f8 16             	cmp    $0x16,%eax
801056bf:	77 28                	ja     801056e9 <syscall+0x4c>
801056c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056c4:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056cb:	85 c0                	test   %eax,%eax
801056cd:	74 1a                	je     801056e9 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
801056cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d5:	8b 58 18             	mov    0x18(%eax),%ebx
801056d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056db:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056e2:	ff d0                	call   *%eax
801056e4:	89 43 1c             	mov    %eax,0x1c(%ebx)
801056e7:	eb 3d                	jmp    80105726 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801056e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ef:	8d 48 6c             	lea    0x6c(%eax),%ecx
801056f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801056f8:	8b 40 10             	mov    0x10(%eax),%eax
801056fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056fe:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105702:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105706:	89 44 24 04          	mov    %eax,0x4(%esp)
8010570a:	c7 04 24 d3 8a 10 80 	movl   $0x80108ad3,(%esp)
80105711:	e8 8b ac ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105716:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010571c:	8b 40 18             	mov    0x18(%eax),%eax
8010571f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105726:	83 c4 24             	add    $0x24,%esp
80105729:	5b                   	pop    %ebx
8010572a:	5d                   	pop    %ebp
8010572b:	c3                   	ret    

8010572c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010572c:	55                   	push   %ebp
8010572d:	89 e5                	mov    %esp,%ebp
8010572f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105732:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105735:	89 44 24 04          	mov    %eax,0x4(%esp)
80105739:	8b 45 08             	mov    0x8(%ebp),%eax
8010573c:	89 04 24             	mov    %eax,(%esp)
8010573f:	e8 92 fe ff ff       	call   801055d6 <argint>
80105744:	85 c0                	test   %eax,%eax
80105746:	79 07                	jns    8010574f <argfd+0x23>
    return -1;
80105748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010574d:	eb 50                	jmp    8010579f <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010574f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105752:	85 c0                	test   %eax,%eax
80105754:	78 21                	js     80105777 <argfd+0x4b>
80105756:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105759:	83 f8 0f             	cmp    $0xf,%eax
8010575c:	7f 19                	jg     80105777 <argfd+0x4b>
8010575e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105764:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105767:	83 c2 08             	add    $0x8,%edx
8010576a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010576e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105771:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105775:	75 07                	jne    8010577e <argfd+0x52>
    return -1;
80105777:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577c:	eb 21                	jmp    8010579f <argfd+0x73>
  if(pfd)
8010577e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105782:	74 08                	je     8010578c <argfd+0x60>
    *pfd = fd;
80105784:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105787:	8b 45 0c             	mov    0xc(%ebp),%eax
8010578a:	89 10                	mov    %edx,(%eax)
  if(pf)
8010578c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105790:	74 08                	je     8010579a <argfd+0x6e>
    *pf = f;
80105792:	8b 45 10             	mov    0x10(%ebp),%eax
80105795:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105798:	89 10                	mov    %edx,(%eax)
  return 0;
8010579a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010579f:	c9                   	leave  
801057a0:	c3                   	ret    

801057a1 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801057a1:	55                   	push   %ebp
801057a2:	89 e5                	mov    %esp,%ebp
801057a4:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057a7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057ae:	eb 30                	jmp    801057e0 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801057b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057b9:	83 c2 08             	add    $0x8,%edx
801057bc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057c0:	85 c0                	test   %eax,%eax
801057c2:	75 18                	jne    801057dc <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057cd:	8d 4a 08             	lea    0x8(%edx),%ecx
801057d0:	8b 55 08             	mov    0x8(%ebp),%edx
801057d3:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057da:	eb 0f                	jmp    801057eb <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057dc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057e0:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057e4:	7e ca                	jle    801057b0 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801057e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057eb:	c9                   	leave  
801057ec:	c3                   	ret    

801057ed <sys_dup>:

int
sys_dup(void)
{
801057ed:	55                   	push   %ebp
801057ee:	89 e5                	mov    %esp,%ebp
801057f0:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801057f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057f6:	89 44 24 08          	mov    %eax,0x8(%esp)
801057fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105801:	00 
80105802:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105809:	e8 1e ff ff ff       	call   8010572c <argfd>
8010580e:	85 c0                	test   %eax,%eax
80105810:	79 07                	jns    80105819 <sys_dup+0x2c>
    return -1;
80105812:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105817:	eb 29                	jmp    80105842 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105819:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581c:	89 04 24             	mov    %eax,(%esp)
8010581f:	e8 7d ff ff ff       	call   801057a1 <fdalloc>
80105824:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105827:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010582b:	79 07                	jns    80105834 <sys_dup+0x47>
    return -1;
8010582d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105832:	eb 0e                	jmp    80105842 <sys_dup+0x55>
  filedup(f);
80105834:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105837:	89 04 24             	mov    %eax,(%esp)
8010583a:	e8 61 b7 ff ff       	call   80100fa0 <filedup>
  return fd;
8010583f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105842:	c9                   	leave  
80105843:	c3                   	ret    

80105844 <sys_read>:

int
sys_read(void)
{
80105844:	55                   	push   %ebp
80105845:	89 e5                	mov    %esp,%ebp
80105847:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010584a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010584d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105851:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105858:	00 
80105859:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105860:	e8 c7 fe ff ff       	call   8010572c <argfd>
80105865:	85 c0                	test   %eax,%eax
80105867:	78 35                	js     8010589e <sys_read+0x5a>
80105869:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010586c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105870:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105877:	e8 5a fd ff ff       	call   801055d6 <argint>
8010587c:	85 c0                	test   %eax,%eax
8010587e:	78 1e                	js     8010589e <sys_read+0x5a>
80105880:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105883:	89 44 24 08          	mov    %eax,0x8(%esp)
80105887:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010588a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010588e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105895:	e8 6a fd ff ff       	call   80105604 <argptr>
8010589a:	85 c0                	test   %eax,%eax
8010589c:	79 07                	jns    801058a5 <sys_read+0x61>
    return -1;
8010589e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a3:	eb 19                	jmp    801058be <sys_read+0x7a>
  return fileread(f, p, n);
801058a5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058ae:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801058b2:	89 54 24 04          	mov    %edx,0x4(%esp)
801058b6:	89 04 24             	mov    %eax,(%esp)
801058b9:	e8 4f b8 ff ff       	call   8010110d <fileread>
}
801058be:	c9                   	leave  
801058bf:	c3                   	ret    

801058c0 <sys_write>:

int
sys_write(void)
{
801058c0:	55                   	push   %ebp
801058c1:	89 e5                	mov    %esp,%ebp
801058c3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058c9:	89 44 24 08          	mov    %eax,0x8(%esp)
801058cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058d4:	00 
801058d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058dc:	e8 4b fe ff ff       	call   8010572c <argfd>
801058e1:	85 c0                	test   %eax,%eax
801058e3:	78 35                	js     8010591a <sys_write+0x5a>
801058e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801058ec:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801058f3:	e8 de fc ff ff       	call   801055d6 <argint>
801058f8:	85 c0                	test   %eax,%eax
801058fa:	78 1e                	js     8010591a <sys_write+0x5a>
801058fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80105903:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105906:	89 44 24 04          	mov    %eax,0x4(%esp)
8010590a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105911:	e8 ee fc ff ff       	call   80105604 <argptr>
80105916:	85 c0                	test   %eax,%eax
80105918:	79 07                	jns    80105921 <sys_write+0x61>
    return -1;
8010591a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591f:	eb 19                	jmp    8010593a <sys_write+0x7a>
  return filewrite(f, p, n);
80105921:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105924:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010592a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010592e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105932:	89 04 24             	mov    %eax,(%esp)
80105935:	e8 8f b8 ff ff       	call   801011c9 <filewrite>
}
8010593a:	c9                   	leave  
8010593b:	c3                   	ret    

8010593c <sys_close>:

int
sys_close(void)
{
8010593c:	55                   	push   %ebp
8010593d:	89 e5                	mov    %esp,%ebp
8010593f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105942:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105945:	89 44 24 08          	mov    %eax,0x8(%esp)
80105949:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010594c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105950:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105957:	e8 d0 fd ff ff       	call   8010572c <argfd>
8010595c:	85 c0                	test   %eax,%eax
8010595e:	79 07                	jns    80105967 <sys_close+0x2b>
    return -1;
80105960:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105965:	eb 24                	jmp    8010598b <sys_close+0x4f>
  proc->ofile[fd] = 0;
80105967:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010596d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105970:	83 c2 08             	add    $0x8,%edx
80105973:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010597a:	00 
  fileclose(f);
8010597b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597e:	89 04 24             	mov    %eax,(%esp)
80105981:	e8 62 b6 ff ff       	call   80100fe8 <fileclose>
  return 0;
80105986:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010598b:	c9                   	leave  
8010598c:	c3                   	ret    

8010598d <sys_fstat>:

int
sys_fstat(void)
{
8010598d:	55                   	push   %ebp
8010598e:	89 e5                	mov    %esp,%ebp
80105990:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105993:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105996:	89 44 24 08          	mov    %eax,0x8(%esp)
8010599a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801059a1:	00 
801059a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059a9:	e8 7e fd ff ff       	call   8010572c <argfd>
801059ae:	85 c0                	test   %eax,%eax
801059b0:	78 1f                	js     801059d1 <sys_fstat+0x44>
801059b2:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801059b9:	00 
801059ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801059c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059c8:	e8 37 fc ff ff       	call   80105604 <argptr>
801059cd:	85 c0                	test   %eax,%eax
801059cf:	79 07                	jns    801059d8 <sys_fstat+0x4b>
    return -1;
801059d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d6:	eb 12                	jmp    801059ea <sys_fstat+0x5d>
  return filestat(f, st);
801059d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059de:	89 54 24 04          	mov    %edx,0x4(%esp)
801059e2:	89 04 24             	mov    %eax,(%esp)
801059e5:	e8 d4 b6 ff ff       	call   801010be <filestat>
}
801059ea:	c9                   	leave  
801059eb:	c3                   	ret    

801059ec <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059ec:	55                   	push   %ebp
801059ed:	89 e5                	mov    %esp,%ebp
801059ef:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801059f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a00:	e8 61 fc ff ff       	call   80105666 <argstr>
80105a05:	85 c0                	test   %eax,%eax
80105a07:	78 17                	js     80105a20 <sys_link+0x34>
80105a09:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a10:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a17:	e8 4a fc ff ff       	call   80105666 <argstr>
80105a1c:	85 c0                	test   %eax,%eax
80105a1e:	79 0a                	jns    80105a2a <sys_link+0x3e>
    return -1;
80105a20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a25:	e9 41 01 00 00       	jmp    80105b6b <sys_link+0x17f>

  begin_op();
80105a2a:	e8 4a da ff ff       	call   80103479 <begin_op>
  if((ip = namei(old)) == 0){
80105a2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a32:	89 04 24             	mov    %eax,(%esp)
80105a35:	e8 f4 c9 ff ff       	call   8010242e <namei>
80105a3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a41:	75 0f                	jne    80105a52 <sys_link+0x66>
    end_op();
80105a43:	e8 b2 da ff ff       	call   801034fa <end_op>
    return -1;
80105a48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4d:	e9 19 01 00 00       	jmp    80105b6b <sys_link+0x17f>
  }

  ilock(ip);
80105a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a55:	89 04 24             	mov    %eax,(%esp)
80105a58:	e8 2f be ff ff       	call   8010188c <ilock>
  if(ip->type == T_DIR){
80105a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a60:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a64:	66 83 f8 01          	cmp    $0x1,%ax
80105a68:	75 1a                	jne    80105a84 <sys_link+0x98>
    iunlockput(ip);
80105a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6d:	89 04 24             	mov    %eax,(%esp)
80105a70:	e8 9b c0 ff ff       	call   80101b10 <iunlockput>
    end_op();
80105a75:	e8 80 da ff ff       	call   801034fa <end_op>
    return -1;
80105a7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a7f:	e9 e7 00 00 00       	jmp    80105b6b <sys_link+0x17f>
  }

  ip->nlink++;
80105a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a87:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a8b:	8d 50 01             	lea    0x1(%eax),%edx
80105a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a91:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a98:	89 04 24             	mov    %eax,(%esp)
80105a9b:	e8 30 bc ff ff       	call   801016d0 <iupdate>
  iunlock(ip);
80105aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa3:	89 04 24             	mov    %eax,(%esp)
80105aa6:	e8 2f bf ff ff       	call   801019da <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105aab:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105aae:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105ab1:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ab5:	89 04 24             	mov    %eax,(%esp)
80105ab8:	e8 93 c9 ff ff       	call   80102450 <nameiparent>
80105abd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ac0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ac4:	74 68                	je     80105b2e <sys_link+0x142>
    goto bad;
  ilock(dp);
80105ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ac9:	89 04 24             	mov    %eax,(%esp)
80105acc:	e8 bb bd ff ff       	call   8010188c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad4:	8b 10                	mov    (%eax),%edx
80105ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad9:	8b 00                	mov    (%eax),%eax
80105adb:	39 c2                	cmp    %eax,%edx
80105add:	75 20                	jne    80105aff <sys_link+0x113>
80105adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae2:	8b 40 04             	mov    0x4(%eax),%eax
80105ae5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ae9:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105aec:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af3:	89 04 24             	mov    %eax,(%esp)
80105af6:	e8 72 c6 ff ff       	call   8010216d <dirlink>
80105afb:	85 c0                	test   %eax,%eax
80105afd:	79 0d                	jns    80105b0c <sys_link+0x120>
    iunlockput(dp);
80105aff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b02:	89 04 24             	mov    %eax,(%esp)
80105b05:	e8 06 c0 ff ff       	call   80101b10 <iunlockput>
    goto bad;
80105b0a:	eb 23                	jmp    80105b2f <sys_link+0x143>
  }
  iunlockput(dp);
80105b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0f:	89 04 24             	mov    %eax,(%esp)
80105b12:	e8 f9 bf ff ff       	call   80101b10 <iunlockput>
  iput(ip);
80105b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1a:	89 04 24             	mov    %eax,(%esp)
80105b1d:	e8 1d bf ff ff       	call   80101a3f <iput>

  end_op();
80105b22:	e8 d3 d9 ff ff       	call   801034fa <end_op>

  return 0;
80105b27:	b8 00 00 00 00       	mov    $0x0,%eax
80105b2c:	eb 3d                	jmp    80105b6b <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105b2e:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b32:	89 04 24             	mov    %eax,(%esp)
80105b35:	e8 52 bd ff ff       	call   8010188c <ilock>
  ip->nlink--;
80105b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b41:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b47:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b4e:	89 04 24             	mov    %eax,(%esp)
80105b51:	e8 7a bb ff ff       	call   801016d0 <iupdate>
  iunlockput(ip);
80105b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b59:	89 04 24             	mov    %eax,(%esp)
80105b5c:	e8 af bf ff ff       	call   80101b10 <iunlockput>
  end_op();
80105b61:	e8 94 d9 ff ff       	call   801034fa <end_op>
  return -1;
80105b66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b6b:	c9                   	leave  
80105b6c:	c3                   	ret    

80105b6d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b6d:	55                   	push   %ebp
80105b6e:	89 e5                	mov    %esp,%ebp
80105b70:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b73:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b7a:	eb 4b                	jmp    80105bc7 <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b86:	00 
80105b87:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b8b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b92:	8b 45 08             	mov    0x8(%ebp),%eax
80105b95:	89 04 24             	mov    %eax,(%esp)
80105b98:	e8 e5 c1 ff ff       	call   80101d82 <readi>
80105b9d:	83 f8 10             	cmp    $0x10,%eax
80105ba0:	74 0c                	je     80105bae <isdirempty+0x41>
      panic("isdirempty: readi");
80105ba2:	c7 04 24 ef 8a 10 80 	movl   $0x80108aef,(%esp)
80105ba9:	e8 8f a9 ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105bae:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105bb2:	66 85 c0             	test   %ax,%ax
80105bb5:	74 07                	je     80105bbe <isdirempty+0x51>
      return 0;
80105bb7:	b8 00 00 00 00       	mov    $0x0,%eax
80105bbc:	eb 1b                	jmp    80105bd9 <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc1:	83 c0 10             	add    $0x10,%eax
80105bc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bca:	8b 45 08             	mov    0x8(%ebp),%eax
80105bcd:	8b 40 18             	mov    0x18(%eax),%eax
80105bd0:	39 c2                	cmp    %eax,%edx
80105bd2:	72 a8                	jb     80105b7c <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105bd4:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bd9:	c9                   	leave  
80105bda:	c3                   	ret    

80105bdb <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bdb:	55                   	push   %ebp
80105bdc:	89 e5                	mov    %esp,%ebp
80105bde:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105be1:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105be4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105be8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bef:	e8 72 fa ff ff       	call   80105666 <argstr>
80105bf4:	85 c0                	test   %eax,%eax
80105bf6:	79 0a                	jns    80105c02 <sys_unlink+0x27>
    return -1;
80105bf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfd:	e9 af 01 00 00       	jmp    80105db1 <sys_unlink+0x1d6>

  begin_op();
80105c02:	e8 72 d8 ff ff       	call   80103479 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c07:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c0a:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c0d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105c11:	89 04 24             	mov    %eax,(%esp)
80105c14:	e8 37 c8 ff ff       	call   80102450 <nameiparent>
80105c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c1c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c20:	75 0f                	jne    80105c31 <sys_unlink+0x56>
    end_op();
80105c22:	e8 d3 d8 ff ff       	call   801034fa <end_op>
    return -1;
80105c27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c2c:	e9 80 01 00 00       	jmp    80105db1 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c34:	89 04 24             	mov    %eax,(%esp)
80105c37:	e8 50 bc ff ff       	call   8010188c <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c3c:	c7 44 24 04 01 8b 10 	movl   $0x80108b01,0x4(%esp)
80105c43:	80 
80105c44:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c47:	89 04 24             	mov    %eax,(%esp)
80105c4a:	e8 34 c4 ff ff       	call   80102083 <namecmp>
80105c4f:	85 c0                	test   %eax,%eax
80105c51:	0f 84 45 01 00 00    	je     80105d9c <sys_unlink+0x1c1>
80105c57:	c7 44 24 04 03 8b 10 	movl   $0x80108b03,0x4(%esp)
80105c5e:	80 
80105c5f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c62:	89 04 24             	mov    %eax,(%esp)
80105c65:	e8 19 c4 ff ff       	call   80102083 <namecmp>
80105c6a:	85 c0                	test   %eax,%eax
80105c6c:	0f 84 2a 01 00 00    	je     80105d9c <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c72:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c75:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c79:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c83:	89 04 24             	mov    %eax,(%esp)
80105c86:	e8 1a c4 ff ff       	call   801020a5 <dirlookup>
80105c8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c92:	0f 84 03 01 00 00    	je     80105d9b <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
80105c98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9b:	89 04 24             	mov    %eax,(%esp)
80105c9e:	e8 e9 bb ff ff       	call   8010188c <ilock>

  if(ip->nlink < 1)
80105ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105caa:	66 85 c0             	test   %ax,%ax
80105cad:	7f 0c                	jg     80105cbb <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
80105caf:	c7 04 24 06 8b 10 80 	movl   $0x80108b06,(%esp)
80105cb6:	e8 82 a8 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cbe:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cc2:	66 83 f8 01          	cmp    $0x1,%ax
80105cc6:	75 1f                	jne    80105ce7 <sys_unlink+0x10c>
80105cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ccb:	89 04 24             	mov    %eax,(%esp)
80105cce:	e8 9a fe ff ff       	call   80105b6d <isdirempty>
80105cd3:	85 c0                	test   %eax,%eax
80105cd5:	75 10                	jne    80105ce7 <sys_unlink+0x10c>
    iunlockput(ip);
80105cd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cda:	89 04 24             	mov    %eax,(%esp)
80105cdd:	e8 2e be ff ff       	call   80101b10 <iunlockput>
    goto bad;
80105ce2:	e9 b5 00 00 00       	jmp    80105d9c <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105ce7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105cee:	00 
80105cef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cf6:	00 
80105cf7:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cfa:	89 04 24             	mov    %eax,(%esp)
80105cfd:	e8 78 f5 ff ff       	call   8010527a <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d02:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d05:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105d0c:	00 
80105d0d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d11:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d14:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d1b:	89 04 24             	mov    %eax,(%esp)
80105d1e:	e8 ca c1 ff ff       	call   80101eed <writei>
80105d23:	83 f8 10             	cmp    $0x10,%eax
80105d26:	74 0c                	je     80105d34 <sys_unlink+0x159>
    panic("unlink: writei");
80105d28:	c7 04 24 18 8b 10 80 	movl   $0x80108b18,(%esp)
80105d2f:	e8 09 a8 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d37:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d3b:	66 83 f8 01          	cmp    $0x1,%ax
80105d3f:	75 1c                	jne    80105d5d <sys_unlink+0x182>
    dp->nlink--;
80105d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d44:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d48:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4e:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d55:	89 04 24             	mov    %eax,(%esp)
80105d58:	e8 73 b9 ff ff       	call   801016d0 <iupdate>
  }
  iunlockput(dp);
80105d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d60:	89 04 24             	mov    %eax,(%esp)
80105d63:	e8 a8 bd ff ff       	call   80101b10 <iunlockput>

  ip->nlink--;
80105d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d6b:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d6f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d75:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7c:	89 04 24             	mov    %eax,(%esp)
80105d7f:	e8 4c b9 ff ff       	call   801016d0 <iupdate>
  iunlockput(ip);
80105d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d87:	89 04 24             	mov    %eax,(%esp)
80105d8a:	e8 81 bd ff ff       	call   80101b10 <iunlockput>

  end_op();
80105d8f:	e8 66 d7 ff ff       	call   801034fa <end_op>

  return 0;
80105d94:	b8 00 00 00 00       	mov    $0x0,%eax
80105d99:	eb 16                	jmp    80105db1 <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105d9b:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9f:	89 04 24             	mov    %eax,(%esp)
80105da2:	e8 69 bd ff ff       	call   80101b10 <iunlockput>
  end_op();
80105da7:	e8 4e d7 ff ff       	call   801034fa <end_op>
  return -1;
80105dac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105db1:	c9                   	leave  
80105db2:	c3                   	ret    

80105db3 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105db3:	55                   	push   %ebp
80105db4:	89 e5                	mov    %esp,%ebp
80105db6:	83 ec 48             	sub    $0x48,%esp
80105db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105dbc:	8b 55 10             	mov    0x10(%ebp),%edx
80105dbf:	8b 45 14             	mov    0x14(%ebp),%eax
80105dc2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105dc6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105dca:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dce:	8d 45 de             	lea    -0x22(%ebp),%eax
80105dd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80105dd8:	89 04 24             	mov    %eax,(%esp)
80105ddb:	e8 70 c6 ff ff       	call   80102450 <nameiparent>
80105de0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105de3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105de7:	75 0a                	jne    80105df3 <create+0x40>
    return 0;
80105de9:	b8 00 00 00 00       	mov    $0x0,%eax
80105dee:	e9 7e 01 00 00       	jmp    80105f71 <create+0x1be>
  ilock(dp);
80105df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df6:	89 04 24             	mov    %eax,(%esp)
80105df9:	e8 8e ba ff ff       	call   8010188c <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105dfe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e01:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e05:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e08:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0f:	89 04 24             	mov    %eax,(%esp)
80105e12:	e8 8e c2 ff ff       	call   801020a5 <dirlookup>
80105e17:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e1e:	74 47                	je     80105e67 <create+0xb4>
    iunlockput(dp);
80105e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e23:	89 04 24             	mov    %eax,(%esp)
80105e26:	e8 e5 bc ff ff       	call   80101b10 <iunlockput>
    ilock(ip);
80105e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2e:	89 04 24             	mov    %eax,(%esp)
80105e31:	e8 56 ba ff ff       	call   8010188c <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105e36:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e3b:	75 15                	jne    80105e52 <create+0x9f>
80105e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e40:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e44:	66 83 f8 02          	cmp    $0x2,%ax
80105e48:	75 08                	jne    80105e52 <create+0x9f>
      return ip;
80105e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e4d:	e9 1f 01 00 00       	jmp    80105f71 <create+0x1be>
    iunlockput(ip);
80105e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e55:	89 04 24             	mov    %eax,(%esp)
80105e58:	e8 b3 bc ff ff       	call   80101b10 <iunlockput>
    return 0;
80105e5d:	b8 00 00 00 00       	mov    $0x0,%eax
80105e62:	e9 0a 01 00 00       	jmp    80105f71 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e67:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6e:	8b 00                	mov    (%eax),%eax
80105e70:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e74:	89 04 24             	mov    %eax,(%esp)
80105e77:	e8 77 b7 ff ff       	call   801015f3 <ialloc>
80105e7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e7f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e83:	75 0c                	jne    80105e91 <create+0xde>
    panic("create: ialloc");
80105e85:	c7 04 24 27 8b 10 80 	movl   $0x80108b27,(%esp)
80105e8c:	e8 ac a6 ff ff       	call   8010053d <panic>

  ilock(ip);
80105e91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e94:	89 04 24             	mov    %eax,(%esp)
80105e97:	e8 f0 b9 ff ff       	call   8010188c <ilock>
  ip->major = major;
80105e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9f:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105ea3:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105ea7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eaa:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105eae:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb5:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ebe:	89 04 24             	mov    %eax,(%esp)
80105ec1:	e8 0a b8 ff ff       	call   801016d0 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105ec6:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ecb:	75 6a                	jne    80105f37 <create+0x184>
    dp->nlink++;  // for ".."
80105ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ed0:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ed4:	8d 50 01             	lea    0x1(%eax),%edx
80105ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eda:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ede:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee1:	89 04 24             	mov    %eax,(%esp)
80105ee4:	e8 e7 b7 ff ff       	call   801016d0 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ee9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eec:	8b 40 04             	mov    0x4(%eax),%eax
80105eef:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ef3:	c7 44 24 04 01 8b 10 	movl   $0x80108b01,0x4(%esp)
80105efa:	80 
80105efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efe:	89 04 24             	mov    %eax,(%esp)
80105f01:	e8 67 c2 ff ff       	call   8010216d <dirlink>
80105f06:	85 c0                	test   %eax,%eax
80105f08:	78 21                	js     80105f2b <create+0x178>
80105f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0d:	8b 40 04             	mov    0x4(%eax),%eax
80105f10:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f14:	c7 44 24 04 03 8b 10 	movl   $0x80108b03,0x4(%esp)
80105f1b:	80 
80105f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1f:	89 04 24             	mov    %eax,(%esp)
80105f22:	e8 46 c2 ff ff       	call   8010216d <dirlink>
80105f27:	85 c0                	test   %eax,%eax
80105f29:	79 0c                	jns    80105f37 <create+0x184>
      panic("create dots");
80105f2b:	c7 04 24 36 8b 10 80 	movl   $0x80108b36,(%esp)
80105f32:	e8 06 a6 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f3a:	8b 40 04             	mov    0x4(%eax),%eax
80105f3d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f41:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f44:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4b:	89 04 24             	mov    %eax,(%esp)
80105f4e:	e8 1a c2 ff ff       	call   8010216d <dirlink>
80105f53:	85 c0                	test   %eax,%eax
80105f55:	79 0c                	jns    80105f63 <create+0x1b0>
    panic("create: dirlink");
80105f57:	c7 04 24 42 8b 10 80 	movl   $0x80108b42,(%esp)
80105f5e:	e8 da a5 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80105f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f66:	89 04 24             	mov    %eax,(%esp)
80105f69:	e8 a2 bb ff ff       	call   80101b10 <iunlockput>

  return ip;
80105f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f71:	c9                   	leave  
80105f72:	c3                   	ret    

80105f73 <sys_open>:

int
sys_open(void)
{
80105f73:	55                   	push   %ebp
80105f74:	89 e5                	mov    %esp,%ebp
80105f76:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f79:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f87:	e8 da f6 ff ff       	call   80105666 <argstr>
80105f8c:	85 c0                	test   %eax,%eax
80105f8e:	78 17                	js     80105fa7 <sys_open+0x34>
80105f90:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f93:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f9e:	e8 33 f6 ff ff       	call   801055d6 <argint>
80105fa3:	85 c0                	test   %eax,%eax
80105fa5:	79 0a                	jns    80105fb1 <sys_open+0x3e>
    return -1;
80105fa7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fac:	e9 5a 01 00 00       	jmp    8010610b <sys_open+0x198>

  begin_op();
80105fb1:	e8 c3 d4 ff ff       	call   80103479 <begin_op>

  if(omode & O_CREATE){
80105fb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fb9:	25 00 02 00 00       	and    $0x200,%eax
80105fbe:	85 c0                	test   %eax,%eax
80105fc0:	74 3b                	je     80105ffd <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105fc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fc5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105fcc:	00 
80105fcd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105fd4:	00 
80105fd5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105fdc:	00 
80105fdd:	89 04 24             	mov    %eax,(%esp)
80105fe0:	e8 ce fd ff ff       	call   80105db3 <create>
80105fe5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105fe8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fec:	75 6b                	jne    80106059 <sys_open+0xe6>
      end_op();
80105fee:	e8 07 d5 ff ff       	call   801034fa <end_op>
      return -1;
80105ff3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff8:	e9 0e 01 00 00       	jmp    8010610b <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
80105ffd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106000:	89 04 24             	mov    %eax,(%esp)
80106003:	e8 26 c4 ff ff       	call   8010242e <namei>
80106008:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010600b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010600f:	75 0f                	jne    80106020 <sys_open+0xad>
      end_op();
80106011:	e8 e4 d4 ff ff       	call   801034fa <end_op>
      return -1;
80106016:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601b:	e9 eb 00 00 00       	jmp    8010610b <sys_open+0x198>
    }
    ilock(ip);
80106020:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106023:	89 04 24             	mov    %eax,(%esp)
80106026:	e8 61 b8 ff ff       	call   8010188c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010602b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106032:	66 83 f8 01          	cmp    $0x1,%ax
80106036:	75 21                	jne    80106059 <sys_open+0xe6>
80106038:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010603b:	85 c0                	test   %eax,%eax
8010603d:	74 1a                	je     80106059 <sys_open+0xe6>
      iunlockput(ip);
8010603f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106042:	89 04 24             	mov    %eax,(%esp)
80106045:	e8 c6 ba ff ff       	call   80101b10 <iunlockput>
      end_op();
8010604a:	e8 ab d4 ff ff       	call   801034fa <end_op>
      return -1;
8010604f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106054:	e9 b2 00 00 00       	jmp    8010610b <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106059:	e8 e2 ae ff ff       	call   80100f40 <filealloc>
8010605e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106061:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106065:	74 14                	je     8010607b <sys_open+0x108>
80106067:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010606a:	89 04 24             	mov    %eax,(%esp)
8010606d:	e8 2f f7 ff ff       	call   801057a1 <fdalloc>
80106072:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106075:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106079:	79 28                	jns    801060a3 <sys_open+0x130>
    if(f)
8010607b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010607f:	74 0b                	je     8010608c <sys_open+0x119>
      fileclose(f);
80106081:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106084:	89 04 24             	mov    %eax,(%esp)
80106087:	e8 5c af ff ff       	call   80100fe8 <fileclose>
    iunlockput(ip);
8010608c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608f:	89 04 24             	mov    %eax,(%esp)
80106092:	e8 79 ba ff ff       	call   80101b10 <iunlockput>
    end_op();
80106097:	e8 5e d4 ff ff       	call   801034fa <end_op>
    return -1;
8010609c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060a1:	eb 68                	jmp    8010610b <sys_open+0x198>
  }
  iunlock(ip);
801060a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a6:	89 04 24             	mov    %eax,(%esp)
801060a9:	e8 2c b9 ff ff       	call   801019da <iunlock>
  end_op();
801060ae:	e8 47 d4 ff ff       	call   801034fa <end_op>

  f->type = FD_INODE;
801060b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b6:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060c2:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060d2:	83 e0 01             	and    $0x1,%eax
801060d5:	85 c0                	test   %eax,%eax
801060d7:	0f 94 c2             	sete   %dl
801060da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060dd:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060e3:	83 e0 01             	and    $0x1,%eax
801060e6:	84 c0                	test   %al,%al
801060e8:	75 0a                	jne    801060f4 <sys_open+0x181>
801060ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060ed:	83 e0 02             	and    $0x2,%eax
801060f0:	85 c0                	test   %eax,%eax
801060f2:	74 07                	je     801060fb <sys_open+0x188>
801060f4:	b8 01 00 00 00       	mov    $0x1,%eax
801060f9:	eb 05                	jmp    80106100 <sys_open+0x18d>
801060fb:	b8 00 00 00 00       	mov    $0x0,%eax
80106100:	89 c2                	mov    %eax,%edx
80106102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106105:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106108:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010610b:	c9                   	leave  
8010610c:	c3                   	ret    

8010610d <sys_mkdir>:

int
sys_mkdir(void)
{
8010610d:	55                   	push   %ebp
8010610e:	89 e5                	mov    %esp,%ebp
80106110:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106113:	e8 61 d3 ff ff       	call   80103479 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106118:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010611b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010611f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106126:	e8 3b f5 ff ff       	call   80105666 <argstr>
8010612b:	85 c0                	test   %eax,%eax
8010612d:	78 2c                	js     8010615b <sys_mkdir+0x4e>
8010612f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106132:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106139:	00 
8010613a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106141:	00 
80106142:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106149:	00 
8010614a:	89 04 24             	mov    %eax,(%esp)
8010614d:	e8 61 fc ff ff       	call   80105db3 <create>
80106152:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106155:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106159:	75 0c                	jne    80106167 <sys_mkdir+0x5a>
    end_op();
8010615b:	e8 9a d3 ff ff       	call   801034fa <end_op>
    return -1;
80106160:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106165:	eb 15                	jmp    8010617c <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010616a:	89 04 24             	mov    %eax,(%esp)
8010616d:	e8 9e b9 ff ff       	call   80101b10 <iunlockput>
  end_op();
80106172:	e8 83 d3 ff ff       	call   801034fa <end_op>
  return 0;
80106177:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010617c:	c9                   	leave  
8010617d:	c3                   	ret    

8010617e <sys_mknod>:

int
sys_mknod(void)
{
8010617e:	55                   	push   %ebp
8010617f:	89 e5                	mov    %esp,%ebp
80106181:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106184:	e8 f0 d2 ff ff       	call   80103479 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106189:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010618c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106190:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106197:	e8 ca f4 ff ff       	call   80105666 <argstr>
8010619c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010619f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061a3:	78 5e                	js     80106203 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
801061a5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801061b3:	e8 1e f4 ff ff       	call   801055d6 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801061b8:	85 c0                	test   %eax,%eax
801061ba:	78 47                	js     80106203 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801061c3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801061ca:	e8 07 f4 ff ff       	call   801055d6 <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801061cf:	85 c0                	test   %eax,%eax
801061d1:	78 30                	js     80106203 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801061d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061d6:	0f bf c8             	movswl %ax,%ecx
801061d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061dc:	0f bf d0             	movswl %ax,%edx
801061df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061e2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801061e6:	89 54 24 08          	mov    %edx,0x8(%esp)
801061ea:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801061f1:	00 
801061f2:	89 04 24             	mov    %eax,(%esp)
801061f5:	e8 b9 fb ff ff       	call   80105db3 <create>
801061fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106201:	75 0c                	jne    8010620f <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106203:	e8 f2 d2 ff ff       	call   801034fa <end_op>
    return -1;
80106208:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010620d:	eb 15                	jmp    80106224 <sys_mknod+0xa6>
  }
  iunlockput(ip);
8010620f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106212:	89 04 24             	mov    %eax,(%esp)
80106215:	e8 f6 b8 ff ff       	call   80101b10 <iunlockput>
  end_op();
8010621a:	e8 db d2 ff ff       	call   801034fa <end_op>
  return 0;
8010621f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106224:	c9                   	leave  
80106225:	c3                   	ret    

80106226 <sys_chdir>:

int
sys_chdir(void)
{
80106226:	55                   	push   %ebp
80106227:	89 e5                	mov    %esp,%ebp
80106229:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010622c:	e8 48 d2 ff ff       	call   80103479 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106231:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106234:	89 44 24 04          	mov    %eax,0x4(%esp)
80106238:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010623f:	e8 22 f4 ff ff       	call   80105666 <argstr>
80106244:	85 c0                	test   %eax,%eax
80106246:	78 14                	js     8010625c <sys_chdir+0x36>
80106248:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624b:	89 04 24             	mov    %eax,(%esp)
8010624e:	e8 db c1 ff ff       	call   8010242e <namei>
80106253:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106256:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010625a:	75 0c                	jne    80106268 <sys_chdir+0x42>
    end_op();
8010625c:	e8 99 d2 ff ff       	call   801034fa <end_op>
    return -1;
80106261:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106266:	eb 61                	jmp    801062c9 <sys_chdir+0xa3>
  }
  ilock(ip);
80106268:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010626b:	89 04 24             	mov    %eax,(%esp)
8010626e:	e8 19 b6 ff ff       	call   8010188c <ilock>
  if(ip->type != T_DIR){
80106273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106276:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010627a:	66 83 f8 01          	cmp    $0x1,%ax
8010627e:	74 17                	je     80106297 <sys_chdir+0x71>
    iunlockput(ip);
80106280:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106283:	89 04 24             	mov    %eax,(%esp)
80106286:	e8 85 b8 ff ff       	call   80101b10 <iunlockput>
    end_op();
8010628b:	e8 6a d2 ff ff       	call   801034fa <end_op>
    return -1;
80106290:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106295:	eb 32                	jmp    801062c9 <sys_chdir+0xa3>
  }
  iunlock(ip);
80106297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629a:	89 04 24             	mov    %eax,(%esp)
8010629d:	e8 38 b7 ff ff       	call   801019da <iunlock>
  iput(proc->cwd);
801062a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062a8:	8b 40 68             	mov    0x68(%eax),%eax
801062ab:	89 04 24             	mov    %eax,(%esp)
801062ae:	e8 8c b7 ff ff       	call   80101a3f <iput>
  end_op();
801062b3:	e8 42 d2 ff ff       	call   801034fa <end_op>
  proc->cwd = ip;
801062b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062c1:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062c9:	c9                   	leave  
801062ca:	c3                   	ret    

801062cb <sys_exec>:

int
sys_exec(void)
{
801062cb:	55                   	push   %ebp
801062cc:	89 e5                	mov    %esp,%ebp
801062ce:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801062db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062e2:	e8 7f f3 ff ff       	call   80105666 <argstr>
801062e7:	85 c0                	test   %eax,%eax
801062e9:	78 1a                	js     80106305 <sys_exec+0x3a>
801062eb:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801062f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062fc:	e8 d5 f2 ff ff       	call   801055d6 <argint>
80106301:	85 c0                	test   %eax,%eax
80106303:	79 0a                	jns    8010630f <sys_exec+0x44>
    return -1;
80106305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630a:	e9 cc 00 00 00       	jmp    801063db <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
8010630f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106316:	00 
80106317:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010631e:	00 
8010631f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106325:	89 04 24             	mov    %eax,(%esp)
80106328:	e8 4d ef ff ff       	call   8010527a <memset>
  for(i=0;; i++){
8010632d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106337:	83 f8 1f             	cmp    $0x1f,%eax
8010633a:	76 0a                	jbe    80106346 <sys_exec+0x7b>
      return -1;
8010633c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106341:	e9 95 00 00 00       	jmp    801063db <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106349:	c1 e0 02             	shl    $0x2,%eax
8010634c:	89 c2                	mov    %eax,%edx
8010634e:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106354:	01 c2                	add    %eax,%edx
80106356:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010635c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106360:	89 14 24             	mov    %edx,(%esp)
80106363:	e8 d0 f1 ff ff       	call   80105538 <fetchint>
80106368:	85 c0                	test   %eax,%eax
8010636a:	79 07                	jns    80106373 <sys_exec+0xa8>
      return -1;
8010636c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106371:	eb 68                	jmp    801063db <sys_exec+0x110>
    if(uarg == 0){
80106373:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106379:	85 c0                	test   %eax,%eax
8010637b:	75 26                	jne    801063a3 <sys_exec+0xd8>
      argv[i] = 0;
8010637d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106380:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106387:	00 00 00 00 
      break;
8010638b:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010638c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010638f:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106395:	89 54 24 04          	mov    %edx,0x4(%esp)
80106399:	89 04 24             	mov    %eax,(%esp)
8010639c:	e8 6f a7 ff ff       	call   80100b10 <exec>
801063a1:	eb 38                	jmp    801063db <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801063a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801063ad:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801063b3:	01 c2                	add    %eax,%edx
801063b5:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801063bf:	89 04 24             	mov    %eax,(%esp)
801063c2:	e8 ab f1 ff ff       	call   80105572 <fetchstr>
801063c7:	85 c0                	test   %eax,%eax
801063c9:	79 07                	jns    801063d2 <sys_exec+0x107>
      return -1;
801063cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d0:	eb 09                	jmp    801063db <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801063d2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801063d6:	e9 59 ff ff ff       	jmp    80106334 <sys_exec+0x69>
  return exec(path, argv);
}
801063db:	c9                   	leave  
801063dc:	c3                   	ret    

801063dd <sys_pipe>:

int
sys_pipe(void)
{
801063dd:	55                   	push   %ebp
801063de:	89 e5                	mov    %esp,%ebp
801063e0:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063e3:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801063ea:	00 
801063eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801063f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063f9:	e8 06 f2 ff ff       	call   80105604 <argptr>
801063fe:	85 c0                	test   %eax,%eax
80106400:	79 0a                	jns    8010640c <sys_pipe+0x2f>
    return -1;
80106402:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106407:	e9 9b 00 00 00       	jmp    801064a7 <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
8010640c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010640f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106413:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106416:	89 04 24             	mov    %eax,(%esp)
80106419:	e8 8a db ff ff       	call   80103fa8 <pipealloc>
8010641e:	85 c0                	test   %eax,%eax
80106420:	79 07                	jns    80106429 <sys_pipe+0x4c>
    return -1;
80106422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106427:	eb 7e                	jmp    801064a7 <sys_pipe+0xca>
  fd0 = -1;
80106429:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106430:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106433:	89 04 24             	mov    %eax,(%esp)
80106436:	e8 66 f3 ff ff       	call   801057a1 <fdalloc>
8010643b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010643e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106442:	78 14                	js     80106458 <sys_pipe+0x7b>
80106444:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106447:	89 04 24             	mov    %eax,(%esp)
8010644a:	e8 52 f3 ff ff       	call   801057a1 <fdalloc>
8010644f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106452:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106456:	79 37                	jns    8010648f <sys_pipe+0xb2>
    if(fd0 >= 0)
80106458:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010645c:	78 14                	js     80106472 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
8010645e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106464:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106467:	83 c2 08             	add    $0x8,%edx
8010646a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106471:	00 
    fileclose(rf);
80106472:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106475:	89 04 24             	mov    %eax,(%esp)
80106478:	e8 6b ab ff ff       	call   80100fe8 <fileclose>
    fileclose(wf);
8010647d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106480:	89 04 24             	mov    %eax,(%esp)
80106483:	e8 60 ab ff ff       	call   80100fe8 <fileclose>
    return -1;
80106488:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648d:	eb 18                	jmp    801064a7 <sys_pipe+0xca>
  }
  fd[0] = fd0;
8010648f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106492:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106495:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106497:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010649a:	8d 50 04             	lea    0x4(%eax),%edx
8010649d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a0:	89 02                	mov    %eax,(%edx)
  return 0;
801064a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064a7:	c9                   	leave  
801064a8:	c3                   	ret    
801064a9:	00 00                	add    %al,(%eax)
	...

801064ac <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801064ac:	55                   	push   %ebp
801064ad:	89 e5                	mov    %esp,%ebp
801064af:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064b2:	e8 a4 e1 ff ff       	call   8010465b <fork>
}
801064b7:	c9                   	leave  
801064b8:	c3                   	ret    

801064b9 <sys_exit>:

int
sys_exit(void)
{
801064b9:	55                   	push   %ebp
801064ba:	89 e5                	mov    %esp,%ebp
801064bc:	83 ec 28             	sub    $0x28,%esp
	int status;
	if(argint(0, &status) < 0)
801064bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801064c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064cd:	e8 04 f1 ff ff       	call   801055d6 <argint>
801064d2:	85 c0                	test   %eax,%eax
801064d4:	79 07                	jns    801064dd <sys_exit+0x24>
	    return -1;
801064d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064db:	eb 10                	jmp    801064ed <sys_exit+0x34>

	exit(status);
801064dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e0:	89 04 24             	mov    %eax,(%esp)
801064e3:	e8 ee e2 ff ff       	call   801047d6 <exit>
	return 0;  // not reached
801064e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064ed:	c9                   	leave  
801064ee:	c3                   	ret    

801064ef <sys_wait>:

int
sys_wait(void)
{
801064ef:	55                   	push   %ebp
801064f0:	89 e5                	mov    %esp,%ebp
801064f2:	83 ec 28             	sub    $0x28,%esp
	int* status;
	//take argument from environment
	if(argptr(0,(char**)&status, sizeof(int)) <0){ //error check
801064f5:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801064fc:	00 
801064fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106500:	89 44 24 04          	mov    %eax,0x4(%esp)
80106504:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010650b:	e8 f4 f0 ff ff       	call   80105604 <argptr>
80106510:	85 c0                	test   %eax,%eax
80106512:	79 07                	jns    8010651b <sys_wait+0x2c>
		return -1;
80106514:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106519:	eb 0b                	jmp    80106526 <sys_wait+0x37>
	}
	return wait(status);
8010651b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010651e:	89 04 24             	mov    %eax,(%esp)
80106521:	e8 de e3 ff ff       	call   80104904 <wait>
}
80106526:	c9                   	leave  
80106527:	c3                   	ret    

80106528 <sys_waitpid>:

int
sys_waitpid(void)
{
80106528:	55                   	push   %ebp
80106529:	89 e5                	mov    %esp,%ebp
8010652b:	83 ec 28             	sub    $0x28,%esp
	int pid;
	int *status;
	int options;

	if (	(argint(0, &pid) < 0) ||
8010652e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106531:	89 44 24 04          	mov    %eax,0x4(%esp)
80106535:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010653c:	e8 95 f0 ff ff       	call   801055d6 <argint>
80106541:	85 c0                	test   %eax,%eax
80106543:	78 36                	js     8010657b <sys_waitpid+0x53>
			(argptr(1,(char**)&status, sizeof(int)) < 0) ||
80106545:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
8010654c:	00 
8010654d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106550:	89 44 24 04          	mov    %eax,0x4(%esp)
80106554:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010655b:	e8 a4 f0 ff ff       	call   80105604 <argptr>
{
	int pid;
	int *status;
	int options;

	if (	(argint(0, &pid) < 0) ||
80106560:	85 c0                	test   %eax,%eax
80106562:	78 17                	js     8010657b <sys_waitpid+0x53>
			(argptr(1,(char**)&status, sizeof(int)) < 0) ||
			(argint(2, &options) < 0) ){
80106564:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106567:	89 44 24 04          	mov    %eax,0x4(%esp)
8010656b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106572:	e8 5f f0 ff ff       	call   801055d6 <argint>
	int pid;
	int *status;
	int options;

	if (	(argint(0, &pid) < 0) ||
			(argptr(1,(char**)&status, sizeof(int)) < 0) ||
80106577:	85 c0                	test   %eax,%eax
80106579:	79 07                	jns    80106582 <sys_waitpid+0x5a>
			(argint(2, &options) < 0) ){

		return -1;
8010657b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106580:	eb 19                	jmp    8010659b <sys_waitpid+0x73>
	}

	return waitpid(pid, status, options);
80106582:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106585:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010658b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010658f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106593:	89 04 24             	mov    %eax,(%esp)
80106596:	e8 8d e4 ff ff       	call   80104a28 <waitpid>
}
8010659b:	c9                   	leave  
8010659c:	c3                   	ret    

8010659d <sys_kill>:

int
sys_kill(void)
{
8010659d:	55                   	push   %ebp
8010659e:	89 e5                	mov    %esp,%ebp
801065a0:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801065a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801065aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065b1:	e8 20 f0 ff ff       	call   801055d6 <argint>
801065b6:	85 c0                	test   %eax,%eax
801065b8:	79 07                	jns    801065c1 <sys_kill+0x24>
    return -1;
801065ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065bf:	eb 0b                	jmp    801065cc <sys_kill+0x2f>
  return kill(pid);
801065c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c4:	89 04 24             	mov    %eax,(%esp)
801065c7:	e8 86 e8 ff ff       	call   80104e52 <kill>
}
801065cc:	c9                   	leave  
801065cd:	c3                   	ret    

801065ce <sys_getpid>:

int
sys_getpid(void)
{
801065ce:	55                   	push   %ebp
801065cf:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801065d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065d7:	8b 40 10             	mov    0x10(%eax),%eax
}
801065da:	5d                   	pop    %ebp
801065db:	c3                   	ret    

801065dc <sys_sbrk>:

int
sys_sbrk(void)
{
801065dc:	55                   	push   %ebp
801065dd:	89 e5                	mov    %esp,%ebp
801065df:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801065e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801065e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065f0:	e8 e1 ef ff ff       	call   801055d6 <argint>
801065f5:	85 c0                	test   %eax,%eax
801065f7:	79 07                	jns    80106600 <sys_sbrk+0x24>
    return -1;
801065f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065fe:	eb 24                	jmp    80106624 <sys_sbrk+0x48>
  addr = proc->sz;
80106600:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106606:	8b 00                	mov    (%eax),%eax
80106608:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010660b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010660e:	89 04 24             	mov    %eax,(%esp)
80106611:	e8 a0 df ff ff       	call   801045b6 <growproc>
80106616:	85 c0                	test   %eax,%eax
80106618:	79 07                	jns    80106621 <sys_sbrk+0x45>
    return -1;
8010661a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010661f:	eb 03                	jmp    80106624 <sys_sbrk+0x48>
  return addr;
80106621:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106624:	c9                   	leave  
80106625:	c3                   	ret    

80106626 <sys_sleep>:

int
sys_sleep(void)
{
80106626:	55                   	push   %ebp
80106627:	89 e5                	mov    %esp,%ebp
80106629:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010662c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010662f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106633:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010663a:	e8 97 ef ff ff       	call   801055d6 <argint>
8010663f:	85 c0                	test   %eax,%eax
80106641:	79 07                	jns    8010664a <sys_sleep+0x24>
    return -1;
80106643:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106648:	eb 6c                	jmp    801066b6 <sys_sleep+0x90>
  acquire(&tickslock);
8010664a:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106651:	e8 d5 e9 ff ff       	call   8010502b <acquire>
  ticks0 = ticks;
80106656:	a1 e0 51 11 80       	mov    0x801151e0,%eax
8010665b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010665e:	eb 34                	jmp    80106694 <sys_sleep+0x6e>
    if(proc->killed){
80106660:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106666:	8b 40 24             	mov    0x24(%eax),%eax
80106669:	85 c0                	test   %eax,%eax
8010666b:	74 13                	je     80106680 <sys_sleep+0x5a>
      release(&tickslock);
8010666d:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106674:	e8 14 ea ff ff       	call   8010508d <release>
      return -1;
80106679:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010667e:	eb 36                	jmp    801066b6 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106680:	c7 44 24 04 a0 49 11 	movl   $0x801149a0,0x4(%esp)
80106687:	80 
80106688:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
8010668f:	e8 ba e6 ff ff       	call   80104d4e <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106694:	a1 e0 51 11 80       	mov    0x801151e0,%eax
80106699:	89 c2                	mov    %eax,%edx
8010669b:	2b 55 f4             	sub    -0xc(%ebp),%edx
8010669e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066a1:	39 c2                	cmp    %eax,%edx
801066a3:	72 bb                	jb     80106660 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801066a5:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801066ac:	e8 dc e9 ff ff       	call   8010508d <release>
  return 0;
801066b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066b6:	c9                   	leave  
801066b7:	c3                   	ret    

801066b8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801066b8:	55                   	push   %ebp
801066b9:	89 e5                	mov    %esp,%ebp
801066bb:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801066be:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801066c5:	e8 61 e9 ff ff       	call   8010502b <acquire>
  xticks = ticks;
801066ca:	a1 e0 51 11 80       	mov    0x801151e0,%eax
801066cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801066d2:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801066d9:	e8 af e9 ff ff       	call   8010508d <release>
  return xticks;
801066de:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066e1:	c9                   	leave  
801066e2:	c3                   	ret    
	...

801066e4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801066e4:	55                   	push   %ebp
801066e5:	89 e5                	mov    %esp,%ebp
801066e7:	83 ec 08             	sub    $0x8,%esp
801066ea:	8b 55 08             	mov    0x8(%ebp),%edx
801066ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801066f0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801066f4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801066f7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801066fb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801066ff:	ee                   	out    %al,(%dx)
}
80106700:	c9                   	leave  
80106701:	c3                   	ret    

80106702 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106702:	55                   	push   %ebp
80106703:	89 e5                	mov    %esp,%ebp
80106705:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106708:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
8010670f:	00 
80106710:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
80106717:	e8 c8 ff ff ff       	call   801066e4 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010671c:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106723:	00 
80106724:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010672b:	e8 b4 ff ff ff       	call   801066e4 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106730:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106737:	00 
80106738:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010673f:	e8 a0 ff ff ff       	call   801066e4 <outb>
  picenable(IRQ_TIMER);
80106744:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010674b:	e8 e1 d6 ff ff       	call   80103e31 <picenable>
}
80106750:	c9                   	leave  
80106751:	c3                   	ret    
	...

80106754 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106754:	1e                   	push   %ds
  pushl %es
80106755:	06                   	push   %es
  pushl %fs
80106756:	0f a0                	push   %fs
  pushl %gs
80106758:	0f a8                	push   %gs
  pushal
8010675a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010675b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010675f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106761:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106763:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106767:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106769:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010676b:	54                   	push   %esp
  call trap
8010676c:	e8 de 01 00 00       	call   8010694f <trap>
  addl $4, %esp
80106771:	83 c4 04             	add    $0x4,%esp

80106774 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106774:	61                   	popa   
  popl %gs
80106775:	0f a9                	pop    %gs
  popl %fs
80106777:	0f a1                	pop    %fs
  popl %es
80106779:	07                   	pop    %es
  popl %ds
8010677a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010677b:	83 c4 08             	add    $0x8,%esp
  iret
8010677e:	cf                   	iret   
	...

80106780 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106780:	55                   	push   %ebp
80106781:	89 e5                	mov    %esp,%ebp
80106783:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106786:	8b 45 0c             	mov    0xc(%ebp),%eax
80106789:	83 e8 01             	sub    $0x1,%eax
8010678c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106790:	8b 45 08             	mov    0x8(%ebp),%eax
80106793:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106797:	8b 45 08             	mov    0x8(%ebp),%eax
8010679a:	c1 e8 10             	shr    $0x10,%eax
8010679d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801067a1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801067a4:	0f 01 18             	lidtl  (%eax)
}
801067a7:	c9                   	leave  
801067a8:	c3                   	ret    

801067a9 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801067a9:	55                   	push   %ebp
801067aa:	89 e5                	mov    %esp,%ebp
801067ac:	53                   	push   %ebx
801067ad:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067b0:	0f 20 d3             	mov    %cr2,%ebx
801067b3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
801067b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801067b9:	83 c4 10             	add    $0x10,%esp
801067bc:	5b                   	pop    %ebx
801067bd:	5d                   	pop    %ebp
801067be:	c3                   	ret    

801067bf <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067bf:	55                   	push   %ebp
801067c0:	89 e5                	mov    %esp,%ebp
801067c2:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801067c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067cc:	e9 c3 00 00 00       	jmp    80106894 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801067d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d4:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
801067db:	89 c2                	mov    %eax,%edx
801067dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e0:	66 89 14 c5 e0 49 11 	mov    %dx,-0x7feeb620(,%eax,8)
801067e7:	80 
801067e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067eb:	66 c7 04 c5 e2 49 11 	movw   $0x8,-0x7feeb61e(,%eax,8)
801067f2:	80 08 00 
801067f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f8:	0f b6 14 c5 e4 49 11 	movzbl -0x7feeb61c(,%eax,8),%edx
801067ff:	80 
80106800:	83 e2 e0             	and    $0xffffffe0,%edx
80106803:	88 14 c5 e4 49 11 80 	mov    %dl,-0x7feeb61c(,%eax,8)
8010680a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680d:	0f b6 14 c5 e4 49 11 	movzbl -0x7feeb61c(,%eax,8),%edx
80106814:	80 
80106815:	83 e2 1f             	and    $0x1f,%edx
80106818:	88 14 c5 e4 49 11 80 	mov    %dl,-0x7feeb61c(,%eax,8)
8010681f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106822:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
80106829:	80 
8010682a:	83 e2 f0             	and    $0xfffffff0,%edx
8010682d:	83 ca 0e             	or     $0xe,%edx
80106830:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
80106837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683a:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
80106841:	80 
80106842:	83 e2 ef             	and    $0xffffffef,%edx
80106845:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
8010684c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684f:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
80106856:	80 
80106857:	83 e2 9f             	and    $0xffffff9f,%edx
8010685a:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
80106861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106864:	0f b6 14 c5 e5 49 11 	movzbl -0x7feeb61b(,%eax,8),%edx
8010686b:	80 
8010686c:	83 ca 80             	or     $0xffffff80,%edx
8010686f:	88 14 c5 e5 49 11 80 	mov    %dl,-0x7feeb61b(,%eax,8)
80106876:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106879:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106880:	c1 e8 10             	shr    $0x10,%eax
80106883:	89 c2                	mov    %eax,%edx
80106885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106888:	66 89 14 c5 e6 49 11 	mov    %dx,-0x7feeb61a(,%eax,8)
8010688f:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106890:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106894:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010689b:	0f 8e 30 ff ff ff    	jle    801067d1 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801068a1:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
801068a6:	66 a3 e0 4b 11 80    	mov    %ax,0x80114be0
801068ac:	66 c7 05 e2 4b 11 80 	movw   $0x8,0x80114be2
801068b3:	08 00 
801068b5:	0f b6 05 e4 4b 11 80 	movzbl 0x80114be4,%eax
801068bc:	83 e0 e0             	and    $0xffffffe0,%eax
801068bf:	a2 e4 4b 11 80       	mov    %al,0x80114be4
801068c4:	0f b6 05 e4 4b 11 80 	movzbl 0x80114be4,%eax
801068cb:	83 e0 1f             	and    $0x1f,%eax
801068ce:	a2 e4 4b 11 80       	mov    %al,0x80114be4
801068d3:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801068da:	83 c8 0f             	or     $0xf,%eax
801068dd:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801068e2:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801068e9:	83 e0 ef             	and    $0xffffffef,%eax
801068ec:	a2 e5 4b 11 80       	mov    %al,0x80114be5
801068f1:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
801068f8:	83 c8 60             	or     $0x60,%eax
801068fb:	a2 e5 4b 11 80       	mov    %al,0x80114be5
80106900:	0f b6 05 e5 4b 11 80 	movzbl 0x80114be5,%eax
80106907:	83 c8 80             	or     $0xffffff80,%eax
8010690a:	a2 e5 4b 11 80       	mov    %al,0x80114be5
8010690f:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106914:	c1 e8 10             	shr    $0x10,%eax
80106917:	66 a3 e6 4b 11 80    	mov    %ax,0x80114be6
  
  initlock(&tickslock, "time");
8010691d:	c7 44 24 04 54 8b 10 	movl   $0x80108b54,0x4(%esp)
80106924:	80 
80106925:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
8010692c:	e8 d9 e6 ff ff       	call   8010500a <initlock>
}
80106931:	c9                   	leave  
80106932:	c3                   	ret    

80106933 <idtinit>:

void
idtinit(void)
{
80106933:	55                   	push   %ebp
80106934:	89 e5                	mov    %esp,%ebp
80106936:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106939:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106940:	00 
80106941:	c7 04 24 e0 49 11 80 	movl   $0x801149e0,(%esp)
80106948:	e8 33 fe ff ff       	call   80106780 <lidt>
}
8010694d:	c9                   	leave  
8010694e:	c3                   	ret    

8010694f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010694f:	55                   	push   %ebp
80106950:	89 e5                	mov    %esp,%ebp
80106952:	57                   	push   %edi
80106953:	56                   	push   %esi
80106954:	53                   	push   %ebx
80106955:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106958:	8b 45 08             	mov    0x8(%ebp),%eax
8010695b:	8b 40 30             	mov    0x30(%eax),%eax
8010695e:	83 f8 40             	cmp    $0x40,%eax
80106961:	75 4c                	jne    801069af <trap+0x60>
    if(proc->killed)
80106963:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106969:	8b 40 24             	mov    0x24(%eax),%eax
8010696c:	85 c0                	test   %eax,%eax
8010696e:	74 0c                	je     8010697c <trap+0x2d>
      exit(EXIT_STATUS_DEFAULT);
80106970:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106977:	e8 5a de ff ff       	call   801047d6 <exit>
    proc->tf = tf;
8010697c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106982:	8b 55 08             	mov    0x8(%ebp),%edx
80106985:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106988:	e8 10 ed ff ff       	call   8010569d <syscall>
    if(proc->killed)
8010698d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106993:	8b 40 24             	mov    0x24(%eax),%eax
80106996:	85 c0                	test   %eax,%eax
80106998:	0f 84 49 02 00 00    	je     80106be7 <trap+0x298>
      exit(EXIT_STATUS_DEFAULT);
8010699e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801069a5:	e8 2c de ff ff       	call   801047d6 <exit>
    return;
801069aa:	e9 38 02 00 00       	jmp    80106be7 <trap+0x298>
  }

  switch(tf->trapno){
801069af:	8b 45 08             	mov    0x8(%ebp),%eax
801069b2:	8b 40 30             	mov    0x30(%eax),%eax
801069b5:	83 e8 20             	sub    $0x20,%eax
801069b8:	83 f8 1f             	cmp    $0x1f,%eax
801069bb:	0f 87 bc 00 00 00    	ja     80106a7d <trap+0x12e>
801069c1:	8b 04 85 fc 8b 10 80 	mov    -0x7fef7404(,%eax,4),%eax
801069c8:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801069ca:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069d0:	0f b6 00             	movzbl (%eax),%eax
801069d3:	84 c0                	test   %al,%al
801069d5:	75 31                	jne    80106a08 <trap+0xb9>
      acquire(&tickslock);
801069d7:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
801069de:	e8 48 e6 ff ff       	call   8010502b <acquire>
      ticks++;
801069e3:	a1 e0 51 11 80       	mov    0x801151e0,%eax
801069e8:	83 c0 01             	add    $0x1,%eax
801069eb:	a3 e0 51 11 80       	mov    %eax,0x801151e0
      wakeup(&ticks);
801069f0:	c7 04 24 e0 51 11 80 	movl   $0x801151e0,(%esp)
801069f7:	e8 2b e4 ff ff       	call   80104e27 <wakeup>
      release(&tickslock);
801069fc:	c7 04 24 a0 49 11 80 	movl   $0x801149a0,(%esp)
80106a03:	e8 85 e6 ff ff       	call   8010508d <release>
    }
    lapiceoi();
80106a08:	e8 2a c5 ff ff       	call   80102f37 <lapiceoi>
    break;
80106a0d:	e9 41 01 00 00       	jmp    80106b53 <trap+0x204>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106a12:	e8 fe bc ff ff       	call   80102715 <ideintr>
    lapiceoi();
80106a17:	e8 1b c5 ff ff       	call   80102f37 <lapiceoi>
    break;
80106a1c:	e9 32 01 00 00       	jmp    80106b53 <trap+0x204>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106a21:	e8 c5 c2 ff ff       	call   80102ceb <kbdintr>
    lapiceoi();
80106a26:	e8 0c c5 ff ff       	call   80102f37 <lapiceoi>
    break;
80106a2b:	e9 23 01 00 00       	jmp    80106b53 <trap+0x204>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106a30:	e8 b7 03 00 00       	call   80106dec <uartintr>
    lapiceoi();
80106a35:	e8 fd c4 ff ff       	call   80102f37 <lapiceoi>
    break;
80106a3a:	e9 14 01 00 00       	jmp    80106b53 <trap+0x204>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106a3f:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a42:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106a45:	8b 45 08             	mov    0x8(%ebp),%eax
80106a48:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a4c:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106a4f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a55:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106a58:	0f b6 c0             	movzbl %al,%eax
80106a5b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a5f:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a63:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a67:	c7 04 24 5c 8b 10 80 	movl   $0x80108b5c,(%esp)
80106a6e:	e8 2e 99 ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106a73:	e8 bf c4 ff ff       	call   80102f37 <lapiceoi>
    break;
80106a78:	e9 d6 00 00 00       	jmp    80106b53 <trap+0x204>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106a7d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a83:	85 c0                	test   %eax,%eax
80106a85:	74 11                	je     80106a98 <trap+0x149>
80106a87:	8b 45 08             	mov    0x8(%ebp),%eax
80106a8a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a8e:	0f b7 c0             	movzwl %ax,%eax
80106a91:	83 e0 03             	and    $0x3,%eax
80106a94:	85 c0                	test   %eax,%eax
80106a96:	75 46                	jne    80106ade <trap+0x18f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106a98:	e8 0c fd ff ff       	call   801067a9 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
80106a9d:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106aa0:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106aa3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106aaa:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106aad:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106ab0:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ab3:	8b 52 30             	mov    0x30(%edx),%edx
80106ab6:	89 44 24 10          	mov    %eax,0x10(%esp)
80106aba:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106abe:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106ac2:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ac6:	c7 04 24 80 8b 10 80 	movl   $0x80108b80,(%esp)
80106acd:	e8 cf 98 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106ad2:	c7 04 24 b2 8b 10 80 	movl   $0x80108bb2,(%esp)
80106ad9:	e8 5f 9a ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ade:	e8 c6 fc ff ff       	call   801067a9 <rcr2>
80106ae3:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106ae5:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106ae8:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106aeb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106af1:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106af4:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106af7:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106afa:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106afd:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b00:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106b03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b09:	83 c0 6c             	add    $0x6c,%eax
80106b0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106b15:	8b 40 10             	mov    0x10(%eax),%eax
80106b18:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106b1c:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106b20:	89 74 24 14          	mov    %esi,0x14(%esp)
80106b24:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b28:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b2c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106b2f:	89 54 24 08          	mov    %edx,0x8(%esp)
80106b33:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b37:	c7 04 24 b8 8b 10 80 	movl   $0x80108bb8,(%esp)
80106b3e:	e8 5e 98 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106b43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b49:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106b50:	eb 01                	jmp    80106b53 <trap+0x204>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106b52:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106b53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b59:	85 c0                	test   %eax,%eax
80106b5b:	74 2b                	je     80106b88 <trap+0x239>
80106b5d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b63:	8b 40 24             	mov    0x24(%eax),%eax
80106b66:	85 c0                	test   %eax,%eax
80106b68:	74 1e                	je     80106b88 <trap+0x239>
80106b6a:	8b 45 08             	mov    0x8(%ebp),%eax
80106b6d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b71:	0f b7 c0             	movzwl %ax,%eax
80106b74:	83 e0 03             	and    $0x3,%eax
80106b77:	83 f8 03             	cmp    $0x3,%eax
80106b7a:	75 0c                	jne    80106b88 <trap+0x239>
    exit(EXIT_STATUS_DEFAULT);
80106b7c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106b83:	e8 4e dc ff ff       	call   801047d6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106b88:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b8e:	85 c0                	test   %eax,%eax
80106b90:	74 1e                	je     80106bb0 <trap+0x261>
80106b92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b98:	8b 40 0c             	mov    0xc(%eax),%eax
80106b9b:	83 f8 04             	cmp    $0x4,%eax
80106b9e:	75 10                	jne    80106bb0 <trap+0x261>
80106ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80106ba3:	8b 40 30             	mov    0x30(%eax),%eax
80106ba6:	83 f8 20             	cmp    $0x20,%eax
80106ba9:	75 05                	jne    80106bb0 <trap+0x261>
    yield();
80106bab:	e8 40 e1 ff ff       	call   80104cf0 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106bb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bb6:	85 c0                	test   %eax,%eax
80106bb8:	74 2e                	je     80106be8 <trap+0x299>
80106bba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106bc0:	8b 40 24             	mov    0x24(%eax),%eax
80106bc3:	85 c0                	test   %eax,%eax
80106bc5:	74 21                	je     80106be8 <trap+0x299>
80106bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80106bca:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bce:	0f b7 c0             	movzwl %ax,%eax
80106bd1:	83 e0 03             	and    $0x3,%eax
80106bd4:	83 f8 03             	cmp    $0x3,%eax
80106bd7:	75 0f                	jne    80106be8 <trap+0x299>
    exit(EXIT_STATUS_DEFAULT);
80106bd9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106be0:	e8 f1 db ff ff       	call   801047d6 <exit>
80106be5:	eb 01                	jmp    80106be8 <trap+0x299>
      exit(EXIT_STATUS_DEFAULT);
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit(EXIT_STATUS_DEFAULT);
    return;
80106be7:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit(EXIT_STATUS_DEFAULT);
}
80106be8:	83 c4 3c             	add    $0x3c,%esp
80106beb:	5b                   	pop    %ebx
80106bec:	5e                   	pop    %esi
80106bed:	5f                   	pop    %edi
80106bee:	5d                   	pop    %ebp
80106bef:	c3                   	ret    

80106bf0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106bf0:	55                   	push   %ebp
80106bf1:	89 e5                	mov    %esp,%ebp
80106bf3:	53                   	push   %ebx
80106bf4:	83 ec 14             	sub    $0x14,%esp
80106bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80106bfa:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106bfe:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106c02:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106c06:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106c0a:	ec                   	in     (%dx),%al
80106c0b:	89 c3                	mov    %eax,%ebx
80106c0d:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106c10:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106c14:	83 c4 14             	add    $0x14,%esp
80106c17:	5b                   	pop    %ebx
80106c18:	5d                   	pop    %ebp
80106c19:	c3                   	ret    

80106c1a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106c1a:	55                   	push   %ebp
80106c1b:	89 e5                	mov    %esp,%ebp
80106c1d:	83 ec 08             	sub    $0x8,%esp
80106c20:	8b 55 08             	mov    0x8(%ebp),%edx
80106c23:	8b 45 0c             	mov    0xc(%ebp),%eax
80106c26:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106c2a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106c2d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106c31:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106c35:	ee                   	out    %al,(%dx)
}
80106c36:	c9                   	leave  
80106c37:	c3                   	ret    

80106c38 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106c38:	55                   	push   %ebp
80106c39:	89 e5                	mov    %esp,%ebp
80106c3b:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106c3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c45:	00 
80106c46:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106c4d:	e8 c8 ff ff ff       	call   80106c1a <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106c52:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106c59:	00 
80106c5a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c61:	e8 b4 ff ff ff       	call   80106c1a <outb>
  outb(COM1+0, 115200/9600);
80106c66:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106c6d:	00 
80106c6e:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c75:	e8 a0 ff ff ff       	call   80106c1a <outb>
  outb(COM1+1, 0);
80106c7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c81:	00 
80106c82:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106c89:	e8 8c ff ff ff       	call   80106c1a <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106c8e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106c95:	00 
80106c96:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106c9d:	e8 78 ff ff ff       	call   80106c1a <outb>
  outb(COM1+4, 0);
80106ca2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ca9:	00 
80106caa:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106cb1:	e8 64 ff ff ff       	call   80106c1a <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106cb6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106cbd:	00 
80106cbe:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106cc5:	e8 50 ff ff ff       	call   80106c1a <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106cca:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106cd1:	e8 1a ff ff ff       	call   80106bf0 <inb>
80106cd6:	3c ff                	cmp    $0xff,%al
80106cd8:	74 6c                	je     80106d46 <uartinit+0x10e>
    return;
  uart = 1;
80106cda:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106ce1:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106ce4:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106ceb:	e8 00 ff ff ff       	call   80106bf0 <inb>
  inb(COM1+0);
80106cf0:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cf7:	e8 f4 fe ff ff       	call   80106bf0 <inb>
  picenable(IRQ_COM1);
80106cfc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d03:	e8 29 d1 ff ff       	call   80103e31 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106d08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d0f:	00 
80106d10:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106d17:	e8 7e bc ff ff       	call   8010299a <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d1c:	c7 45 f4 7c 8c 10 80 	movl   $0x80108c7c,-0xc(%ebp)
80106d23:	eb 15                	jmp    80106d3a <uartinit+0x102>
    uartputc(*p);
80106d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d28:	0f b6 00             	movzbl (%eax),%eax
80106d2b:	0f be c0             	movsbl %al,%eax
80106d2e:	89 04 24             	mov    %eax,(%esp)
80106d31:	e8 13 00 00 00       	call   80106d49 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106d36:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d3d:	0f b6 00             	movzbl (%eax),%eax
80106d40:	84 c0                	test   %al,%al
80106d42:	75 e1                	jne    80106d25 <uartinit+0xed>
80106d44:	eb 01                	jmp    80106d47 <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106d46:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106d47:	c9                   	leave  
80106d48:	c3                   	ret    

80106d49 <uartputc>:

void
uartputc(int c)
{
80106d49:	55                   	push   %ebp
80106d4a:	89 e5                	mov    %esp,%ebp
80106d4c:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106d4f:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106d54:	85 c0                	test   %eax,%eax
80106d56:	74 4d                	je     80106da5 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d5f:	eb 10                	jmp    80106d71 <uartputc+0x28>
    microdelay(10);
80106d61:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106d68:	e8 ef c1 ff ff       	call   80102f5c <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106d6d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106d71:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106d75:	7f 16                	jg     80106d8d <uartputc+0x44>
80106d77:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106d7e:	e8 6d fe ff ff       	call   80106bf0 <inb>
80106d83:	0f b6 c0             	movzbl %al,%eax
80106d86:	83 e0 20             	and    $0x20,%eax
80106d89:	85 c0                	test   %eax,%eax
80106d8b:	74 d4                	je     80106d61 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d90:	0f b6 c0             	movzbl %al,%eax
80106d93:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d97:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106d9e:	e8 77 fe ff ff       	call   80106c1a <outb>
80106da3:	eb 01                	jmp    80106da6 <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106da5:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106da6:	c9                   	leave  
80106da7:	c3                   	ret    

80106da8 <uartgetc>:

static int
uartgetc(void)
{
80106da8:	55                   	push   %ebp
80106da9:	89 e5                	mov    %esp,%ebp
80106dab:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106dae:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106db3:	85 c0                	test   %eax,%eax
80106db5:	75 07                	jne    80106dbe <uartgetc+0x16>
    return -1;
80106db7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dbc:	eb 2c                	jmp    80106dea <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106dbe:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106dc5:	e8 26 fe ff ff       	call   80106bf0 <inb>
80106dca:	0f b6 c0             	movzbl %al,%eax
80106dcd:	83 e0 01             	and    $0x1,%eax
80106dd0:	85 c0                	test   %eax,%eax
80106dd2:	75 07                	jne    80106ddb <uartgetc+0x33>
    return -1;
80106dd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dd9:	eb 0f                	jmp    80106dea <uartgetc+0x42>
  return inb(COM1+0);
80106ddb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106de2:	e8 09 fe ff ff       	call   80106bf0 <inb>
80106de7:	0f b6 c0             	movzbl %al,%eax
}
80106dea:	c9                   	leave  
80106deb:	c3                   	ret    

80106dec <uartintr>:

void
uartintr(void)
{
80106dec:	55                   	push   %ebp
80106ded:	89 e5                	mov    %esp,%ebp
80106def:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106df2:	c7 04 24 a8 6d 10 80 	movl   $0x80106da8,(%esp)
80106df9:	e8 af 99 ff ff       	call   801007ad <consoleintr>
}
80106dfe:	c9                   	leave  
80106dff:	c3                   	ret    

80106e00 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106e00:	6a 00                	push   $0x0
  pushl $0
80106e02:	6a 00                	push   $0x0
  jmp alltraps
80106e04:	e9 4b f9 ff ff       	jmp    80106754 <alltraps>

80106e09 <vector1>:
.globl vector1
vector1:
  pushl $0
80106e09:	6a 00                	push   $0x0
  pushl $1
80106e0b:	6a 01                	push   $0x1
  jmp alltraps
80106e0d:	e9 42 f9 ff ff       	jmp    80106754 <alltraps>

80106e12 <vector2>:
.globl vector2
vector2:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $2
80106e14:	6a 02                	push   $0x2
  jmp alltraps
80106e16:	e9 39 f9 ff ff       	jmp    80106754 <alltraps>

80106e1b <vector3>:
.globl vector3
vector3:
  pushl $0
80106e1b:	6a 00                	push   $0x0
  pushl $3
80106e1d:	6a 03                	push   $0x3
  jmp alltraps
80106e1f:	e9 30 f9 ff ff       	jmp    80106754 <alltraps>

80106e24 <vector4>:
.globl vector4
vector4:
  pushl $0
80106e24:	6a 00                	push   $0x0
  pushl $4
80106e26:	6a 04                	push   $0x4
  jmp alltraps
80106e28:	e9 27 f9 ff ff       	jmp    80106754 <alltraps>

80106e2d <vector5>:
.globl vector5
vector5:
  pushl $0
80106e2d:	6a 00                	push   $0x0
  pushl $5
80106e2f:	6a 05                	push   $0x5
  jmp alltraps
80106e31:	e9 1e f9 ff ff       	jmp    80106754 <alltraps>

80106e36 <vector6>:
.globl vector6
vector6:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $6
80106e38:	6a 06                	push   $0x6
  jmp alltraps
80106e3a:	e9 15 f9 ff ff       	jmp    80106754 <alltraps>

80106e3f <vector7>:
.globl vector7
vector7:
  pushl $0
80106e3f:	6a 00                	push   $0x0
  pushl $7
80106e41:	6a 07                	push   $0x7
  jmp alltraps
80106e43:	e9 0c f9 ff ff       	jmp    80106754 <alltraps>

80106e48 <vector8>:
.globl vector8
vector8:
  pushl $8
80106e48:	6a 08                	push   $0x8
  jmp alltraps
80106e4a:	e9 05 f9 ff ff       	jmp    80106754 <alltraps>

80106e4f <vector9>:
.globl vector9
vector9:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $9
80106e51:	6a 09                	push   $0x9
  jmp alltraps
80106e53:	e9 fc f8 ff ff       	jmp    80106754 <alltraps>

80106e58 <vector10>:
.globl vector10
vector10:
  pushl $10
80106e58:	6a 0a                	push   $0xa
  jmp alltraps
80106e5a:	e9 f5 f8 ff ff       	jmp    80106754 <alltraps>

80106e5f <vector11>:
.globl vector11
vector11:
  pushl $11
80106e5f:	6a 0b                	push   $0xb
  jmp alltraps
80106e61:	e9 ee f8 ff ff       	jmp    80106754 <alltraps>

80106e66 <vector12>:
.globl vector12
vector12:
  pushl $12
80106e66:	6a 0c                	push   $0xc
  jmp alltraps
80106e68:	e9 e7 f8 ff ff       	jmp    80106754 <alltraps>

80106e6d <vector13>:
.globl vector13
vector13:
  pushl $13
80106e6d:	6a 0d                	push   $0xd
  jmp alltraps
80106e6f:	e9 e0 f8 ff ff       	jmp    80106754 <alltraps>

80106e74 <vector14>:
.globl vector14
vector14:
  pushl $14
80106e74:	6a 0e                	push   $0xe
  jmp alltraps
80106e76:	e9 d9 f8 ff ff       	jmp    80106754 <alltraps>

80106e7b <vector15>:
.globl vector15
vector15:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $15
80106e7d:	6a 0f                	push   $0xf
  jmp alltraps
80106e7f:	e9 d0 f8 ff ff       	jmp    80106754 <alltraps>

80106e84 <vector16>:
.globl vector16
vector16:
  pushl $0
80106e84:	6a 00                	push   $0x0
  pushl $16
80106e86:	6a 10                	push   $0x10
  jmp alltraps
80106e88:	e9 c7 f8 ff ff       	jmp    80106754 <alltraps>

80106e8d <vector17>:
.globl vector17
vector17:
  pushl $17
80106e8d:	6a 11                	push   $0x11
  jmp alltraps
80106e8f:	e9 c0 f8 ff ff       	jmp    80106754 <alltraps>

80106e94 <vector18>:
.globl vector18
vector18:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $18
80106e96:	6a 12                	push   $0x12
  jmp alltraps
80106e98:	e9 b7 f8 ff ff       	jmp    80106754 <alltraps>

80106e9d <vector19>:
.globl vector19
vector19:
  pushl $0
80106e9d:	6a 00                	push   $0x0
  pushl $19
80106e9f:	6a 13                	push   $0x13
  jmp alltraps
80106ea1:	e9 ae f8 ff ff       	jmp    80106754 <alltraps>

80106ea6 <vector20>:
.globl vector20
vector20:
  pushl $0
80106ea6:	6a 00                	push   $0x0
  pushl $20
80106ea8:	6a 14                	push   $0x14
  jmp alltraps
80106eaa:	e9 a5 f8 ff ff       	jmp    80106754 <alltraps>

80106eaf <vector21>:
.globl vector21
vector21:
  pushl $0
80106eaf:	6a 00                	push   $0x0
  pushl $21
80106eb1:	6a 15                	push   $0x15
  jmp alltraps
80106eb3:	e9 9c f8 ff ff       	jmp    80106754 <alltraps>

80106eb8 <vector22>:
.globl vector22
vector22:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $22
80106eba:	6a 16                	push   $0x16
  jmp alltraps
80106ebc:	e9 93 f8 ff ff       	jmp    80106754 <alltraps>

80106ec1 <vector23>:
.globl vector23
vector23:
  pushl $0
80106ec1:	6a 00                	push   $0x0
  pushl $23
80106ec3:	6a 17                	push   $0x17
  jmp alltraps
80106ec5:	e9 8a f8 ff ff       	jmp    80106754 <alltraps>

80106eca <vector24>:
.globl vector24
vector24:
  pushl $0
80106eca:	6a 00                	push   $0x0
  pushl $24
80106ecc:	6a 18                	push   $0x18
  jmp alltraps
80106ece:	e9 81 f8 ff ff       	jmp    80106754 <alltraps>

80106ed3 <vector25>:
.globl vector25
vector25:
  pushl $0
80106ed3:	6a 00                	push   $0x0
  pushl $25
80106ed5:	6a 19                	push   $0x19
  jmp alltraps
80106ed7:	e9 78 f8 ff ff       	jmp    80106754 <alltraps>

80106edc <vector26>:
.globl vector26
vector26:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $26
80106ede:	6a 1a                	push   $0x1a
  jmp alltraps
80106ee0:	e9 6f f8 ff ff       	jmp    80106754 <alltraps>

80106ee5 <vector27>:
.globl vector27
vector27:
  pushl $0
80106ee5:	6a 00                	push   $0x0
  pushl $27
80106ee7:	6a 1b                	push   $0x1b
  jmp alltraps
80106ee9:	e9 66 f8 ff ff       	jmp    80106754 <alltraps>

80106eee <vector28>:
.globl vector28
vector28:
  pushl $0
80106eee:	6a 00                	push   $0x0
  pushl $28
80106ef0:	6a 1c                	push   $0x1c
  jmp alltraps
80106ef2:	e9 5d f8 ff ff       	jmp    80106754 <alltraps>

80106ef7 <vector29>:
.globl vector29
vector29:
  pushl $0
80106ef7:	6a 00                	push   $0x0
  pushl $29
80106ef9:	6a 1d                	push   $0x1d
  jmp alltraps
80106efb:	e9 54 f8 ff ff       	jmp    80106754 <alltraps>

80106f00 <vector30>:
.globl vector30
vector30:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $30
80106f02:	6a 1e                	push   $0x1e
  jmp alltraps
80106f04:	e9 4b f8 ff ff       	jmp    80106754 <alltraps>

80106f09 <vector31>:
.globl vector31
vector31:
  pushl $0
80106f09:	6a 00                	push   $0x0
  pushl $31
80106f0b:	6a 1f                	push   $0x1f
  jmp alltraps
80106f0d:	e9 42 f8 ff ff       	jmp    80106754 <alltraps>

80106f12 <vector32>:
.globl vector32
vector32:
  pushl $0
80106f12:	6a 00                	push   $0x0
  pushl $32
80106f14:	6a 20                	push   $0x20
  jmp alltraps
80106f16:	e9 39 f8 ff ff       	jmp    80106754 <alltraps>

80106f1b <vector33>:
.globl vector33
vector33:
  pushl $0
80106f1b:	6a 00                	push   $0x0
  pushl $33
80106f1d:	6a 21                	push   $0x21
  jmp alltraps
80106f1f:	e9 30 f8 ff ff       	jmp    80106754 <alltraps>

80106f24 <vector34>:
.globl vector34
vector34:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $34
80106f26:	6a 22                	push   $0x22
  jmp alltraps
80106f28:	e9 27 f8 ff ff       	jmp    80106754 <alltraps>

80106f2d <vector35>:
.globl vector35
vector35:
  pushl $0
80106f2d:	6a 00                	push   $0x0
  pushl $35
80106f2f:	6a 23                	push   $0x23
  jmp alltraps
80106f31:	e9 1e f8 ff ff       	jmp    80106754 <alltraps>

80106f36 <vector36>:
.globl vector36
vector36:
  pushl $0
80106f36:	6a 00                	push   $0x0
  pushl $36
80106f38:	6a 24                	push   $0x24
  jmp alltraps
80106f3a:	e9 15 f8 ff ff       	jmp    80106754 <alltraps>

80106f3f <vector37>:
.globl vector37
vector37:
  pushl $0
80106f3f:	6a 00                	push   $0x0
  pushl $37
80106f41:	6a 25                	push   $0x25
  jmp alltraps
80106f43:	e9 0c f8 ff ff       	jmp    80106754 <alltraps>

80106f48 <vector38>:
.globl vector38
vector38:
  pushl $0
80106f48:	6a 00                	push   $0x0
  pushl $38
80106f4a:	6a 26                	push   $0x26
  jmp alltraps
80106f4c:	e9 03 f8 ff ff       	jmp    80106754 <alltraps>

80106f51 <vector39>:
.globl vector39
vector39:
  pushl $0
80106f51:	6a 00                	push   $0x0
  pushl $39
80106f53:	6a 27                	push   $0x27
  jmp alltraps
80106f55:	e9 fa f7 ff ff       	jmp    80106754 <alltraps>

80106f5a <vector40>:
.globl vector40
vector40:
  pushl $0
80106f5a:	6a 00                	push   $0x0
  pushl $40
80106f5c:	6a 28                	push   $0x28
  jmp alltraps
80106f5e:	e9 f1 f7 ff ff       	jmp    80106754 <alltraps>

80106f63 <vector41>:
.globl vector41
vector41:
  pushl $0
80106f63:	6a 00                	push   $0x0
  pushl $41
80106f65:	6a 29                	push   $0x29
  jmp alltraps
80106f67:	e9 e8 f7 ff ff       	jmp    80106754 <alltraps>

80106f6c <vector42>:
.globl vector42
vector42:
  pushl $0
80106f6c:	6a 00                	push   $0x0
  pushl $42
80106f6e:	6a 2a                	push   $0x2a
  jmp alltraps
80106f70:	e9 df f7 ff ff       	jmp    80106754 <alltraps>

80106f75 <vector43>:
.globl vector43
vector43:
  pushl $0
80106f75:	6a 00                	push   $0x0
  pushl $43
80106f77:	6a 2b                	push   $0x2b
  jmp alltraps
80106f79:	e9 d6 f7 ff ff       	jmp    80106754 <alltraps>

80106f7e <vector44>:
.globl vector44
vector44:
  pushl $0
80106f7e:	6a 00                	push   $0x0
  pushl $44
80106f80:	6a 2c                	push   $0x2c
  jmp alltraps
80106f82:	e9 cd f7 ff ff       	jmp    80106754 <alltraps>

80106f87 <vector45>:
.globl vector45
vector45:
  pushl $0
80106f87:	6a 00                	push   $0x0
  pushl $45
80106f89:	6a 2d                	push   $0x2d
  jmp alltraps
80106f8b:	e9 c4 f7 ff ff       	jmp    80106754 <alltraps>

80106f90 <vector46>:
.globl vector46
vector46:
  pushl $0
80106f90:	6a 00                	push   $0x0
  pushl $46
80106f92:	6a 2e                	push   $0x2e
  jmp alltraps
80106f94:	e9 bb f7 ff ff       	jmp    80106754 <alltraps>

80106f99 <vector47>:
.globl vector47
vector47:
  pushl $0
80106f99:	6a 00                	push   $0x0
  pushl $47
80106f9b:	6a 2f                	push   $0x2f
  jmp alltraps
80106f9d:	e9 b2 f7 ff ff       	jmp    80106754 <alltraps>

80106fa2 <vector48>:
.globl vector48
vector48:
  pushl $0
80106fa2:	6a 00                	push   $0x0
  pushl $48
80106fa4:	6a 30                	push   $0x30
  jmp alltraps
80106fa6:	e9 a9 f7 ff ff       	jmp    80106754 <alltraps>

80106fab <vector49>:
.globl vector49
vector49:
  pushl $0
80106fab:	6a 00                	push   $0x0
  pushl $49
80106fad:	6a 31                	push   $0x31
  jmp alltraps
80106faf:	e9 a0 f7 ff ff       	jmp    80106754 <alltraps>

80106fb4 <vector50>:
.globl vector50
vector50:
  pushl $0
80106fb4:	6a 00                	push   $0x0
  pushl $50
80106fb6:	6a 32                	push   $0x32
  jmp alltraps
80106fb8:	e9 97 f7 ff ff       	jmp    80106754 <alltraps>

80106fbd <vector51>:
.globl vector51
vector51:
  pushl $0
80106fbd:	6a 00                	push   $0x0
  pushl $51
80106fbf:	6a 33                	push   $0x33
  jmp alltraps
80106fc1:	e9 8e f7 ff ff       	jmp    80106754 <alltraps>

80106fc6 <vector52>:
.globl vector52
vector52:
  pushl $0
80106fc6:	6a 00                	push   $0x0
  pushl $52
80106fc8:	6a 34                	push   $0x34
  jmp alltraps
80106fca:	e9 85 f7 ff ff       	jmp    80106754 <alltraps>

80106fcf <vector53>:
.globl vector53
vector53:
  pushl $0
80106fcf:	6a 00                	push   $0x0
  pushl $53
80106fd1:	6a 35                	push   $0x35
  jmp alltraps
80106fd3:	e9 7c f7 ff ff       	jmp    80106754 <alltraps>

80106fd8 <vector54>:
.globl vector54
vector54:
  pushl $0
80106fd8:	6a 00                	push   $0x0
  pushl $54
80106fda:	6a 36                	push   $0x36
  jmp alltraps
80106fdc:	e9 73 f7 ff ff       	jmp    80106754 <alltraps>

80106fe1 <vector55>:
.globl vector55
vector55:
  pushl $0
80106fe1:	6a 00                	push   $0x0
  pushl $55
80106fe3:	6a 37                	push   $0x37
  jmp alltraps
80106fe5:	e9 6a f7 ff ff       	jmp    80106754 <alltraps>

80106fea <vector56>:
.globl vector56
vector56:
  pushl $0
80106fea:	6a 00                	push   $0x0
  pushl $56
80106fec:	6a 38                	push   $0x38
  jmp alltraps
80106fee:	e9 61 f7 ff ff       	jmp    80106754 <alltraps>

80106ff3 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ff3:	6a 00                	push   $0x0
  pushl $57
80106ff5:	6a 39                	push   $0x39
  jmp alltraps
80106ff7:	e9 58 f7 ff ff       	jmp    80106754 <alltraps>

80106ffc <vector58>:
.globl vector58
vector58:
  pushl $0
80106ffc:	6a 00                	push   $0x0
  pushl $58
80106ffe:	6a 3a                	push   $0x3a
  jmp alltraps
80107000:	e9 4f f7 ff ff       	jmp    80106754 <alltraps>

80107005 <vector59>:
.globl vector59
vector59:
  pushl $0
80107005:	6a 00                	push   $0x0
  pushl $59
80107007:	6a 3b                	push   $0x3b
  jmp alltraps
80107009:	e9 46 f7 ff ff       	jmp    80106754 <alltraps>

8010700e <vector60>:
.globl vector60
vector60:
  pushl $0
8010700e:	6a 00                	push   $0x0
  pushl $60
80107010:	6a 3c                	push   $0x3c
  jmp alltraps
80107012:	e9 3d f7 ff ff       	jmp    80106754 <alltraps>

80107017 <vector61>:
.globl vector61
vector61:
  pushl $0
80107017:	6a 00                	push   $0x0
  pushl $61
80107019:	6a 3d                	push   $0x3d
  jmp alltraps
8010701b:	e9 34 f7 ff ff       	jmp    80106754 <alltraps>

80107020 <vector62>:
.globl vector62
vector62:
  pushl $0
80107020:	6a 00                	push   $0x0
  pushl $62
80107022:	6a 3e                	push   $0x3e
  jmp alltraps
80107024:	e9 2b f7 ff ff       	jmp    80106754 <alltraps>

80107029 <vector63>:
.globl vector63
vector63:
  pushl $0
80107029:	6a 00                	push   $0x0
  pushl $63
8010702b:	6a 3f                	push   $0x3f
  jmp alltraps
8010702d:	e9 22 f7 ff ff       	jmp    80106754 <alltraps>

80107032 <vector64>:
.globl vector64
vector64:
  pushl $0
80107032:	6a 00                	push   $0x0
  pushl $64
80107034:	6a 40                	push   $0x40
  jmp alltraps
80107036:	e9 19 f7 ff ff       	jmp    80106754 <alltraps>

8010703b <vector65>:
.globl vector65
vector65:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $65
8010703d:	6a 41                	push   $0x41
  jmp alltraps
8010703f:	e9 10 f7 ff ff       	jmp    80106754 <alltraps>

80107044 <vector66>:
.globl vector66
vector66:
  pushl $0
80107044:	6a 00                	push   $0x0
  pushl $66
80107046:	6a 42                	push   $0x42
  jmp alltraps
80107048:	e9 07 f7 ff ff       	jmp    80106754 <alltraps>

8010704d <vector67>:
.globl vector67
vector67:
  pushl $0
8010704d:	6a 00                	push   $0x0
  pushl $67
8010704f:	6a 43                	push   $0x43
  jmp alltraps
80107051:	e9 fe f6 ff ff       	jmp    80106754 <alltraps>

80107056 <vector68>:
.globl vector68
vector68:
  pushl $0
80107056:	6a 00                	push   $0x0
  pushl $68
80107058:	6a 44                	push   $0x44
  jmp alltraps
8010705a:	e9 f5 f6 ff ff       	jmp    80106754 <alltraps>

8010705f <vector69>:
.globl vector69
vector69:
  pushl $0
8010705f:	6a 00                	push   $0x0
  pushl $69
80107061:	6a 45                	push   $0x45
  jmp alltraps
80107063:	e9 ec f6 ff ff       	jmp    80106754 <alltraps>

80107068 <vector70>:
.globl vector70
vector70:
  pushl $0
80107068:	6a 00                	push   $0x0
  pushl $70
8010706a:	6a 46                	push   $0x46
  jmp alltraps
8010706c:	e9 e3 f6 ff ff       	jmp    80106754 <alltraps>

80107071 <vector71>:
.globl vector71
vector71:
  pushl $0
80107071:	6a 00                	push   $0x0
  pushl $71
80107073:	6a 47                	push   $0x47
  jmp alltraps
80107075:	e9 da f6 ff ff       	jmp    80106754 <alltraps>

8010707a <vector72>:
.globl vector72
vector72:
  pushl $0
8010707a:	6a 00                	push   $0x0
  pushl $72
8010707c:	6a 48                	push   $0x48
  jmp alltraps
8010707e:	e9 d1 f6 ff ff       	jmp    80106754 <alltraps>

80107083 <vector73>:
.globl vector73
vector73:
  pushl $0
80107083:	6a 00                	push   $0x0
  pushl $73
80107085:	6a 49                	push   $0x49
  jmp alltraps
80107087:	e9 c8 f6 ff ff       	jmp    80106754 <alltraps>

8010708c <vector74>:
.globl vector74
vector74:
  pushl $0
8010708c:	6a 00                	push   $0x0
  pushl $74
8010708e:	6a 4a                	push   $0x4a
  jmp alltraps
80107090:	e9 bf f6 ff ff       	jmp    80106754 <alltraps>

80107095 <vector75>:
.globl vector75
vector75:
  pushl $0
80107095:	6a 00                	push   $0x0
  pushl $75
80107097:	6a 4b                	push   $0x4b
  jmp alltraps
80107099:	e9 b6 f6 ff ff       	jmp    80106754 <alltraps>

8010709e <vector76>:
.globl vector76
vector76:
  pushl $0
8010709e:	6a 00                	push   $0x0
  pushl $76
801070a0:	6a 4c                	push   $0x4c
  jmp alltraps
801070a2:	e9 ad f6 ff ff       	jmp    80106754 <alltraps>

801070a7 <vector77>:
.globl vector77
vector77:
  pushl $0
801070a7:	6a 00                	push   $0x0
  pushl $77
801070a9:	6a 4d                	push   $0x4d
  jmp alltraps
801070ab:	e9 a4 f6 ff ff       	jmp    80106754 <alltraps>

801070b0 <vector78>:
.globl vector78
vector78:
  pushl $0
801070b0:	6a 00                	push   $0x0
  pushl $78
801070b2:	6a 4e                	push   $0x4e
  jmp alltraps
801070b4:	e9 9b f6 ff ff       	jmp    80106754 <alltraps>

801070b9 <vector79>:
.globl vector79
vector79:
  pushl $0
801070b9:	6a 00                	push   $0x0
  pushl $79
801070bb:	6a 4f                	push   $0x4f
  jmp alltraps
801070bd:	e9 92 f6 ff ff       	jmp    80106754 <alltraps>

801070c2 <vector80>:
.globl vector80
vector80:
  pushl $0
801070c2:	6a 00                	push   $0x0
  pushl $80
801070c4:	6a 50                	push   $0x50
  jmp alltraps
801070c6:	e9 89 f6 ff ff       	jmp    80106754 <alltraps>

801070cb <vector81>:
.globl vector81
vector81:
  pushl $0
801070cb:	6a 00                	push   $0x0
  pushl $81
801070cd:	6a 51                	push   $0x51
  jmp alltraps
801070cf:	e9 80 f6 ff ff       	jmp    80106754 <alltraps>

801070d4 <vector82>:
.globl vector82
vector82:
  pushl $0
801070d4:	6a 00                	push   $0x0
  pushl $82
801070d6:	6a 52                	push   $0x52
  jmp alltraps
801070d8:	e9 77 f6 ff ff       	jmp    80106754 <alltraps>

801070dd <vector83>:
.globl vector83
vector83:
  pushl $0
801070dd:	6a 00                	push   $0x0
  pushl $83
801070df:	6a 53                	push   $0x53
  jmp alltraps
801070e1:	e9 6e f6 ff ff       	jmp    80106754 <alltraps>

801070e6 <vector84>:
.globl vector84
vector84:
  pushl $0
801070e6:	6a 00                	push   $0x0
  pushl $84
801070e8:	6a 54                	push   $0x54
  jmp alltraps
801070ea:	e9 65 f6 ff ff       	jmp    80106754 <alltraps>

801070ef <vector85>:
.globl vector85
vector85:
  pushl $0
801070ef:	6a 00                	push   $0x0
  pushl $85
801070f1:	6a 55                	push   $0x55
  jmp alltraps
801070f3:	e9 5c f6 ff ff       	jmp    80106754 <alltraps>

801070f8 <vector86>:
.globl vector86
vector86:
  pushl $0
801070f8:	6a 00                	push   $0x0
  pushl $86
801070fa:	6a 56                	push   $0x56
  jmp alltraps
801070fc:	e9 53 f6 ff ff       	jmp    80106754 <alltraps>

80107101 <vector87>:
.globl vector87
vector87:
  pushl $0
80107101:	6a 00                	push   $0x0
  pushl $87
80107103:	6a 57                	push   $0x57
  jmp alltraps
80107105:	e9 4a f6 ff ff       	jmp    80106754 <alltraps>

8010710a <vector88>:
.globl vector88
vector88:
  pushl $0
8010710a:	6a 00                	push   $0x0
  pushl $88
8010710c:	6a 58                	push   $0x58
  jmp alltraps
8010710e:	e9 41 f6 ff ff       	jmp    80106754 <alltraps>

80107113 <vector89>:
.globl vector89
vector89:
  pushl $0
80107113:	6a 00                	push   $0x0
  pushl $89
80107115:	6a 59                	push   $0x59
  jmp alltraps
80107117:	e9 38 f6 ff ff       	jmp    80106754 <alltraps>

8010711c <vector90>:
.globl vector90
vector90:
  pushl $0
8010711c:	6a 00                	push   $0x0
  pushl $90
8010711e:	6a 5a                	push   $0x5a
  jmp alltraps
80107120:	e9 2f f6 ff ff       	jmp    80106754 <alltraps>

80107125 <vector91>:
.globl vector91
vector91:
  pushl $0
80107125:	6a 00                	push   $0x0
  pushl $91
80107127:	6a 5b                	push   $0x5b
  jmp alltraps
80107129:	e9 26 f6 ff ff       	jmp    80106754 <alltraps>

8010712e <vector92>:
.globl vector92
vector92:
  pushl $0
8010712e:	6a 00                	push   $0x0
  pushl $92
80107130:	6a 5c                	push   $0x5c
  jmp alltraps
80107132:	e9 1d f6 ff ff       	jmp    80106754 <alltraps>

80107137 <vector93>:
.globl vector93
vector93:
  pushl $0
80107137:	6a 00                	push   $0x0
  pushl $93
80107139:	6a 5d                	push   $0x5d
  jmp alltraps
8010713b:	e9 14 f6 ff ff       	jmp    80106754 <alltraps>

80107140 <vector94>:
.globl vector94
vector94:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $94
80107142:	6a 5e                	push   $0x5e
  jmp alltraps
80107144:	e9 0b f6 ff ff       	jmp    80106754 <alltraps>

80107149 <vector95>:
.globl vector95
vector95:
  pushl $0
80107149:	6a 00                	push   $0x0
  pushl $95
8010714b:	6a 5f                	push   $0x5f
  jmp alltraps
8010714d:	e9 02 f6 ff ff       	jmp    80106754 <alltraps>

80107152 <vector96>:
.globl vector96
vector96:
  pushl $0
80107152:	6a 00                	push   $0x0
  pushl $96
80107154:	6a 60                	push   $0x60
  jmp alltraps
80107156:	e9 f9 f5 ff ff       	jmp    80106754 <alltraps>

8010715b <vector97>:
.globl vector97
vector97:
  pushl $0
8010715b:	6a 00                	push   $0x0
  pushl $97
8010715d:	6a 61                	push   $0x61
  jmp alltraps
8010715f:	e9 f0 f5 ff ff       	jmp    80106754 <alltraps>

80107164 <vector98>:
.globl vector98
vector98:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $98
80107166:	6a 62                	push   $0x62
  jmp alltraps
80107168:	e9 e7 f5 ff ff       	jmp    80106754 <alltraps>

8010716d <vector99>:
.globl vector99
vector99:
  pushl $0
8010716d:	6a 00                	push   $0x0
  pushl $99
8010716f:	6a 63                	push   $0x63
  jmp alltraps
80107171:	e9 de f5 ff ff       	jmp    80106754 <alltraps>

80107176 <vector100>:
.globl vector100
vector100:
  pushl $0
80107176:	6a 00                	push   $0x0
  pushl $100
80107178:	6a 64                	push   $0x64
  jmp alltraps
8010717a:	e9 d5 f5 ff ff       	jmp    80106754 <alltraps>

8010717f <vector101>:
.globl vector101
vector101:
  pushl $0
8010717f:	6a 00                	push   $0x0
  pushl $101
80107181:	6a 65                	push   $0x65
  jmp alltraps
80107183:	e9 cc f5 ff ff       	jmp    80106754 <alltraps>

80107188 <vector102>:
.globl vector102
vector102:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $102
8010718a:	6a 66                	push   $0x66
  jmp alltraps
8010718c:	e9 c3 f5 ff ff       	jmp    80106754 <alltraps>

80107191 <vector103>:
.globl vector103
vector103:
  pushl $0
80107191:	6a 00                	push   $0x0
  pushl $103
80107193:	6a 67                	push   $0x67
  jmp alltraps
80107195:	e9 ba f5 ff ff       	jmp    80106754 <alltraps>

8010719a <vector104>:
.globl vector104
vector104:
  pushl $0
8010719a:	6a 00                	push   $0x0
  pushl $104
8010719c:	6a 68                	push   $0x68
  jmp alltraps
8010719e:	e9 b1 f5 ff ff       	jmp    80106754 <alltraps>

801071a3 <vector105>:
.globl vector105
vector105:
  pushl $0
801071a3:	6a 00                	push   $0x0
  pushl $105
801071a5:	6a 69                	push   $0x69
  jmp alltraps
801071a7:	e9 a8 f5 ff ff       	jmp    80106754 <alltraps>

801071ac <vector106>:
.globl vector106
vector106:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $106
801071ae:	6a 6a                	push   $0x6a
  jmp alltraps
801071b0:	e9 9f f5 ff ff       	jmp    80106754 <alltraps>

801071b5 <vector107>:
.globl vector107
vector107:
  pushl $0
801071b5:	6a 00                	push   $0x0
  pushl $107
801071b7:	6a 6b                	push   $0x6b
  jmp alltraps
801071b9:	e9 96 f5 ff ff       	jmp    80106754 <alltraps>

801071be <vector108>:
.globl vector108
vector108:
  pushl $0
801071be:	6a 00                	push   $0x0
  pushl $108
801071c0:	6a 6c                	push   $0x6c
  jmp alltraps
801071c2:	e9 8d f5 ff ff       	jmp    80106754 <alltraps>

801071c7 <vector109>:
.globl vector109
vector109:
  pushl $0
801071c7:	6a 00                	push   $0x0
  pushl $109
801071c9:	6a 6d                	push   $0x6d
  jmp alltraps
801071cb:	e9 84 f5 ff ff       	jmp    80106754 <alltraps>

801071d0 <vector110>:
.globl vector110
vector110:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $110
801071d2:	6a 6e                	push   $0x6e
  jmp alltraps
801071d4:	e9 7b f5 ff ff       	jmp    80106754 <alltraps>

801071d9 <vector111>:
.globl vector111
vector111:
  pushl $0
801071d9:	6a 00                	push   $0x0
  pushl $111
801071db:	6a 6f                	push   $0x6f
  jmp alltraps
801071dd:	e9 72 f5 ff ff       	jmp    80106754 <alltraps>

801071e2 <vector112>:
.globl vector112
vector112:
  pushl $0
801071e2:	6a 00                	push   $0x0
  pushl $112
801071e4:	6a 70                	push   $0x70
  jmp alltraps
801071e6:	e9 69 f5 ff ff       	jmp    80106754 <alltraps>

801071eb <vector113>:
.globl vector113
vector113:
  pushl $0
801071eb:	6a 00                	push   $0x0
  pushl $113
801071ed:	6a 71                	push   $0x71
  jmp alltraps
801071ef:	e9 60 f5 ff ff       	jmp    80106754 <alltraps>

801071f4 <vector114>:
.globl vector114
vector114:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $114
801071f6:	6a 72                	push   $0x72
  jmp alltraps
801071f8:	e9 57 f5 ff ff       	jmp    80106754 <alltraps>

801071fd <vector115>:
.globl vector115
vector115:
  pushl $0
801071fd:	6a 00                	push   $0x0
  pushl $115
801071ff:	6a 73                	push   $0x73
  jmp alltraps
80107201:	e9 4e f5 ff ff       	jmp    80106754 <alltraps>

80107206 <vector116>:
.globl vector116
vector116:
  pushl $0
80107206:	6a 00                	push   $0x0
  pushl $116
80107208:	6a 74                	push   $0x74
  jmp alltraps
8010720a:	e9 45 f5 ff ff       	jmp    80106754 <alltraps>

8010720f <vector117>:
.globl vector117
vector117:
  pushl $0
8010720f:	6a 00                	push   $0x0
  pushl $117
80107211:	6a 75                	push   $0x75
  jmp alltraps
80107213:	e9 3c f5 ff ff       	jmp    80106754 <alltraps>

80107218 <vector118>:
.globl vector118
vector118:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $118
8010721a:	6a 76                	push   $0x76
  jmp alltraps
8010721c:	e9 33 f5 ff ff       	jmp    80106754 <alltraps>

80107221 <vector119>:
.globl vector119
vector119:
  pushl $0
80107221:	6a 00                	push   $0x0
  pushl $119
80107223:	6a 77                	push   $0x77
  jmp alltraps
80107225:	e9 2a f5 ff ff       	jmp    80106754 <alltraps>

8010722a <vector120>:
.globl vector120
vector120:
  pushl $0
8010722a:	6a 00                	push   $0x0
  pushl $120
8010722c:	6a 78                	push   $0x78
  jmp alltraps
8010722e:	e9 21 f5 ff ff       	jmp    80106754 <alltraps>

80107233 <vector121>:
.globl vector121
vector121:
  pushl $0
80107233:	6a 00                	push   $0x0
  pushl $121
80107235:	6a 79                	push   $0x79
  jmp alltraps
80107237:	e9 18 f5 ff ff       	jmp    80106754 <alltraps>

8010723c <vector122>:
.globl vector122
vector122:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $122
8010723e:	6a 7a                	push   $0x7a
  jmp alltraps
80107240:	e9 0f f5 ff ff       	jmp    80106754 <alltraps>

80107245 <vector123>:
.globl vector123
vector123:
  pushl $0
80107245:	6a 00                	push   $0x0
  pushl $123
80107247:	6a 7b                	push   $0x7b
  jmp alltraps
80107249:	e9 06 f5 ff ff       	jmp    80106754 <alltraps>

8010724e <vector124>:
.globl vector124
vector124:
  pushl $0
8010724e:	6a 00                	push   $0x0
  pushl $124
80107250:	6a 7c                	push   $0x7c
  jmp alltraps
80107252:	e9 fd f4 ff ff       	jmp    80106754 <alltraps>

80107257 <vector125>:
.globl vector125
vector125:
  pushl $0
80107257:	6a 00                	push   $0x0
  pushl $125
80107259:	6a 7d                	push   $0x7d
  jmp alltraps
8010725b:	e9 f4 f4 ff ff       	jmp    80106754 <alltraps>

80107260 <vector126>:
.globl vector126
vector126:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $126
80107262:	6a 7e                	push   $0x7e
  jmp alltraps
80107264:	e9 eb f4 ff ff       	jmp    80106754 <alltraps>

80107269 <vector127>:
.globl vector127
vector127:
  pushl $0
80107269:	6a 00                	push   $0x0
  pushl $127
8010726b:	6a 7f                	push   $0x7f
  jmp alltraps
8010726d:	e9 e2 f4 ff ff       	jmp    80106754 <alltraps>

80107272 <vector128>:
.globl vector128
vector128:
  pushl $0
80107272:	6a 00                	push   $0x0
  pushl $128
80107274:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107279:	e9 d6 f4 ff ff       	jmp    80106754 <alltraps>

8010727e <vector129>:
.globl vector129
vector129:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $129
80107280:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107285:	e9 ca f4 ff ff       	jmp    80106754 <alltraps>

8010728a <vector130>:
.globl vector130
vector130:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $130
8010728c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107291:	e9 be f4 ff ff       	jmp    80106754 <alltraps>

80107296 <vector131>:
.globl vector131
vector131:
  pushl $0
80107296:	6a 00                	push   $0x0
  pushl $131
80107298:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010729d:	e9 b2 f4 ff ff       	jmp    80106754 <alltraps>

801072a2 <vector132>:
.globl vector132
vector132:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $132
801072a4:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801072a9:	e9 a6 f4 ff ff       	jmp    80106754 <alltraps>

801072ae <vector133>:
.globl vector133
vector133:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $133
801072b0:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801072b5:	e9 9a f4 ff ff       	jmp    80106754 <alltraps>

801072ba <vector134>:
.globl vector134
vector134:
  pushl $0
801072ba:	6a 00                	push   $0x0
  pushl $134
801072bc:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801072c1:	e9 8e f4 ff ff       	jmp    80106754 <alltraps>

801072c6 <vector135>:
.globl vector135
vector135:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $135
801072c8:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801072cd:	e9 82 f4 ff ff       	jmp    80106754 <alltraps>

801072d2 <vector136>:
.globl vector136
vector136:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $136
801072d4:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801072d9:	e9 76 f4 ff ff       	jmp    80106754 <alltraps>

801072de <vector137>:
.globl vector137
vector137:
  pushl $0
801072de:	6a 00                	push   $0x0
  pushl $137
801072e0:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801072e5:	e9 6a f4 ff ff       	jmp    80106754 <alltraps>

801072ea <vector138>:
.globl vector138
vector138:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $138
801072ec:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801072f1:	e9 5e f4 ff ff       	jmp    80106754 <alltraps>

801072f6 <vector139>:
.globl vector139
vector139:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $139
801072f8:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801072fd:	e9 52 f4 ff ff       	jmp    80106754 <alltraps>

80107302 <vector140>:
.globl vector140
vector140:
  pushl $0
80107302:	6a 00                	push   $0x0
  pushl $140
80107304:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107309:	e9 46 f4 ff ff       	jmp    80106754 <alltraps>

8010730e <vector141>:
.globl vector141
vector141:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $141
80107310:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107315:	e9 3a f4 ff ff       	jmp    80106754 <alltraps>

8010731a <vector142>:
.globl vector142
vector142:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $142
8010731c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107321:	e9 2e f4 ff ff       	jmp    80106754 <alltraps>

80107326 <vector143>:
.globl vector143
vector143:
  pushl $0
80107326:	6a 00                	push   $0x0
  pushl $143
80107328:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010732d:	e9 22 f4 ff ff       	jmp    80106754 <alltraps>

80107332 <vector144>:
.globl vector144
vector144:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $144
80107334:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107339:	e9 16 f4 ff ff       	jmp    80106754 <alltraps>

8010733e <vector145>:
.globl vector145
vector145:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $145
80107340:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107345:	e9 0a f4 ff ff       	jmp    80106754 <alltraps>

8010734a <vector146>:
.globl vector146
vector146:
  pushl $0
8010734a:	6a 00                	push   $0x0
  pushl $146
8010734c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107351:	e9 fe f3 ff ff       	jmp    80106754 <alltraps>

80107356 <vector147>:
.globl vector147
vector147:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $147
80107358:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010735d:	e9 f2 f3 ff ff       	jmp    80106754 <alltraps>

80107362 <vector148>:
.globl vector148
vector148:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $148
80107364:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107369:	e9 e6 f3 ff ff       	jmp    80106754 <alltraps>

8010736e <vector149>:
.globl vector149
vector149:
  pushl $0
8010736e:	6a 00                	push   $0x0
  pushl $149
80107370:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107375:	e9 da f3 ff ff       	jmp    80106754 <alltraps>

8010737a <vector150>:
.globl vector150
vector150:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $150
8010737c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107381:	e9 ce f3 ff ff       	jmp    80106754 <alltraps>

80107386 <vector151>:
.globl vector151
vector151:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $151
80107388:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010738d:	e9 c2 f3 ff ff       	jmp    80106754 <alltraps>

80107392 <vector152>:
.globl vector152
vector152:
  pushl $0
80107392:	6a 00                	push   $0x0
  pushl $152
80107394:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107399:	e9 b6 f3 ff ff       	jmp    80106754 <alltraps>

8010739e <vector153>:
.globl vector153
vector153:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $153
801073a0:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801073a5:	e9 aa f3 ff ff       	jmp    80106754 <alltraps>

801073aa <vector154>:
.globl vector154
vector154:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $154
801073ac:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801073b1:	e9 9e f3 ff ff       	jmp    80106754 <alltraps>

801073b6 <vector155>:
.globl vector155
vector155:
  pushl $0
801073b6:	6a 00                	push   $0x0
  pushl $155
801073b8:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801073bd:	e9 92 f3 ff ff       	jmp    80106754 <alltraps>

801073c2 <vector156>:
.globl vector156
vector156:
  pushl $0
801073c2:	6a 00                	push   $0x0
  pushl $156
801073c4:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801073c9:	e9 86 f3 ff ff       	jmp    80106754 <alltraps>

801073ce <vector157>:
.globl vector157
vector157:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $157
801073d0:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801073d5:	e9 7a f3 ff ff       	jmp    80106754 <alltraps>

801073da <vector158>:
.globl vector158
vector158:
  pushl $0
801073da:	6a 00                	push   $0x0
  pushl $158
801073dc:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801073e1:	e9 6e f3 ff ff       	jmp    80106754 <alltraps>

801073e6 <vector159>:
.globl vector159
vector159:
  pushl $0
801073e6:	6a 00                	push   $0x0
  pushl $159
801073e8:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801073ed:	e9 62 f3 ff ff       	jmp    80106754 <alltraps>

801073f2 <vector160>:
.globl vector160
vector160:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $160
801073f4:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801073f9:	e9 56 f3 ff ff       	jmp    80106754 <alltraps>

801073fe <vector161>:
.globl vector161
vector161:
  pushl $0
801073fe:	6a 00                	push   $0x0
  pushl $161
80107400:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107405:	e9 4a f3 ff ff       	jmp    80106754 <alltraps>

8010740a <vector162>:
.globl vector162
vector162:
  pushl $0
8010740a:	6a 00                	push   $0x0
  pushl $162
8010740c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107411:	e9 3e f3 ff ff       	jmp    80106754 <alltraps>

80107416 <vector163>:
.globl vector163
vector163:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $163
80107418:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010741d:	e9 32 f3 ff ff       	jmp    80106754 <alltraps>

80107422 <vector164>:
.globl vector164
vector164:
  pushl $0
80107422:	6a 00                	push   $0x0
  pushl $164
80107424:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107429:	e9 26 f3 ff ff       	jmp    80106754 <alltraps>

8010742e <vector165>:
.globl vector165
vector165:
  pushl $0
8010742e:	6a 00                	push   $0x0
  pushl $165
80107430:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107435:	e9 1a f3 ff ff       	jmp    80106754 <alltraps>

8010743a <vector166>:
.globl vector166
vector166:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $166
8010743c:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107441:	e9 0e f3 ff ff       	jmp    80106754 <alltraps>

80107446 <vector167>:
.globl vector167
vector167:
  pushl $0
80107446:	6a 00                	push   $0x0
  pushl $167
80107448:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010744d:	e9 02 f3 ff ff       	jmp    80106754 <alltraps>

80107452 <vector168>:
.globl vector168
vector168:
  pushl $0
80107452:	6a 00                	push   $0x0
  pushl $168
80107454:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107459:	e9 f6 f2 ff ff       	jmp    80106754 <alltraps>

8010745e <vector169>:
.globl vector169
vector169:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $169
80107460:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107465:	e9 ea f2 ff ff       	jmp    80106754 <alltraps>

8010746a <vector170>:
.globl vector170
vector170:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $170
8010746c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107471:	e9 de f2 ff ff       	jmp    80106754 <alltraps>

80107476 <vector171>:
.globl vector171
vector171:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $171
80107478:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010747d:	e9 d2 f2 ff ff       	jmp    80106754 <alltraps>

80107482 <vector172>:
.globl vector172
vector172:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $172
80107484:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107489:	e9 c6 f2 ff ff       	jmp    80106754 <alltraps>

8010748e <vector173>:
.globl vector173
vector173:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $173
80107490:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107495:	e9 ba f2 ff ff       	jmp    80106754 <alltraps>

8010749a <vector174>:
.globl vector174
vector174:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $174
8010749c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801074a1:	e9 ae f2 ff ff       	jmp    80106754 <alltraps>

801074a6 <vector175>:
.globl vector175
vector175:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $175
801074a8:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801074ad:	e9 a2 f2 ff ff       	jmp    80106754 <alltraps>

801074b2 <vector176>:
.globl vector176
vector176:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $176
801074b4:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801074b9:	e9 96 f2 ff ff       	jmp    80106754 <alltraps>

801074be <vector177>:
.globl vector177
vector177:
  pushl $0
801074be:	6a 00                	push   $0x0
  pushl $177
801074c0:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801074c5:	e9 8a f2 ff ff       	jmp    80106754 <alltraps>

801074ca <vector178>:
.globl vector178
vector178:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $178
801074cc:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801074d1:	e9 7e f2 ff ff       	jmp    80106754 <alltraps>

801074d6 <vector179>:
.globl vector179
vector179:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $179
801074d8:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801074dd:	e9 72 f2 ff ff       	jmp    80106754 <alltraps>

801074e2 <vector180>:
.globl vector180
vector180:
  pushl $0
801074e2:	6a 00                	push   $0x0
  pushl $180
801074e4:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801074e9:	e9 66 f2 ff ff       	jmp    80106754 <alltraps>

801074ee <vector181>:
.globl vector181
vector181:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $181
801074f0:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801074f5:	e9 5a f2 ff ff       	jmp    80106754 <alltraps>

801074fa <vector182>:
.globl vector182
vector182:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $182
801074fc:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107501:	e9 4e f2 ff ff       	jmp    80106754 <alltraps>

80107506 <vector183>:
.globl vector183
vector183:
  pushl $0
80107506:	6a 00                	push   $0x0
  pushl $183
80107508:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010750d:	e9 42 f2 ff ff       	jmp    80106754 <alltraps>

80107512 <vector184>:
.globl vector184
vector184:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $184
80107514:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107519:	e9 36 f2 ff ff       	jmp    80106754 <alltraps>

8010751e <vector185>:
.globl vector185
vector185:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $185
80107520:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107525:	e9 2a f2 ff ff       	jmp    80106754 <alltraps>

8010752a <vector186>:
.globl vector186
vector186:
  pushl $0
8010752a:	6a 00                	push   $0x0
  pushl $186
8010752c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107531:	e9 1e f2 ff ff       	jmp    80106754 <alltraps>

80107536 <vector187>:
.globl vector187
vector187:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $187
80107538:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010753d:	e9 12 f2 ff ff       	jmp    80106754 <alltraps>

80107542 <vector188>:
.globl vector188
vector188:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $188
80107544:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107549:	e9 06 f2 ff ff       	jmp    80106754 <alltraps>

8010754e <vector189>:
.globl vector189
vector189:
  pushl $0
8010754e:	6a 00                	push   $0x0
  pushl $189
80107550:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107555:	e9 fa f1 ff ff       	jmp    80106754 <alltraps>

8010755a <vector190>:
.globl vector190
vector190:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $190
8010755c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107561:	e9 ee f1 ff ff       	jmp    80106754 <alltraps>

80107566 <vector191>:
.globl vector191
vector191:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $191
80107568:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010756d:	e9 e2 f1 ff ff       	jmp    80106754 <alltraps>

80107572 <vector192>:
.globl vector192
vector192:
  pushl $0
80107572:	6a 00                	push   $0x0
  pushl $192
80107574:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107579:	e9 d6 f1 ff ff       	jmp    80106754 <alltraps>

8010757e <vector193>:
.globl vector193
vector193:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $193
80107580:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107585:	e9 ca f1 ff ff       	jmp    80106754 <alltraps>

8010758a <vector194>:
.globl vector194
vector194:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $194
8010758c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107591:	e9 be f1 ff ff       	jmp    80106754 <alltraps>

80107596 <vector195>:
.globl vector195
vector195:
  pushl $0
80107596:	6a 00                	push   $0x0
  pushl $195
80107598:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010759d:	e9 b2 f1 ff ff       	jmp    80106754 <alltraps>

801075a2 <vector196>:
.globl vector196
vector196:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $196
801075a4:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801075a9:	e9 a6 f1 ff ff       	jmp    80106754 <alltraps>

801075ae <vector197>:
.globl vector197
vector197:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $197
801075b0:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801075b5:	e9 9a f1 ff ff       	jmp    80106754 <alltraps>

801075ba <vector198>:
.globl vector198
vector198:
  pushl $0
801075ba:	6a 00                	push   $0x0
  pushl $198
801075bc:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801075c1:	e9 8e f1 ff ff       	jmp    80106754 <alltraps>

801075c6 <vector199>:
.globl vector199
vector199:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $199
801075c8:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801075cd:	e9 82 f1 ff ff       	jmp    80106754 <alltraps>

801075d2 <vector200>:
.globl vector200
vector200:
  pushl $0
801075d2:	6a 00                	push   $0x0
  pushl $200
801075d4:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801075d9:	e9 76 f1 ff ff       	jmp    80106754 <alltraps>

801075de <vector201>:
.globl vector201
vector201:
  pushl $0
801075de:	6a 00                	push   $0x0
  pushl $201
801075e0:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801075e5:	e9 6a f1 ff ff       	jmp    80106754 <alltraps>

801075ea <vector202>:
.globl vector202
vector202:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $202
801075ec:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801075f1:	e9 5e f1 ff ff       	jmp    80106754 <alltraps>

801075f6 <vector203>:
.globl vector203
vector203:
  pushl $0
801075f6:	6a 00                	push   $0x0
  pushl $203
801075f8:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801075fd:	e9 52 f1 ff ff       	jmp    80106754 <alltraps>

80107602 <vector204>:
.globl vector204
vector204:
  pushl $0
80107602:	6a 00                	push   $0x0
  pushl $204
80107604:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107609:	e9 46 f1 ff ff       	jmp    80106754 <alltraps>

8010760e <vector205>:
.globl vector205
vector205:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $205
80107610:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107615:	e9 3a f1 ff ff       	jmp    80106754 <alltraps>

8010761a <vector206>:
.globl vector206
vector206:
  pushl $0
8010761a:	6a 00                	push   $0x0
  pushl $206
8010761c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107621:	e9 2e f1 ff ff       	jmp    80106754 <alltraps>

80107626 <vector207>:
.globl vector207
vector207:
  pushl $0
80107626:	6a 00                	push   $0x0
  pushl $207
80107628:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010762d:	e9 22 f1 ff ff       	jmp    80106754 <alltraps>

80107632 <vector208>:
.globl vector208
vector208:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $208
80107634:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107639:	e9 16 f1 ff ff       	jmp    80106754 <alltraps>

8010763e <vector209>:
.globl vector209
vector209:
  pushl $0
8010763e:	6a 00                	push   $0x0
  pushl $209
80107640:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107645:	e9 0a f1 ff ff       	jmp    80106754 <alltraps>

8010764a <vector210>:
.globl vector210
vector210:
  pushl $0
8010764a:	6a 00                	push   $0x0
  pushl $210
8010764c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107651:	e9 fe f0 ff ff       	jmp    80106754 <alltraps>

80107656 <vector211>:
.globl vector211
vector211:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $211
80107658:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010765d:	e9 f2 f0 ff ff       	jmp    80106754 <alltraps>

80107662 <vector212>:
.globl vector212
vector212:
  pushl $0
80107662:	6a 00                	push   $0x0
  pushl $212
80107664:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107669:	e9 e6 f0 ff ff       	jmp    80106754 <alltraps>

8010766e <vector213>:
.globl vector213
vector213:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $213
80107670:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107675:	e9 da f0 ff ff       	jmp    80106754 <alltraps>

8010767a <vector214>:
.globl vector214
vector214:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $214
8010767c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107681:	e9 ce f0 ff ff       	jmp    80106754 <alltraps>

80107686 <vector215>:
.globl vector215
vector215:
  pushl $0
80107686:	6a 00                	push   $0x0
  pushl $215
80107688:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010768d:	e9 c2 f0 ff ff       	jmp    80106754 <alltraps>

80107692 <vector216>:
.globl vector216
vector216:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $216
80107694:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107699:	e9 b6 f0 ff ff       	jmp    80106754 <alltraps>

8010769e <vector217>:
.globl vector217
vector217:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $217
801076a0:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801076a5:	e9 aa f0 ff ff       	jmp    80106754 <alltraps>

801076aa <vector218>:
.globl vector218
vector218:
  pushl $0
801076aa:	6a 00                	push   $0x0
  pushl $218
801076ac:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801076b1:	e9 9e f0 ff ff       	jmp    80106754 <alltraps>

801076b6 <vector219>:
.globl vector219
vector219:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $219
801076b8:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801076bd:	e9 92 f0 ff ff       	jmp    80106754 <alltraps>

801076c2 <vector220>:
.globl vector220
vector220:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $220
801076c4:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801076c9:	e9 86 f0 ff ff       	jmp    80106754 <alltraps>

801076ce <vector221>:
.globl vector221
vector221:
  pushl $0
801076ce:	6a 00                	push   $0x0
  pushl $221
801076d0:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801076d5:	e9 7a f0 ff ff       	jmp    80106754 <alltraps>

801076da <vector222>:
.globl vector222
vector222:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $222
801076dc:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801076e1:	e9 6e f0 ff ff       	jmp    80106754 <alltraps>

801076e6 <vector223>:
.globl vector223
vector223:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $223
801076e8:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801076ed:	e9 62 f0 ff ff       	jmp    80106754 <alltraps>

801076f2 <vector224>:
.globl vector224
vector224:
  pushl $0
801076f2:	6a 00                	push   $0x0
  pushl $224
801076f4:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801076f9:	e9 56 f0 ff ff       	jmp    80106754 <alltraps>

801076fe <vector225>:
.globl vector225
vector225:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $225
80107700:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107705:	e9 4a f0 ff ff       	jmp    80106754 <alltraps>

8010770a <vector226>:
.globl vector226
vector226:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $226
8010770c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107711:	e9 3e f0 ff ff       	jmp    80106754 <alltraps>

80107716 <vector227>:
.globl vector227
vector227:
  pushl $0
80107716:	6a 00                	push   $0x0
  pushl $227
80107718:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010771d:	e9 32 f0 ff ff       	jmp    80106754 <alltraps>

80107722 <vector228>:
.globl vector228
vector228:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $228
80107724:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107729:	e9 26 f0 ff ff       	jmp    80106754 <alltraps>

8010772e <vector229>:
.globl vector229
vector229:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $229
80107730:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107735:	e9 1a f0 ff ff       	jmp    80106754 <alltraps>

8010773a <vector230>:
.globl vector230
vector230:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $230
8010773c:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107741:	e9 0e f0 ff ff       	jmp    80106754 <alltraps>

80107746 <vector231>:
.globl vector231
vector231:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $231
80107748:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010774d:	e9 02 f0 ff ff       	jmp    80106754 <alltraps>

80107752 <vector232>:
.globl vector232
vector232:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $232
80107754:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107759:	e9 f6 ef ff ff       	jmp    80106754 <alltraps>

8010775e <vector233>:
.globl vector233
vector233:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $233
80107760:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107765:	e9 ea ef ff ff       	jmp    80106754 <alltraps>

8010776a <vector234>:
.globl vector234
vector234:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $234
8010776c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107771:	e9 de ef ff ff       	jmp    80106754 <alltraps>

80107776 <vector235>:
.globl vector235
vector235:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $235
80107778:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010777d:	e9 d2 ef ff ff       	jmp    80106754 <alltraps>

80107782 <vector236>:
.globl vector236
vector236:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $236
80107784:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107789:	e9 c6 ef ff ff       	jmp    80106754 <alltraps>

8010778e <vector237>:
.globl vector237
vector237:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $237
80107790:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107795:	e9 ba ef ff ff       	jmp    80106754 <alltraps>

8010779a <vector238>:
.globl vector238
vector238:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $238
8010779c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801077a1:	e9 ae ef ff ff       	jmp    80106754 <alltraps>

801077a6 <vector239>:
.globl vector239
vector239:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $239
801077a8:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801077ad:	e9 a2 ef ff ff       	jmp    80106754 <alltraps>

801077b2 <vector240>:
.globl vector240
vector240:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $240
801077b4:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801077b9:	e9 96 ef ff ff       	jmp    80106754 <alltraps>

801077be <vector241>:
.globl vector241
vector241:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $241
801077c0:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801077c5:	e9 8a ef ff ff       	jmp    80106754 <alltraps>

801077ca <vector242>:
.globl vector242
vector242:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $242
801077cc:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801077d1:	e9 7e ef ff ff       	jmp    80106754 <alltraps>

801077d6 <vector243>:
.globl vector243
vector243:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $243
801077d8:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801077dd:	e9 72 ef ff ff       	jmp    80106754 <alltraps>

801077e2 <vector244>:
.globl vector244
vector244:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $244
801077e4:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801077e9:	e9 66 ef ff ff       	jmp    80106754 <alltraps>

801077ee <vector245>:
.globl vector245
vector245:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $245
801077f0:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801077f5:	e9 5a ef ff ff       	jmp    80106754 <alltraps>

801077fa <vector246>:
.globl vector246
vector246:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $246
801077fc:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107801:	e9 4e ef ff ff       	jmp    80106754 <alltraps>

80107806 <vector247>:
.globl vector247
vector247:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $247
80107808:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010780d:	e9 42 ef ff ff       	jmp    80106754 <alltraps>

80107812 <vector248>:
.globl vector248
vector248:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $248
80107814:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107819:	e9 36 ef ff ff       	jmp    80106754 <alltraps>

8010781e <vector249>:
.globl vector249
vector249:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $249
80107820:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107825:	e9 2a ef ff ff       	jmp    80106754 <alltraps>

8010782a <vector250>:
.globl vector250
vector250:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $250
8010782c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107831:	e9 1e ef ff ff       	jmp    80106754 <alltraps>

80107836 <vector251>:
.globl vector251
vector251:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $251
80107838:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010783d:	e9 12 ef ff ff       	jmp    80106754 <alltraps>

80107842 <vector252>:
.globl vector252
vector252:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $252
80107844:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107849:	e9 06 ef ff ff       	jmp    80106754 <alltraps>

8010784e <vector253>:
.globl vector253
vector253:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $253
80107850:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107855:	e9 fa ee ff ff       	jmp    80106754 <alltraps>

8010785a <vector254>:
.globl vector254
vector254:
  pushl $0
8010785a:	6a 00                	push   $0x0
  pushl $254
8010785c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107861:	e9 ee ee ff ff       	jmp    80106754 <alltraps>

80107866 <vector255>:
.globl vector255
vector255:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $255
80107868:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010786d:	e9 e2 ee ff ff       	jmp    80106754 <alltraps>
	...

80107874 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107874:	55                   	push   %ebp
80107875:	89 e5                	mov    %esp,%ebp
80107877:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010787a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010787d:	83 e8 01             	sub    $0x1,%eax
80107880:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107884:	8b 45 08             	mov    0x8(%ebp),%eax
80107887:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010788b:	8b 45 08             	mov    0x8(%ebp),%eax
8010788e:	c1 e8 10             	shr    $0x10,%eax
80107891:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107895:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107898:	0f 01 10             	lgdtl  (%eax)
}
8010789b:	c9                   	leave  
8010789c:	c3                   	ret    

8010789d <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010789d:	55                   	push   %ebp
8010789e:	89 e5                	mov    %esp,%ebp
801078a0:	83 ec 04             	sub    $0x4,%esp
801078a3:	8b 45 08             	mov    0x8(%ebp),%eax
801078a6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801078aa:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078ae:	0f 00 d8             	ltr    %ax
}
801078b1:	c9                   	leave  
801078b2:	c3                   	ret    

801078b3 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801078b3:	55                   	push   %ebp
801078b4:	89 e5                	mov    %esp,%ebp
801078b6:	83 ec 04             	sub    $0x4,%esp
801078b9:	8b 45 08             	mov    0x8(%ebp),%eax
801078bc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801078c0:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801078c4:	8e e8                	mov    %eax,%gs
}
801078c6:	c9                   	leave  
801078c7:	c3                   	ret    

801078c8 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801078c8:	55                   	push   %ebp
801078c9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801078cb:	8b 45 08             	mov    0x8(%ebp),%eax
801078ce:	0f 22 d8             	mov    %eax,%cr3
}
801078d1:	5d                   	pop    %ebp
801078d2:	c3                   	ret    

801078d3 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801078d3:	55                   	push   %ebp
801078d4:	89 e5                	mov    %esp,%ebp
801078d6:	8b 45 08             	mov    0x8(%ebp),%eax
801078d9:	05 00 00 00 80       	add    $0x80000000,%eax
801078de:	5d                   	pop    %ebp
801078df:	c3                   	ret    

801078e0 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801078e0:	55                   	push   %ebp
801078e1:	89 e5                	mov    %esp,%ebp
801078e3:	8b 45 08             	mov    0x8(%ebp),%eax
801078e6:	05 00 00 00 80       	add    $0x80000000,%eax
801078eb:	5d                   	pop    %ebp
801078ec:	c3                   	ret    

801078ed <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801078ed:	55                   	push   %ebp
801078ee:	89 e5                	mov    %esp,%ebp
801078f0:	53                   	push   %ebx
801078f1:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801078f4:	e8 e2 b5 ff ff       	call   80102edb <cpunum>
801078f9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801078ff:	05 60 23 11 80       	add    $0x80112360,%eax
80107904:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010790a:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107913:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010791c:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107920:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107923:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107927:	83 e2 f0             	and    $0xfffffff0,%edx
8010792a:	83 ca 0a             	or     $0xa,%edx
8010792d:	88 50 7d             	mov    %dl,0x7d(%eax)
80107930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107933:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107937:	83 ca 10             	or     $0x10,%edx
8010793a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010793d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107940:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107944:	83 e2 9f             	and    $0xffffff9f,%edx
80107947:	88 50 7d             	mov    %dl,0x7d(%eax)
8010794a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107951:	83 ca 80             	or     $0xffffff80,%edx
80107954:	88 50 7d             	mov    %dl,0x7d(%eax)
80107957:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010795a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010795e:	83 ca 0f             	or     $0xf,%edx
80107961:	88 50 7e             	mov    %dl,0x7e(%eax)
80107964:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107967:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010796b:	83 e2 ef             	and    $0xffffffef,%edx
8010796e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107974:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107978:	83 e2 df             	and    $0xffffffdf,%edx
8010797b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010797e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107981:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107985:	83 ca 40             	or     $0x40,%edx
80107988:	88 50 7e             	mov    %dl,0x7e(%eax)
8010798b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107992:	83 ca 80             	or     $0xffffff80,%edx
80107995:	88 50 7e             	mov    %dl,0x7e(%eax)
80107998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010799f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a2:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801079a9:	ff ff 
801079ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ae:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801079b5:	00 00 
801079b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ba:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801079c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079cb:	83 e2 f0             	and    $0xfffffff0,%edx
801079ce:	83 ca 02             	or     $0x2,%edx
801079d1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079da:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079e1:	83 ca 10             	or     $0x10,%edx
801079e4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ed:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801079f4:	83 e2 9f             	and    $0xffffff9f,%edx
801079f7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801079fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a00:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a07:	83 ca 80             	or     $0xffffff80,%edx
80107a0a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a13:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a1a:	83 ca 0f             	or     $0xf,%edx
80107a1d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a26:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a2d:	83 e2 ef             	and    $0xffffffef,%edx
80107a30:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a39:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a40:	83 e2 df             	and    $0xffffffdf,%edx
80107a43:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a53:	83 ca 40             	or     $0x40,%edx
80107a56:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107a66:	83 ca 80             	or     $0xffffff80,%edx
80107a69:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a72:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107a83:	ff ff 
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107a8f:	00 00 
80107a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a94:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107aa5:	83 e2 f0             	and    $0xfffffff0,%edx
80107aa8:	83 ca 0a             	or     $0xa,%edx
80107aab:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab4:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107abb:	83 ca 10             	or     $0x10,%edx
80107abe:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac7:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ace:	83 ca 60             	or     $0x60,%edx
80107ad1:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ada:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ae1:	83 ca 80             	or     $0xffffff80,%edx
80107ae4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aed:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107af4:	83 ca 0f             	or     $0xf,%edx
80107af7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b00:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b07:	83 e2 ef             	and    $0xffffffef,%edx
80107b0a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b13:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b1a:	83 e2 df             	and    $0xffffffdf,%edx
80107b1d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b26:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b2d:	83 ca 40             	or     $0x40,%edx
80107b30:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b39:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b40:	83 ca 80             	or     $0xffffff80,%edx
80107b43:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b56:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107b5d:	ff ff 
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107b69:	00 00 
80107b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b6e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b78:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b7f:	83 e2 f0             	and    $0xfffffff0,%edx
80107b82:	83 ca 02             	or     $0x2,%edx
80107b85:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107b95:	83 ca 10             	or     $0x10,%edx
80107b98:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba1:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ba8:	83 ca 60             	or     $0x60,%edx
80107bab:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bbb:	83 ca 80             	or     $0xffffff80,%edx
80107bbe:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bce:	83 ca 0f             	or     $0xf,%edx
80107bd1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bda:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107be1:	83 e2 ef             	and    $0xffffffef,%edx
80107be4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bed:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107bf4:	83 e2 df             	and    $0xffffffdf,%edx
80107bf7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c00:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c07:	83 ca 40             	or     $0x40,%edx
80107c0a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c13:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c1a:	83 ca 80             	or     $0xffffff80,%edx
80107c1d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c26:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c30:	05 b4 00 00 00       	add    $0xb4,%eax
80107c35:	89 c3                	mov    %eax,%ebx
80107c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3a:	05 b4 00 00 00       	add    $0xb4,%eax
80107c3f:	c1 e8 10             	shr    $0x10,%eax
80107c42:	89 c1                	mov    %eax,%ecx
80107c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c47:	05 b4 00 00 00       	add    $0xb4,%eax
80107c4c:	c1 e8 18             	shr    $0x18,%eax
80107c4f:	89 c2                	mov    %eax,%edx
80107c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c54:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107c5b:	00 00 
80107c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c60:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c6a:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c73:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c7a:	83 e1 f0             	and    $0xfffffff0,%ecx
80107c7d:	83 c9 02             	or     $0x2,%ecx
80107c80:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c89:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107c90:	83 c9 10             	or     $0x10,%ecx
80107c93:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9c:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ca3:	83 e1 9f             	and    $0xffffff9f,%ecx
80107ca6:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caf:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107cb6:	83 c9 80             	or     $0xffffff80,%ecx
80107cb9:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc2:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cc9:	83 e1 f0             	and    $0xfffffff0,%ecx
80107ccc:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd5:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cdc:	83 e1 ef             	and    $0xffffffef,%ecx
80107cdf:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce8:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107cef:	83 e1 df             	and    $0xffffffdf,%ecx
80107cf2:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfb:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d02:	83 c9 40             	or     $0x40,%ecx
80107d05:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0e:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107d15:	83 c9 80             	or     $0xffffff80,%ecx
80107d18:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d21:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2a:	83 c0 70             	add    $0x70,%eax
80107d2d:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107d34:	00 
80107d35:	89 04 24             	mov    %eax,(%esp)
80107d38:	e8 37 fb ff ff       	call   80107874 <lgdt>
  loadgs(SEG_KCPU << 3);
80107d3d:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107d44:	e8 6a fb ff ff       	call   801078b3 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4c:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107d52:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107d59:	00 00 00 00 
}
80107d5d:	83 c4 24             	add    $0x24,%esp
80107d60:	5b                   	pop    %ebx
80107d61:	5d                   	pop    %ebp
80107d62:	c3                   	ret    

80107d63 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107d63:	55                   	push   %ebp
80107d64:	89 e5                	mov    %esp,%ebp
80107d66:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107d69:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d6c:	c1 e8 16             	shr    $0x16,%eax
80107d6f:	c1 e0 02             	shl    $0x2,%eax
80107d72:	03 45 08             	add    0x8(%ebp),%eax
80107d75:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d7b:	8b 00                	mov    (%eax),%eax
80107d7d:	83 e0 01             	and    $0x1,%eax
80107d80:	84 c0                	test   %al,%al
80107d82:	74 17                	je     80107d9b <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107d84:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d87:	8b 00                	mov    (%eax),%eax
80107d89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d8e:	89 04 24             	mov    %eax,(%esp)
80107d91:	e8 4a fb ff ff       	call   801078e0 <p2v>
80107d96:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107d99:	eb 4b                	jmp    80107de6 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107d9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107d9f:	74 0e                	je     80107daf <walkpgdir+0x4c>
80107da1:	e8 7d ad ff ff       	call   80102b23 <kalloc>
80107da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107da9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107dad:	75 07                	jne    80107db6 <walkpgdir+0x53>
      return 0;
80107daf:	b8 00 00 00 00       	mov    $0x0,%eax
80107db4:	eb 41                	jmp    80107df7 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107db6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107dbd:	00 
80107dbe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107dc5:	00 
80107dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc9:	89 04 24             	mov    %eax,(%esp)
80107dcc:	e8 a9 d4 ff ff       	call   8010527a <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd4:	89 04 24             	mov    %eax,(%esp)
80107dd7:	e8 f7 fa ff ff       	call   801078d3 <v2p>
80107ddc:	89 c2                	mov    %eax,%edx
80107dde:	83 ca 07             	or     $0x7,%edx
80107de1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107de4:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107de6:	8b 45 0c             	mov    0xc(%ebp),%eax
80107de9:	c1 e8 0c             	shr    $0xc,%eax
80107dec:	25 ff 03 00 00       	and    $0x3ff,%eax
80107df1:	c1 e0 02             	shl    $0x2,%eax
80107df4:	03 45 f4             	add    -0xc(%ebp),%eax
}
80107df7:	c9                   	leave  
80107df8:	c3                   	ret    

80107df9 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107df9:	55                   	push   %ebp
80107dfa:	89 e5                	mov    %esp,%ebp
80107dfc:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107dff:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e0d:	03 45 10             	add    0x10(%ebp),%eax
80107e10:	83 e8 01             	sub    $0x1,%eax
80107e13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e18:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107e1b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107e22:	00 
80107e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e26:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80107e2d:	89 04 24             	mov    %eax,(%esp)
80107e30:	e8 2e ff ff ff       	call   80107d63 <walkpgdir>
80107e35:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107e38:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e3c:	75 07                	jne    80107e45 <mappages+0x4c>
      return -1;
80107e3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107e43:	eb 46                	jmp    80107e8b <mappages+0x92>
    if(*pte & PTE_P)
80107e45:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e48:	8b 00                	mov    (%eax),%eax
80107e4a:	83 e0 01             	and    $0x1,%eax
80107e4d:	84 c0                	test   %al,%al
80107e4f:	74 0c                	je     80107e5d <mappages+0x64>
      panic("remap");
80107e51:	c7 04 24 84 8c 10 80 	movl   $0x80108c84,(%esp)
80107e58:	e8 e0 86 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80107e5d:	8b 45 18             	mov    0x18(%ebp),%eax
80107e60:	0b 45 14             	or     0x14(%ebp),%eax
80107e63:	89 c2                	mov    %eax,%edx
80107e65:	83 ca 01             	or     $0x1,%edx
80107e68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e6b:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e70:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107e73:	74 10                	je     80107e85 <mappages+0x8c>
      break;
    a += PGSIZE;
80107e75:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107e7c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107e83:	eb 96                	jmp    80107e1b <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107e85:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107e86:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107e8b:	c9                   	leave  
80107e8c:	c3                   	ret    

80107e8d <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107e8d:	55                   	push   %ebp
80107e8e:	89 e5                	mov    %esp,%ebp
80107e90:	53                   	push   %ebx
80107e91:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107e94:	e8 8a ac ff ff       	call   80102b23 <kalloc>
80107e99:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107e9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ea0:	75 0a                	jne    80107eac <setupkvm+0x1f>
    return 0;
80107ea2:	b8 00 00 00 00       	mov    $0x0,%eax
80107ea7:	e9 98 00 00 00       	jmp    80107f44 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107eac:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107eb3:	00 
80107eb4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107ebb:	00 
80107ebc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ebf:	89 04 24             	mov    %eax,(%esp)
80107ec2:	e8 b3 d3 ff ff       	call   8010527a <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107ec7:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107ece:	e8 0d fa ff ff       	call   801078e0 <p2v>
80107ed3:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107ed8:	76 0c                	jbe    80107ee6 <setupkvm+0x59>
    panic("PHYSTOP too high");
80107eda:	c7 04 24 8a 8c 10 80 	movl   $0x80108c8a,(%esp)
80107ee1:	e8 57 86 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ee6:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107eed:	eb 49                	jmp    80107f38 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80107eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107ef2:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107ef5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107ef8:	8b 50 04             	mov    0x4(%eax),%edx
80107efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efe:	8b 58 08             	mov    0x8(%eax),%ebx
80107f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f04:	8b 40 04             	mov    0x4(%eax),%eax
80107f07:	29 c3                	sub    %eax,%ebx
80107f09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0c:	8b 00                	mov    (%eax),%eax
80107f0e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107f12:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f16:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f21:	89 04 24             	mov    %eax,(%esp)
80107f24:	e8 d0 fe ff ff       	call   80107df9 <mappages>
80107f29:	85 c0                	test   %eax,%eax
80107f2b:	79 07                	jns    80107f34 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107f2d:	b8 00 00 00 00       	mov    $0x0,%eax
80107f32:	eb 10                	jmp    80107f44 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f34:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107f38:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107f3f:	72 ae                	jb     80107eef <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107f44:	83 c4 34             	add    $0x34,%esp
80107f47:	5b                   	pop    %ebx
80107f48:	5d                   	pop    %ebp
80107f49:	c3                   	ret    

80107f4a <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107f4a:	55                   	push   %ebp
80107f4b:	89 e5                	mov    %esp,%ebp
80107f4d:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107f50:	e8 38 ff ff ff       	call   80107e8d <setupkvm>
80107f55:	a3 38 52 11 80       	mov    %eax,0x80115238
  switchkvm();
80107f5a:	e8 02 00 00 00       	call   80107f61 <switchkvm>
}
80107f5f:	c9                   	leave  
80107f60:	c3                   	ret    

80107f61 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107f61:	55                   	push   %ebp
80107f62:	89 e5                	mov    %esp,%ebp
80107f64:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107f67:	a1 38 52 11 80       	mov    0x80115238,%eax
80107f6c:	89 04 24             	mov    %eax,(%esp)
80107f6f:	e8 5f f9 ff ff       	call   801078d3 <v2p>
80107f74:	89 04 24             	mov    %eax,(%esp)
80107f77:	e8 4c f9 ff ff       	call   801078c8 <lcr3>
}
80107f7c:	c9                   	leave  
80107f7d:	c3                   	ret    

80107f7e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107f7e:	55                   	push   %ebp
80107f7f:	89 e5                	mov    %esp,%ebp
80107f81:	53                   	push   %ebx
80107f82:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107f85:	e8 e9 d1 ff ff       	call   80105173 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107f8a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f90:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107f97:	83 c2 08             	add    $0x8,%edx
80107f9a:	89 d3                	mov    %edx,%ebx
80107f9c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fa3:	83 c2 08             	add    $0x8,%edx
80107fa6:	c1 ea 10             	shr    $0x10,%edx
80107fa9:	89 d1                	mov    %edx,%ecx
80107fab:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107fb2:	83 c2 08             	add    $0x8,%edx
80107fb5:	c1 ea 18             	shr    $0x18,%edx
80107fb8:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107fbf:	67 00 
80107fc1:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107fc8:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107fce:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107fd5:	83 e1 f0             	and    $0xfffffff0,%ecx
80107fd8:	83 c9 09             	or     $0x9,%ecx
80107fdb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107fe1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107fe8:	83 c9 10             	or     $0x10,%ecx
80107feb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ff1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ff8:	83 e1 9f             	and    $0xffffff9f,%ecx
80107ffb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108001:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108008:	83 c9 80             	or     $0xffffff80,%ecx
8010800b:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80108011:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108018:	83 e1 f0             	and    $0xfffffff0,%ecx
8010801b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108021:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108028:	83 e1 ef             	and    $0xffffffef,%ecx
8010802b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108031:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108038:	83 e1 df             	and    $0xffffffdf,%ecx
8010803b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108041:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108048:	83 c9 40             	or     $0x40,%ecx
8010804b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108051:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108058:	83 e1 7f             	and    $0x7f,%ecx
8010805b:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80108061:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108067:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010806d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108074:	83 e2 ef             	and    $0xffffffef,%edx
80108077:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
8010807d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108083:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108089:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010808f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108096:	8b 52 08             	mov    0x8(%edx),%edx
80108099:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010809f:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801080a2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801080a9:	e8 ef f7 ff ff       	call   8010789d <ltr>
  if(p->pgdir == 0)
801080ae:	8b 45 08             	mov    0x8(%ebp),%eax
801080b1:	8b 40 04             	mov    0x4(%eax),%eax
801080b4:	85 c0                	test   %eax,%eax
801080b6:	75 0c                	jne    801080c4 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801080b8:	c7 04 24 9b 8c 10 80 	movl   $0x80108c9b,(%esp)
801080bf:	e8 79 84 ff ff       	call   8010053d <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
801080c4:	8b 45 08             	mov    0x8(%ebp),%eax
801080c7:	8b 40 04             	mov    0x4(%eax),%eax
801080ca:	89 04 24             	mov    %eax,(%esp)
801080cd:	e8 01 f8 ff ff       	call   801078d3 <v2p>
801080d2:	89 04 24             	mov    %eax,(%esp)
801080d5:	e8 ee f7 ff ff       	call   801078c8 <lcr3>
  popcli();
801080da:	e8 dc d0 ff ff       	call   801051bb <popcli>
}
801080df:	83 c4 14             	add    $0x14,%esp
801080e2:	5b                   	pop    %ebx
801080e3:	5d                   	pop    %ebp
801080e4:	c3                   	ret    

801080e5 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801080e5:	55                   	push   %ebp
801080e6:	89 e5                	mov    %esp,%ebp
801080e8:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801080eb:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801080f2:	76 0c                	jbe    80108100 <inituvm+0x1b>
    panic("inituvm: more than a page");
801080f4:	c7 04 24 af 8c 10 80 	movl   $0x80108caf,(%esp)
801080fb:	e8 3d 84 ff ff       	call   8010053d <panic>
  mem = kalloc();
80108100:	e8 1e aa ff ff       	call   80102b23 <kalloc>
80108105:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108108:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010810f:	00 
80108110:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108117:	00 
80108118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811b:	89 04 24             	mov    %eax,(%esp)
8010811e:	e8 57 d1 ff ff       	call   8010527a <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108123:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108126:	89 04 24             	mov    %eax,(%esp)
80108129:	e8 a5 f7 ff ff       	call   801078d3 <v2p>
8010812e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108135:	00 
80108136:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010813a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108141:	00 
80108142:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108149:	00 
8010814a:	8b 45 08             	mov    0x8(%ebp),%eax
8010814d:	89 04 24             	mov    %eax,(%esp)
80108150:	e8 a4 fc ff ff       	call   80107df9 <mappages>
  memmove(mem, init, sz);
80108155:	8b 45 10             	mov    0x10(%ebp),%eax
80108158:	89 44 24 08          	mov    %eax,0x8(%esp)
8010815c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010815f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108166:	89 04 24             	mov    %eax,(%esp)
80108169:	e8 df d1 ff ff       	call   8010534d <memmove>
}
8010816e:	c9                   	leave  
8010816f:	c3                   	ret    

80108170 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108170:	55                   	push   %ebp
80108171:	89 e5                	mov    %esp,%ebp
80108173:	53                   	push   %ebx
80108174:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108177:	8b 45 0c             	mov    0xc(%ebp),%eax
8010817a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010817f:	85 c0                	test   %eax,%eax
80108181:	74 0c                	je     8010818f <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80108183:	c7 04 24 cc 8c 10 80 	movl   $0x80108ccc,(%esp)
8010818a:	e8 ae 83 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010818f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108196:	e9 ad 00 00 00       	jmp    80108248 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010819b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010819e:	8b 55 0c             	mov    0xc(%ebp),%edx
801081a1:	01 d0                	add    %edx,%eax
801081a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801081aa:	00 
801081ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801081af:	8b 45 08             	mov    0x8(%ebp),%eax
801081b2:	89 04 24             	mov    %eax,(%esp)
801081b5:	e8 a9 fb ff ff       	call   80107d63 <walkpgdir>
801081ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081c1:	75 0c                	jne    801081cf <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801081c3:	c7 04 24 ef 8c 10 80 	movl   $0x80108cef,(%esp)
801081ca:	e8 6e 83 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801081cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081d2:	8b 00                	mov    (%eax),%eax
801081d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081d9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801081dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081df:	8b 55 18             	mov    0x18(%ebp),%edx
801081e2:	89 d1                	mov    %edx,%ecx
801081e4:	29 c1                	sub    %eax,%ecx
801081e6:	89 c8                	mov    %ecx,%eax
801081e8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801081ed:	77 11                	ja     80108200 <loaduvm+0x90>
      n = sz - i;
801081ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f2:	8b 55 18             	mov    0x18(%ebp),%edx
801081f5:	89 d1                	mov    %edx,%ecx
801081f7:	29 c1                	sub    %eax,%ecx
801081f9:	89 c8                	mov    %ecx,%eax
801081fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801081fe:	eb 07                	jmp    80108207 <loaduvm+0x97>
    else
      n = PGSIZE;
80108200:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108207:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010820a:	8b 55 14             	mov    0x14(%ebp),%edx
8010820d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108210:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108213:	89 04 24             	mov    %eax,(%esp)
80108216:	e8 c5 f6 ff ff       	call   801078e0 <p2v>
8010821b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010821e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108222:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108226:	89 44 24 04          	mov    %eax,0x4(%esp)
8010822a:	8b 45 10             	mov    0x10(%ebp),%eax
8010822d:	89 04 24             	mov    %eax,(%esp)
80108230:	e8 4d 9b ff ff       	call   80101d82 <readi>
80108235:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108238:	74 07                	je     80108241 <loaduvm+0xd1>
      return -1;
8010823a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010823f:	eb 18                	jmp    80108259 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108241:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010824b:	3b 45 18             	cmp    0x18(%ebp),%eax
8010824e:	0f 82 47 ff ff ff    	jb     8010819b <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108254:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108259:	83 c4 24             	add    $0x24,%esp
8010825c:	5b                   	pop    %ebx
8010825d:	5d                   	pop    %ebp
8010825e:	c3                   	ret    

8010825f <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010825f:	55                   	push   %ebp
80108260:	89 e5                	mov    %esp,%ebp
80108262:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108265:	8b 45 10             	mov    0x10(%ebp),%eax
80108268:	85 c0                	test   %eax,%eax
8010826a:	79 0a                	jns    80108276 <allocuvm+0x17>
    return 0;
8010826c:	b8 00 00 00 00       	mov    $0x0,%eax
80108271:	e9 c1 00 00 00       	jmp    80108337 <allocuvm+0xd8>
  if(newsz < oldsz)
80108276:	8b 45 10             	mov    0x10(%ebp),%eax
80108279:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010827c:	73 08                	jae    80108286 <allocuvm+0x27>
    return oldsz;
8010827e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108281:	e9 b1 00 00 00       	jmp    80108337 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80108286:	8b 45 0c             	mov    0xc(%ebp),%eax
80108289:	05 ff 0f 00 00       	add    $0xfff,%eax
8010828e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108293:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108296:	e9 8d 00 00 00       	jmp    80108328 <allocuvm+0xc9>
    mem = kalloc();
8010829b:	e8 83 a8 ff ff       	call   80102b23 <kalloc>
801082a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801082a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801082a7:	75 2c                	jne    801082d5 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801082a9:	c7 04 24 0d 8d 10 80 	movl   $0x80108d0d,(%esp)
801082b0:	e8 ec 80 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801082b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801082b8:	89 44 24 08          	mov    %eax,0x8(%esp)
801082bc:	8b 45 10             	mov    0x10(%ebp),%eax
801082bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801082c3:	8b 45 08             	mov    0x8(%ebp),%eax
801082c6:	89 04 24             	mov    %eax,(%esp)
801082c9:	e8 6b 00 00 00       	call   80108339 <deallocuvm>
      return 0;
801082ce:	b8 00 00 00 00       	mov    $0x0,%eax
801082d3:	eb 62                	jmp    80108337 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801082d5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082dc:	00 
801082dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082e4:	00 
801082e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082e8:	89 04 24             	mov    %eax,(%esp)
801082eb:	e8 8a cf ff ff       	call   8010527a <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
801082f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082f3:	89 04 24             	mov    %eax,(%esp)
801082f6:	e8 d8 f5 ff ff       	call   801078d3 <v2p>
801082fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801082fe:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108305:	00 
80108306:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010830a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108311:	00 
80108312:	89 54 24 04          	mov    %edx,0x4(%esp)
80108316:	8b 45 08             	mov    0x8(%ebp),%eax
80108319:	89 04 24             	mov    %eax,(%esp)
8010831c:	e8 d8 fa ff ff       	call   80107df9 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108321:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010832e:	0f 82 67 ff ff ff    	jb     8010829b <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108334:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108337:	c9                   	leave  
80108338:	c3                   	ret    

80108339 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108339:	55                   	push   %ebp
8010833a:	89 e5                	mov    %esp,%ebp
8010833c:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010833f:	8b 45 10             	mov    0x10(%ebp),%eax
80108342:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108345:	72 08                	jb     8010834f <deallocuvm+0x16>
    return oldsz;
80108347:	8b 45 0c             	mov    0xc(%ebp),%eax
8010834a:	e9 a4 00 00 00       	jmp    801083f3 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010834f:	8b 45 10             	mov    0x10(%ebp),%eax
80108352:	05 ff 0f 00 00       	add    $0xfff,%eax
80108357:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010835c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010835f:	e9 80 00 00 00       	jmp    801083e4 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108367:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010836e:	00 
8010836f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108373:	8b 45 08             	mov    0x8(%ebp),%eax
80108376:	89 04 24             	mov    %eax,(%esp)
80108379:	e8 e5 f9 ff ff       	call   80107d63 <walkpgdir>
8010837e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108381:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108385:	75 09                	jne    80108390 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80108387:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
8010838e:	eb 4d                	jmp    801083dd <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80108390:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108393:	8b 00                	mov    (%eax),%eax
80108395:	83 e0 01             	and    $0x1,%eax
80108398:	84 c0                	test   %al,%al
8010839a:	74 41                	je     801083dd <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
8010839c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010839f:	8b 00                	mov    (%eax),%eax
801083a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801083a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083ad:	75 0c                	jne    801083bb <deallocuvm+0x82>
        panic("kfree");
801083af:	c7 04 24 25 8d 10 80 	movl   $0x80108d25,(%esp)
801083b6:	e8 82 81 ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
801083bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083be:	89 04 24             	mov    %eax,(%esp)
801083c1:	e8 1a f5 ff ff       	call   801078e0 <p2v>
801083c6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801083c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801083cc:	89 04 24             	mov    %eax,(%esp)
801083cf:	e8 b6 a6 ff ff       	call   80102a8a <kfree>
      *pte = 0;
801083d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801083dd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083ea:	0f 82 74 ff ff ff    	jb     80108364 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801083f0:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083f3:	c9                   	leave  
801083f4:	c3                   	ret    

801083f5 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801083f5:	55                   	push   %ebp
801083f6:	89 e5                	mov    %esp,%ebp
801083f8:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801083fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801083ff:	75 0c                	jne    8010840d <freevm+0x18>
    panic("freevm: no pgdir");
80108401:	c7 04 24 2b 8d 10 80 	movl   $0x80108d2b,(%esp)
80108408:	e8 30 81 ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010840d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108414:	00 
80108415:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010841c:	80 
8010841d:	8b 45 08             	mov    0x8(%ebp),%eax
80108420:	89 04 24             	mov    %eax,(%esp)
80108423:	e8 11 ff ff ff       	call   80108339 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108428:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010842f:	eb 3c                	jmp    8010846d <freevm+0x78>
    if(pgdir[i] & PTE_P){
80108431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108434:	c1 e0 02             	shl    $0x2,%eax
80108437:	03 45 08             	add    0x8(%ebp),%eax
8010843a:	8b 00                	mov    (%eax),%eax
8010843c:	83 e0 01             	and    $0x1,%eax
8010843f:	84 c0                	test   %al,%al
80108441:	74 26                	je     80108469 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108446:	c1 e0 02             	shl    $0x2,%eax
80108449:	03 45 08             	add    0x8(%ebp),%eax
8010844c:	8b 00                	mov    (%eax),%eax
8010844e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108453:	89 04 24             	mov    %eax,(%esp)
80108456:	e8 85 f4 ff ff       	call   801078e0 <p2v>
8010845b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010845e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108461:	89 04 24             	mov    %eax,(%esp)
80108464:	e8 21 a6 ff ff       	call   80102a8a <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108469:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010846d:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108474:	76 bb                	jbe    80108431 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108476:	8b 45 08             	mov    0x8(%ebp),%eax
80108479:	89 04 24             	mov    %eax,(%esp)
8010847c:	e8 09 a6 ff ff       	call   80102a8a <kfree>
}
80108481:	c9                   	leave  
80108482:	c3                   	ret    

80108483 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108483:	55                   	push   %ebp
80108484:	89 e5                	mov    %esp,%ebp
80108486:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108489:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108490:	00 
80108491:	8b 45 0c             	mov    0xc(%ebp),%eax
80108494:	89 44 24 04          	mov    %eax,0x4(%esp)
80108498:	8b 45 08             	mov    0x8(%ebp),%eax
8010849b:	89 04 24             	mov    %eax,(%esp)
8010849e:	e8 c0 f8 ff ff       	call   80107d63 <walkpgdir>
801084a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801084a6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801084aa:	75 0c                	jne    801084b8 <clearpteu+0x35>
    panic("clearpteu");
801084ac:	c7 04 24 3c 8d 10 80 	movl   $0x80108d3c,(%esp)
801084b3:	e8 85 80 ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
801084b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bb:	8b 00                	mov    (%eax),%eax
801084bd:	89 c2                	mov    %eax,%edx
801084bf:	83 e2 fb             	and    $0xfffffffb,%edx
801084c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c5:	89 10                	mov    %edx,(%eax)
}
801084c7:	c9                   	leave  
801084c8:	c3                   	ret    

801084c9 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801084c9:	55                   	push   %ebp
801084ca:	89 e5                	mov    %esp,%ebp
801084cc:	53                   	push   %ebx
801084cd:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801084d0:	e8 b8 f9 ff ff       	call   80107e8d <setupkvm>
801084d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801084d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084dc:	75 0a                	jne    801084e8 <copyuvm+0x1f>
    return 0;
801084de:	b8 00 00 00 00       	mov    $0x0,%eax
801084e3:	e9 fd 00 00 00       	jmp    801085e5 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
801084e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084ef:	e9 cc 00 00 00       	jmp    801085c0 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801084f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084fe:	00 
801084ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80108503:	8b 45 08             	mov    0x8(%ebp),%eax
80108506:	89 04 24             	mov    %eax,(%esp)
80108509:	e8 55 f8 ff ff       	call   80107d63 <walkpgdir>
8010850e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108511:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108515:	75 0c                	jne    80108523 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108517:	c7 04 24 46 8d 10 80 	movl   $0x80108d46,(%esp)
8010851e:	e8 1a 80 ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108523:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108526:	8b 00                	mov    (%eax),%eax
80108528:	83 e0 01             	and    $0x1,%eax
8010852b:	85 c0                	test   %eax,%eax
8010852d:	75 0c                	jne    8010853b <copyuvm+0x72>
      panic("copyuvm: page not present");
8010852f:	c7 04 24 60 8d 10 80 	movl   $0x80108d60,(%esp)
80108536:	e8 02 80 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
8010853b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010853e:	8b 00                	mov    (%eax),%eax
80108540:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108545:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108548:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010854b:	8b 00                	mov    (%eax),%eax
8010854d:	25 ff 0f 00 00       	and    $0xfff,%eax
80108552:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108555:	e8 c9 a5 ff ff       	call   80102b23 <kalloc>
8010855a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010855d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108561:	74 6e                	je     801085d1 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108563:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108566:	89 04 24             	mov    %eax,(%esp)
80108569:	e8 72 f3 ff ff       	call   801078e0 <p2v>
8010856e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108575:	00 
80108576:	89 44 24 04          	mov    %eax,0x4(%esp)
8010857a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010857d:	89 04 24             	mov    %eax,(%esp)
80108580:	e8 c8 cd ff ff       	call   8010534d <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108585:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108588:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010858b:	89 04 24             	mov    %eax,(%esp)
8010858e:	e8 40 f3 ff ff       	call   801078d3 <v2p>
80108593:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108596:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010859a:	89 44 24 0c          	mov    %eax,0xc(%esp)
8010859e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085a5:	00 
801085a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801085aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ad:	89 04 24             	mov    %eax,(%esp)
801085b0:	e8 44 f8 ff ff       	call   80107df9 <mappages>
801085b5:	85 c0                	test   %eax,%eax
801085b7:	78 1b                	js     801085d4 <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801085b9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801085c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085c6:	0f 82 28 ff ff ff    	jb     801084f4 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801085cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085cf:	eb 14                	jmp    801085e5 <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801085d1:	90                   	nop
801085d2:	eb 01                	jmp    801085d5 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801085d4:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801085d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085d8:	89 04 24             	mov    %eax,(%esp)
801085db:	e8 15 fe ff ff       	call   801083f5 <freevm>
  return 0;
801085e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085e5:	83 c4 44             	add    $0x44,%esp
801085e8:	5b                   	pop    %ebx
801085e9:	5d                   	pop    %ebp
801085ea:	c3                   	ret    

801085eb <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801085eb:	55                   	push   %ebp
801085ec:	89 e5                	mov    %esp,%ebp
801085ee:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085f8:	00 
801085f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801085fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80108600:	8b 45 08             	mov    0x8(%ebp),%eax
80108603:	89 04 24             	mov    %eax,(%esp)
80108606:	e8 58 f7 ff ff       	call   80107d63 <walkpgdir>
8010860b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010860e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108611:	8b 00                	mov    (%eax),%eax
80108613:	83 e0 01             	and    $0x1,%eax
80108616:	85 c0                	test   %eax,%eax
80108618:	75 07                	jne    80108621 <uva2ka+0x36>
    return 0;
8010861a:	b8 00 00 00 00       	mov    $0x0,%eax
8010861f:	eb 25                	jmp    80108646 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108624:	8b 00                	mov    (%eax),%eax
80108626:	83 e0 04             	and    $0x4,%eax
80108629:	85 c0                	test   %eax,%eax
8010862b:	75 07                	jne    80108634 <uva2ka+0x49>
    return 0;
8010862d:	b8 00 00 00 00       	mov    $0x0,%eax
80108632:	eb 12                	jmp    80108646 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108634:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108637:	8b 00                	mov    (%eax),%eax
80108639:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010863e:	89 04 24             	mov    %eax,(%esp)
80108641:	e8 9a f2 ff ff       	call   801078e0 <p2v>
}
80108646:	c9                   	leave  
80108647:	c3                   	ret    

80108648 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108648:	55                   	push   %ebp
80108649:	89 e5                	mov    %esp,%ebp
8010864b:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010864e:	8b 45 10             	mov    0x10(%ebp),%eax
80108651:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108654:	e9 8b 00 00 00       	jmp    801086e4 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108659:	8b 45 0c             	mov    0xc(%ebp),%eax
8010865c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108661:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108664:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108667:	89 44 24 04          	mov    %eax,0x4(%esp)
8010866b:	8b 45 08             	mov    0x8(%ebp),%eax
8010866e:	89 04 24             	mov    %eax,(%esp)
80108671:	e8 75 ff ff ff       	call   801085eb <uva2ka>
80108676:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108679:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010867d:	75 07                	jne    80108686 <copyout+0x3e>
      return -1;
8010867f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108684:	eb 6d                	jmp    801086f3 <copyout+0xab>
    n = PGSIZE - (va - va0);
80108686:	8b 45 0c             	mov    0xc(%ebp),%eax
80108689:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010868c:	89 d1                	mov    %edx,%ecx
8010868e:	29 c1                	sub    %eax,%ecx
80108690:	89 c8                	mov    %ecx,%eax
80108692:	05 00 10 00 00       	add    $0x1000,%eax
80108697:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010869a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010869d:	3b 45 14             	cmp    0x14(%ebp),%eax
801086a0:	76 06                	jbe    801086a8 <copyout+0x60>
      n = len;
801086a2:	8b 45 14             	mov    0x14(%ebp),%eax
801086a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801086a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086ab:	8b 55 0c             	mov    0xc(%ebp),%edx
801086ae:	89 d1                	mov    %edx,%ecx
801086b0:	29 c1                	sub    %eax,%ecx
801086b2:	89 c8                	mov    %ecx,%eax
801086b4:	03 45 e8             	add    -0x18(%ebp),%eax
801086b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801086ba:	89 54 24 08          	mov    %edx,0x8(%esp)
801086be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801086c5:	89 04 24             	mov    %eax,(%esp)
801086c8:	e8 80 cc ff ff       	call   8010534d <memmove>
    len -= n;
801086cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d0:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801086d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d6:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801086d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086dc:	05 00 10 00 00       	add    $0x1000,%eax
801086e1:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801086e4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801086e8:	0f 85 6b ff ff ff    	jne    80108659 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801086ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086f3:	c9                   	leave  
801086f4:	c3                   	ret    
