
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
80100028:	bc 50 d6 10 80       	mov    $0x8010d650,%esp

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
8010003a:	c7 44 24 04 cc 89 10 	movl   $0x801089cc,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100049:	e8 30 4e 00 00       	call   80104e7e <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 70 15 11 80 64 	movl   $0x80111564,0x80111570
80100055:	15 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 74 15 11 80 64 	movl   $0x80111564,0x80111574
8010005f:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 94 d6 10 80 	movl   $0x8010d694,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 74 15 11 80       	mov    0x80111574,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 74 15 11 80       	mov    %eax,0x80111574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
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
801000b6:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801000bd:	e8 dd 4d 00 00       	call   80104e9f <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 74 15 11 80       	mov    0x80111574,%eax
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
801000fd:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
80100104:	e8 f8 4d 00 00       	call   80104f01 <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 60 d6 10 	movl   $0x8010d660,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 9d 4a 00 00       	call   80104bc1 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 70 15 11 80       	mov    0x80111570,%eax
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
80100175:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010017c:	e8 80 4d 00 00       	call   80104f01 <release>
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
8010018f:	81 7d f4 64 15 11 80 	cmpl   $0x80111564,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 d3 89 10 80 	movl   $0x801089d3,(%esp)
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
801001ef:	c7 04 24 e4 89 10 80 	movl   $0x801089e4,(%esp)
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
80100229:	c7 04 24 eb 89 10 80 	movl   $0x801089eb,(%esp)
80100230:	e8 08 03 00 00       	call   8010053d <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
8010023c:	e8 5e 4c 00 00       	call   80104e9f <acquire>

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
8010025f:	8b 15 74 15 11 80    	mov    0x80111574,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c 64 15 11 80 	movl   $0x80111564,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 74 15 11 80       	mov    0x80111574,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 74 15 11 80       	mov    %eax,0x80111574

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
8010029d:	e8 f8 49 00 00       	call   80104c9a <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 60 d6 10 80 	movl   $0x8010d660,(%esp)
801002a9:	e8 53 4c 00 00       	call   80104f01 <release>
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
801003a7:	a1 f4 c5 10 80       	mov    0x8010c5f4,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
801003bc:	e8 de 4a 00 00       	call   80104e9f <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 f2 89 10 80 	movl   $0x801089f2,(%esp)
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
801004af:	c7 45 ec fb 89 10 80 	movl   $0x801089fb,-0x14(%ebp)
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
8010052f:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100536:	e8 c6 49 00 00       	call   80104f01 <release>
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
80100548:	c7 05 f4 c5 10 80 00 	movl   $0x0,0x8010c5f4
8010054f:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100552:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100558:	0f b6 00             	movzbl (%eax),%eax
8010055b:	0f b6 c0             	movzbl %al,%eax
8010055e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100562:	c7 04 24 02 8a 10 80 	movl   $0x80108a02,(%esp)
80100569:	e8 33 fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
8010056e:	8b 45 08             	mov    0x8(%ebp),%eax
80100571:	89 04 24             	mov    %eax,(%esp)
80100574:	e8 28 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100579:	c7 04 24 11 8a 10 80 	movl   $0x80108a11,(%esp)
80100580:	e8 1c fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
80100585:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010058c:	8d 45 08             	lea    0x8(%ebp),%eax
8010058f:	89 04 24             	mov    %eax,(%esp)
80100592:	e8 b9 49 00 00       	call   80104f50 <getcallerpcs>
  for(i=0; i<10; i++)
80100597:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059e:	eb 1b                	jmp    801005bb <panic+0x7e>
    cprintf(" %p", pcs[i]);
801005a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005ab:	c7 04 24 13 8a 10 80 	movl   $0x80108a13,(%esp)
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
801005c1:	c7 05 a0 c5 10 80 01 	movl   $0x1,0x8010c5a0
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
801006b2:	e8 0a 4b 00 00       	call   801051c1 <memmove>
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
801006e1:	e8 08 4a 00 00       	call   801050ee <memset>
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
80100756:	a1 a0 c5 10 80       	mov    0x8010c5a0,%eax
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
80100776:	e8 c2 64 00 00       	call   80106c3d <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 b6 64 00 00       	call   80106c3d <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 aa 64 00 00       	call   80106c3d <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 9d 64 00 00       	call   80106c3d <uartputc>
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
801007b3:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
801007ba:	e8 e0 46 00 00       	call   80104e9f <acquire>
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
801007ea:	e8 4e 45 00 00       	call   80104d3d <procdump>
      break;
801007ef:	e9 11 01 00 00       	jmp    80100905 <consoleintr+0x158>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 3c 18 11 80       	mov    %eax,0x8011183c
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
80100810:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
80100816:	a1 38 18 11 80       	mov    0x80111838,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	0f 84 db 00 00 00    	je     801008fe <consoleintr+0x151>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100823:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100828:	83 e8 01             	sub    $0x1,%eax
8010082b:	83 e0 7f             	and    $0x7f,%eax
8010082e:	0f b6 80 b4 17 11 80 	movzbl -0x7feee84c(%eax),%eax
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
8010083e:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
80100844:	a1 38 18 11 80       	mov    0x80111838,%eax
80100849:	39 c2                	cmp    %eax,%edx
8010084b:	0f 84 b0 00 00 00    	je     80100901 <consoleintr+0x154>
        input.e--;
80100851:	a1 3c 18 11 80       	mov    0x8011183c,%eax
80100856:	83 e8 01             	sub    $0x1,%eax
80100859:	a3 3c 18 11 80       	mov    %eax,0x8011183c
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
80100879:	8b 15 3c 18 11 80    	mov    0x8011183c,%edx
8010087f:	a1 34 18 11 80       	mov    0x80111834,%eax
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
801008a2:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801008a7:	89 c1                	mov    %eax,%ecx
801008a9:	83 e1 7f             	and    $0x7f,%ecx
801008ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008af:	88 91 b4 17 11 80    	mov    %dl,-0x7feee84c(%ecx)
801008b5:	83 c0 01             	add    $0x1,%eax
801008b8:	a3 3c 18 11 80       	mov    %eax,0x8011183c
        consputc(c);
801008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008c0:	89 04 24             	mov    %eax,(%esp)
801008c3:	e8 88 fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c8:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008cc:	74 18                	je     801008e6 <consoleintr+0x139>
801008ce:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008d2:	74 12                	je     801008e6 <consoleintr+0x139>
801008d4:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801008d9:	8b 15 34 18 11 80    	mov    0x80111834,%edx
801008df:	83 ea 80             	sub    $0xffffff80,%edx
801008e2:	39 d0                	cmp    %edx,%eax
801008e4:	75 1e                	jne    80100904 <consoleintr+0x157>
          input.w = input.e;
801008e6:	a1 3c 18 11 80       	mov    0x8011183c,%eax
801008eb:	a3 38 18 11 80       	mov    %eax,0x80111838
          wakeup(&input.r);
801008f0:	c7 04 24 34 18 11 80 	movl   $0x80111834,(%esp)
801008f7:	e8 9e 43 00 00       	call   80104c9a <wakeup>
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
80100917:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
8010091e:	e8 de 45 00 00       	call   80104f01 <release>
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
8010093c:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100943:	e8 57 45 00 00       	call   80104e9f <acquire>
  while(n > 0){
80100948:	e9 a8 00 00 00       	jmp    801009f5 <consoleread+0xd0>
    while(input.r == input.w){
      if(proc->killed){
8010094d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100953:	8b 40 24             	mov    0x24(%eax),%eax
80100956:	85 c0                	test   %eax,%eax
80100958:	74 21                	je     8010097b <consoleread+0x56>
        release(&input.lock);
8010095a:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100961:	e8 9b 45 00 00       	call   80104f01 <release>
        ilock(ip);
80100966:	8b 45 08             	mov    0x8(%ebp),%eax
80100969:	89 04 24             	mov    %eax,(%esp)
8010096c:	e8 03 0f 00 00       	call   80101874 <ilock>
        return -1;
80100971:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100976:	e9 a9 00 00 00       	jmp    80100a24 <consoleread+0xff>
      }
      sleep(&input.r, &input.lock);
8010097b:	c7 44 24 04 80 17 11 	movl   $0x80111780,0x4(%esp)
80100982:	80 
80100983:	c7 04 24 34 18 11 80 	movl   $0x80111834,(%esp)
8010098a:	e8 32 42 00 00       	call   80104bc1 <sleep>
8010098f:	eb 01                	jmp    80100992 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100991:	90                   	nop
80100992:	8b 15 34 18 11 80    	mov    0x80111834,%edx
80100998:	a1 38 18 11 80       	mov    0x80111838,%eax
8010099d:	39 c2                	cmp    %eax,%edx
8010099f:	74 ac                	je     8010094d <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009a1:	a1 34 18 11 80       	mov    0x80111834,%eax
801009a6:	89 c2                	mov    %eax,%edx
801009a8:	83 e2 7f             	and    $0x7f,%edx
801009ab:	0f b6 92 b4 17 11 80 	movzbl -0x7feee84c(%edx),%edx
801009b2:	0f be d2             	movsbl %dl,%edx
801009b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801009b8:	83 c0 01             	add    $0x1,%eax
801009bb:	a3 34 18 11 80       	mov    %eax,0x80111834
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
801009ce:	a1 34 18 11 80       	mov    0x80111834,%eax
801009d3:	83 e8 01             	sub    $0x1,%eax
801009d6:	a3 34 18 11 80       	mov    %eax,0x80111834
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
80100a01:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100a08:	e8 f4 44 00 00       	call   80104f01 <release>
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
80100a37:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a3e:	e8 5c 44 00 00       	call   80104e9f <acquire>
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
80100a71:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100a78:	e8 84 44 00 00       	call   80104f01 <release>
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
80100a93:	c7 44 24 04 17 8a 10 	movl   $0x80108a17,0x4(%esp)
80100a9a:	80 
80100a9b:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
80100aa2:	e8 d7 43 00 00       	call   80104e7e <initlock>
  initlock(&input.lock, "input");
80100aa7:	c7 44 24 04 1f 8a 10 	movl   $0x80108a1f,0x4(%esp)
80100aae:	80 
80100aaf:	c7 04 24 80 17 11 80 	movl   $0x80111780,(%esp)
80100ab6:	e8 c3 43 00 00       	call   80104e7e <initlock>

  devsw[CONSOLE].write = consolewrite;
80100abb:	c7 05 ec 21 11 80 26 	movl   $0x80100a26,0x801121ec
80100ac2:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ac5:	c7 05 e8 21 11 80 25 	movl   $0x80100925,0x801121e8
80100acc:	09 10 80 
  cons.locking = 1;
80100acf:	c7 05 f4 c5 10 80 01 	movl   $0x1,0x8010c5f4
80100ad6:	00 00 00 

  picenable(IRQ_KBD);
80100ad9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae0:	e8 54 33 00 00       	call   80103e39 <picenable>
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
80100b7e:	e8 31 75 00 00       	call   801080b4 <setupkvm>
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
80100c17:	e8 61 78 00 00       	call   8010847d <allocuvm>
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
80100c54:	e8 35 77 00 00       	call   8010838e <loaduvm>
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
80100cc4:	e8 b4 77 00 00       	call   8010847d <allocuvm>
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
80100ce8:	e8 b4 79 00 00       	call   801086a1 <clearpteu>
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
80100d17:	e8 50 46 00 00       	call   8010536c <strlen>
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
80100d35:	e8 32 46 00 00       	call   8010536c <strlen>
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
80100d5f:	e8 02 7b 00 00       	call   80108866 <copyout>
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
80100dff:	e8 62 7a 00 00       	call   80108866 <copyout>
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
80100e56:	e8 c3 44 00 00       	call   8010531e <safestrcpy>

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
80100ea8:	e8 00 73 00 00       	call   801081ad <switchuvm>
  freevm(oldpgdir);
80100ead:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100eb0:	89 04 24             	mov    %eax,(%esp)
80100eb3:	e8 5b 77 00 00       	call   80108613 <freevm>
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
80100eea:	e8 24 77 00 00       	call   80108613 <freevm>
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
80100f12:	c7 44 24 04 25 8a 10 	movl   $0x80108a25,0x4(%esp)
80100f19:	80 
80100f1a:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f21:	e8 58 3f 00 00       	call   80104e7e <initlock>
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
80100f2e:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f35:	e8 65 3f 00 00       	call   80104e9f <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f3a:	c7 45 f4 74 18 11 80 	movl   $0x80111874,-0xc(%ebp)
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
80100f57:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f5e:	e8 9e 3f 00 00       	call   80104f01 <release>
      return f;
80100f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f66:	eb 1e                	jmp    80100f86 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f68:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f6c:	81 7d f4 d4 21 11 80 	cmpl   $0x801121d4,-0xc(%ebp)
80100f73:	72 ce                	jb     80100f43 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f75:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f7c:	e8 80 3f 00 00       	call   80104f01 <release>
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
80100f8e:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100f95:	e8 05 3f 00 00       	call   80104e9f <acquire>
  if(f->ref < 1)
80100f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9d:	8b 40 04             	mov    0x4(%eax),%eax
80100fa0:	85 c0                	test   %eax,%eax
80100fa2:	7f 0c                	jg     80100fb0 <filedup+0x28>
    panic("filedup");
80100fa4:	c7 04 24 2c 8a 10 80 	movl   $0x80108a2c,(%esp)
80100fab:	e8 8d f5 ff ff       	call   8010053d <panic>
  f->ref++;
80100fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb3:	8b 40 04             	mov    0x4(%eax),%eax
80100fb6:	8d 50 01             	lea    0x1(%eax),%edx
80100fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80100fbc:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fbf:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100fc6:	e8 36 3f 00 00       	call   80104f01 <release>
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
80100fd6:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80100fdd:	e8 bd 3e 00 00       	call   80104e9f <acquire>
  if(f->ref < 1)
80100fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe5:	8b 40 04             	mov    0x4(%eax),%eax
80100fe8:	85 c0                	test   %eax,%eax
80100fea:	7f 0c                	jg     80100ff8 <fileclose+0x28>
    panic("fileclose");
80100fec:	c7 04 24 34 8a 10 80 	movl   $0x80108a34,(%esp)
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
80101011:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80101018:	e8 e4 3e 00 00       	call   80104f01 <release>
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
8010105b:	c7 04 24 40 18 11 80 	movl   $0x80111840,(%esp)
80101062:	e8 9a 3e 00 00       	call   80104f01 <release>
  
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
80101080:	e8 6e 30 00 00       	call   801040f3 <pipeclose>
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
80101131:	e8 3f 31 00 00       	call   80104275 <piperead>
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
801011a3:	c7 04 24 3e 8a 10 80 	movl   $0x80108a3e,(%esp)
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
801011ee:	e8 92 2f 00 00       	call   80104185 <pipewrite>
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
801012af:	c7 04 24 47 8a 10 80 	movl   $0x80108a47,(%esp)
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
801012e4:	c7 04 24 57 8a 10 80 	movl   $0x80108a57,(%esp)
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
8010132c:	e8 90 3e 00 00       	call   801051c1 <memmove>
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
80101372:	e8 77 3d 00 00       	call   801050ee <memset>
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
801014da:	c7 04 24 61 8a 10 80 	movl   $0x80108a61,(%esp)
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
80101571:	c7 04 24 77 8a 10 80 	movl   $0x80108a77,(%esp)
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
801015c5:	c7 44 24 04 8a 8a 10 	movl   $0x80108a8a,0x4(%esp)
801015cc:	80 
801015cd:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801015d4:	e8 a5 38 00 00       	call   80104e7e <initlock>
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
80101656:	e8 93 3a 00 00       	call   801050ee <memset>
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
801016ac:	c7 04 24 91 8a 10 80 	movl   $0x80108a91,(%esp)
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
80101753:	e8 69 3a 00 00       	call   801051c1 <memmove>
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
80101776:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
8010177d:	e8 1d 37 00 00       	call   80104e9f <acquire>

  // Is the inode already cached?
  empty = 0;
80101782:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101789:	c7 45 f4 74 22 11 80 	movl   $0x80112274,-0xc(%ebp)
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
801017c0:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801017c7:	e8 35 37 00 00       	call   80104f01 <release>
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
801017eb:	81 7d f4 14 32 11 80 	cmpl   $0x80113214,-0xc(%ebp)
801017f2:	72 9e                	jb     80101792 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017f8:	75 0c                	jne    80101806 <iget+0x96>
    panic("iget: no inodes");
801017fa:	c7 04 24 a3 8a 10 80 	movl   $0x80108aa3,(%esp)
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
80101831:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101838:	e8 c4 36 00 00       	call   80104f01 <release>

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
80101848:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
8010184f:	e8 4b 36 00 00       	call   80104e9f <acquire>
  ip->ref++;
80101854:	8b 45 08             	mov    0x8(%ebp),%eax
80101857:	8b 40 08             	mov    0x8(%eax),%eax
8010185a:	8d 50 01             	lea    0x1(%eax),%edx
8010185d:	8b 45 08             	mov    0x8(%ebp),%eax
80101860:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101863:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
8010186a:	e8 92 36 00 00       	call   80104f01 <release>
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
8010188a:	c7 04 24 b3 8a 10 80 	movl   $0x80108ab3,(%esp)
80101891:	e8 a7 ec ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
80101896:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
8010189d:	e8 fd 35 00 00       	call   80104e9f <acquire>
  while(ip->flags & I_BUSY)
801018a2:	eb 13                	jmp    801018b7 <ilock+0x43>
    sleep(ip, &icache.lock);
801018a4:	c7 44 24 04 40 22 11 	movl   $0x80112240,0x4(%esp)
801018ab:	80 
801018ac:	8b 45 08             	mov    0x8(%ebp),%eax
801018af:	89 04 24             	mov    %eax,(%esp)
801018b2:	e8 0a 33 00 00       	call   80104bc1 <sleep>

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
801018d5:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801018dc:	e8 20 36 00 00       	call   80104f01 <release>

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
80101987:	e8 35 38 00 00       	call   801051c1 <memmove>
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
801019b4:	c7 04 24 b9 8a 10 80 	movl   $0x80108ab9,(%esp)
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
801019e5:	c7 04 24 c8 8a 10 80 	movl   $0x80108ac8,(%esp)
801019ec:	e8 4c eb ff ff       	call   8010053d <panic>

  acquire(&icache.lock);
801019f1:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
801019f8:	e8 a2 34 00 00       	call   80104e9f <acquire>
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
80101a14:	e8 81 32 00 00       	call   80104c9a <wakeup>
  release(&icache.lock);
80101a19:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101a20:	e8 dc 34 00 00       	call   80104f01 <release>
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
80101a2d:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101a34:	e8 66 34 00 00       	call   80104e9f <acquire>
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
80101a72:	c7 04 24 d0 8a 10 80 	movl   $0x80108ad0,(%esp)
80101a79:	e8 bf ea ff ff       	call   8010053d <panic>
    ip->flags |= I_BUSY;
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	8b 40 0c             	mov    0xc(%eax),%eax
80101a84:	89 c2                	mov    %eax,%edx
80101a86:	83 ca 01             	or     $0x1,%edx
80101a89:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8c:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a8f:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101a96:	e8 66 34 00 00       	call   80104f01 <release>
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
80101aba:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101ac1:	e8 d9 33 00 00       	call   80104e9f <acquire>
    ip->flags = 0;
80101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	89 04 24             	mov    %eax,(%esp)
80101ad6:	e8 bf 31 00 00       	call   80104c9a <wakeup>
  }
  ip->ref--;
80101adb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ade:	8b 40 08             	mov    0x8(%eax),%eax
80101ae1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101aea:	c7 04 24 40 22 11 80 	movl   $0x80112240,(%esp)
80101af1:	e8 0b 34 00 00       	call   80104f01 <release>
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
80101c06:	c7 04 24 da 8a 10 80 	movl   $0x80108ada,(%esp)
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
80101d9f:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101da6:	85 c0                	test   %eax,%eax
80101da8:	75 0a                	jne    80101db4 <readi+0x4a>
      return -1;
80101daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101daf:	e9 1b 01 00 00       	jmp    80101ecf <readi+0x165>
    return devsw[ip->major].read(ip, dst, n);
80101db4:	8b 45 08             	mov    0x8(%ebp),%eax
80101db7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101dbb:	98                   	cwtl   
80101dbc:	8b 14 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%edx
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
80101e9e:	e8 1e 33 00 00       	call   801051c1 <memmove>
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
80101f0a:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80101f11:	85 c0                	test   %eax,%eax
80101f13:	75 0a                	jne    80101f1f <writei+0x4a>
      return -1;
80101f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1a:	e9 46 01 00 00       	jmp    80102065 <writei+0x190>
    return devsw[ip->major].write(ip, src, n);
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f26:	98                   	cwtl   
80101f27:	8b 14 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%edx
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
80102004:	e8 b8 31 00 00       	call   801051c1 <memmove>
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
80102086:	e8 da 31 00 00       	call   80105265 <strncmp>
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
801020a0:	c7 04 24 ed 8a 10 80 	movl   $0x80108aed,(%esp)
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
801020de:	c7 04 24 ff 8a 10 80 	movl   $0x80108aff,(%esp)
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
801021c2:	c7 04 24 ff 8a 10 80 	movl   $0x80108aff,(%esp)
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
80102208:	e8 b0 30 00 00       	call   801052bd <strncpy>
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
8010223a:	c7 04 24 0c 8b 10 80 	movl   $0x80108b0c,(%esp)
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
801022c1:	e8 fb 2e 00 00       	call   801051c1 <memmove>
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
801022dc:	e8 e0 2e 00 00       	call   801051c1 <memmove>
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
80102538:	c7 44 24 04 14 8b 10 	movl   $0x80108b14,0x4(%esp)
8010253f:	80 
80102540:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102547:	e8 32 29 00 00       	call   80104e7e <initlock>
  picenable(IRQ_IDE);
8010254c:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102553:	e8 e1 18 00 00       	call   80103e39 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102558:	a1 00 3a 11 80       	mov    0x80113a00,%eax
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
801025a9:	c7 05 38 c6 10 80 01 	movl   $0x1,0x8010c638
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
801025e4:	c7 04 24 18 8b 10 80 	movl   $0x80108b18,(%esp)
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
80102703:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
8010270a:	e8 90 27 00 00       	call   80104e9f <acquire>
  if((b = idequeue) == 0){
8010270f:	a1 34 c6 10 80       	mov    0x8010c634,%eax
80102714:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010271b:	75 11                	jne    8010272e <ideintr+0x31>
    release(&idelock);
8010271d:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102724:	e8 d8 27 00 00       	call   80104f01 <release>
    // cprintf("spurious IDE interrupt\n");
    return;
80102729:	e9 90 00 00 00       	jmp    801027be <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102731:	8b 40 14             	mov    0x14(%eax),%eax
80102734:	a3 34 c6 10 80       	mov    %eax,0x8010c634

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
80102797:	e8 fe 24 00 00       	call   80104c9a <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010279c:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801027a1:	85 c0                	test   %eax,%eax
801027a3:	74 0d                	je     801027b2 <ideintr+0xb5>
    idestart(idequeue);
801027a5:	a1 34 c6 10 80       	mov    0x8010c634,%eax
801027aa:	89 04 24             	mov    %eax,(%esp)
801027ad:	e8 26 fe ff ff       	call   801025d8 <idestart>

  release(&idelock);
801027b2:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
801027b9:	e8 43 27 00 00       	call   80104f01 <release>
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
801027d2:	c7 04 24 21 8b 10 80 	movl   $0x80108b21,(%esp)
801027d9:	e8 5f dd ff ff       	call   8010053d <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801027de:	8b 45 08             	mov    0x8(%ebp),%eax
801027e1:	8b 00                	mov    (%eax),%eax
801027e3:	83 e0 06             	and    $0x6,%eax
801027e6:	83 f8 02             	cmp    $0x2,%eax
801027e9:	75 0c                	jne    801027f7 <iderw+0x37>
    panic("iderw: nothing to do");
801027eb:	c7 04 24 35 8b 10 80 	movl   $0x80108b35,(%esp)
801027f2:	e8 46 dd ff ff       	call   8010053d <panic>
  if(b->dev != 0 && !havedisk1)
801027f7:	8b 45 08             	mov    0x8(%ebp),%eax
801027fa:	8b 40 04             	mov    0x4(%eax),%eax
801027fd:	85 c0                	test   %eax,%eax
801027ff:	74 15                	je     80102816 <iderw+0x56>
80102801:	a1 38 c6 10 80       	mov    0x8010c638,%eax
80102806:	85 c0                	test   %eax,%eax
80102808:	75 0c                	jne    80102816 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
8010280a:	c7 04 24 4a 8b 10 80 	movl   $0x80108b4a,(%esp)
80102811:	e8 27 dd ff ff       	call   8010053d <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102816:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
8010281d:	e8 7d 26 00 00       	call   80104e9f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102822:	8b 45 08             	mov    0x8(%ebp),%eax
80102825:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010282c:	c7 45 f4 34 c6 10 80 	movl   $0x8010c634,-0xc(%ebp)
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
80102851:	a1 34 c6 10 80       	mov    0x8010c634,%eax
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
80102868:	c7 44 24 04 00 c6 10 	movl   $0x8010c600,0x4(%esp)
8010286f:	80 
80102870:	8b 45 08             	mov    0x8(%ebp),%eax
80102873:	89 04 24             	mov    %eax,(%esp)
80102876:	e8 46 23 00 00       	call   80104bc1 <sleep>
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
8010288b:	c7 04 24 00 c6 10 80 	movl   $0x8010c600,(%esp)
80102892:	e8 6a 26 00 00       	call   80104f01 <release>
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
8010289f:	a1 14 32 11 80       	mov    0x80113214,%eax
801028a4:	8b 55 08             	mov    0x8(%ebp),%edx
801028a7:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801028a9:	a1 14 32 11 80       	mov    0x80113214,%eax
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
801028b6:	a1 14 32 11 80       	mov    0x80113214,%eax
801028bb:	8b 55 08             	mov    0x8(%ebp),%edx
801028be:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801028c0:	a1 14 32 11 80       	mov    0x80113214,%eax
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
801028d3:	a1 44 33 11 80       	mov    0x80113344,%eax
801028d8:	85 c0                	test   %eax,%eax
801028da:	0f 84 9f 00 00 00    	je     8010297f <ioapicinit+0xb2>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
801028e0:	c7 05 14 32 11 80 00 	movl   $0xfec00000,0x80113214
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
80102913:	0f b6 05 40 33 11 80 	movzbl 0x80113340,%eax
8010291a:	0f b6 c0             	movzbl %al,%eax
8010291d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102920:	74 0c                	je     8010292e <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102922:	c7 04 24 68 8b 10 80 	movl   $0x80108b68,(%esp)
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
80102988:	a1 44 33 11 80       	mov    0x80113344,%eax
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
801029e3:	c7 44 24 04 9a 8b 10 	movl   $0x80108b9a,0x4(%esp)
801029ea:	80 
801029eb:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
801029f2:	e8 87 24 00 00       	call   80104e7e <initlock>
  kmem.use_lock = 0;
801029f7:	c7 05 54 32 11 80 00 	movl   $0x0,0x80113254
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
80102a2d:	c7 05 54 32 11 80 01 	movl   $0x1,0x80113254
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
80102a84:	81 7d 08 f8 61 11 80 	cmpl   $0x801161f8,0x8(%ebp)
80102a8b:	72 12                	jb     80102a9f <kfree+0x2d>
80102a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a90:	89 04 24             	mov    %eax,(%esp)
80102a93:	e8 38 ff ff ff       	call   801029d0 <v2p>
80102a98:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a9d:	76 0c                	jbe    80102aab <kfree+0x39>
    panic("kfree");
80102a9f:	c7 04 24 9f 8b 10 80 	movl   $0x80108b9f,(%esp)
80102aa6:	e8 92 da ff ff       	call   8010053d <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102aab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102ab2:	00 
80102ab3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102aba:	00 
80102abb:	8b 45 08             	mov    0x8(%ebp),%eax
80102abe:	89 04 24             	mov    %eax,(%esp)
80102ac1:	e8 28 26 00 00       	call   801050ee <memset>

  if(kmem.use_lock)
80102ac6:	a1 54 32 11 80       	mov    0x80113254,%eax
80102acb:	85 c0                	test   %eax,%eax
80102acd:	74 0c                	je     80102adb <kfree+0x69>
    acquire(&kmem.lock);
80102acf:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102ad6:	e8 c4 23 00 00       	call   80104e9f <acquire>
  r = (struct run*)v;
80102adb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ade:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ae1:	8b 15 58 32 11 80    	mov    0x80113258,%edx
80102ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aea:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aef:	a3 58 32 11 80       	mov    %eax,0x80113258
  if(kmem.use_lock)
80102af4:	a1 54 32 11 80       	mov    0x80113254,%eax
80102af9:	85 c0                	test   %eax,%eax
80102afb:	74 0c                	je     80102b09 <kfree+0x97>
    release(&kmem.lock);
80102afd:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102b04:	e8 f8 23 00 00       	call   80104f01 <release>
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
80102b11:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b16:	85 c0                	test   %eax,%eax
80102b18:	74 0c                	je     80102b26 <kalloc+0x1b>
    acquire(&kmem.lock);
80102b1a:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102b21:	e8 79 23 00 00       	call   80104e9f <acquire>
  r = kmem.freelist;
80102b26:	a1 58 32 11 80       	mov    0x80113258,%eax
80102b2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102b2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b32:	74 0a                	je     80102b3e <kalloc+0x33>
    kmem.freelist = r->next;
80102b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b37:	8b 00                	mov    (%eax),%eax
80102b39:	a3 58 32 11 80       	mov    %eax,0x80113258
  if(kmem.use_lock)
80102b3e:	a1 54 32 11 80       	mov    0x80113254,%eax
80102b43:	85 c0                	test   %eax,%eax
80102b45:	74 0c                	je     80102b53 <kalloc+0x48>
    release(&kmem.lock);
80102b47:	c7 04 24 20 32 11 80 	movl   $0x80113220,(%esp)
80102b4e:	e8 ae 23 00 00       	call   80104f01 <release>
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
80102bc9:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102bce:	83 c8 40             	or     $0x40,%eax
80102bd1:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
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
80102bec:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
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
80102c09:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c0e:	0f b6 00             	movzbl (%eax),%eax
80102c11:	83 c8 40             	or     $0x40,%eax
80102c14:	0f b6 c0             	movzbl %al,%eax
80102c17:	f7 d0                	not    %eax
80102c19:	89 c2                	mov    %eax,%edx
80102c1b:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c20:	21 d0                	and    %edx,%eax
80102c22:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
    return 0;
80102c27:	b8 00 00 00 00       	mov    $0x0,%eax
80102c2c:	e9 a0 00 00 00       	jmp    80102cd1 <kbdgetc+0x14f>
  } else if(shift & E0ESC){
80102c31:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c36:	83 e0 40             	and    $0x40,%eax
80102c39:	85 c0                	test   %eax,%eax
80102c3b:	74 14                	je     80102c51 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102c3d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102c44:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c49:	83 e0 bf             	and    $0xffffffbf,%eax
80102c4c:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  }

  shift |= shiftcode[data];
80102c51:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c54:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102c59:	0f b6 00             	movzbl (%eax),%eax
80102c5c:	0f b6 d0             	movzbl %al,%edx
80102c5f:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c64:	09 d0                	or     %edx,%eax
80102c66:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  shift ^= togglecode[data];
80102c6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c6e:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102c73:	0f b6 00             	movzbl (%eax),%eax
80102c76:	0f b6 d0             	movzbl %al,%edx
80102c79:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c7e:	31 d0                	xor    %edx,%eax
80102c80:	a3 3c c6 10 80       	mov    %eax,0x8010c63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c85:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
80102c8a:	83 e0 03             	and    $0x3,%eax
80102c8d:	8b 04 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%eax
80102c94:	03 45 fc             	add    -0x4(%ebp),%eax
80102c97:	0f b6 00             	movzbl (%eax),%eax
80102c9a:	0f b6 c0             	movzbl %al,%eax
80102c9d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ca0:	a1 3c c6 10 80       	mov    0x8010c63c,%eax
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
80102d48:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102d4d:	8b 55 08             	mov    0x8(%ebp),%edx
80102d50:	c1 e2 02             	shl    $0x2,%edx
80102d53:	01 c2                	add    %eax,%edx
80102d55:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d58:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102d5a:	a1 5c 32 11 80       	mov    0x8011325c,%eax
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
80102d6c:	a1 5c 32 11 80       	mov    0x8011325c,%eax
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
80102df1:	a1 5c 32 11 80       	mov    0x8011325c,%eax
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
80102e95:	a1 5c 32 11 80       	mov    0x8011325c,%eax
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
80102ed7:	a1 40 c6 10 80       	mov    0x8010c640,%eax
80102edc:	85 c0                	test   %eax,%eax
80102ede:	0f 94 c2             	sete   %dl
80102ee1:	83 c0 01             	add    $0x1,%eax
80102ee4:	a3 40 c6 10 80       	mov    %eax,0x8010c640
80102ee9:	84 d2                	test   %dl,%dl
80102eeb:	74 13                	je     80102f00 <cpunum+0x3d>
      cprintf("cpu called from %x with interrupts enabled\n",
80102eed:	8b 45 04             	mov    0x4(%ebp),%eax
80102ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ef4:	c7 04 24 a8 8b 10 80 	movl   $0x80108ba8,(%esp)
80102efb:	e8 a1 d4 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102f00:	a1 5c 32 11 80       	mov    0x8011325c,%eax
80102f05:	85 c0                	test   %eax,%eax
80102f07:	74 0f                	je     80102f18 <cpunum+0x55>
    return lapic[ID]>>24;
80102f09:	a1 5c 32 11 80       	mov    0x8011325c,%eax
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
80102f25:	a1 5c 32 11 80       	mov    0x8011325c,%eax
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
80103158:	e8 08 20 00 00       	call   80105165 <memcmp>
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
8010325a:	c7 44 24 04 d4 8b 10 	movl   $0x80108bd4,0x4(%esp)
80103261:	80 
80103262:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103269:	e8 10 1c 00 00       	call   80104e7e <initlock>
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
8010328d:	a3 94 32 11 80       	mov    %eax,0x80113294
  log.size = sb.nlog;
80103292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103295:	a3 98 32 11 80       	mov    %eax,0x80113298
  log.dev = ROOTDEV;
8010329a:	c7 05 a4 32 11 80 01 	movl   $0x1,0x801132a4
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
801032bd:	a1 94 32 11 80       	mov    0x80113294,%eax
801032c2:	03 45 f4             	add    -0xc(%ebp),%eax
801032c5:	83 c0 01             	add    $0x1,%eax
801032c8:	89 c2                	mov    %eax,%edx
801032ca:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801032cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801032d3:	89 04 24             	mov    %eax,(%esp)
801032d6:	e8 cb ce ff ff       	call   801001a6 <bread>
801032db:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801032de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e1:	83 c0 10             	add    $0x10,%eax
801032e4:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
801032eb:	89 c2                	mov    %eax,%edx
801032ed:	a1 a4 32 11 80       	mov    0x801132a4,%eax
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
8010331c:	e8 a0 1e 00 00       	call   801051c1 <memmove>
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
80103346:	a1 a8 32 11 80       	mov    0x801132a8,%eax
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
8010335c:	a1 94 32 11 80       	mov    0x80113294,%eax
80103361:	89 c2                	mov    %eax,%edx
80103363:	a1 a4 32 11 80       	mov    0x801132a4,%eax
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
80103385:	a3 a8 32 11 80       	mov    %eax,0x801132a8
  for (i = 0; i < log.lh.n; i++) {
8010338a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103391:	eb 1b                	jmp    801033ae <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103393:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103396:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103399:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010339d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033a0:	83 c2 10             	add    $0x10,%edx
801033a3:	89 04 95 6c 32 11 80 	mov    %eax,-0x7feecd94(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033aa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033ae:	a1 a8 32 11 80       	mov    0x801132a8,%eax
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
801033cb:	a1 94 32 11 80       	mov    0x80113294,%eax
801033d0:	89 c2                	mov    %eax,%edx
801033d2:	a1 a4 32 11 80       	mov    0x801132a4,%eax
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
801033ef:	8b 15 a8 32 11 80    	mov    0x801132a8,%edx
801033f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033f8:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801033fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103401:	eb 1b                	jmp    8010341e <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
80103403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103406:	83 c0 10             	add    $0x10,%eax
80103409:	8b 0c 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%ecx
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
8010341e:	a1 a8 32 11 80       	mov    0x801132a8,%eax
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
80103450:	c7 05 a8 32 11 80 00 	movl   $0x0,0x801132a8
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
80103467:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
8010346e:	e8 2c 1a 00 00       	call   80104e9f <acquire>
  while(1){
    if(log.committing){
80103473:	a1 a0 32 11 80       	mov    0x801132a0,%eax
80103478:	85 c0                	test   %eax,%eax
8010347a:	74 16                	je     80103492 <begin_op+0x31>
      sleep(&log, &log.lock);
8010347c:	c7 44 24 04 60 32 11 	movl   $0x80113260,0x4(%esp)
80103483:	80 
80103484:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
8010348b:	e8 31 17 00 00       	call   80104bc1 <sleep>
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
80103492:	8b 0d a8 32 11 80    	mov    0x801132a8,%ecx
80103498:	a1 9c 32 11 80       	mov    0x8011329c,%eax
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
801034b0:	c7 44 24 04 60 32 11 	movl   $0x80113260,0x4(%esp)
801034b7:	80 
801034b8:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801034bf:	e8 fd 16 00 00       	call   80104bc1 <sleep>
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
801034c6:	a1 9c 32 11 80       	mov    0x8011329c,%eax
801034cb:	83 c0 01             	add    $0x1,%eax
801034ce:	a3 9c 32 11 80       	mov    %eax,0x8011329c
      release(&log.lock);
801034d3:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801034da:	e8 22 1a 00 00       	call   80104f01 <release>
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
801034ef:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801034f6:	e8 a4 19 00 00       	call   80104e9f <acquire>
  log.outstanding -= 1;
801034fb:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80103500:	83 e8 01             	sub    $0x1,%eax
80103503:	a3 9c 32 11 80       	mov    %eax,0x8011329c
  if(log.committing)
80103508:	a1 a0 32 11 80       	mov    0x801132a0,%eax
8010350d:	85 c0                	test   %eax,%eax
8010350f:	74 0c                	je     8010351d <end_op+0x3b>
    panic("log.committing");
80103511:	c7 04 24 d8 8b 10 80 	movl   $0x80108bd8,(%esp)
80103518:	e8 20 d0 ff ff       	call   8010053d <panic>
  if(log.outstanding == 0){
8010351d:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80103522:	85 c0                	test   %eax,%eax
80103524:	75 13                	jne    80103539 <end_op+0x57>
    do_commit = 1;
80103526:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010352d:	c7 05 a0 32 11 80 01 	movl   $0x1,0x801132a0
80103534:	00 00 00 
80103537:	eb 0c                	jmp    80103545 <end_op+0x63>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103539:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103540:	e8 55 17 00 00       	call   80104c9a <wakeup>
  }
  release(&log.lock);
80103545:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
8010354c:	e8 b0 19 00 00       	call   80104f01 <release>

  if(do_commit){
80103551:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103555:	74 33                	je     8010358a <end_op+0xa8>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103557:	e8 db 00 00 00       	call   80103637 <commit>
    acquire(&log.lock);
8010355c:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103563:	e8 37 19 00 00       	call   80104e9f <acquire>
    log.committing = 0;
80103568:	c7 05 a0 32 11 80 00 	movl   $0x0,0x801132a0
8010356f:	00 00 00 
    wakeup(&log);
80103572:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103579:	e8 1c 17 00 00       	call   80104c9a <wakeup>
    release(&log.lock);
8010357e:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103585:	e8 77 19 00 00       	call   80104f01 <release>
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
8010359e:	a1 94 32 11 80       	mov    0x80113294,%eax
801035a3:	03 45 f4             	add    -0xc(%ebp),%eax
801035a6:	83 c0 01             	add    $0x1,%eax
801035a9:	89 c2                	mov    %eax,%edx
801035ab:	a1 a4 32 11 80       	mov    0x801132a4,%eax
801035b0:	89 54 24 04          	mov    %edx,0x4(%esp)
801035b4:	89 04 24             	mov    %eax,(%esp)
801035b7:	e8 ea cb ff ff       	call   801001a6 <bread>
801035bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
801035bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035c2:	83 c0 10             	add    $0x10,%eax
801035c5:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
801035cc:	89 c2                	mov    %eax,%edx
801035ce:	a1 a4 32 11 80       	mov    0x801132a4,%eax
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
801035fd:	e8 bf 1b 00 00       	call   801051c1 <memmove>
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
80103627:	a1 a8 32 11 80       	mov    0x801132a8,%eax
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
8010363d:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103642:	85 c0                	test   %eax,%eax
80103644:	7e 1e                	jle    80103664 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103646:	e8 41 ff ff ff       	call   8010358c <write_log>
    write_head();    // Write header to disk -- the real commit
8010364b:	e8 75 fd ff ff       	call   801033c5 <write_head>
    install_trans(); // Now install writes to home locations
80103650:	e8 56 fc ff ff       	call   801032ab <install_trans>
    log.lh.n = 0; 
80103655:	c7 05 a8 32 11 80 00 	movl   $0x0,0x801132a8
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
8010366c:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103671:	83 f8 1d             	cmp    $0x1d,%eax
80103674:	7f 12                	jg     80103688 <log_write+0x22>
80103676:	a1 a8 32 11 80       	mov    0x801132a8,%eax
8010367b:	8b 15 98 32 11 80    	mov    0x80113298,%edx
80103681:	83 ea 01             	sub    $0x1,%edx
80103684:	39 d0                	cmp    %edx,%eax
80103686:	7c 0c                	jl     80103694 <log_write+0x2e>
    panic("too big a transaction");
80103688:	c7 04 24 e7 8b 10 80 	movl   $0x80108be7,(%esp)
8010368f:	e8 a9 ce ff ff       	call   8010053d <panic>
  if (log.outstanding < 1)
80103694:	a1 9c 32 11 80       	mov    0x8011329c,%eax
80103699:	85 c0                	test   %eax,%eax
8010369b:	7f 0c                	jg     801036a9 <log_write+0x43>
    panic("log_write outside of trans");
8010369d:	c7 04 24 fd 8b 10 80 	movl   $0x80108bfd,(%esp)
801036a4:	e8 94 ce ff ff       	call   8010053d <panic>

  acquire(&log.lock);
801036a9:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
801036b0:	e8 ea 17 00 00       	call   80104e9f <acquire>
  for (i = 0; i < log.lh.n; i++) {
801036b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036bc:	eb 1d                	jmp    801036db <log_write+0x75>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
801036be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036c1:	83 c0 10             	add    $0x10,%eax
801036c4:	8b 04 85 6c 32 11 80 	mov    -0x7feecd94(,%eax,4),%eax
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
801036db:	a1 a8 32 11 80       	mov    0x801132a8,%eax
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
801036f4:	89 04 95 6c 32 11 80 	mov    %eax,-0x7feecd94(,%edx,4)
  if (i == log.lh.n)
801036fb:	a1 a8 32 11 80       	mov    0x801132a8,%eax
80103700:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103703:	75 0d                	jne    80103712 <log_write+0xac>
    log.lh.n++;
80103705:	a1 a8 32 11 80       	mov    0x801132a8,%eax
8010370a:	83 c0 01             	add    $0x1,%eax
8010370d:	a3 a8 32 11 80       	mov    %eax,0x801132a8
  b->flags |= B_DIRTY; // prevent eviction
80103712:	8b 45 08             	mov    0x8(%ebp),%eax
80103715:	8b 00                	mov    (%eax),%eax
80103717:	89 c2                	mov    %eax,%edx
80103719:	83 ca 04             	or     $0x4,%edx
8010371c:	8b 45 08             	mov    0x8(%ebp),%eax
8010371f:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103721:	c7 04 24 60 32 11 80 	movl   $0x80113260,(%esp)
80103728:	e8 d4 17 00 00       	call   80104f01 <release>
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
80103780:	c7 04 24 f8 61 11 80 	movl   $0x801161f8,(%esp)
80103787:	e8 51 f2 ff ff       	call   801029dd <kinit1>
  seginit();       // set up segments
8010378c:	e8 3f 43 00 00       	call   80107ad0 <seginit>
  kvmalloc(cpu);   // kernel page table
80103791:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103797:	89 04 24             	mov    %eax,(%esp)
8010379a:	e8 d2 49 00 00       	call   80108171 <kvmalloc>
  mpinit();        // collect info about this machine
8010379f:	e8 65 04 00 00       	call   80103c09 <mpinit>
  lapicinit();
801037a4:	e8 bd f5 ff ff       	call   80102d66 <lapicinit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801037a9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801037af:	0f b6 00             	movzbl (%eax),%eax
801037b2:	0f b6 c0             	movzbl %al,%eax
801037b5:	89 44 24 04          	mov    %eax,0x4(%esp)
801037b9:	c7 04 24 18 8c 10 80 	movl   $0x80108c18,(%esp)
801037c0:	e8 dc cb ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801037c5:	e8 a4 06 00 00       	call   80103e6e <picinit>
  ioapicinit();    // another interrupt controller
801037ca:	e8 fe f0 ff ff       	call   801028cd <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801037cf:	e8 b9 d2 ff ff       	call   80100a8d <consoleinit>
  uartinit();      // serial port
801037d4:	e8 53 33 00 00       	call   80106b2c <uartinit>
  pinit();         // process table
801037d9:	e8 a5 0b 00 00       	call   80104383 <pinit>
  tvinit();        // trap vectors
801037de:	e8 bd 2d 00 00       	call   801065a0 <tvinit>
  binit();         // buffer cache
801037e3:	e8 4c c8 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801037e8:	e8 1f d7 ff ff       	call   80100f0c <fileinit>
  iinit();         // inode cache
801037ed:	e8 cd dd ff ff       	call   801015bf <iinit>
  ideinit();       // disk
801037f2:	e8 3b ed ff ff       	call   80102532 <ideinit>
  if(!ismp)
801037f7:	a1 44 33 11 80       	mov    0x80113344,%eax
801037fc:	85 c0                	test   %eax,%eax
801037fe:	75 05                	jne    80103805 <main+0x96>
    timerinit();   // uniprocessor timer
80103800:	e8 d1 2c 00 00       	call   801064d6 <timerinit>
  startothers();   // start other processors
80103805:	e8 94 00 00 00       	call   8010389e <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010380a:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103811:	8e 
80103812:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103819:	e8 f7 f1 ff ff       	call   80102a15 <kinit2>
  userinit();      // first user process
8010381e:	e8 7b 0c 00 00       	call   8010449e <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103823:	e8 2f 00 00 00       	call   80103857 <mpmain>

80103828 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103828:	55                   	push   %ebp
80103829:	89 e5                	mov    %esp,%ebp
8010382b:	83 ec 18             	sub    $0x18,%esp
  switchkvm(&cpus[0]); 
8010382e:	c7 04 24 60 33 11 80 	movl   $0x80113360,(%esp)
80103835:	e8 55 49 00 00       	call   8010818f <switchkvm>
  seginit();
8010383a:	e8 91 42 00 00       	call   80107ad0 <seginit>
  kvmalloc(cpu);
8010383f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103845:	89 04 24             	mov    %eax,(%esp)
80103848:	e8 24 49 00 00       	call   80108171 <kvmalloc>
  lapicinit();
8010384d:	e8 14 f5 ff ff       	call   80102d66 <lapicinit>
  mpmain();
80103852:	e8 00 00 00 00       	call   80103857 <mpmain>

80103857 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103857:	55                   	push   %ebp
80103858:	89 e5                	mov    %esp,%ebp
8010385a:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010385d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103863:	0f b6 00             	movzbl (%eax),%eax
80103866:	0f b6 c0             	movzbl %al,%eax
80103869:	89 44 24 04          	mov    %eax,0x4(%esp)
8010386d:	c7 04 24 2f 8c 10 80 	movl   $0x80108c2f,(%esp)
80103874:	e8 28 cb ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103879:	e8 96 2e 00 00       	call   80106714 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010387e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103884:	05 c0 00 00 00       	add    $0xc0,%eax
80103889:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103890:	00 
80103891:	89 04 24             	mov    %eax,(%esp)
80103894:	e8 b1 fe ff ff       	call   8010374a <xchg>
  scheduler();     // start running processes
80103899:	e8 71 11 00 00       	call   80104a0f <scheduler>

8010389e <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010389e:	55                   	push   %ebp
8010389f:	89 e5                	mov    %esp,%ebp
801038a1:	53                   	push   %ebx
801038a2:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801038a5:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801038ac:	e8 8c fe ff ff       	call   8010373d <p2v>
801038b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038b4:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801038bd:	c7 44 24 04 0c c5 10 	movl   $0x8010c50c,0x4(%esp)
801038c4:	80 
801038c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038c8:	89 04 24             	mov    %eax,(%esp)
801038cb:	e8 f1 18 00 00       	call   801051c1 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801038d0:	c7 45 f4 60 33 11 80 	movl   $0x80113360,-0xc(%ebp)
801038d7:	e9 86 00 00 00       	jmp    80103962 <startothers+0xc4>
    if(c == cpus+cpunum())  // We've started already.
801038dc:	e8 e2 f5 ff ff       	call   80102ec3 <cpunum>
801038e1:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
801038e7:	05 60 33 11 80       	add    $0x80113360,%eax
801038ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038ef:	74 69                	je     8010395a <startothers+0xbc>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801038f1:	e8 15 f2 ff ff       	call   80102b0b <kalloc>
801038f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801038f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038fc:	83 e8 04             	sub    $0x4,%eax
801038ff:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103902:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103908:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010390a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390d:	83 e8 08             	sub    $0x8,%eax
80103910:	c7 00 28 38 10 80    	movl   $0x80103828,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103916:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103919:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010391c:	c7 04 24 00 b0 10 80 	movl   $0x8010b000,(%esp)
80103923:	e8 08 fe ff ff       	call   80103730 <v2p>
80103928:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010392a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010392d:	89 04 24             	mov    %eax,(%esp)
80103930:	e8 fb fd ff ff       	call   80103730 <v2p>
80103935:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103938:	0f b6 12             	movzbl (%edx),%edx
8010393b:	0f b6 d2             	movzbl %dl,%edx
8010393e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103942:	89 14 24             	mov    %edx,(%esp)
80103945:	e8 ff f5 ff ff       	call   80102f49 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010394a:	90                   	nop
8010394b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010394e:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
80103954:	85 c0                	test   %eax,%eax
80103956:	74 f3                	je     8010394b <startothers+0xad>
80103958:	eb 01                	jmp    8010395b <startothers+0xbd>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010395a:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010395b:	81 45 f4 d4 00 00 00 	addl   $0xd4,-0xc(%ebp)
80103962:	a1 00 3a 11 80       	mov    0x80113a00,%eax
80103967:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
8010396d:	05 60 33 11 80       	add    $0x80113360,%eax
80103972:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103975:	0f 87 61 ff ff ff    	ja     801038dc <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
8010397b:	83 c4 24             	add    $0x24,%esp
8010397e:	5b                   	pop    %ebx
8010397f:	5d                   	pop    %ebp
80103980:	c3                   	ret    
80103981:	00 00                	add    %al,(%eax)
	...

80103984 <p2v>:
80103984:	55                   	push   %ebp
80103985:	89 e5                	mov    %esp,%ebp
80103987:	8b 45 08             	mov    0x8(%ebp),%eax
8010398a:	05 00 00 00 80       	add    $0x80000000,%eax
8010398f:	5d                   	pop    %ebp
80103990:	c3                   	ret    

80103991 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103991:	55                   	push   %ebp
80103992:	89 e5                	mov    %esp,%ebp
80103994:	53                   	push   %ebx
80103995:	83 ec 14             	sub    $0x14,%esp
80103998:	8b 45 08             	mov    0x8(%ebp),%eax
8010399b:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010399f:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
801039a3:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801039a7:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
801039ab:	ec                   	in     (%dx),%al
801039ac:	89 c3                	mov    %eax,%ebx
801039ae:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801039b1:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
801039b5:	83 c4 14             	add    $0x14,%esp
801039b8:	5b                   	pop    %ebx
801039b9:	5d                   	pop    %ebp
801039ba:	c3                   	ret    

801039bb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039bb:	55                   	push   %ebp
801039bc:	89 e5                	mov    %esp,%ebp
801039be:	83 ec 08             	sub    $0x8,%esp
801039c1:	8b 55 08             	mov    0x8(%ebp),%edx
801039c4:	8b 45 0c             	mov    0xc(%ebp),%eax
801039c7:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801039cb:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039ce:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801039d2:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801039d6:	ee                   	out    %al,(%dx)
}
801039d7:	c9                   	leave  
801039d8:	c3                   	ret    

801039d9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801039d9:	55                   	push   %ebp
801039da:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801039dc:	a1 44 c6 10 80       	mov    0x8010c644,%eax
801039e1:	89 c2                	mov    %eax,%edx
801039e3:	b8 60 33 11 80       	mov    $0x80113360,%eax
801039e8:	89 d1                	mov    %edx,%ecx
801039ea:	29 c1                	sub    %eax,%ecx
801039ec:	89 c8                	mov    %ecx,%eax
801039ee:	c1 f8 02             	sar    $0x2,%eax
801039f1:	69 c0 1d 52 13 8c    	imul   $0x8c13521d,%eax,%eax
}
801039f7:	5d                   	pop    %ebp
801039f8:	c3                   	ret    

801039f9 <sum>:

static uchar
sum(uchar *addr, int len)
{
801039f9:	55                   	push   %ebp
801039fa:	89 e5                	mov    %esp,%ebp
801039fc:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
801039ff:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a06:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a0d:	eb 13                	jmp    80103a22 <sum+0x29>
    sum += addr[i];
80103a0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a12:	03 45 08             	add    0x8(%ebp),%eax
80103a15:	0f b6 00             	movzbl (%eax),%eax
80103a18:	0f b6 c0             	movzbl %al,%eax
80103a1b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a1e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a25:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a28:	7c e5                	jl     80103a0f <sum+0x16>
    sum += addr[i];
  return sum;
80103a2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a2d:	c9                   	leave  
80103a2e:	c3                   	ret    

80103a2f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a2f:	55                   	push   %ebp
80103a30:	89 e5                	mov    %esp,%ebp
80103a32:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103a35:	8b 45 08             	mov    0x8(%ebp),%eax
80103a38:	89 04 24             	mov    %eax,(%esp)
80103a3b:	e8 44 ff ff ff       	call   80103984 <p2v>
80103a40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a43:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a46:	03 45 f0             	add    -0x10(%ebp),%eax
80103a49:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a52:	eb 3f                	jmp    80103a93 <mpsearch1+0x64>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a54:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a5b:	00 
80103a5c:	c7 44 24 04 40 8c 10 	movl   $0x80108c40,0x4(%esp)
80103a63:	80 
80103a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a67:	89 04 24             	mov    %eax,(%esp)
80103a6a:	e8 f6 16 00 00       	call   80105165 <memcmp>
80103a6f:	85 c0                	test   %eax,%eax
80103a71:	75 1c                	jne    80103a8f <mpsearch1+0x60>
80103a73:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a7a:	00 
80103a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7e:	89 04 24             	mov    %eax,(%esp)
80103a81:	e8 73 ff ff ff       	call   801039f9 <sum>
80103a86:	84 c0                	test   %al,%al
80103a88:	75 05                	jne    80103a8f <mpsearch1+0x60>
      return (struct mp*)p;
80103a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8d:	eb 11                	jmp    80103aa0 <mpsearch1+0x71>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a8f:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a96:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a99:	72 b9                	jb     80103a54 <mpsearch1+0x25>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103aa0:	c9                   	leave  
80103aa1:	c3                   	ret    

80103aa2 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103aa2:	55                   	push   %ebp
80103aa3:	89 e5                	mov    %esp,%ebp
80103aa5:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103aa8:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab2:	83 c0 0f             	add    $0xf,%eax
80103ab5:	0f b6 00             	movzbl (%eax),%eax
80103ab8:	0f b6 c0             	movzbl %al,%eax
80103abb:	89 c2                	mov    %eax,%edx
80103abd:	c1 e2 08             	shl    $0x8,%edx
80103ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac3:	83 c0 0e             	add    $0xe,%eax
80103ac6:	0f b6 00             	movzbl (%eax),%eax
80103ac9:	0f b6 c0             	movzbl %al,%eax
80103acc:	09 d0                	or     %edx,%eax
80103ace:	c1 e0 04             	shl    $0x4,%eax
80103ad1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ad4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ad8:	74 21                	je     80103afb <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103ada:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ae1:	00 
80103ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ae5:	89 04 24             	mov    %eax,(%esp)
80103ae8:	e8 42 ff ff ff       	call   80103a2f <mpsearch1>
80103aed:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103af0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103af4:	74 50                	je     80103b46 <mpsearch+0xa4>
      return mp;
80103af6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103af9:	eb 5f                	jmp    80103b5a <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afe:	83 c0 14             	add    $0x14,%eax
80103b01:	0f b6 00             	movzbl (%eax),%eax
80103b04:	0f b6 c0             	movzbl %al,%eax
80103b07:	89 c2                	mov    %eax,%edx
80103b09:	c1 e2 08             	shl    $0x8,%edx
80103b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0f:	83 c0 13             	add    $0x13,%eax
80103b12:	0f b6 00             	movzbl (%eax),%eax
80103b15:	0f b6 c0             	movzbl %al,%eax
80103b18:	09 d0                	or     %edx,%eax
80103b1a:	c1 e0 0a             	shl    $0xa,%eax
80103b1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b23:	2d 00 04 00 00       	sub    $0x400,%eax
80103b28:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b2f:	00 
80103b30:	89 04 24             	mov    %eax,(%esp)
80103b33:	e8 f7 fe ff ff       	call   80103a2f <mpsearch1>
80103b38:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b3b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b3f:	74 05                	je     80103b46 <mpsearch+0xa4>
      return mp;
80103b41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b44:	eb 14                	jmp    80103b5a <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b46:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b4d:	00 
80103b4e:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b55:	e8 d5 fe ff ff       	call   80103a2f <mpsearch1>
}
80103b5a:	c9                   	leave  
80103b5b:	c3                   	ret    

80103b5c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b5c:	55                   	push   %ebp
80103b5d:	89 e5                	mov    %esp,%ebp
80103b5f:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b62:	e8 3b ff ff ff       	call   80103aa2 <mpsearch>
80103b67:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b6a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b6e:	74 0a                	je     80103b7a <mpconfig+0x1e>
80103b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b73:	8b 40 04             	mov    0x4(%eax),%eax
80103b76:	85 c0                	test   %eax,%eax
80103b78:	75 0a                	jne    80103b84 <mpconfig+0x28>
    return 0;
80103b7a:	b8 00 00 00 00       	mov    $0x0,%eax
80103b7f:	e9 83 00 00 00       	jmp    80103c07 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b87:	8b 40 04             	mov    0x4(%eax),%eax
80103b8a:	89 04 24             	mov    %eax,(%esp)
80103b8d:	e8 f2 fd ff ff       	call   80103984 <p2v>
80103b92:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b95:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b9c:	00 
80103b9d:	c7 44 24 04 45 8c 10 	movl   $0x80108c45,0x4(%esp)
80103ba4:	80 
80103ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba8:	89 04 24             	mov    %eax,(%esp)
80103bab:	e8 b5 15 00 00       	call   80105165 <memcmp>
80103bb0:	85 c0                	test   %eax,%eax
80103bb2:	74 07                	je     80103bbb <mpconfig+0x5f>
    return 0;
80103bb4:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb9:	eb 4c                	jmp    80103c07 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bbe:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bc2:	3c 01                	cmp    $0x1,%al
80103bc4:	74 12                	je     80103bd8 <mpconfig+0x7c>
80103bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc9:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103bcd:	3c 04                	cmp    $0x4,%al
80103bcf:	74 07                	je     80103bd8 <mpconfig+0x7c>
    return 0;
80103bd1:	b8 00 00 00 00       	mov    $0x0,%eax
80103bd6:	eb 2f                	jmp    80103c07 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103bd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bdb:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103bdf:	0f b7 c0             	movzwl %ax,%eax
80103be2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be9:	89 04 24             	mov    %eax,(%esp)
80103bec:	e8 08 fe ff ff       	call   801039f9 <sum>
80103bf1:	84 c0                	test   %al,%al
80103bf3:	74 07                	je     80103bfc <mpconfig+0xa0>
    return 0;
80103bf5:	b8 00 00 00 00       	mov    $0x0,%eax
80103bfa:	eb 0b                	jmp    80103c07 <mpconfig+0xab>
  *pmp = mp;
80103bfc:	8b 45 08             	mov    0x8(%ebp),%eax
80103bff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c02:	89 10                	mov    %edx,(%eax)
  return conf;
80103c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c07:	c9                   	leave  
80103c08:	c3                   	ret    

80103c09 <mpinit>:

void
mpinit(void)
{
80103c09:	55                   	push   %ebp
80103c0a:	89 e5                	mov    %esp,%ebp
80103c0c:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c0f:	c7 05 44 c6 10 80 60 	movl   $0x80113360,0x8010c644
80103c16:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c19:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c1c:	89 04 24             	mov    %eax,(%esp)
80103c1f:	e8 38 ff ff ff       	call   80103b5c <mpconfig>
80103c24:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c27:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c2b:	0f 84 9c 01 00 00    	je     80103dcd <mpinit+0x1c4>
    return;
  ismp = 1;
80103c31:	c7 05 44 33 11 80 01 	movl   $0x1,0x80113344
80103c38:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3e:	8b 40 24             	mov    0x24(%eax),%eax
80103c41:	a3 5c 32 11 80       	mov    %eax,0x8011325c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c49:	83 c0 2c             	add    $0x2c,%eax
80103c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c52:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c56:	0f b7 c0             	movzwl %ax,%eax
80103c59:	03 45 f0             	add    -0x10(%ebp),%eax
80103c5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c5f:	e9 f4 00 00 00       	jmp    80103d58 <mpinit+0x14f>
    switch(*p){
80103c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c67:	0f b6 00             	movzbl (%eax),%eax
80103c6a:	0f b6 c0             	movzbl %al,%eax
80103c6d:	83 f8 04             	cmp    $0x4,%eax
80103c70:	0f 87 bf 00 00 00    	ja     80103d35 <mpinit+0x12c>
80103c76:	8b 04 85 88 8c 10 80 	mov    -0x7fef7378(,%eax,4),%eax
80103c7d:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103c85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c88:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c8c:	0f b6 d0             	movzbl %al,%edx
80103c8f:	a1 00 3a 11 80       	mov    0x80113a00,%eax
80103c94:	39 c2                	cmp    %eax,%edx
80103c96:	74 2d                	je     80103cc5 <mpinit+0xbc>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103c98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c9b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103c9f:	0f b6 d0             	movzbl %al,%edx
80103ca2:	a1 00 3a 11 80       	mov    0x80113a00,%eax
80103ca7:	89 54 24 08          	mov    %edx,0x8(%esp)
80103cab:	89 44 24 04          	mov    %eax,0x4(%esp)
80103caf:	c7 04 24 4a 8c 10 80 	movl   $0x80108c4a,(%esp)
80103cb6:	e8 e6 c6 ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103cbb:	c7 05 44 33 11 80 00 	movl   $0x0,0x80113344
80103cc2:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103cc5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cc8:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103ccc:	0f b6 c0             	movzbl %al,%eax
80103ccf:	83 e0 02             	and    $0x2,%eax
80103cd2:	85 c0                	test   %eax,%eax
80103cd4:	74 15                	je     80103ceb <mpinit+0xe2>
        bcpu = &cpus[ncpu];
80103cd6:	a1 00 3a 11 80       	mov    0x80113a00,%eax
80103cdb:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
80103ce1:	05 60 33 11 80       	add    $0x80113360,%eax
80103ce6:	a3 44 c6 10 80       	mov    %eax,0x8010c644
      cpus[ncpu].id = ncpu;
80103ceb:	8b 15 00 3a 11 80    	mov    0x80113a00,%edx
80103cf1:	a1 00 3a 11 80       	mov    0x80113a00,%eax
80103cf6:	69 d2 d4 00 00 00    	imul   $0xd4,%edx,%edx
80103cfc:	81 c2 60 33 11 80    	add    $0x80113360,%edx
80103d02:	88 02                	mov    %al,(%edx)
      ncpu++;
80103d04:	a1 00 3a 11 80       	mov    0x80113a00,%eax
80103d09:	83 c0 01             	add    $0x1,%eax
80103d0c:	a3 00 3a 11 80       	mov    %eax,0x80113a00
      p += sizeof(struct mpproc);
80103d11:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d15:	eb 41                	jmp    80103d58 <mpinit+0x14f>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d20:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d24:	a2 40 33 11 80       	mov    %al,0x80113340
      p += sizeof(struct mpioapic);
80103d29:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d2d:	eb 29                	jmp    80103d58 <mpinit+0x14f>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d2f:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d33:	eb 23                	jmp    80103d58 <mpinit+0x14f>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d38:	0f b6 00             	movzbl (%eax),%eax
80103d3b:	0f b6 c0             	movzbl %al,%eax
80103d3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d42:	c7 04 24 68 8c 10 80 	movl   $0x80108c68,(%esp)
80103d49:	e8 53 c6 ff ff       	call   801003a1 <cprintf>
      ismp = 0;
80103d4e:	c7 05 44 33 11 80 00 	movl   $0x0,0x80113344
80103d55:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103d5e:	0f 82 00 ff ff ff    	jb     80103c64 <mpinit+0x5b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103d64:	a1 44 33 11 80       	mov    0x80113344,%eax
80103d69:	85 c0                	test   %eax,%eax
80103d6b:	75 1d                	jne    80103d8a <mpinit+0x181>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103d6d:	c7 05 00 3a 11 80 01 	movl   $0x1,0x80113a00
80103d74:	00 00 00 
    lapic = 0;
80103d77:	c7 05 5c 32 11 80 00 	movl   $0x0,0x8011325c
80103d7e:	00 00 00 
    ioapicid = 0;
80103d81:	c6 05 40 33 11 80 00 	movb   $0x0,0x80113340
    return;
80103d88:	eb 44                	jmp    80103dce <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103d8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d8d:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103d91:	84 c0                	test   %al,%al
80103d93:	74 39                	je     80103dce <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d95:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d9c:	00 
80103d9d:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103da4:	e8 12 fc ff ff       	call   801039bb <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103da9:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103db0:	e8 dc fb ff ff       	call   80103991 <inb>
80103db5:	83 c8 01             	or     $0x1,%eax
80103db8:	0f b6 c0             	movzbl %al,%eax
80103dbb:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dbf:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103dc6:	e8 f0 fb ff ff       	call   801039bb <outb>
80103dcb:	eb 01                	jmp    80103dce <mpinit+0x1c5>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103dcd:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103dce:	c9                   	leave  
80103dcf:	c3                   	ret    

80103dd0 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103dd0:	55                   	push   %ebp
80103dd1:	89 e5                	mov    %esp,%ebp
80103dd3:	83 ec 08             	sub    $0x8,%esp
80103dd6:	8b 55 08             	mov    0x8(%ebp),%edx
80103dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ddc:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103de0:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103de3:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103de7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103deb:	ee                   	out    %al,(%dx)
}
80103dec:	c9                   	leave  
80103ded:	c3                   	ret    

80103dee <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103dee:	55                   	push   %ebp
80103def:	89 e5                	mov    %esp,%ebp
80103df1:	83 ec 0c             	sub    $0xc,%esp
80103df4:	8b 45 08             	mov    0x8(%ebp),%eax
80103df7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103dfb:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103dff:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103e05:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e09:	0f b6 c0             	movzbl %al,%eax
80103e0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e10:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e17:	e8 b4 ff ff ff       	call   80103dd0 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103e1c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e20:	66 c1 e8 08          	shr    $0x8,%ax
80103e24:	0f b6 c0             	movzbl %al,%eax
80103e27:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e2b:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e32:	e8 99 ff ff ff       	call   80103dd0 <outb>
}
80103e37:	c9                   	leave  
80103e38:	c3                   	ret    

80103e39 <picenable>:

void
picenable(int irq)
{
80103e39:	55                   	push   %ebp
80103e3a:	89 e5                	mov    %esp,%ebp
80103e3c:	53                   	push   %ebx
80103e3d:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103e40:	8b 45 08             	mov    0x8(%ebp),%eax
80103e43:	ba 01 00 00 00       	mov    $0x1,%edx
80103e48:	89 d3                	mov    %edx,%ebx
80103e4a:	89 c1                	mov    %eax,%ecx
80103e4c:	d3 e3                	shl    %cl,%ebx
80103e4e:	89 d8                	mov    %ebx,%eax
80103e50:	89 c2                	mov    %eax,%edx
80103e52:	f7 d2                	not    %edx
80103e54:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103e5b:	21 d0                	and    %edx,%eax
80103e5d:	0f b7 c0             	movzwl %ax,%eax
80103e60:	89 04 24             	mov    %eax,(%esp)
80103e63:	e8 86 ff ff ff       	call   80103dee <picsetmask>
}
80103e68:	83 c4 04             	add    $0x4,%esp
80103e6b:	5b                   	pop    %ebx
80103e6c:	5d                   	pop    %ebp
80103e6d:	c3                   	ret    

80103e6e <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103e6e:	55                   	push   %ebp
80103e6f:	89 e5                	mov    %esp,%ebp
80103e71:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e74:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e7b:	00 
80103e7c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e83:	e8 48 ff ff ff       	call   80103dd0 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e88:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e8f:	00 
80103e90:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e97:	e8 34 ff ff ff       	call   80103dd0 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103e9c:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ea3:	00 
80103ea4:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103eab:	e8 20 ff ff ff       	call   80103dd0 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103eb0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103eb7:	00 
80103eb8:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ebf:	e8 0c ff ff ff       	call   80103dd0 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103ec4:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103ecb:	00 
80103ecc:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ed3:	e8 f8 fe ff ff       	call   80103dd0 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103ed8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103edf:	00 
80103ee0:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ee7:	e8 e4 fe ff ff       	call   80103dd0 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103eec:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103ef3:	00 
80103ef4:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103efb:	e8 d0 fe ff ff       	call   80103dd0 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f00:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103f07:	00 
80103f08:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f0f:	e8 bc fe ff ff       	call   80103dd0 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f14:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103f1b:	00 
80103f1c:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f23:	e8 a8 fe ff ff       	call   80103dd0 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f28:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103f2f:	00 
80103f30:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f37:	e8 94 fe ff ff       	call   80103dd0 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f3c:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f43:	00 
80103f44:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f4b:	e8 80 fe ff ff       	call   80103dd0 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f50:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f57:	00 
80103f58:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103f5f:	e8 6c fe ff ff       	call   80103dd0 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103f64:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103f6b:	00 
80103f6c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f73:	e8 58 fe ff ff       	call   80103dd0 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103f78:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103f7f:	00 
80103f80:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103f87:	e8 44 fe ff ff       	call   80103dd0 <outb>

  if(irqmask != 0xFFFF)
80103f8c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f93:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f97:	74 12                	je     80103fab <picinit+0x13d>
    picsetmask(irqmask);
80103f99:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fa0:	0f b7 c0             	movzwl %ax,%eax
80103fa3:	89 04 24             	mov    %eax,(%esp)
80103fa6:	e8 43 fe ff ff       	call   80103dee <picsetmask>
}
80103fab:	c9                   	leave  
80103fac:	c3                   	ret    
80103fad:	00 00                	add    %al,(%eax)
	...

80103fb0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fb0:	55                   	push   %ebp
80103fb1:	89 e5                	mov    %esp,%ebp
80103fb3:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103fb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc9:	8b 10                	mov    (%eax),%edx
80103fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80103fce:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fd0:	e8 53 cf ff ff       	call   80100f28 <filealloc>
80103fd5:	8b 55 08             	mov    0x8(%ebp),%edx
80103fd8:	89 02                	mov    %eax,(%edx)
80103fda:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdd:	8b 00                	mov    (%eax),%eax
80103fdf:	85 c0                	test   %eax,%eax
80103fe1:	0f 84 c8 00 00 00    	je     801040af <pipealloc+0xff>
80103fe7:	e8 3c cf ff ff       	call   80100f28 <filealloc>
80103fec:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fef:	89 02                	mov    %eax,(%edx)
80103ff1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff4:	8b 00                	mov    (%eax),%eax
80103ff6:	85 c0                	test   %eax,%eax
80103ff8:	0f 84 b1 00 00 00    	je     801040af <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103ffe:	e8 08 eb ff ff       	call   80102b0b <kalloc>
80104003:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104006:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010400a:	0f 84 9e 00 00 00    	je     801040ae <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80104010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104013:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010401a:	00 00 00 
  p->writeopen = 1;
8010401d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104020:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104027:	00 00 00 
  p->nwrite = 0;
8010402a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010402d:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104034:	00 00 00 
  p->nread = 0;
80104037:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010403a:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104041:	00 00 00 
  initlock(&p->lock, "pipe");
80104044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104047:	c7 44 24 04 9c 8c 10 	movl   $0x80108c9c,0x4(%esp)
8010404e:	80 
8010404f:	89 04 24             	mov    %eax,(%esp)
80104052:	e8 27 0e 00 00       	call   80104e7e <initlock>
  (*f0)->type = FD_PIPE;
80104057:	8b 45 08             	mov    0x8(%ebp),%eax
8010405a:	8b 00                	mov    (%eax),%eax
8010405c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104062:	8b 45 08             	mov    0x8(%ebp),%eax
80104065:	8b 00                	mov    (%eax),%eax
80104067:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010406b:	8b 45 08             	mov    0x8(%ebp),%eax
8010406e:	8b 00                	mov    (%eax),%eax
80104070:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104074:	8b 45 08             	mov    0x8(%ebp),%eax
80104077:	8b 00                	mov    (%eax),%eax
80104079:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010407c:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010407f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104082:	8b 00                	mov    (%eax),%eax
80104084:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010408a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408d:	8b 00                	mov    (%eax),%eax
8010408f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104093:	8b 45 0c             	mov    0xc(%ebp),%eax
80104096:	8b 00                	mov    (%eax),%eax
80104098:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010409c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409f:	8b 00                	mov    (%eax),%eax
801040a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040a4:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040a7:	b8 00 00 00 00       	mov    $0x0,%eax
801040ac:	eb 43                	jmp    801040f1 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801040ae:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801040af:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040b3:	74 0b                	je     801040c0 <pipealloc+0x110>
    kfree((char*)p);
801040b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b8:	89 04 24             	mov    %eax,(%esp)
801040bb:	e8 b2 e9 ff ff       	call   80102a72 <kfree>
  if(*f0)
801040c0:	8b 45 08             	mov    0x8(%ebp),%eax
801040c3:	8b 00                	mov    (%eax),%eax
801040c5:	85 c0                	test   %eax,%eax
801040c7:	74 0d                	je     801040d6 <pipealloc+0x126>
    fileclose(*f0);
801040c9:	8b 45 08             	mov    0x8(%ebp),%eax
801040cc:	8b 00                	mov    (%eax),%eax
801040ce:	89 04 24             	mov    %eax,(%esp)
801040d1:	e8 fa ce ff ff       	call   80100fd0 <fileclose>
  if(*f1)
801040d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801040d9:	8b 00                	mov    (%eax),%eax
801040db:	85 c0                	test   %eax,%eax
801040dd:	74 0d                	je     801040ec <pipealloc+0x13c>
    fileclose(*f1);
801040df:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e2:	8b 00                	mov    (%eax),%eax
801040e4:	89 04 24             	mov    %eax,(%esp)
801040e7:	e8 e4 ce ff ff       	call   80100fd0 <fileclose>
  return -1;
801040ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801040f1:	c9                   	leave  
801040f2:	c3                   	ret    

801040f3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801040f3:	55                   	push   %ebp
801040f4:	89 e5                	mov    %esp,%ebp
801040f6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801040f9:	8b 45 08             	mov    0x8(%ebp),%eax
801040fc:	89 04 24             	mov    %eax,(%esp)
801040ff:	e8 9b 0d 00 00       	call   80104e9f <acquire>
  if(writable){
80104104:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104108:	74 1f                	je     80104129 <pipeclose+0x36>
    p->writeopen = 0;
8010410a:	8b 45 08             	mov    0x8(%ebp),%eax
8010410d:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104114:	00 00 00 
    wakeup(&p->nread);
80104117:	8b 45 08             	mov    0x8(%ebp),%eax
8010411a:	05 34 02 00 00       	add    $0x234,%eax
8010411f:	89 04 24             	mov    %eax,(%esp)
80104122:	e8 73 0b 00 00       	call   80104c9a <wakeup>
80104127:	eb 1d                	jmp    80104146 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104129:	8b 45 08             	mov    0x8(%ebp),%eax
8010412c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104133:	00 00 00 
    wakeup(&p->nwrite);
80104136:	8b 45 08             	mov    0x8(%ebp),%eax
80104139:	05 38 02 00 00       	add    $0x238,%eax
8010413e:	89 04 24             	mov    %eax,(%esp)
80104141:	e8 54 0b 00 00       	call   80104c9a <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104146:	8b 45 08             	mov    0x8(%ebp),%eax
80104149:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010414f:	85 c0                	test   %eax,%eax
80104151:	75 25                	jne    80104178 <pipeclose+0x85>
80104153:	8b 45 08             	mov    0x8(%ebp),%eax
80104156:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010415c:	85 c0                	test   %eax,%eax
8010415e:	75 18                	jne    80104178 <pipeclose+0x85>
    release(&p->lock);
80104160:	8b 45 08             	mov    0x8(%ebp),%eax
80104163:	89 04 24             	mov    %eax,(%esp)
80104166:	e8 96 0d 00 00       	call   80104f01 <release>
    kfree((char*)p);
8010416b:	8b 45 08             	mov    0x8(%ebp),%eax
8010416e:	89 04 24             	mov    %eax,(%esp)
80104171:	e8 fc e8 ff ff       	call   80102a72 <kfree>
80104176:	eb 0b                	jmp    80104183 <pipeclose+0x90>
  } else
    release(&p->lock);
80104178:	8b 45 08             	mov    0x8(%ebp),%eax
8010417b:	89 04 24             	mov    %eax,(%esp)
8010417e:	e8 7e 0d 00 00       	call   80104f01 <release>
}
80104183:	c9                   	leave  
80104184:	c3                   	ret    

80104185 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104185:	55                   	push   %ebp
80104186:	89 e5                	mov    %esp,%ebp
80104188:	53                   	push   %ebx
80104189:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010418c:	8b 45 08             	mov    0x8(%ebp),%eax
8010418f:	89 04 24             	mov    %eax,(%esp)
80104192:	e8 08 0d 00 00       	call   80104e9f <acquire>
  for(i = 0; i < n; i++){
80104197:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010419e:	e9 a6 00 00 00       	jmp    80104249 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801041a3:	8b 45 08             	mov    0x8(%ebp),%eax
801041a6:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041ac:	85 c0                	test   %eax,%eax
801041ae:	74 0d                	je     801041bd <pipewrite+0x38>
801041b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041b6:	8b 40 24             	mov    0x24(%eax),%eax
801041b9:	85 c0                	test   %eax,%eax
801041bb:	74 15                	je     801041d2 <pipewrite+0x4d>
        release(&p->lock);
801041bd:	8b 45 08             	mov    0x8(%ebp),%eax
801041c0:	89 04 24             	mov    %eax,(%esp)
801041c3:	e8 39 0d 00 00       	call   80104f01 <release>
        return -1;
801041c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041cd:	e9 9d 00 00 00       	jmp    8010426f <pipewrite+0xea>
      }
      wakeup(&p->nread);
801041d2:	8b 45 08             	mov    0x8(%ebp),%eax
801041d5:	05 34 02 00 00       	add    $0x234,%eax
801041da:	89 04 24             	mov    %eax,(%esp)
801041dd:	e8 b8 0a 00 00       	call   80104c9a <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801041e2:	8b 45 08             	mov    0x8(%ebp),%eax
801041e5:	8b 55 08             	mov    0x8(%ebp),%edx
801041e8:	81 c2 38 02 00 00    	add    $0x238,%edx
801041ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801041f2:	89 14 24             	mov    %edx,(%esp)
801041f5:	e8 c7 09 00 00       	call   80104bc1 <sleep>
801041fa:	eb 01                	jmp    801041fd <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801041fc:	90                   	nop
801041fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104200:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104206:	8b 45 08             	mov    0x8(%ebp),%eax
80104209:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010420f:	05 00 02 00 00       	add    $0x200,%eax
80104214:	39 c2                	cmp    %eax,%edx
80104216:	74 8b                	je     801041a3 <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104218:	8b 45 08             	mov    0x8(%ebp),%eax
8010421b:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104221:	89 c3                	mov    %eax,%ebx
80104223:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80104229:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010422c:	03 55 0c             	add    0xc(%ebp),%edx
8010422f:	0f b6 0a             	movzbl (%edx),%ecx
80104232:	8b 55 08             	mov    0x8(%ebp),%edx
80104235:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80104239:	8d 50 01             	lea    0x1(%eax),%edx
8010423c:	8b 45 08             	mov    0x8(%ebp),%eax
8010423f:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104245:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104249:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010424c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010424f:	7c ab                	jl     801041fc <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104251:	8b 45 08             	mov    0x8(%ebp),%eax
80104254:	05 34 02 00 00       	add    $0x234,%eax
80104259:	89 04 24             	mov    %eax,(%esp)
8010425c:	e8 39 0a 00 00       	call   80104c9a <wakeup>
  release(&p->lock);
80104261:	8b 45 08             	mov    0x8(%ebp),%eax
80104264:	89 04 24             	mov    %eax,(%esp)
80104267:	e8 95 0c 00 00       	call   80104f01 <release>
  return n;
8010426c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010426f:	83 c4 24             	add    $0x24,%esp
80104272:	5b                   	pop    %ebx
80104273:	5d                   	pop    %ebp
80104274:	c3                   	ret    

80104275 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104275:	55                   	push   %ebp
80104276:	89 e5                	mov    %esp,%ebp
80104278:	53                   	push   %ebx
80104279:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010427c:	8b 45 08             	mov    0x8(%ebp),%eax
8010427f:	89 04 24             	mov    %eax,(%esp)
80104282:	e8 18 0c 00 00       	call   80104e9f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104287:	eb 3a                	jmp    801042c3 <piperead+0x4e>
    if(proc->killed){
80104289:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010428f:	8b 40 24             	mov    0x24(%eax),%eax
80104292:	85 c0                	test   %eax,%eax
80104294:	74 15                	je     801042ab <piperead+0x36>
      release(&p->lock);
80104296:	8b 45 08             	mov    0x8(%ebp),%eax
80104299:	89 04 24             	mov    %eax,(%esp)
8010429c:	e8 60 0c 00 00       	call   80104f01 <release>
      return -1;
801042a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a6:	e9 b6 00 00 00       	jmp    80104361 <piperead+0xec>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042ab:	8b 45 08             	mov    0x8(%ebp),%eax
801042ae:	8b 55 08             	mov    0x8(%ebp),%edx
801042b1:	81 c2 34 02 00 00    	add    $0x234,%edx
801042b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801042bb:	89 14 24             	mov    %edx,(%esp)
801042be:	e8 fe 08 00 00       	call   80104bc1 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042c3:	8b 45 08             	mov    0x8(%ebp),%eax
801042c6:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042cc:	8b 45 08             	mov    0x8(%ebp),%eax
801042cf:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042d5:	39 c2                	cmp    %eax,%edx
801042d7:	75 0d                	jne    801042e6 <piperead+0x71>
801042d9:	8b 45 08             	mov    0x8(%ebp),%eax
801042dc:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042e2:	85 c0                	test   %eax,%eax
801042e4:	75 a3                	jne    80104289 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042ed:	eb 49                	jmp    80104338 <piperead+0xc3>
    if(p->nread == p->nwrite)
801042ef:	8b 45 08             	mov    0x8(%ebp),%eax
801042f2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801042f8:	8b 45 08             	mov    0x8(%ebp),%eax
801042fb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104301:	39 c2                	cmp    %eax,%edx
80104303:	74 3d                	je     80104342 <piperead+0xcd>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104305:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104308:	89 c2                	mov    %eax,%edx
8010430a:	03 55 0c             	add    0xc(%ebp),%edx
8010430d:	8b 45 08             	mov    0x8(%ebp),%eax
80104310:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104316:	89 c3                	mov    %eax,%ebx
80104318:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
8010431e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104321:	0f b6 4c 19 34       	movzbl 0x34(%ecx,%ebx,1),%ecx
80104326:	88 0a                	mov    %cl,(%edx)
80104328:	8d 50 01             	lea    0x1(%eax),%edx
8010432b:	8b 45 08             	mov    0x8(%ebp),%eax
8010432e:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104334:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010433e:	7c af                	jl     801042ef <piperead+0x7a>
80104340:	eb 01                	jmp    80104343 <piperead+0xce>
    if(p->nread == p->nwrite)
      break;
80104342:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	05 38 02 00 00       	add    $0x238,%eax
8010434b:	89 04 24             	mov    %eax,(%esp)
8010434e:	e8 47 09 00 00       	call   80104c9a <wakeup>
  release(&p->lock);
80104353:	8b 45 08             	mov    0x8(%ebp),%eax
80104356:	89 04 24             	mov    %eax,(%esp)
80104359:	e8 a3 0b 00 00       	call   80104f01 <release>
  return i;
8010435e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104361:	83 c4 24             	add    $0x24,%esp
80104364:	5b                   	pop    %ebx
80104365:	5d                   	pop    %ebp
80104366:	c3                   	ret    
	...

80104368 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104368:	55                   	push   %ebp
80104369:	89 e5                	mov    %esp,%ebp
8010436b:	53                   	push   %ebx
8010436c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010436f:	9c                   	pushf  
80104370:	5b                   	pop    %ebx
80104371:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104374:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104377:	83 c4 10             	add    $0x10,%esp
8010437a:	5b                   	pop    %ebx
8010437b:	5d                   	pop    %ebp
8010437c:	c3                   	ret    

8010437d <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
8010437d:	55                   	push   %ebp
8010437e:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104380:	fb                   	sti    
}
80104381:	5d                   	pop    %ebp
80104382:	c3                   	ret    

80104383 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104383:	55                   	push   %ebp
80104384:	89 e5                	mov    %esp,%ebp
80104386:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104389:	c7 44 24 04 a1 8c 10 	movl   $0x80108ca1,0x4(%esp)
80104390:	80 
80104391:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104398:	e8 e1 0a 00 00       	call   80104e7e <initlock>
}
8010439d:	c9                   	leave  
8010439e:	c3                   	ret    

8010439f <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010439f:	55                   	push   %ebp
801043a0:	89 e5                	mov    %esp,%ebp
801043a2:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801043a5:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
801043ac:	e8 ee 0a 00 00       	call   80104e9f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043b1:	c7 45 f4 54 3a 11 80 	movl   $0x80113a54,-0xc(%ebp)
801043b8:	eb 0e                	jmp    801043c8 <allocproc+0x29>
    if(p->state == UNUSED)
801043ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043bd:	8b 40 0c             	mov    0xc(%eax),%eax
801043c0:	85 c0                	test   %eax,%eax
801043c2:	74 23                	je     801043e7 <allocproc+0x48>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043c4:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801043c8:	81 7d f4 54 59 11 80 	cmpl   $0x80115954,-0xc(%ebp)
801043cf:	72 e9                	jb     801043ba <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801043d1:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
801043d8:	e8 24 0b 00 00       	call   80104f01 <release>
  return 0;
801043dd:	b8 00 00 00 00       	mov    $0x0,%eax
801043e2:	e9 b5 00 00 00       	jmp    8010449c <allocproc+0xfd>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801043e7:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801043e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043eb:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801043f2:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801043f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043fa:	89 42 10             	mov    %eax,0x10(%edx)
801043fd:	83 c0 01             	add    $0x1,%eax
80104400:	a3 04 c0 10 80       	mov    %eax,0x8010c004
  release(&ptable.lock);
80104405:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
8010440c:	e8 f0 0a 00 00       	call   80104f01 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104411:	e8 f5 e6 ff ff       	call   80102b0b <kalloc>
80104416:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104419:	89 42 08             	mov    %eax,0x8(%edx)
8010441c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441f:	8b 40 08             	mov    0x8(%eax),%eax
80104422:	85 c0                	test   %eax,%eax
80104424:	75 11                	jne    80104437 <allocproc+0x98>
    p->state = UNUSED;
80104426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104429:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104430:	b8 00 00 00 00       	mov    $0x0,%eax
80104435:	eb 65                	jmp    8010449c <allocproc+0xfd>
  }
  sp = p->kstack + KSTACKSIZE;
80104437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443a:	8b 40 08             	mov    0x8(%eax),%eax
8010443d:	05 00 10 00 00       	add    $0x1000,%eax
80104442:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104445:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010444f:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104452:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104456:	ba 48 65 10 80       	mov    $0x80106548,%edx
8010445b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010445e:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104460:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104467:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010446a:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010446d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104470:	8b 40 1c             	mov    0x1c(%eax),%eax
80104473:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010447a:	00 
8010447b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104482:	00 
80104483:	89 04 24             	mov    %eax,(%esp)
80104486:	e8 63 0c 00 00       	call   801050ee <memset>
  p->context->eip = (uint)forkret;
8010448b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104491:	ba 95 4b 10 80       	mov    $0x80104b95,%edx
80104496:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010449c:	c9                   	leave  
8010449d:	c3                   	ret    

8010449e <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010449e:	55                   	push   %ebp
8010449f:	89 e5                	mov    %esp,%ebp
801044a1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801044a4:	e8 f6 fe ff ff       	call   8010439f <allocproc>
801044a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801044ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044af:	a3 48 c6 10 80       	mov    %eax,0x8010c648
  if((p->pgdir = setupkvm()) == 0)
801044b4:	e8 fb 3b 00 00       	call   801080b4 <setupkvm>
801044b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044bc:	89 42 04             	mov    %eax,0x4(%edx)
801044bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c2:	8b 40 04             	mov    0x4(%eax),%eax
801044c5:	85 c0                	test   %eax,%eax
801044c7:	75 0c                	jne    801044d5 <userinit+0x37>
    panic("userinit: out of memory?");
801044c9:	c7 04 24 a8 8c 10 80 	movl   $0x80108ca8,(%esp)
801044d0:	e8 68 c0 ff ff       	call   8010053d <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801044d5:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dd:	8b 40 04             	mov    0x4(%eax),%eax
801044e0:	89 54 24 08          	mov    %edx,0x8(%esp)
801044e4:	c7 44 24 04 e0 c4 10 	movl   $0x8010c4e0,0x4(%esp)
801044eb:	80 
801044ec:	89 04 24             	mov    %eax,(%esp)
801044ef:	e8 0f 3e 00 00       	call   80108303 <inituvm>
  p->sz = PGSIZE;
801044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f7:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801044fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104500:	8b 40 18             	mov    0x18(%eax),%eax
80104503:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010450a:	00 
8010450b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104512:	00 
80104513:	89 04 24             	mov    %eax,(%esp)
80104516:	e8 d3 0b 00 00       	call   801050ee <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010451b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451e:	8b 40 18             	mov    0x18(%eax),%eax
80104521:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452a:	8b 40 18             	mov    0x18(%eax),%eax
8010452d:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104536:	8b 40 18             	mov    0x18(%eax),%eax
80104539:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010453c:	8b 52 18             	mov    0x18(%edx),%edx
8010453f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104543:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454a:	8b 40 18             	mov    0x18(%eax),%eax
8010454d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104550:	8b 52 18             	mov    0x18(%edx),%edx
80104553:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104557:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010455b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010455e:	8b 40 18             	mov    0x18(%eax),%eax
80104561:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104568:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456b:	8b 40 18             	mov    0x18(%eax),%eax
8010456e:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104578:	8b 40 18             	mov    0x18(%eax),%eax
8010457b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104585:	83 c0 6c             	add    $0x6c,%eax
80104588:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010458f:	00 
80104590:	c7 44 24 04 c1 8c 10 	movl   $0x80108cc1,0x4(%esp)
80104597:	80 
80104598:	89 04 24             	mov    %eax,(%esp)
8010459b:	e8 7e 0d 00 00       	call   8010531e <safestrcpy>
  p->cwd = namei("/");
801045a0:	c7 04 24 ca 8c 10 80 	movl   $0x80108cca,(%esp)
801045a7:	e8 6a de ff ff       	call   80102416 <namei>
801045ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045af:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801045b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801045bc:	c9                   	leave  
801045bd:	c3                   	ret    

801045be <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801045be:	55                   	push   %ebp
801045bf:	89 e5                	mov    %esp,%ebp
801045c1:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801045c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045ca:	8b 00                	mov    (%eax),%eax
801045cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045cf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045d3:	7e 34                	jle    80104609 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801045d5:	8b 45 08             	mov    0x8(%ebp),%eax
801045d8:	89 c2                	mov    %eax,%edx
801045da:	03 55 f4             	add    -0xc(%ebp),%edx
801045dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045e3:	8b 40 04             	mov    0x4(%eax),%eax
801045e6:	89 54 24 08          	mov    %edx,0x8(%esp)
801045ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045ed:	89 54 24 04          	mov    %edx,0x4(%esp)
801045f1:	89 04 24             	mov    %eax,(%esp)
801045f4:	e8 84 3e 00 00       	call   8010847d <allocuvm>
801045f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104600:	75 41                	jne    80104643 <growproc+0x85>
      return -1;
80104602:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104607:	eb 58                	jmp    80104661 <growproc+0xa3>
  } else if(n < 0){
80104609:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010460d:	79 34                	jns    80104643 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010460f:	8b 45 08             	mov    0x8(%ebp),%eax
80104612:	89 c2                	mov    %eax,%edx
80104614:	03 55 f4             	add    -0xc(%ebp),%edx
80104617:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010461d:	8b 40 04             	mov    0x4(%eax),%eax
80104620:	89 54 24 08          	mov    %edx,0x8(%esp)
80104624:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104627:	89 54 24 04          	mov    %edx,0x4(%esp)
8010462b:	89 04 24             	mov    %eax,(%esp)
8010462e:	e8 24 3f 00 00       	call   80108557 <deallocuvm>
80104633:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104636:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010463a:	75 07                	jne    80104643 <growproc+0x85>
      return -1;
8010463c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104641:	eb 1e                	jmp    80104661 <growproc+0xa3>
  }
  proc->sz = sz;
80104643:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104649:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464c:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010464e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104654:	89 04 24             	mov    %eax,(%esp)
80104657:	e8 51 3b 00 00       	call   801081ad <switchuvm>
  return 0;
8010465c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104661:	c9                   	leave  
80104662:	c3                   	ret    

80104663 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104663:	55                   	push   %ebp
80104664:	89 e5                	mov    %esp,%ebp
80104666:	57                   	push   %edi
80104667:	56                   	push   %esi
80104668:	53                   	push   %ebx
80104669:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010466c:	e8 2e fd ff ff       	call   8010439f <allocproc>
80104671:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104674:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104678:	75 0a                	jne    80104684 <fork+0x21>
    return -1;
8010467a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010467f:	e9 52 01 00 00       	jmp    801047d6 <fork+0x173>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104684:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010468a:	8b 10                	mov    (%eax),%edx
8010468c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104692:	8b 40 04             	mov    0x4(%eax),%eax
80104695:	89 54 24 04          	mov    %edx,0x4(%esp)
80104699:	89 04 24             	mov    %eax,(%esp)
8010469c:	e8 46 40 00 00       	call   801086e7 <copyuvm>
801046a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046a4:	89 42 04             	mov    %eax,0x4(%edx)
801046a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046aa:	8b 40 04             	mov    0x4(%eax),%eax
801046ad:	85 c0                	test   %eax,%eax
801046af:	75 2c                	jne    801046dd <fork+0x7a>
    kfree(np->kstack);
801046b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046b4:	8b 40 08             	mov    0x8(%eax),%eax
801046b7:	89 04 24             	mov    %eax,(%esp)
801046ba:	e8 b3 e3 ff ff       	call   80102a72 <kfree>
    np->kstack = 0;
801046bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046cc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046d8:	e9 f9 00 00 00       	jmp    801047d6 <fork+0x173>
  }
  np->sz = proc->sz;
801046dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e3:	8b 10                	mov    (%eax),%edx
801046e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e8:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801046ea:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801046f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046f4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801046f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046fa:	8b 50 18             	mov    0x18(%eax),%edx
801046fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104703:	8b 40 18             	mov    0x18(%eax),%eax
80104706:	89 c3                	mov    %eax,%ebx
80104708:	b8 13 00 00 00       	mov    $0x13,%eax
8010470d:	89 d7                	mov    %edx,%edi
8010470f:	89 de                	mov    %ebx,%esi
80104711:	89 c1                	mov    %eax,%ecx
80104713:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104715:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104718:	8b 40 18             	mov    0x18(%eax),%eax
8010471b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104722:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104729:	eb 3d                	jmp    80104768 <fork+0x105>
    if(proc->ofile[i])
8010472b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104731:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104734:	83 c2 08             	add    $0x8,%edx
80104737:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010473b:	85 c0                	test   %eax,%eax
8010473d:	74 25                	je     80104764 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010473f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104745:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104748:	83 c2 08             	add    $0x8,%edx
8010474b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010474f:	89 04 24             	mov    %eax,(%esp)
80104752:	e8 31 c8 ff ff       	call   80100f88 <filedup>
80104757:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010475a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010475d:	83 c1 08             	add    $0x8,%ecx
80104760:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104764:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104768:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010476c:	7e bd                	jle    8010472b <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010476e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104774:	8b 40 68             	mov    0x68(%eax),%eax
80104777:	89 04 24             	mov    %eax,(%esp)
8010477a:	e8 c3 d0 ff ff       	call   80101842 <idup>
8010477f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104782:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104785:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010478b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010478e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104791:	83 c0 6c             	add    $0x6c,%eax
80104794:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010479b:	00 
8010479c:	89 54 24 04          	mov    %edx,0x4(%esp)
801047a0:	89 04 24             	mov    %eax,(%esp)
801047a3:	e8 76 0b 00 00       	call   8010531e <safestrcpy>
 
  pid = np->pid;
801047a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ab:	8b 40 10             	mov    0x10(%eax),%eax
801047ae:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801047b1:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
801047b8:	e8 e2 06 00 00       	call   80104e9f <acquire>
  np->state = RUNNABLE;
801047bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801047c7:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
801047ce:	e8 2e 07 00 00       	call   80104f01 <release>
  
  return pid;
801047d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801047d6:	83 c4 2c             	add    $0x2c,%esp
801047d9:	5b                   	pop    %ebx
801047da:	5e                   	pop    %esi
801047db:	5f                   	pop    %edi
801047dc:	5d                   	pop    %ebp
801047dd:	c3                   	ret    

801047de <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801047de:	55                   	push   %ebp
801047df:	89 e5                	mov    %esp,%ebp
801047e1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801047e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047eb:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801047f0:	39 c2                	cmp    %eax,%edx
801047f2:	75 0c                	jne    80104800 <exit+0x22>
    panic("init exiting");
801047f4:	c7 04 24 cc 8c 10 80 	movl   $0x80108ccc,(%esp)
801047fb:	e8 3d bd ff ff       	call   8010053d <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104800:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104807:	eb 44                	jmp    8010484d <exit+0x6f>
    if(proc->ofile[fd]){
80104809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104812:	83 c2 08             	add    $0x8,%edx
80104815:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104819:	85 c0                	test   %eax,%eax
8010481b:	74 2c                	je     80104849 <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010481d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104823:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104826:	83 c2 08             	add    $0x8,%edx
80104829:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010482d:	89 04 24             	mov    %eax,(%esp)
80104830:	e8 9b c7 ff ff       	call   80100fd0 <fileclose>
      proc->ofile[fd] = 0;
80104835:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010483e:	83 c2 08             	add    $0x8,%edx
80104841:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104848:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104849:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010484d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104851:	7e b6                	jle    80104809 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104853:	e8 09 ec ff ff       	call   80103461 <begin_op>
  iput(proc->cwd);
80104858:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010485e:	8b 40 68             	mov    0x68(%eax),%eax
80104861:	89 04 24             	mov    %eax,(%esp)
80104864:	e8 be d1 ff ff       	call   80101a27 <iput>
  end_op();
80104869:	e8 74 ec ff ff       	call   801034e2 <end_op>
  proc->cwd = 0;
8010486e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104874:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010487b:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104882:	e8 18 06 00 00       	call   80104e9f <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104887:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010488d:	8b 40 14             	mov    0x14(%eax),%eax
80104890:	89 04 24             	mov    %eax,(%esp)
80104893:	e8 c4 03 00 00       	call   80104c5c <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104898:	c7 45 f4 54 3a 11 80 	movl   $0x80113a54,-0xc(%ebp)
8010489f:	eb 38                	jmp    801048d9 <exit+0xfb>
    if(p->parent == proc){
801048a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a4:	8b 50 14             	mov    0x14(%eax),%edx
801048a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ad:	39 c2                	cmp    %eax,%edx
801048af:	75 24                	jne    801048d5 <exit+0xf7>
      p->parent = initproc;
801048b1:	8b 15 48 c6 10 80    	mov    0x8010c648,%edx
801048b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ba:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c0:	8b 40 0c             	mov    0xc(%eax),%eax
801048c3:	83 f8 05             	cmp    $0x5,%eax
801048c6:	75 0d                	jne    801048d5 <exit+0xf7>
        wakeup1(initproc);
801048c8:	a1 48 c6 10 80       	mov    0x8010c648,%eax
801048cd:	89 04 24             	mov    %eax,(%esp)
801048d0:	e8 87 03 00 00       	call   80104c5c <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048d5:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801048d9:	81 7d f4 54 59 11 80 	cmpl   $0x80115954,-0xc(%ebp)
801048e0:	72 bf                	jb     801048a1 <exit+0xc3>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801048e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048e8:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801048ef:	e8 bd 01 00 00       	call   80104ab1 <sched>
  panic("zombie exit");
801048f4:	c7 04 24 d9 8c 10 80 	movl   $0x80108cd9,(%esp)
801048fb:	e8 3d bc ff ff       	call   8010053d <panic>

80104900 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104900:	55                   	push   %ebp
80104901:	89 e5                	mov    %esp,%ebp
80104903:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104906:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
8010490d:	e8 8d 05 00 00       	call   80104e9f <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104912:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104919:	c7 45 f4 54 3a 11 80 	movl   $0x80113a54,-0xc(%ebp)
80104920:	e9 9a 00 00 00       	jmp    801049bf <wait+0xbf>
      if(p->parent != proc)
80104925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104928:	8b 50 14             	mov    0x14(%eax),%edx
8010492b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104931:	39 c2                	cmp    %eax,%edx
80104933:	0f 85 81 00 00 00    	jne    801049ba <wait+0xba>
        continue;
      havekids = 1;
80104939:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104940:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104943:	8b 40 0c             	mov    0xc(%eax),%eax
80104946:	83 f8 05             	cmp    $0x5,%eax
80104949:	75 70                	jne    801049bb <wait+0xbb>
        // Found one.
        pid = p->pid;
8010494b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010494e:	8b 40 10             	mov    0x10(%eax),%eax
80104951:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104957:	8b 40 08             	mov    0x8(%eax),%eax
8010495a:	89 04 24             	mov    %eax,(%esp)
8010495d:	e8 10 e1 ff ff       	call   80102a72 <kfree>
        p->kstack = 0;
80104962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104965:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010496c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496f:	8b 40 04             	mov    0x4(%eax),%eax
80104972:	89 04 24             	mov    %eax,(%esp)
80104975:	e8 99 3c 00 00       	call   80108613 <freevm>
        p->state = UNUSED;
8010497a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010497d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104987:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010498e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104991:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010499b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010499f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a2:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801049a9:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
801049b0:	e8 4c 05 00 00       	call   80104f01 <release>
        return pid;
801049b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049b8:	eb 53                	jmp    80104a0d <wait+0x10d>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801049ba:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049bb:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801049bf:	81 7d f4 54 59 11 80 	cmpl   $0x80115954,-0xc(%ebp)
801049c6:	0f 82 59 ff ff ff    	jb     80104925 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801049cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801049d0:	74 0d                	je     801049df <wait+0xdf>
801049d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d8:	8b 40 24             	mov    0x24(%eax),%eax
801049db:	85 c0                	test   %eax,%eax
801049dd:	74 13                	je     801049f2 <wait+0xf2>
      release(&ptable.lock);
801049df:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
801049e6:	e8 16 05 00 00       	call   80104f01 <release>
      return -1;
801049eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049f0:	eb 1b                	jmp    80104a0d <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801049f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f8:	c7 44 24 04 20 3a 11 	movl   $0x80113a20,0x4(%esp)
801049ff:	80 
80104a00:	89 04 24             	mov    %eax,(%esp)
80104a03:	e8 b9 01 00 00       	call   80104bc1 <sleep>
  }
80104a08:	e9 05 ff ff ff       	jmp    80104912 <wait+0x12>
}
80104a0d:	c9                   	leave  
80104a0e:	c3                   	ret    

80104a0f <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104a0f:	55                   	push   %ebp
80104a10:	89 e5                	mov    %esp,%ebp
80104a12:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104a15:	e8 63 f9 ff ff       	call   8010437d <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104a1a:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104a21:	e8 79 04 00 00       	call   80104e9f <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a26:	c7 45 f4 54 3a 11 80 	movl   $0x80113a54,-0xc(%ebp)
80104a2d:	eb 68                	jmp    80104a97 <scheduler+0x88>
      if(p->state != RUNNABLE)
80104a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a32:	8b 40 0c             	mov    0xc(%eax),%eax
80104a35:	83 f8 03             	cmp    $0x3,%eax
80104a38:	75 58                	jne    80104a92 <scheduler+0x83>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3d:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a46:	89 04 24             	mov    %eax,(%esp)
80104a49:	e8 5f 37 00 00       	call   801081ad <switchuvm>
      p->state = RUNNING;
80104a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a51:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104a58:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a5e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a61:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104a68:	83 c2 1c             	add    $0x1c,%edx
80104a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a6f:	89 14 24             	mov    %edx,(%esp)
80104a72:	e8 1d 09 00 00       	call   80105394 <swtch>
      switchkvm(cpu);
80104a77:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104a7d:	89 04 24             	mov    %eax,(%esp)
80104a80:	e8 0a 37 00 00       	call   8010818f <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104a85:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104a8c:	00 00 00 00 
80104a90:	eb 01                	jmp    80104a93 <scheduler+0x84>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104a92:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a93:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a97:	81 7d f4 54 59 11 80 	cmpl   $0x80115954,-0xc(%ebp)
80104a9e:	72 8f                	jb     80104a2f <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104aa0:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104aa7:	e8 55 04 00 00       	call   80104f01 <release>

  }
80104aac:	e9 64 ff ff ff       	jmp    80104a15 <scheduler+0x6>

80104ab1 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ab1:	55                   	push   %ebp
80104ab2:	89 e5                	mov    %esp,%ebp
80104ab4:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104ab7:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104abe:	e8 fa 04 00 00       	call   80104fbd <holding>
80104ac3:	85 c0                	test   %eax,%eax
80104ac5:	75 0c                	jne    80104ad3 <sched+0x22>
    panic("sched ptable.lock");
80104ac7:	c7 04 24 e5 8c 10 80 	movl   $0x80108ce5,(%esp)
80104ace:	e8 6a ba ff ff       	call   8010053d <panic>
  if(cpu->ncli != 1)
80104ad3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ad9:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
80104adf:	83 f8 01             	cmp    $0x1,%eax
80104ae2:	74 0c                	je     80104af0 <sched+0x3f>
    panic("sched locks");
80104ae4:	c7 04 24 f7 8c 10 80 	movl   $0x80108cf7,(%esp)
80104aeb:	e8 4d ba ff ff       	call   8010053d <panic>
  if(proc->state == RUNNING)
80104af0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af6:	8b 40 0c             	mov    0xc(%eax),%eax
80104af9:	83 f8 04             	cmp    $0x4,%eax
80104afc:	75 0c                	jne    80104b0a <sched+0x59>
    panic("sched running");
80104afe:	c7 04 24 03 8d 10 80 	movl   $0x80108d03,(%esp)
80104b05:	e8 33 ba ff ff       	call   8010053d <panic>
  if(readeflags()&FL_IF)
80104b0a:	e8 59 f8 ff ff       	call   80104368 <readeflags>
80104b0f:	25 00 02 00 00       	and    $0x200,%eax
80104b14:	85 c0                	test   %eax,%eax
80104b16:	74 0c                	je     80104b24 <sched+0x73>
    panic("sched interruptible");
80104b18:	c7 04 24 11 8d 10 80 	movl   $0x80108d11,(%esp)
80104b1f:	e8 19 ba ff ff       	call   8010053d <panic>
  intena = cpu->intena;
80104b24:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b2a:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80104b30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104b33:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b39:	8b 40 1c             	mov    0x1c(%eax),%eax
80104b3c:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104b43:	83 c2 1c             	add    $0x1c,%edx
80104b46:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b4a:	89 14 24             	mov    %edx,(%esp)
80104b4d:	e8 42 08 00 00       	call   80105394 <swtch>
  cpu->intena = intena;
80104b52:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104b58:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b5b:	89 90 c8 00 00 00    	mov    %edx,0xc8(%eax)
}
80104b61:	c9                   	leave  
80104b62:	c3                   	ret    

80104b63 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b63:	55                   	push   %ebp
80104b64:	89 e5                	mov    %esp,%ebp
80104b66:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104b69:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104b70:	e8 2a 03 00 00       	call   80104e9f <acquire>
  proc->state = RUNNABLE;
80104b75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b7b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b82:	e8 2a ff ff ff       	call   80104ab1 <sched>
  release(&ptable.lock);
80104b87:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104b8e:	e8 6e 03 00 00       	call   80104f01 <release>
}
80104b93:	c9                   	leave  
80104b94:	c3                   	ret    

80104b95 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b95:	55                   	push   %ebp
80104b96:	89 e5                	mov    %esp,%ebp
80104b98:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104b9b:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104ba2:	e8 5a 03 00 00       	call   80104f01 <release>

  if (first) {
80104ba7:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80104bac:	85 c0                	test   %eax,%eax
80104bae:	74 0f                	je     80104bbf <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104bb0:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
80104bb7:	00 00 00 
    initlog();
80104bba:	e8 95 e6 ff ff       	call   80103254 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104bbf:	c9                   	leave  
80104bc0:	c3                   	ret    

80104bc1 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104bc1:	55                   	push   %ebp
80104bc2:	89 e5                	mov    %esp,%ebp
80104bc4:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104bc7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bcd:	85 c0                	test   %eax,%eax
80104bcf:	75 0c                	jne    80104bdd <sleep+0x1c>
    panic("sleep");
80104bd1:	c7 04 24 25 8d 10 80 	movl   $0x80108d25,(%esp)
80104bd8:	e8 60 b9 ff ff       	call   8010053d <panic>

  if(lk == 0)
80104bdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104be1:	75 0c                	jne    80104bef <sleep+0x2e>
    panic("sleep without lk");
80104be3:	c7 04 24 2b 8d 10 80 	movl   $0x80108d2b,(%esp)
80104bea:	e8 4e b9 ff ff       	call   8010053d <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104bef:	81 7d 0c 20 3a 11 80 	cmpl   $0x80113a20,0xc(%ebp)
80104bf6:	74 17                	je     80104c0f <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104bf8:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104bff:	e8 9b 02 00 00       	call   80104e9f <acquire>
    release(lk);
80104c04:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c07:	89 04 24             	mov    %eax,(%esp)
80104c0a:	e8 f2 02 00 00       	call   80104f01 <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104c0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c15:	8b 55 08             	mov    0x8(%ebp),%edx
80104c18:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104c1b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c21:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104c28:	e8 84 fe ff ff       	call   80104ab1 <sched>

  // Tidy up.
  proc->chan = 0;
80104c2d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c33:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104c3a:	81 7d 0c 20 3a 11 80 	cmpl   $0x80113a20,0xc(%ebp)
80104c41:	74 17                	je     80104c5a <sleep+0x99>
    release(&ptable.lock);
80104c43:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104c4a:	e8 b2 02 00 00       	call   80104f01 <release>
    acquire(lk);
80104c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c52:	89 04 24             	mov    %eax,(%esp)
80104c55:	e8 45 02 00 00       	call   80104e9f <acquire>
  }
}
80104c5a:	c9                   	leave  
80104c5b:	c3                   	ret    

80104c5c <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104c5c:	55                   	push   %ebp
80104c5d:	89 e5                	mov    %esp,%ebp
80104c5f:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c62:	c7 45 fc 54 3a 11 80 	movl   $0x80113a54,-0x4(%ebp)
80104c69:	eb 24                	jmp    80104c8f <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104c6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c6e:	8b 40 0c             	mov    0xc(%eax),%eax
80104c71:	83 f8 02             	cmp    $0x2,%eax
80104c74:	75 15                	jne    80104c8b <wakeup1+0x2f>
80104c76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c79:	8b 40 20             	mov    0x20(%eax),%eax
80104c7c:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c7f:	75 0a                	jne    80104c8b <wakeup1+0x2f>
      p->state = RUNNABLE;
80104c81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c84:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104c8b:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104c8f:	81 7d fc 54 59 11 80 	cmpl   $0x80115954,-0x4(%ebp)
80104c96:	72 d3                	jb     80104c6b <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104c98:	c9                   	leave  
80104c99:	c3                   	ret    

80104c9a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c9a:	55                   	push   %ebp
80104c9b:	89 e5                	mov    %esp,%ebp
80104c9d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104ca0:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104ca7:	e8 f3 01 00 00       	call   80104e9f <acquire>
  wakeup1(chan);
80104cac:	8b 45 08             	mov    0x8(%ebp),%eax
80104caf:	89 04 24             	mov    %eax,(%esp)
80104cb2:	e8 a5 ff ff ff       	call   80104c5c <wakeup1>
  release(&ptable.lock);
80104cb7:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104cbe:	e8 3e 02 00 00       	call   80104f01 <release>
}
80104cc3:	c9                   	leave  
80104cc4:	c3                   	ret    

80104cc5 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104cc5:	55                   	push   %ebp
80104cc6:	89 e5                	mov    %esp,%ebp
80104cc8:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ccb:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104cd2:	e8 c8 01 00 00       	call   80104e9f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cd7:	c7 45 f4 54 3a 11 80 	movl   $0x80113a54,-0xc(%ebp)
80104cde:	eb 41                	jmp    80104d21 <kill+0x5c>
    if(p->pid == pid){
80104ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce3:	8b 40 10             	mov    0x10(%eax),%eax
80104ce6:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ce9:	75 32                	jne    80104d1d <kill+0x58>
      p->killed = 1;
80104ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cee:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf8:	8b 40 0c             	mov    0xc(%eax),%eax
80104cfb:	83 f8 02             	cmp    $0x2,%eax
80104cfe:	75 0a                	jne    80104d0a <kill+0x45>
        p->state = RUNNABLE;
80104d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d03:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104d0a:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104d11:	e8 eb 01 00 00       	call   80104f01 <release>
      return 0;
80104d16:	b8 00 00 00 00       	mov    $0x0,%eax
80104d1b:	eb 1e                	jmp    80104d3b <kill+0x76>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d1d:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104d21:	81 7d f4 54 59 11 80 	cmpl   $0x80115954,-0xc(%ebp)
80104d28:	72 b6                	jb     80104ce0 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104d2a:	c7 04 24 20 3a 11 80 	movl   $0x80113a20,(%esp)
80104d31:	e8 cb 01 00 00       	call   80104f01 <release>
  return -1;
80104d36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d3b:	c9                   	leave  
80104d3c:	c3                   	ret    

80104d3d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104d3d:	55                   	push   %ebp
80104d3e:	89 e5                	mov    %esp,%ebp
80104d40:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d43:	c7 45 f0 54 3a 11 80 	movl   $0x80113a54,-0x10(%ebp)
80104d4a:	e9 d8 00 00 00       	jmp    80104e27 <procdump+0xea>
    if(p->state == UNUSED)
80104d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d52:	8b 40 0c             	mov    0xc(%eax),%eax
80104d55:	85 c0                	test   %eax,%eax
80104d57:	0f 84 c5 00 00 00    	je     80104e22 <procdump+0xe5>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d60:	8b 40 0c             	mov    0xc(%eax),%eax
80104d63:	83 f8 05             	cmp    $0x5,%eax
80104d66:	77 23                	ja     80104d8b <procdump+0x4e>
80104d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d6b:	8b 40 0c             	mov    0xc(%eax),%eax
80104d6e:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104d75:	85 c0                	test   %eax,%eax
80104d77:	74 12                	je     80104d8b <procdump+0x4e>
      state = states[p->state];
80104d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d7c:	8b 40 0c             	mov    0xc(%eax),%eax
80104d7f:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104d86:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104d89:	eb 07                	jmp    80104d92 <procdump+0x55>
    else
      state = "???";
80104d8b:	c7 45 ec 3c 8d 10 80 	movl   $0x80108d3c,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104d92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d95:	8d 50 6c             	lea    0x6c(%eax),%edx
80104d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d9b:	8b 40 10             	mov    0x10(%eax),%eax
80104d9e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104da2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104da5:	89 54 24 08          	mov    %edx,0x8(%esp)
80104da9:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dad:	c7 04 24 40 8d 10 80 	movl   $0x80108d40,(%esp)
80104db4:	e8 e8 b5 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dbc:	8b 40 0c             	mov    0xc(%eax),%eax
80104dbf:	83 f8 02             	cmp    $0x2,%eax
80104dc2:	75 50                	jne    80104e14 <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dc7:	8b 40 1c             	mov    0x1c(%eax),%eax
80104dca:	8b 40 0c             	mov    0xc(%eax),%eax
80104dcd:	83 c0 08             	add    $0x8,%eax
80104dd0:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
80104dd7:	89 04 24             	mov    %eax,(%esp)
80104dda:	e8 71 01 00 00       	call   80104f50 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104ddf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104de6:	eb 1b                	jmp    80104e03 <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104deb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104def:	89 44 24 04          	mov    %eax,0x4(%esp)
80104df3:	c7 04 24 49 8d 10 80 	movl   $0x80108d49,(%esp)
80104dfa:	e8 a2 b5 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104dff:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104e03:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104e07:	7f 0b                	jg     80104e14 <procdump+0xd7>
80104e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e0c:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104e10:	85 c0                	test   %eax,%eax
80104e12:	75 d4                	jne    80104de8 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104e14:	c7 04 24 4d 8d 10 80 	movl   $0x80108d4d,(%esp)
80104e1b:	e8 81 b5 ff ff       	call   801003a1 <cprintf>
80104e20:	eb 01                	jmp    80104e23 <procdump+0xe6>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104e22:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e23:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104e27:	81 7d f0 54 59 11 80 	cmpl   $0x80115954,-0x10(%ebp)
80104e2e:	0f 82 1b ff ff ff    	jb     80104d4f <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104e34:	c9                   	leave  
80104e35:	c3                   	ret    
	...

80104e38 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104e38:	55                   	push   %ebp
80104e39:	89 e5                	mov    %esp,%ebp
80104e3b:	53                   	push   %ebx
80104e3c:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104e3f:	9c                   	pushf  
80104e40:	5b                   	pop    %ebx
80104e41:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104e44:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104e47:	83 c4 10             	add    $0x10,%esp
80104e4a:	5b                   	pop    %ebx
80104e4b:	5d                   	pop    %ebp
80104e4c:	c3                   	ret    

80104e4d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104e4d:	55                   	push   %ebp
80104e4e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104e50:	fa                   	cli    
}
80104e51:	5d                   	pop    %ebp
80104e52:	c3                   	ret    

80104e53 <sti>:

static inline void
sti(void)
{
80104e53:	55                   	push   %ebp
80104e54:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104e56:	fb                   	sti    
}
80104e57:	5d                   	pop    %ebp
80104e58:	c3                   	ret    

80104e59 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104e59:	55                   	push   %ebp
80104e5a:	89 e5                	mov    %esp,%ebp
80104e5c:	53                   	push   %ebx
80104e5d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104e60:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104e63:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104e66:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104e69:	89 c3                	mov    %eax,%ebx
80104e6b:	89 d8                	mov    %ebx,%eax
80104e6d:	f0 87 02             	lock xchg %eax,(%edx)
80104e70:	89 c3                	mov    %eax,%ebx
80104e72:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104e75:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104e78:	83 c4 10             	add    $0x10,%esp
80104e7b:	5b                   	pop    %ebx
80104e7c:	5d                   	pop    %ebp
80104e7d:	c3                   	ret    

80104e7e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104e7e:	55                   	push   %ebp
80104e7f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104e81:	8b 45 08             	mov    0x8(%ebp),%eax
80104e84:	8b 55 0c             	mov    0xc(%ebp),%edx
80104e87:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104e8d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104e93:	8b 45 08             	mov    0x8(%ebp),%eax
80104e96:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104e9d:	5d                   	pop    %ebp
80104e9e:	c3                   	ret    

80104e9f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104e9f:	55                   	push   %ebp
80104ea0:	89 e5                	mov    %esp,%ebp
80104ea2:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104ea5:	e8 3d 01 00 00       	call   80104fe7 <pushcli>
  if(holding(lk))
80104eaa:	8b 45 08             	mov    0x8(%ebp),%eax
80104ead:	89 04 24             	mov    %eax,(%esp)
80104eb0:	e8 08 01 00 00       	call   80104fbd <holding>
80104eb5:	85 c0                	test   %eax,%eax
80104eb7:	74 0c                	je     80104ec5 <acquire+0x26>
    panic("acquire");
80104eb9:	c7 04 24 79 8d 10 80 	movl   $0x80108d79,(%esp)
80104ec0:	e8 78 b6 ff ff       	call   8010053d <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104ec5:	90                   	nop
80104ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ec9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104ed0:	00 
80104ed1:	89 04 24             	mov    %eax,(%esp)
80104ed4:	e8 80 ff ff ff       	call   80104e59 <xchg>
80104ed9:	85 c0                	test   %eax,%eax
80104edb:	75 e9                	jne    80104ec6 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104edd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ee0:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ee7:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104eea:	8b 45 08             	mov    0x8(%ebp),%eax
80104eed:	83 c0 0c             	add    $0xc,%eax
80104ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ef4:	8d 45 08             	lea    0x8(%ebp),%eax
80104ef7:	89 04 24             	mov    %eax,(%esp)
80104efa:	e8 51 00 00 00       	call   80104f50 <getcallerpcs>
}
80104eff:	c9                   	leave  
80104f00:	c3                   	ret    

80104f01 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104f01:	55                   	push   %ebp
80104f02:	89 e5                	mov    %esp,%ebp
80104f04:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104f07:	8b 45 08             	mov    0x8(%ebp),%eax
80104f0a:	89 04 24             	mov    %eax,(%esp)
80104f0d:	e8 ab 00 00 00       	call   80104fbd <holding>
80104f12:	85 c0                	test   %eax,%eax
80104f14:	75 0c                	jne    80104f22 <release+0x21>
    panic("release");
80104f16:	c7 04 24 81 8d 10 80 	movl   $0x80108d81,(%esp)
80104f1d:	e8 1b b6 ff ff       	call   8010053d <panic>

  lk->pcs[0] = 0;
80104f22:	8b 45 08             	mov    0x8(%ebp),%eax
80104f25:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104f36:	8b 45 08             	mov    0x8(%ebp),%eax
80104f39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104f40:	00 
80104f41:	89 04 24             	mov    %eax,(%esp)
80104f44:	e8 10 ff ff ff       	call   80104e59 <xchg>

  popcli();
80104f49:	e8 e1 00 00 00       	call   8010502f <popcli>
}
80104f4e:	c9                   	leave  
80104f4f:	c3                   	ret    

80104f50 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104f50:	55                   	push   %ebp
80104f51:	89 e5                	mov    %esp,%ebp
80104f53:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104f56:	8b 45 08             	mov    0x8(%ebp),%eax
80104f59:	83 e8 08             	sub    $0x8,%eax
80104f5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104f5f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104f66:	eb 32                	jmp    80104f9a <getcallerpcs+0x4a>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104f68:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104f6c:	74 47                	je     80104fb5 <getcallerpcs+0x65>
80104f6e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104f75:	76 3e                	jbe    80104fb5 <getcallerpcs+0x65>
80104f77:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104f7b:	74 38                	je     80104fb5 <getcallerpcs+0x65>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104f7d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104f80:	c1 e0 02             	shl    $0x2,%eax
80104f83:	03 45 0c             	add    0xc(%ebp),%eax
80104f86:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104f89:	8b 52 04             	mov    0x4(%edx),%edx
80104f8c:	89 10                	mov    %edx,(%eax)
    ebp = (uint*)ebp[0]; // saved %ebp
80104f8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f91:	8b 00                	mov    (%eax),%eax
80104f93:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104f96:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104f9a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104f9e:	7e c8                	jle    80104f68 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104fa0:	eb 13                	jmp    80104fb5 <getcallerpcs+0x65>
    pcs[i] = 0;
80104fa2:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104fa5:	c1 e0 02             	shl    $0x2,%eax
80104fa8:	03 45 0c             	add    0xc(%ebp),%eax
80104fab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104fb1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104fb5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104fb9:	7e e7                	jle    80104fa2 <getcallerpcs+0x52>
    pcs[i] = 0;
}
80104fbb:	c9                   	leave  
80104fbc:	c3                   	ret    

80104fbd <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104fbd:	55                   	push   %ebp
80104fbe:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104fc0:	8b 45 08             	mov    0x8(%ebp),%eax
80104fc3:	8b 00                	mov    (%eax),%eax
80104fc5:	85 c0                	test   %eax,%eax
80104fc7:	74 17                	je     80104fe0 <holding+0x23>
80104fc9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fcc:	8b 50 08             	mov    0x8(%eax),%edx
80104fcf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104fd5:	39 c2                	cmp    %eax,%edx
80104fd7:	75 07                	jne    80104fe0 <holding+0x23>
80104fd9:	b8 01 00 00 00       	mov    $0x1,%eax
80104fde:	eb 05                	jmp    80104fe5 <holding+0x28>
80104fe0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fe5:	5d                   	pop    %ebp
80104fe6:	c3                   	ret    

80104fe7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104fe7:	55                   	push   %ebp
80104fe8:	89 e5                	mov    %esp,%ebp
80104fea:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104fed:	e8 46 fe ff ff       	call   80104e38 <readeflags>
80104ff2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104ff5:	e8 53 fe ff ff       	call   80104e4d <cli>
  if(cpu->ncli++ == 0)
80104ffa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105000:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
80105006:	85 d2                	test   %edx,%edx
80105008:	0f 94 c1             	sete   %cl
8010500b:	83 c2 01             	add    $0x1,%edx
8010500e:	89 90 c4 00 00 00    	mov    %edx,0xc4(%eax)
80105014:	84 c9                	test   %cl,%cl
80105016:	74 15                	je     8010502d <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105018:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010501e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105021:	81 e2 00 02 00 00    	and    $0x200,%edx
80105027:	89 90 c8 00 00 00    	mov    %edx,0xc8(%eax)
}
8010502d:	c9                   	leave  
8010502e:	c3                   	ret    

8010502f <popcli>:

void
popcli(void)
{
8010502f:	55                   	push   %ebp
80105030:	89 e5                	mov    %esp,%ebp
80105032:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105035:	e8 fe fd ff ff       	call   80104e38 <readeflags>
8010503a:	25 00 02 00 00       	and    $0x200,%eax
8010503f:	85 c0                	test   %eax,%eax
80105041:	74 0c                	je     8010504f <popcli+0x20>
    panic("popcli - interruptible");
80105043:	c7 04 24 89 8d 10 80 	movl   $0x80108d89,(%esp)
8010504a:	e8 ee b4 ff ff       	call   8010053d <panic>
  if(--cpu->ncli < 0)
8010504f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105055:	8b 90 c4 00 00 00    	mov    0xc4(%eax),%edx
8010505b:	83 ea 01             	sub    $0x1,%edx
8010505e:	89 90 c4 00 00 00    	mov    %edx,0xc4(%eax)
80105064:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
8010506a:	85 c0                	test   %eax,%eax
8010506c:	79 0c                	jns    8010507a <popcli+0x4b>
    panic("popcli");
8010506e:	c7 04 24 a0 8d 10 80 	movl   $0x80108da0,(%esp)
80105075:	e8 c3 b4 ff ff       	call   8010053d <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010507a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105080:	8b 80 c4 00 00 00    	mov    0xc4(%eax),%eax
80105086:	85 c0                	test   %eax,%eax
80105088:	75 15                	jne    8010509f <popcli+0x70>
8010508a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105090:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
80105096:	85 c0                	test   %eax,%eax
80105098:	74 05                	je     8010509f <popcli+0x70>
    sti();
8010509a:	e8 b4 fd ff ff       	call   80104e53 <sti>
}
8010509f:	c9                   	leave  
801050a0:	c3                   	ret    
801050a1:	00 00                	add    %al,(%eax)
	...

801050a4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801050a4:	55                   	push   %ebp
801050a5:	89 e5                	mov    %esp,%ebp
801050a7:	57                   	push   %edi
801050a8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801050a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050ac:	8b 55 10             	mov    0x10(%ebp),%edx
801050af:	8b 45 0c             	mov    0xc(%ebp),%eax
801050b2:	89 cb                	mov    %ecx,%ebx
801050b4:	89 df                	mov    %ebx,%edi
801050b6:	89 d1                	mov    %edx,%ecx
801050b8:	fc                   	cld    
801050b9:	f3 aa                	rep stos %al,%es:(%edi)
801050bb:	89 ca                	mov    %ecx,%edx
801050bd:	89 fb                	mov    %edi,%ebx
801050bf:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050c2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801050c5:	5b                   	pop    %ebx
801050c6:	5f                   	pop    %edi
801050c7:	5d                   	pop    %ebp
801050c8:	c3                   	ret    

801050c9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801050c9:	55                   	push   %ebp
801050ca:	89 e5                	mov    %esp,%ebp
801050cc:	57                   	push   %edi
801050cd:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801050ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
801050d1:	8b 55 10             	mov    0x10(%ebp),%edx
801050d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d7:	89 cb                	mov    %ecx,%ebx
801050d9:	89 df                	mov    %ebx,%edi
801050db:	89 d1                	mov    %edx,%ecx
801050dd:	fc                   	cld    
801050de:	f3 ab                	rep stos %eax,%es:(%edi)
801050e0:	89 ca                	mov    %ecx,%edx
801050e2:	89 fb                	mov    %edi,%ebx
801050e4:	89 5d 08             	mov    %ebx,0x8(%ebp)
801050e7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801050ea:	5b                   	pop    %ebx
801050eb:	5f                   	pop    %edi
801050ec:	5d                   	pop    %ebp
801050ed:	c3                   	ret    

801050ee <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801050ee:	55                   	push   %ebp
801050ef:	89 e5                	mov    %esp,%ebp
801050f1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801050f4:	8b 45 08             	mov    0x8(%ebp),%eax
801050f7:	83 e0 03             	and    $0x3,%eax
801050fa:	85 c0                	test   %eax,%eax
801050fc:	75 49                	jne    80105147 <memset+0x59>
801050fe:	8b 45 10             	mov    0x10(%ebp),%eax
80105101:	83 e0 03             	and    $0x3,%eax
80105104:	85 c0                	test   %eax,%eax
80105106:	75 3f                	jne    80105147 <memset+0x59>
    c &= 0xFF;
80105108:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010510f:	8b 45 10             	mov    0x10(%ebp),%eax
80105112:	c1 e8 02             	shr    $0x2,%eax
80105115:	89 c2                	mov    %eax,%edx
80105117:	8b 45 0c             	mov    0xc(%ebp),%eax
8010511a:	89 c1                	mov    %eax,%ecx
8010511c:	c1 e1 18             	shl    $0x18,%ecx
8010511f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105122:	c1 e0 10             	shl    $0x10,%eax
80105125:	09 c1                	or     %eax,%ecx
80105127:	8b 45 0c             	mov    0xc(%ebp),%eax
8010512a:	c1 e0 08             	shl    $0x8,%eax
8010512d:	09 c8                	or     %ecx,%eax
8010512f:	0b 45 0c             	or     0xc(%ebp),%eax
80105132:	89 54 24 08          	mov    %edx,0x8(%esp)
80105136:	89 44 24 04          	mov    %eax,0x4(%esp)
8010513a:	8b 45 08             	mov    0x8(%ebp),%eax
8010513d:	89 04 24             	mov    %eax,(%esp)
80105140:	e8 84 ff ff ff       	call   801050c9 <stosl>
80105145:	eb 19                	jmp    80105160 <memset+0x72>
  } else
    stosb(dst, c, n);
80105147:	8b 45 10             	mov    0x10(%ebp),%eax
8010514a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010514e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105151:	89 44 24 04          	mov    %eax,0x4(%esp)
80105155:	8b 45 08             	mov    0x8(%ebp),%eax
80105158:	89 04 24             	mov    %eax,(%esp)
8010515b:	e8 44 ff ff ff       	call   801050a4 <stosb>
  return dst;
80105160:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105163:	c9                   	leave  
80105164:	c3                   	ret    

80105165 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105165:	55                   	push   %ebp
80105166:	89 e5                	mov    %esp,%ebp
80105168:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010516b:	8b 45 08             	mov    0x8(%ebp),%eax
8010516e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105171:	8b 45 0c             	mov    0xc(%ebp),%eax
80105174:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105177:	eb 32                	jmp    801051ab <memcmp+0x46>
    if(*s1 != *s2)
80105179:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010517c:	0f b6 10             	movzbl (%eax),%edx
8010517f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105182:	0f b6 00             	movzbl (%eax),%eax
80105185:	38 c2                	cmp    %al,%dl
80105187:	74 1a                	je     801051a3 <memcmp+0x3e>
      return *s1 - *s2;
80105189:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010518c:	0f b6 00             	movzbl (%eax),%eax
8010518f:	0f b6 d0             	movzbl %al,%edx
80105192:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105195:	0f b6 00             	movzbl (%eax),%eax
80105198:	0f b6 c0             	movzbl %al,%eax
8010519b:	89 d1                	mov    %edx,%ecx
8010519d:	29 c1                	sub    %eax,%ecx
8010519f:	89 c8                	mov    %ecx,%eax
801051a1:	eb 1c                	jmp    801051bf <memcmp+0x5a>
    s1++, s2++;
801051a3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801051a7:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801051ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801051af:	0f 95 c0             	setne  %al
801051b2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801051b6:	84 c0                	test   %al,%al
801051b8:	75 bf                	jne    80105179 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801051ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051bf:	c9                   	leave  
801051c0:	c3                   	ret    

801051c1 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801051c1:	55                   	push   %ebp
801051c2:	89 e5                	mov    %esp,%ebp
801051c4:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801051c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ca:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801051cd:	8b 45 08             	mov    0x8(%ebp),%eax
801051d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801051d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051d6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051d9:	73 54                	jae    8010522f <memmove+0x6e>
801051db:	8b 45 10             	mov    0x10(%ebp),%eax
801051de:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051e1:	01 d0                	add    %edx,%eax
801051e3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801051e6:	76 47                	jbe    8010522f <memmove+0x6e>
    s += n;
801051e8:	8b 45 10             	mov    0x10(%ebp),%eax
801051eb:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801051ee:	8b 45 10             	mov    0x10(%ebp),%eax
801051f1:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801051f4:	eb 13                	jmp    80105209 <memmove+0x48>
      *--d = *--s;
801051f6:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801051fa:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801051fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105201:	0f b6 10             	movzbl (%eax),%edx
80105204:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105207:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105209:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010520d:	0f 95 c0             	setne  %al
80105210:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105214:	84 c0                	test   %al,%al
80105216:	75 de                	jne    801051f6 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105218:	eb 25                	jmp    8010523f <memmove+0x7e>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010521a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010521d:	0f b6 10             	movzbl (%eax),%edx
80105220:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105223:	88 10                	mov    %dl,(%eax)
80105225:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105229:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010522d:	eb 01                	jmp    80105230 <memmove+0x6f>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010522f:	90                   	nop
80105230:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105234:	0f 95 c0             	setne  %al
80105237:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010523b:	84 c0                	test   %al,%al
8010523d:	75 db                	jne    8010521a <memmove+0x59>
      *d++ = *s++;

  return dst;
8010523f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105242:	c9                   	leave  
80105243:	c3                   	ret    

80105244 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105244:	55                   	push   %ebp
80105245:	89 e5                	mov    %esp,%ebp
80105247:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010524a:	8b 45 10             	mov    0x10(%ebp),%eax
8010524d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105251:	8b 45 0c             	mov    0xc(%ebp),%eax
80105254:	89 44 24 04          	mov    %eax,0x4(%esp)
80105258:	8b 45 08             	mov    0x8(%ebp),%eax
8010525b:	89 04 24             	mov    %eax,(%esp)
8010525e:	e8 5e ff ff ff       	call   801051c1 <memmove>
}
80105263:	c9                   	leave  
80105264:	c3                   	ret    

80105265 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105265:	55                   	push   %ebp
80105266:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105268:	eb 0c                	jmp    80105276 <strncmp+0x11>
    n--, p++, q++;
8010526a:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010526e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105272:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105276:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010527a:	74 1a                	je     80105296 <strncmp+0x31>
8010527c:	8b 45 08             	mov    0x8(%ebp),%eax
8010527f:	0f b6 00             	movzbl (%eax),%eax
80105282:	84 c0                	test   %al,%al
80105284:	74 10                	je     80105296 <strncmp+0x31>
80105286:	8b 45 08             	mov    0x8(%ebp),%eax
80105289:	0f b6 10             	movzbl (%eax),%edx
8010528c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010528f:	0f b6 00             	movzbl (%eax),%eax
80105292:	38 c2                	cmp    %al,%dl
80105294:	74 d4                	je     8010526a <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105296:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010529a:	75 07                	jne    801052a3 <strncmp+0x3e>
    return 0;
8010529c:	b8 00 00 00 00       	mov    $0x0,%eax
801052a1:	eb 18                	jmp    801052bb <strncmp+0x56>
  return (uchar)*p - (uchar)*q;
801052a3:	8b 45 08             	mov    0x8(%ebp),%eax
801052a6:	0f b6 00             	movzbl (%eax),%eax
801052a9:	0f b6 d0             	movzbl %al,%edx
801052ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801052af:	0f b6 00             	movzbl (%eax),%eax
801052b2:	0f b6 c0             	movzbl %al,%eax
801052b5:	89 d1                	mov    %edx,%ecx
801052b7:	29 c1                	sub    %eax,%ecx
801052b9:	89 c8                	mov    %ecx,%eax
}
801052bb:	5d                   	pop    %ebp
801052bc:	c3                   	ret    

801052bd <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801052bd:	55                   	push   %ebp
801052be:	89 e5                	mov    %esp,%ebp
801052c0:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801052c3:	8b 45 08             	mov    0x8(%ebp),%eax
801052c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801052c9:	90                   	nop
801052ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052ce:	0f 9f c0             	setg   %al
801052d1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801052d5:	84 c0                	test   %al,%al
801052d7:	74 30                	je     80105309 <strncpy+0x4c>
801052d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801052dc:	0f b6 10             	movzbl (%eax),%edx
801052df:	8b 45 08             	mov    0x8(%ebp),%eax
801052e2:	88 10                	mov    %dl,(%eax)
801052e4:	8b 45 08             	mov    0x8(%ebp),%eax
801052e7:	0f b6 00             	movzbl (%eax),%eax
801052ea:	84 c0                	test   %al,%al
801052ec:	0f 95 c0             	setne  %al
801052ef:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801052f3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
801052f7:	84 c0                	test   %al,%al
801052f9:	75 cf                	jne    801052ca <strncpy+0xd>
    ;
  while(n-- > 0)
801052fb:	eb 0c                	jmp    80105309 <strncpy+0x4c>
    *s++ = 0;
801052fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105300:	c6 00 00             	movb   $0x0,(%eax)
80105303:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105307:	eb 01                	jmp    8010530a <strncpy+0x4d>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105309:	90                   	nop
8010530a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010530e:	0f 9f c0             	setg   %al
80105311:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105315:	84 c0                	test   %al,%al
80105317:	75 e4                	jne    801052fd <strncpy+0x40>
    *s++ = 0;
  return os;
80105319:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010531c:	c9                   	leave  
8010531d:	c3                   	ret    

8010531e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010531e:	55                   	push   %ebp
8010531f:	89 e5                	mov    %esp,%ebp
80105321:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105324:	8b 45 08             	mov    0x8(%ebp),%eax
80105327:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010532a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010532e:	7f 05                	jg     80105335 <safestrcpy+0x17>
    return os;
80105330:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105333:	eb 35                	jmp    8010536a <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
80105335:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105339:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010533d:	7e 22                	jle    80105361 <safestrcpy+0x43>
8010533f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105342:	0f b6 10             	movzbl (%eax),%edx
80105345:	8b 45 08             	mov    0x8(%ebp),%eax
80105348:	88 10                	mov    %dl,(%eax)
8010534a:	8b 45 08             	mov    0x8(%ebp),%eax
8010534d:	0f b6 00             	movzbl (%eax),%eax
80105350:	84 c0                	test   %al,%al
80105352:	0f 95 c0             	setne  %al
80105355:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105359:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
8010535d:	84 c0                	test   %al,%al
8010535f:	75 d4                	jne    80105335 <safestrcpy+0x17>
    ;
  *s = 0;
80105361:	8b 45 08             	mov    0x8(%ebp),%eax
80105364:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105367:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010536a:	c9                   	leave  
8010536b:	c3                   	ret    

8010536c <strlen>:

int
strlen(const char *s)
{
8010536c:	55                   	push   %ebp
8010536d:	89 e5                	mov    %esp,%ebp
8010536f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105372:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105379:	eb 04                	jmp    8010537f <strlen+0x13>
8010537b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010537f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105382:	03 45 08             	add    0x8(%ebp),%eax
80105385:	0f b6 00             	movzbl (%eax),%eax
80105388:	84 c0                	test   %al,%al
8010538a:	75 ef                	jne    8010537b <strlen+0xf>
    ;
  return n;
8010538c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010538f:	c9                   	leave  
80105390:	c3                   	ret    
80105391:	00 00                	add    %al,(%eax)
	...

80105394 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105394:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105398:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010539c:	55                   	push   %ebp
  pushl %ebx
8010539d:	53                   	push   %ebx
  pushl %esi
8010539e:	56                   	push   %esi
  pushl %edi
8010539f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801053a0:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801053a2:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
801053a4:	5f                   	pop    %edi
  popl %esi
801053a5:	5e                   	pop    %esi
  popl %ebx
801053a6:	5b                   	pop    %ebx
  popl %ebp
801053a7:	5d                   	pop    %ebp
  ret
801053a8:	c3                   	ret    
801053a9:	00 00                	add    %al,(%eax)
	...

801053ac <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801053ac:	55                   	push   %ebp
801053ad:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801053af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053b5:	8b 00                	mov    (%eax),%eax
801053b7:	3b 45 08             	cmp    0x8(%ebp),%eax
801053ba:	76 12                	jbe    801053ce <fetchint+0x22>
801053bc:	8b 45 08             	mov    0x8(%ebp),%eax
801053bf:	8d 50 04             	lea    0x4(%eax),%edx
801053c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053c8:	8b 00                	mov    (%eax),%eax
801053ca:	39 c2                	cmp    %eax,%edx
801053cc:	76 07                	jbe    801053d5 <fetchint+0x29>
    return -1;
801053ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d3:	eb 0f                	jmp    801053e4 <fetchint+0x38>
  *ip = *(int*)(addr);
801053d5:	8b 45 08             	mov    0x8(%ebp),%eax
801053d8:	8b 10                	mov    (%eax),%edx
801053da:	8b 45 0c             	mov    0xc(%ebp),%eax
801053dd:	89 10                	mov    %edx,(%eax)
  return 0;
801053df:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053e4:	5d                   	pop    %ebp
801053e5:	c3                   	ret    

801053e6 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801053e6:	55                   	push   %ebp
801053e7:	89 e5                	mov    %esp,%ebp
801053e9:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801053ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053f2:	8b 00                	mov    (%eax),%eax
801053f4:	3b 45 08             	cmp    0x8(%ebp),%eax
801053f7:	77 07                	ja     80105400 <fetchstr+0x1a>
    return -1;
801053f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053fe:	eb 48                	jmp    80105448 <fetchstr+0x62>
  *pp = (char*)addr;
80105400:	8b 55 08             	mov    0x8(%ebp),%edx
80105403:	8b 45 0c             	mov    0xc(%ebp),%eax
80105406:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105408:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010540e:	8b 00                	mov    (%eax),%eax
80105410:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105413:	8b 45 0c             	mov    0xc(%ebp),%eax
80105416:	8b 00                	mov    (%eax),%eax
80105418:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010541b:	eb 1e                	jmp    8010543b <fetchstr+0x55>
    if(*s == 0)
8010541d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105420:	0f b6 00             	movzbl (%eax),%eax
80105423:	84 c0                	test   %al,%al
80105425:	75 10                	jne    80105437 <fetchstr+0x51>
      return s - *pp;
80105427:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010542a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010542d:	8b 00                	mov    (%eax),%eax
8010542f:	89 d1                	mov    %edx,%ecx
80105431:	29 c1                	sub    %eax,%ecx
80105433:	89 c8                	mov    %ecx,%eax
80105435:	eb 11                	jmp    80105448 <fetchstr+0x62>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105437:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010543b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010543e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105441:	72 da                	jb     8010541d <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105443:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105448:	c9                   	leave  
80105449:	c3                   	ret    

8010544a <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010544a:	55                   	push   %ebp
8010544b:	89 e5                	mov    %esp,%ebp
8010544d:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105450:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105456:	8b 40 18             	mov    0x18(%eax),%eax
80105459:	8b 50 44             	mov    0x44(%eax),%edx
8010545c:	8b 45 08             	mov    0x8(%ebp),%eax
8010545f:	c1 e0 02             	shl    $0x2,%eax
80105462:	01 d0                	add    %edx,%eax
80105464:	8d 50 04             	lea    0x4(%eax),%edx
80105467:	8b 45 0c             	mov    0xc(%ebp),%eax
8010546a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010546e:	89 14 24             	mov    %edx,(%esp)
80105471:	e8 36 ff ff ff       	call   801053ac <fetchint>
}
80105476:	c9                   	leave  
80105477:	c3                   	ret    

80105478 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105478:	55                   	push   %ebp
80105479:	89 e5                	mov    %esp,%ebp
8010547b:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010547e:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105481:	89 44 24 04          	mov    %eax,0x4(%esp)
80105485:	8b 45 08             	mov    0x8(%ebp),%eax
80105488:	89 04 24             	mov    %eax,(%esp)
8010548b:	e8 ba ff ff ff       	call   8010544a <argint>
80105490:	85 c0                	test   %eax,%eax
80105492:	79 07                	jns    8010549b <argptr+0x23>
    return -1;
80105494:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105499:	eb 3d                	jmp    801054d8 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010549b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010549e:	89 c2                	mov    %eax,%edx
801054a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054a6:	8b 00                	mov    (%eax),%eax
801054a8:	39 c2                	cmp    %eax,%edx
801054aa:	73 16                	jae    801054c2 <argptr+0x4a>
801054ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054af:	89 c2                	mov    %eax,%edx
801054b1:	8b 45 10             	mov    0x10(%ebp),%eax
801054b4:	01 c2                	add    %eax,%edx
801054b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054bc:	8b 00                	mov    (%eax),%eax
801054be:	39 c2                	cmp    %eax,%edx
801054c0:	76 07                	jbe    801054c9 <argptr+0x51>
    return -1;
801054c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054c7:	eb 0f                	jmp    801054d8 <argptr+0x60>
  *pp = (char*)i;
801054c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054cc:	89 c2                	mov    %eax,%edx
801054ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d1:	89 10                	mov    %edx,(%eax)
  return 0;
801054d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054d8:	c9                   	leave  
801054d9:	c3                   	ret    

801054da <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801054da:	55                   	push   %ebp
801054db:	89 e5                	mov    %esp,%ebp
801054dd:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801054e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
801054e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801054e7:	8b 45 08             	mov    0x8(%ebp),%eax
801054ea:	89 04 24             	mov    %eax,(%esp)
801054ed:	e8 58 ff ff ff       	call   8010544a <argint>
801054f2:	85 c0                	test   %eax,%eax
801054f4:	79 07                	jns    801054fd <argstr+0x23>
    return -1;
801054f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054fb:	eb 12                	jmp    8010550f <argstr+0x35>
  return fetchstr(addr, pp);
801054fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105500:	8b 55 0c             	mov    0xc(%ebp),%edx
80105503:	89 54 24 04          	mov    %edx,0x4(%esp)
80105507:	89 04 24             	mov    %eax,(%esp)
8010550a:	e8 d7 fe ff ff       	call   801053e6 <fetchstr>
}
8010550f:	c9                   	leave  
80105510:	c3                   	ret    

80105511 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105511:	55                   	push   %ebp
80105512:	89 e5                	mov    %esp,%ebp
80105514:	53                   	push   %ebx
80105515:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
80105518:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010551e:	8b 40 18             	mov    0x18(%eax),%eax
80105521:	8b 40 1c             	mov    0x1c(%eax),%eax
80105524:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105527:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010552b:	7e 30                	jle    8010555d <syscall+0x4c>
8010552d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105530:	83 f8 15             	cmp    $0x15,%eax
80105533:	77 28                	ja     8010555d <syscall+0x4c>
80105535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105538:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
8010553f:	85 c0                	test   %eax,%eax
80105541:	74 1a                	je     8010555d <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105543:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105549:	8b 58 18             	mov    0x18(%eax),%ebx
8010554c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010554f:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105556:	ff d0                	call   *%eax
80105558:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010555b:	eb 3d                	jmp    8010559a <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010555d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105563:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105566:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010556c:	8b 40 10             	mov    0x10(%eax),%eax
8010556f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105572:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105576:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010557a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010557e:	c7 04 24 a7 8d 10 80 	movl   $0x80108da7,(%esp)
80105585:	e8 17 ae ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
8010558a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105590:	8b 40 18             	mov    0x18(%eax),%eax
80105593:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
8010559a:	83 c4 24             	add    $0x24,%esp
8010559d:	5b                   	pop    %ebx
8010559e:	5d                   	pop    %ebp
8010559f:	c3                   	ret    

801055a0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
801055a0:	55                   	push   %ebp
801055a1:	89 e5                	mov    %esp,%ebp
801055a3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
801055a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801055a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801055ad:	8b 45 08             	mov    0x8(%ebp),%eax
801055b0:	89 04 24             	mov    %eax,(%esp)
801055b3:	e8 92 fe ff ff       	call   8010544a <argint>
801055b8:	85 c0                	test   %eax,%eax
801055ba:	79 07                	jns    801055c3 <argfd+0x23>
    return -1;
801055bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c1:	eb 50                	jmp    80105613 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
801055c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055c6:	85 c0                	test   %eax,%eax
801055c8:	78 21                	js     801055eb <argfd+0x4b>
801055ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055cd:	83 f8 0f             	cmp    $0xf,%eax
801055d0:	7f 19                	jg     801055eb <argfd+0x4b>
801055d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055db:	83 c2 08             	add    $0x8,%edx
801055de:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801055e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801055e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801055e9:	75 07                	jne    801055f2 <argfd+0x52>
    return -1;
801055eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055f0:	eb 21                	jmp    80105613 <argfd+0x73>
  if(pfd)
801055f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801055f6:	74 08                	je     80105600 <argfd+0x60>
    *pfd = fd;
801055f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801055fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801055fe:	89 10                	mov    %edx,(%eax)
  if(pf)
80105600:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105604:	74 08                	je     8010560e <argfd+0x6e>
    *pf = f;
80105606:	8b 45 10             	mov    0x10(%ebp),%eax
80105609:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010560c:	89 10                	mov    %edx,(%eax)
  return 0;
8010560e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105613:	c9                   	leave  
80105614:	c3                   	ret    

80105615 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105615:	55                   	push   %ebp
80105616:	89 e5                	mov    %esp,%ebp
80105618:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010561b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105622:	eb 30                	jmp    80105654 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105624:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010562a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010562d:	83 c2 08             	add    $0x8,%edx
80105630:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105634:	85 c0                	test   %eax,%eax
80105636:	75 18                	jne    80105650 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105638:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010563e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105641:	8d 4a 08             	lea    0x8(%edx),%ecx
80105644:	8b 55 08             	mov    0x8(%ebp),%edx
80105647:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010564b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010564e:	eb 0f                	jmp    8010565f <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105650:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105654:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105658:	7e ca                	jle    80105624 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010565a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010565f:	c9                   	leave  
80105660:	c3                   	ret    

80105661 <sys_dup>:

int
sys_dup(void)
{
80105661:	55                   	push   %ebp
80105662:	89 e5                	mov    %esp,%ebp
80105664:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105667:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010566a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010566e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105675:	00 
80105676:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010567d:	e8 1e ff ff ff       	call   801055a0 <argfd>
80105682:	85 c0                	test   %eax,%eax
80105684:	79 07                	jns    8010568d <sys_dup+0x2c>
    return -1;
80105686:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010568b:	eb 29                	jmp    801056b6 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010568d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105690:	89 04 24             	mov    %eax,(%esp)
80105693:	e8 7d ff ff ff       	call   80105615 <fdalloc>
80105698:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010569b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010569f:	79 07                	jns    801056a8 <sys_dup+0x47>
    return -1;
801056a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056a6:	eb 0e                	jmp    801056b6 <sys_dup+0x55>
  filedup(f);
801056a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056ab:	89 04 24             	mov    %eax,(%esp)
801056ae:	e8 d5 b8 ff ff       	call   80100f88 <filedup>
  return fd;
801056b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801056b6:	c9                   	leave  
801056b7:	c3                   	ret    

801056b8 <sys_read>:

int
sys_read(void)
{
801056b8:	55                   	push   %ebp
801056b9:	89 e5                	mov    %esp,%ebp
801056bb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801056be:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056c1:	89 44 24 08          	mov    %eax,0x8(%esp)
801056c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801056cc:	00 
801056cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801056d4:	e8 c7 fe ff ff       	call   801055a0 <argfd>
801056d9:	85 c0                	test   %eax,%eax
801056db:	78 35                	js     80105712 <sys_read+0x5a>
801056dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801056e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801056e4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801056eb:	e8 5a fd ff ff       	call   8010544a <argint>
801056f0:	85 c0                	test   %eax,%eax
801056f2:	78 1e                	js     80105712 <sys_read+0x5a>
801056f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056f7:	89 44 24 08          	mov    %eax,0x8(%esp)
801056fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
801056fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105702:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105709:	e8 6a fd ff ff       	call   80105478 <argptr>
8010570e:	85 c0                	test   %eax,%eax
80105710:	79 07                	jns    80105719 <sys_read+0x61>
    return -1;
80105712:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105717:	eb 19                	jmp    80105732 <sys_read+0x7a>
  return fileread(f, p, n);
80105719:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010571c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010571f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105722:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105726:	89 54 24 04          	mov    %edx,0x4(%esp)
8010572a:	89 04 24             	mov    %eax,(%esp)
8010572d:	e8 c3 b9 ff ff       	call   801010f5 <fileread>
}
80105732:	c9                   	leave  
80105733:	c3                   	ret    

80105734 <sys_write>:

int
sys_write(void)
{
80105734:	55                   	push   %ebp
80105735:	89 e5                	mov    %esp,%ebp
80105737:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010573a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010573d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105741:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105748:	00 
80105749:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105750:	e8 4b fe ff ff       	call   801055a0 <argfd>
80105755:	85 c0                	test   %eax,%eax
80105757:	78 35                	js     8010578e <sys_write+0x5a>
80105759:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010575c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105760:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105767:	e8 de fc ff ff       	call   8010544a <argint>
8010576c:	85 c0                	test   %eax,%eax
8010576e:	78 1e                	js     8010578e <sys_write+0x5a>
80105770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105773:	89 44 24 08          	mov    %eax,0x8(%esp)
80105777:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010577a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010577e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105785:	e8 ee fc ff ff       	call   80105478 <argptr>
8010578a:	85 c0                	test   %eax,%eax
8010578c:	79 07                	jns    80105795 <sys_write+0x61>
    return -1;
8010578e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105793:	eb 19                	jmp    801057ae <sys_write+0x7a>
  return filewrite(f, p, n);
80105795:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105798:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010579b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801057a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801057a6:	89 04 24             	mov    %eax,(%esp)
801057a9:	e8 03 ba ff ff       	call   801011b1 <filewrite>
}
801057ae:	c9                   	leave  
801057af:	c3                   	ret    

801057b0 <sys_close>:

int
sys_close(void)
{
801057b0:	55                   	push   %ebp
801057b1:	89 e5                	mov    %esp,%ebp
801057b3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801057b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801057bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801057c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057cb:	e8 d0 fd ff ff       	call   801055a0 <argfd>
801057d0:	85 c0                	test   %eax,%eax
801057d2:	79 07                	jns    801057db <sys_close+0x2b>
    return -1;
801057d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d9:	eb 24                	jmp    801057ff <sys_close+0x4f>
  proc->ofile[fd] = 0;
801057db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057e4:	83 c2 08             	add    $0x8,%edx
801057e7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801057ee:	00 
  fileclose(f);
801057ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f2:	89 04 24             	mov    %eax,(%esp)
801057f5:	e8 d6 b7 ff ff       	call   80100fd0 <fileclose>
  return 0;
801057fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057ff:	c9                   	leave  
80105800:	c3                   	ret    

80105801 <sys_fstat>:

int
sys_fstat(void)
{
80105801:	55                   	push   %ebp
80105802:	89 e5                	mov    %esp,%ebp
80105804:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105807:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010580a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010580e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105815:	00 
80105816:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010581d:	e8 7e fd ff ff       	call   801055a0 <argfd>
80105822:	85 c0                	test   %eax,%eax
80105824:	78 1f                	js     80105845 <sys_fstat+0x44>
80105826:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010582d:	00 
8010582e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105831:	89 44 24 04          	mov    %eax,0x4(%esp)
80105835:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010583c:	e8 37 fc ff ff       	call   80105478 <argptr>
80105841:	85 c0                	test   %eax,%eax
80105843:	79 07                	jns    8010584c <sys_fstat+0x4b>
    return -1;
80105845:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010584a:	eb 12                	jmp    8010585e <sys_fstat+0x5d>
  return filestat(f, st);
8010584c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010584f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105852:	89 54 24 04          	mov    %edx,0x4(%esp)
80105856:	89 04 24             	mov    %eax,(%esp)
80105859:	e8 48 b8 ff ff       	call   801010a6 <filestat>
}
8010585e:	c9                   	leave  
8010585f:	c3                   	ret    

80105860 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105860:	55                   	push   %ebp
80105861:	89 e5                	mov    %esp,%ebp
80105863:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105866:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105869:	89 44 24 04          	mov    %eax,0x4(%esp)
8010586d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105874:	e8 61 fc ff ff       	call   801054da <argstr>
80105879:	85 c0                	test   %eax,%eax
8010587b:	78 17                	js     80105894 <sys_link+0x34>
8010587d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105880:	89 44 24 04          	mov    %eax,0x4(%esp)
80105884:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010588b:	e8 4a fc ff ff       	call   801054da <argstr>
80105890:	85 c0                	test   %eax,%eax
80105892:	79 0a                	jns    8010589e <sys_link+0x3e>
    return -1;
80105894:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105899:	e9 41 01 00 00       	jmp    801059df <sys_link+0x17f>

  begin_op();
8010589e:	e8 be db ff ff       	call   80103461 <begin_op>
  if((ip = namei(old)) == 0){
801058a3:	8b 45 d8             	mov    -0x28(%ebp),%eax
801058a6:	89 04 24             	mov    %eax,(%esp)
801058a9:	e8 68 cb ff ff       	call   80102416 <namei>
801058ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058b5:	75 0f                	jne    801058c6 <sys_link+0x66>
    end_op();
801058b7:	e8 26 dc ff ff       	call   801034e2 <end_op>
    return -1;
801058bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c1:	e9 19 01 00 00       	jmp    801059df <sys_link+0x17f>
  }

  ilock(ip);
801058c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c9:	89 04 24             	mov    %eax,(%esp)
801058cc:	e8 a3 bf ff ff       	call   80101874 <ilock>
  if(ip->type == T_DIR){
801058d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058d4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801058d8:	66 83 f8 01          	cmp    $0x1,%ax
801058dc:	75 1a                	jne    801058f8 <sys_link+0x98>
    iunlockput(ip);
801058de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e1:	89 04 24             	mov    %eax,(%esp)
801058e4:	e8 0f c2 ff ff       	call   80101af8 <iunlockput>
    end_op();
801058e9:	e8 f4 db ff ff       	call   801034e2 <end_op>
    return -1;
801058ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058f3:	e9 e7 00 00 00       	jmp    801059df <sys_link+0x17f>
  }

  ip->nlink++;
801058f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058fb:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801058ff:	8d 50 01             	lea    0x1(%eax),%edx
80105902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105905:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010590c:	89 04 24             	mov    %eax,(%esp)
8010590f:	e8 a4 bd ff ff       	call   801016b8 <iupdate>
  iunlock(ip);
80105914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105917:	89 04 24             	mov    %eax,(%esp)
8010591a:	e8 a3 c0 ff ff       	call   801019c2 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010591f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105922:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105925:	89 54 24 04          	mov    %edx,0x4(%esp)
80105929:	89 04 24             	mov    %eax,(%esp)
8010592c:	e8 07 cb ff ff       	call   80102438 <nameiparent>
80105931:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105934:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105938:	74 68                	je     801059a2 <sys_link+0x142>
    goto bad;
  ilock(dp);
8010593a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593d:	89 04 24             	mov    %eax,(%esp)
80105940:	e8 2f bf ff ff       	call   80101874 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105945:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105948:	8b 10                	mov    (%eax),%edx
8010594a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594d:	8b 00                	mov    (%eax),%eax
8010594f:	39 c2                	cmp    %eax,%edx
80105951:	75 20                	jne    80105973 <sys_link+0x113>
80105953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105956:	8b 40 04             	mov    0x4(%eax),%eax
80105959:	89 44 24 08          	mov    %eax,0x8(%esp)
8010595d:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105960:	89 44 24 04          	mov    %eax,0x4(%esp)
80105964:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105967:	89 04 24             	mov    %eax,(%esp)
8010596a:	e8 e6 c7 ff ff       	call   80102155 <dirlink>
8010596f:	85 c0                	test   %eax,%eax
80105971:	79 0d                	jns    80105980 <sys_link+0x120>
    iunlockput(dp);
80105973:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105976:	89 04 24             	mov    %eax,(%esp)
80105979:	e8 7a c1 ff ff       	call   80101af8 <iunlockput>
    goto bad;
8010597e:	eb 23                	jmp    801059a3 <sys_link+0x143>
  }
  iunlockput(dp);
80105980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105983:	89 04 24             	mov    %eax,(%esp)
80105986:	e8 6d c1 ff ff       	call   80101af8 <iunlockput>
  iput(ip);
8010598b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598e:	89 04 24             	mov    %eax,(%esp)
80105991:	e8 91 c0 ff ff       	call   80101a27 <iput>

  end_op();
80105996:	e8 47 db ff ff       	call   801034e2 <end_op>

  return 0;
8010599b:	b8 00 00 00 00       	mov    $0x0,%eax
801059a0:	eb 3d                	jmp    801059df <sys_link+0x17f>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
801059a2:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
801059a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a6:	89 04 24             	mov    %eax,(%esp)
801059a9:	e8 c6 be ff ff       	call   80101874 <ilock>
  ip->nlink--;
801059ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801059b5:	8d 50 ff             	lea    -0x1(%eax),%edx
801059b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059bb:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801059bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c2:	89 04 24             	mov    %eax,(%esp)
801059c5:	e8 ee bc ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
801059ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cd:	89 04 24             	mov    %eax,(%esp)
801059d0:	e8 23 c1 ff ff       	call   80101af8 <iunlockput>
  end_op();
801059d5:	e8 08 db ff ff       	call   801034e2 <end_op>
  return -1;
801059da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059df:	c9                   	leave  
801059e0:	c3                   	ret    

801059e1 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801059e1:	55                   	push   %ebp
801059e2:	89 e5                	mov    %esp,%ebp
801059e4:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801059e7:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801059ee:	eb 4b                	jmp    80105a3b <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801059f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f3:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801059fa:	00 
801059fb:	89 44 24 08          	mov    %eax,0x8(%esp)
801059ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105a02:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a06:	8b 45 08             	mov    0x8(%ebp),%eax
80105a09:	89 04 24             	mov    %eax,(%esp)
80105a0c:	e8 59 c3 ff ff       	call   80101d6a <readi>
80105a11:	83 f8 10             	cmp    $0x10,%eax
80105a14:	74 0c                	je     80105a22 <isdirempty+0x41>
      panic("isdirempty: readi");
80105a16:	c7 04 24 c3 8d 10 80 	movl   $0x80108dc3,(%esp)
80105a1d:	e8 1b ab ff ff       	call   8010053d <panic>
    if(de.inum != 0)
80105a22:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105a26:	66 85 c0             	test   %ax,%ax
80105a29:	74 07                	je     80105a32 <isdirempty+0x51>
      return 0;
80105a2b:	b8 00 00 00 00       	mov    $0x0,%eax
80105a30:	eb 1b                	jmp    80105a4d <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a35:	83 c0 10             	add    $0x10,%eax
80105a38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a3b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105a41:	8b 40 18             	mov    0x18(%eax),%eax
80105a44:	39 c2                	cmp    %eax,%edx
80105a46:	72 a8                	jb     801059f0 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105a48:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105a4d:	c9                   	leave  
80105a4e:	c3                   	ret    

80105a4f <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105a4f:	55                   	push   %ebp
80105a50:	89 e5                	mov    %esp,%ebp
80105a52:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105a55:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105a58:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a63:	e8 72 fa ff ff       	call   801054da <argstr>
80105a68:	85 c0                	test   %eax,%eax
80105a6a:	79 0a                	jns    80105a76 <sys_unlink+0x27>
    return -1;
80105a6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a71:	e9 af 01 00 00       	jmp    80105c25 <sys_unlink+0x1d6>

  begin_op();
80105a76:	e8 e6 d9 ff ff       	call   80103461 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105a7b:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105a7e:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105a81:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a85:	89 04 24             	mov    %eax,(%esp)
80105a88:	e8 ab c9 ff ff       	call   80102438 <nameiparent>
80105a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a94:	75 0f                	jne    80105aa5 <sys_unlink+0x56>
    end_op();
80105a96:	e8 47 da ff ff       	call   801034e2 <end_op>
    return -1;
80105a9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa0:	e9 80 01 00 00       	jmp    80105c25 <sys_unlink+0x1d6>
  }

  ilock(dp);
80105aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa8:	89 04 24             	mov    %eax,(%esp)
80105aab:	e8 c4 bd ff ff       	call   80101874 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105ab0:	c7 44 24 04 d5 8d 10 	movl   $0x80108dd5,0x4(%esp)
80105ab7:	80 
80105ab8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105abb:	89 04 24             	mov    %eax,(%esp)
80105abe:	e8 a8 c5 ff ff       	call   8010206b <namecmp>
80105ac3:	85 c0                	test   %eax,%eax
80105ac5:	0f 84 45 01 00 00    	je     80105c10 <sys_unlink+0x1c1>
80105acb:	c7 44 24 04 d7 8d 10 	movl   $0x80108dd7,0x4(%esp)
80105ad2:	80 
80105ad3:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105ad6:	89 04 24             	mov    %eax,(%esp)
80105ad9:	e8 8d c5 ff ff       	call   8010206b <namecmp>
80105ade:	85 c0                	test   %eax,%eax
80105ae0:	0f 84 2a 01 00 00    	je     80105c10 <sys_unlink+0x1c1>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105ae6:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105ae9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105aed:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105af0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af7:	89 04 24             	mov    %eax,(%esp)
80105afa:	e8 8e c5 ff ff       	call   8010208d <dirlookup>
80105aff:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b02:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b06:	0f 84 03 01 00 00    	je     80105c0f <sys_unlink+0x1c0>
    goto bad;
  ilock(ip);
80105b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b0f:	89 04 24             	mov    %eax,(%esp)
80105b12:	e8 5d bd ff ff       	call   80101874 <ilock>

  if(ip->nlink < 1)
80105b17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b1e:	66 85 c0             	test   %ax,%ax
80105b21:	7f 0c                	jg     80105b2f <sys_unlink+0xe0>
    panic("unlink: nlink < 1");
80105b23:	c7 04 24 da 8d 10 80 	movl   $0x80108dda,(%esp)
80105b2a:	e8 0e aa ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b32:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b36:	66 83 f8 01          	cmp    $0x1,%ax
80105b3a:	75 1f                	jne    80105b5b <sys_unlink+0x10c>
80105b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b3f:	89 04 24             	mov    %eax,(%esp)
80105b42:	e8 9a fe ff ff       	call   801059e1 <isdirempty>
80105b47:	85 c0                	test   %eax,%eax
80105b49:	75 10                	jne    80105b5b <sys_unlink+0x10c>
    iunlockput(ip);
80105b4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4e:	89 04 24             	mov    %eax,(%esp)
80105b51:	e8 a2 bf ff ff       	call   80101af8 <iunlockput>
    goto bad;
80105b56:	e9 b5 00 00 00       	jmp    80105c10 <sys_unlink+0x1c1>
  }

  memset(&de, 0, sizeof(de));
80105b5b:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105b62:	00 
80105b63:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105b6a:	00 
80105b6b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b6e:	89 04 24             	mov    %eax,(%esp)
80105b71:	e8 78 f5 ff ff       	call   801050ee <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b76:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105b79:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b80:	00 
80105b81:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b85:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105b88:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8f:	89 04 24             	mov    %eax,(%esp)
80105b92:	e8 3e c3 ff ff       	call   80101ed5 <writei>
80105b97:	83 f8 10             	cmp    $0x10,%eax
80105b9a:	74 0c                	je     80105ba8 <sys_unlink+0x159>
    panic("unlink: writei");
80105b9c:	c7 04 24 ec 8d 10 80 	movl   $0x80108dec,(%esp)
80105ba3:	e8 95 a9 ff ff       	call   8010053d <panic>
  if(ip->type == T_DIR){
80105ba8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bab:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105baf:	66 83 f8 01          	cmp    $0x1,%ax
80105bb3:	75 1c                	jne    80105bd1 <sys_unlink+0x182>
    dp->nlink--;
80105bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb8:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105bbc:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc2:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc9:	89 04 24             	mov    %eax,(%esp)
80105bcc:	e8 e7 ba ff ff       	call   801016b8 <iupdate>
  }
  iunlockput(dp);
80105bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd4:	89 04 24             	mov    %eax,(%esp)
80105bd7:	e8 1c bf ff ff       	call   80101af8 <iunlockput>

  ip->nlink--;
80105bdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bdf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105be3:	8d 50 ff             	lea    -0x1(%eax),%edx
80105be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105be9:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105bed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf0:	89 04 24             	mov    %eax,(%esp)
80105bf3:	e8 c0 ba ff ff       	call   801016b8 <iupdate>
  iunlockput(ip);
80105bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfb:	89 04 24             	mov    %eax,(%esp)
80105bfe:	e8 f5 be ff ff       	call   80101af8 <iunlockput>

  end_op();
80105c03:	e8 da d8 ff ff       	call   801034e2 <end_op>

  return 0;
80105c08:	b8 00 00 00 00       	mov    $0x0,%eax
80105c0d:	eb 16                	jmp    80105c25 <sys_unlink+0x1d6>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105c0f:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c13:	89 04 24             	mov    %eax,(%esp)
80105c16:	e8 dd be ff ff       	call   80101af8 <iunlockput>
  end_op();
80105c1b:	e8 c2 d8 ff ff       	call   801034e2 <end_op>
  return -1;
80105c20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c25:	c9                   	leave  
80105c26:	c3                   	ret    

80105c27 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105c27:	55                   	push   %ebp
80105c28:	89 e5                	mov    %esp,%ebp
80105c2a:	83 ec 48             	sub    $0x48,%esp
80105c2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105c30:	8b 55 10             	mov    0x10(%ebp),%edx
80105c33:	8b 45 14             	mov    0x14(%ebp),%eax
80105c36:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105c3a:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105c3e:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105c42:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c45:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c49:	8b 45 08             	mov    0x8(%ebp),%eax
80105c4c:	89 04 24             	mov    %eax,(%esp)
80105c4f:	e8 e4 c7 ff ff       	call   80102438 <nameiparent>
80105c54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c5b:	75 0a                	jne    80105c67 <create+0x40>
    return 0;
80105c5d:	b8 00 00 00 00       	mov    $0x0,%eax
80105c62:	e9 7e 01 00 00       	jmp    80105de5 <create+0x1be>
  ilock(dp);
80105c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6a:	89 04 24             	mov    %eax,(%esp)
80105c6d:	e8 02 bc ff ff       	call   80101874 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105c72:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c75:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c79:	8d 45 de             	lea    -0x22(%ebp),%eax
80105c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c83:	89 04 24             	mov    %eax,(%esp)
80105c86:	e8 02 c4 ff ff       	call   8010208d <dirlookup>
80105c8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c92:	74 47                	je     80105cdb <create+0xb4>
    iunlockput(dp);
80105c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c97:	89 04 24             	mov    %eax,(%esp)
80105c9a:	e8 59 be ff ff       	call   80101af8 <iunlockput>
    ilock(ip);
80105c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca2:	89 04 24             	mov    %eax,(%esp)
80105ca5:	e8 ca bb ff ff       	call   80101874 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105caa:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105caf:	75 15                	jne    80105cc6 <create+0x9f>
80105cb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb4:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cb8:	66 83 f8 02          	cmp    $0x2,%ax
80105cbc:	75 08                	jne    80105cc6 <create+0x9f>
      return ip;
80105cbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc1:	e9 1f 01 00 00       	jmp    80105de5 <create+0x1be>
    iunlockput(ip);
80105cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc9:	89 04 24             	mov    %eax,(%esp)
80105ccc:	e8 27 be ff ff       	call   80101af8 <iunlockput>
    return 0;
80105cd1:	b8 00 00 00 00       	mov    $0x0,%eax
80105cd6:	e9 0a 01 00 00       	jmp    80105de5 <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105cdb:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce2:	8b 00                	mov    (%eax),%eax
80105ce4:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ce8:	89 04 24             	mov    %eax,(%esp)
80105ceb:	e8 eb b8 ff ff       	call   801015db <ialloc>
80105cf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105cf3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cf7:	75 0c                	jne    80105d05 <create+0xde>
    panic("create: ialloc");
80105cf9:	c7 04 24 fb 8d 10 80 	movl   $0x80108dfb,(%esp)
80105d00:	e8 38 a8 ff ff       	call   8010053d <panic>

  ilock(ip);
80105d05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d08:	89 04 24             	mov    %eax,(%esp)
80105d0b:	e8 64 bb ff ff       	call   80101874 <ilock>
  ip->major = major;
80105d10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d13:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105d17:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1e:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105d22:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d29:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d32:	89 04 24             	mov    %eax,(%esp)
80105d35:	e8 7e b9 ff ff       	call   801016b8 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105d3a:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105d3f:	75 6a                	jne    80105dab <create+0x184>
    dp->nlink++;  // for ".."
80105d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d44:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d48:	8d 50 01             	lea    0x1(%eax),%edx
80105d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4e:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d55:	89 04 24             	mov    %eax,(%esp)
80105d58:	e8 5b b9 ff ff       	call   801016b8 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105d5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d60:	8b 40 04             	mov    0x4(%eax),%eax
80105d63:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d67:	c7 44 24 04 d5 8d 10 	movl   $0x80108dd5,0x4(%esp)
80105d6e:	80 
80105d6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d72:	89 04 24             	mov    %eax,(%esp)
80105d75:	e8 db c3 ff ff       	call   80102155 <dirlink>
80105d7a:	85 c0                	test   %eax,%eax
80105d7c:	78 21                	js     80105d9f <create+0x178>
80105d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d81:	8b 40 04             	mov    0x4(%eax),%eax
80105d84:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d88:	c7 44 24 04 d7 8d 10 	movl   $0x80108dd7,0x4(%esp)
80105d8f:	80 
80105d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d93:	89 04 24             	mov    %eax,(%esp)
80105d96:	e8 ba c3 ff ff       	call   80102155 <dirlink>
80105d9b:	85 c0                	test   %eax,%eax
80105d9d:	79 0c                	jns    80105dab <create+0x184>
      panic("create dots");
80105d9f:	c7 04 24 0a 8e 10 80 	movl   $0x80108e0a,(%esp)
80105da6:	e8 92 a7 ff ff       	call   8010053d <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dae:	8b 40 04             	mov    0x4(%eax),%eax
80105db1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105db5:	8d 45 de             	lea    -0x22(%ebp),%eax
80105db8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dbf:	89 04 24             	mov    %eax,(%esp)
80105dc2:	e8 8e c3 ff ff       	call   80102155 <dirlink>
80105dc7:	85 c0                	test   %eax,%eax
80105dc9:	79 0c                	jns    80105dd7 <create+0x1b0>
    panic("create: dirlink");
80105dcb:	c7 04 24 16 8e 10 80 	movl   $0x80108e16,(%esp)
80105dd2:	e8 66 a7 ff ff       	call   8010053d <panic>

  iunlockput(dp);
80105dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dda:	89 04 24             	mov    %eax,(%esp)
80105ddd:	e8 16 bd ff ff       	call   80101af8 <iunlockput>

  return ip;
80105de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105de5:	c9                   	leave  
80105de6:	c3                   	ret    

80105de7 <sys_open>:

int
sys_open(void)
{
80105de7:	55                   	push   %ebp
80105de8:	89 e5                	mov    %esp,%ebp
80105dea:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105ded:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105df0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105df4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dfb:	e8 da f6 ff ff       	call   801054da <argstr>
80105e00:	85 c0                	test   %eax,%eax
80105e02:	78 17                	js     80105e1b <sys_open+0x34>
80105e04:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105e07:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e12:	e8 33 f6 ff ff       	call   8010544a <argint>
80105e17:	85 c0                	test   %eax,%eax
80105e19:	79 0a                	jns    80105e25 <sys_open+0x3e>
    return -1;
80105e1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e20:	e9 5a 01 00 00       	jmp    80105f7f <sys_open+0x198>

  begin_op();
80105e25:	e8 37 d6 ff ff       	call   80103461 <begin_op>

  if(omode & O_CREATE){
80105e2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e2d:	25 00 02 00 00       	and    $0x200,%eax
80105e32:	85 c0                	test   %eax,%eax
80105e34:	74 3b                	je     80105e71 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80105e36:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e39:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105e40:	00 
80105e41:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105e48:	00 
80105e49:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105e50:	00 
80105e51:	89 04 24             	mov    %eax,(%esp)
80105e54:	e8 ce fd ff ff       	call   80105c27 <create>
80105e59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105e5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e60:	75 6b                	jne    80105ecd <sys_open+0xe6>
      end_op();
80105e62:	e8 7b d6 ff ff       	call   801034e2 <end_op>
      return -1;
80105e67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e6c:	e9 0e 01 00 00       	jmp    80105f7f <sys_open+0x198>
    }
  } else {
    if((ip = namei(path)) == 0){
80105e71:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105e74:	89 04 24             	mov    %eax,(%esp)
80105e77:	e8 9a c5 ff ff       	call   80102416 <namei>
80105e7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e7f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e83:	75 0f                	jne    80105e94 <sys_open+0xad>
      end_op();
80105e85:	e8 58 d6 ff ff       	call   801034e2 <end_op>
      return -1;
80105e8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e8f:	e9 eb 00 00 00       	jmp    80105f7f <sys_open+0x198>
    }
    ilock(ip);
80105e94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e97:	89 04 24             	mov    %eax,(%esp)
80105e9a:	e8 d5 b9 ff ff       	call   80101874 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ea6:	66 83 f8 01          	cmp    $0x1,%ax
80105eaa:	75 21                	jne    80105ecd <sys_open+0xe6>
80105eac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105eaf:	85 c0                	test   %eax,%eax
80105eb1:	74 1a                	je     80105ecd <sys_open+0xe6>
      iunlockput(ip);
80105eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb6:	89 04 24             	mov    %eax,(%esp)
80105eb9:	e8 3a bc ff ff       	call   80101af8 <iunlockput>
      end_op();
80105ebe:	e8 1f d6 ff ff       	call   801034e2 <end_op>
      return -1;
80105ec3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec8:	e9 b2 00 00 00       	jmp    80105f7f <sys_open+0x198>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105ecd:	e8 56 b0 ff ff       	call   80100f28 <filealloc>
80105ed2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105ed5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ed9:	74 14                	je     80105eef <sys_open+0x108>
80105edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ede:	89 04 24             	mov    %eax,(%esp)
80105ee1:	e8 2f f7 ff ff       	call   80105615 <fdalloc>
80105ee6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105ee9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105eed:	79 28                	jns    80105f17 <sys_open+0x130>
    if(f)
80105eef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ef3:	74 0b                	je     80105f00 <sys_open+0x119>
      fileclose(f);
80105ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef8:	89 04 24             	mov    %eax,(%esp)
80105efb:	e8 d0 b0 ff ff       	call   80100fd0 <fileclose>
    iunlockput(ip);
80105f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f03:	89 04 24             	mov    %eax,(%esp)
80105f06:	e8 ed bb ff ff       	call   80101af8 <iunlockput>
    end_op();
80105f0b:	e8 d2 d5 ff ff       	call   801034e2 <end_op>
    return -1;
80105f10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f15:	eb 68                	jmp    80105f7f <sys_open+0x198>
  }
  iunlock(ip);
80105f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f1a:	89 04 24             	mov    %eax,(%esp)
80105f1d:	e8 a0 ba ff ff       	call   801019c2 <iunlock>
  end_op();
80105f22:	e8 bb d5 ff ff       	call   801034e2 <end_op>

  f->type = FD_INODE;
80105f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2a:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f33:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f36:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f3c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105f43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f46:	83 e0 01             	and    $0x1,%eax
80105f49:	85 c0                	test   %eax,%eax
80105f4b:	0f 94 c2             	sete   %dl
80105f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f51:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105f54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f57:	83 e0 01             	and    $0x1,%eax
80105f5a:	84 c0                	test   %al,%al
80105f5c:	75 0a                	jne    80105f68 <sys_open+0x181>
80105f5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f61:	83 e0 02             	and    $0x2,%eax
80105f64:	85 c0                	test   %eax,%eax
80105f66:	74 07                	je     80105f6f <sys_open+0x188>
80105f68:	b8 01 00 00 00       	mov    $0x1,%eax
80105f6d:	eb 05                	jmp    80105f74 <sys_open+0x18d>
80105f6f:	b8 00 00 00 00       	mov    $0x0,%eax
80105f74:	89 c2                	mov    %eax,%edx
80105f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f79:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105f7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105f7f:	c9                   	leave  
80105f80:	c3                   	ret    

80105f81 <sys_mkdir>:

int
sys_mkdir(void)
{
80105f81:	55                   	push   %ebp
80105f82:	89 e5                	mov    %esp,%ebp
80105f84:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105f87:	e8 d5 d4 ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105f8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f9a:	e8 3b f5 ff ff       	call   801054da <argstr>
80105f9f:	85 c0                	test   %eax,%eax
80105fa1:	78 2c                	js     80105fcf <sys_mkdir+0x4e>
80105fa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105fad:	00 
80105fae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105fb5:	00 
80105fb6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105fbd:	00 
80105fbe:	89 04 24             	mov    %eax,(%esp)
80105fc1:	e8 61 fc ff ff       	call   80105c27 <create>
80105fc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fc9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fcd:	75 0c                	jne    80105fdb <sys_mkdir+0x5a>
    end_op();
80105fcf:	e8 0e d5 ff ff       	call   801034e2 <end_op>
    return -1;
80105fd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd9:	eb 15                	jmp    80105ff0 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fde:	89 04 24             	mov    %eax,(%esp)
80105fe1:	e8 12 bb ff ff       	call   80101af8 <iunlockput>
  end_op();
80105fe6:	e8 f7 d4 ff ff       	call   801034e2 <end_op>
  return 0;
80105feb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ff0:	c9                   	leave  
80105ff1:	c3                   	ret    

80105ff2 <sys_mknod>:

int
sys_mknod(void)
{
80105ff2:	55                   	push   %ebp
80105ff3:	89 e5                	mov    %esp,%ebp
80105ff5:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80105ff8:	e8 64 d4 ff ff       	call   80103461 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80105ffd:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106000:	89 44 24 04          	mov    %eax,0x4(%esp)
80106004:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010600b:	e8 ca f4 ff ff       	call   801054da <argstr>
80106010:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106013:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106017:	78 5e                	js     80106077 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106019:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010601c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106020:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106027:	e8 1e f4 ff ff       	call   8010544a <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
8010602c:	85 c0                	test   %eax,%eax
8010602e:	78 47                	js     80106077 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106030:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106033:	89 44 24 04          	mov    %eax,0x4(%esp)
80106037:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010603e:	e8 07 f4 ff ff       	call   8010544a <argint>
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106043:	85 c0                	test   %eax,%eax
80106045:	78 30                	js     80106077 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106047:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010604a:	0f bf c8             	movswl %ax,%ecx
8010604d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106050:	0f bf d0             	movswl %ax,%edx
80106053:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106056:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010605a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010605e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106065:	00 
80106066:	89 04 24             	mov    %eax,(%esp)
80106069:	e8 b9 fb ff ff       	call   80105c27 <create>
8010606e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106071:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106075:	75 0c                	jne    80106083 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106077:	e8 66 d4 ff ff       	call   801034e2 <end_op>
    return -1;
8010607c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106081:	eb 15                	jmp    80106098 <sys_mknod+0xa6>
  }
  iunlockput(ip);
80106083:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106086:	89 04 24             	mov    %eax,(%esp)
80106089:	e8 6a ba ff ff       	call   80101af8 <iunlockput>
  end_op();
8010608e:	e8 4f d4 ff ff       	call   801034e2 <end_op>
  return 0;
80106093:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106098:	c9                   	leave  
80106099:	c3                   	ret    

8010609a <sys_chdir>:

int
sys_chdir(void)
{
8010609a:	55                   	push   %ebp
8010609b:	89 e5                	mov    %esp,%ebp
8010609d:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060a0:	e8 bc d3 ff ff       	call   80103461 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801060a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801060ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060b3:	e8 22 f4 ff ff       	call   801054da <argstr>
801060b8:	85 c0                	test   %eax,%eax
801060ba:	78 14                	js     801060d0 <sys_chdir+0x36>
801060bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060bf:	89 04 24             	mov    %eax,(%esp)
801060c2:	e8 4f c3 ff ff       	call   80102416 <namei>
801060c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060ce:	75 0c                	jne    801060dc <sys_chdir+0x42>
    end_op();
801060d0:	e8 0d d4 ff ff       	call   801034e2 <end_op>
    return -1;
801060d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060da:	eb 61                	jmp    8010613d <sys_chdir+0xa3>
  }
  ilock(ip);
801060dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060df:	89 04 24             	mov    %eax,(%esp)
801060e2:	e8 8d b7 ff ff       	call   80101874 <ilock>
  if(ip->type != T_DIR){
801060e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ea:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801060ee:	66 83 f8 01          	cmp    $0x1,%ax
801060f2:	74 17                	je     8010610b <sys_chdir+0x71>
    iunlockput(ip);
801060f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060f7:	89 04 24             	mov    %eax,(%esp)
801060fa:	e8 f9 b9 ff ff       	call   80101af8 <iunlockput>
    end_op();
801060ff:	e8 de d3 ff ff       	call   801034e2 <end_op>
    return -1;
80106104:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106109:	eb 32                	jmp    8010613d <sys_chdir+0xa3>
  }
  iunlock(ip);
8010610b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610e:	89 04 24             	mov    %eax,(%esp)
80106111:	e8 ac b8 ff ff       	call   801019c2 <iunlock>
  iput(proc->cwd);
80106116:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010611c:	8b 40 68             	mov    0x68(%eax),%eax
8010611f:	89 04 24             	mov    %eax,(%esp)
80106122:	e8 00 b9 ff ff       	call   80101a27 <iput>
  end_op();
80106127:	e8 b6 d3 ff ff       	call   801034e2 <end_op>
  proc->cwd = ip;
8010612c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106132:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106135:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106138:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010613d:	c9                   	leave  
8010613e:	c3                   	ret    

8010613f <sys_exec>:

int
sys_exec(void)
{
8010613f:	55                   	push   %ebp
80106140:	89 e5                	mov    %esp,%ebp
80106142:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106148:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010614b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010614f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106156:	e8 7f f3 ff ff       	call   801054da <argstr>
8010615b:	85 c0                	test   %eax,%eax
8010615d:	78 1a                	js     80106179 <sys_exec+0x3a>
8010615f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106165:	89 44 24 04          	mov    %eax,0x4(%esp)
80106169:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106170:	e8 d5 f2 ff ff       	call   8010544a <argint>
80106175:	85 c0                	test   %eax,%eax
80106177:	79 0a                	jns    80106183 <sys_exec+0x44>
    return -1;
80106179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617e:	e9 cc 00 00 00       	jmp    8010624f <sys_exec+0x110>
  }
  memset(argv, 0, sizeof(argv));
80106183:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010618a:	00 
8010618b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106192:	00 
80106193:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106199:	89 04 24             	mov    %eax,(%esp)
8010619c:	e8 4d ef ff ff       	call   801050ee <memset>
  for(i=0;; i++){
801061a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801061a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ab:	83 f8 1f             	cmp    $0x1f,%eax
801061ae:	76 0a                	jbe    801061ba <sys_exec+0x7b>
      return -1;
801061b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061b5:	e9 95 00 00 00       	jmp    8010624f <sys_exec+0x110>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801061ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061bd:	c1 e0 02             	shl    $0x2,%eax
801061c0:	89 c2                	mov    %eax,%edx
801061c2:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801061c8:	01 c2                	add    %eax,%edx
801061ca:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801061d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801061d4:	89 14 24             	mov    %edx,(%esp)
801061d7:	e8 d0 f1 ff ff       	call   801053ac <fetchint>
801061dc:	85 c0                	test   %eax,%eax
801061de:	79 07                	jns    801061e7 <sys_exec+0xa8>
      return -1;
801061e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e5:	eb 68                	jmp    8010624f <sys_exec+0x110>
    if(uarg == 0){
801061e7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801061ed:	85 c0                	test   %eax,%eax
801061ef:	75 26                	jne    80106217 <sys_exec+0xd8>
      argv[i] = 0;
801061f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f4:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801061fb:	00 00 00 00 
      break;
801061ff:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106200:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106203:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106209:	89 54 24 04          	mov    %edx,0x4(%esp)
8010620d:	89 04 24             	mov    %eax,(%esp)
80106210:	e8 e7 a8 ff ff       	call   80100afc <exec>
80106215:	eb 38                	jmp    8010624f <sys_exec+0x110>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010621a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80106221:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106227:	01 c2                	add    %eax,%edx
80106229:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010622f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106233:	89 04 24             	mov    %eax,(%esp)
80106236:	e8 ab f1 ff ff       	call   801053e6 <fetchstr>
8010623b:	85 c0                	test   %eax,%eax
8010623d:	79 07                	jns    80106246 <sys_exec+0x107>
      return -1;
8010623f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106244:	eb 09                	jmp    8010624f <sys_exec+0x110>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106246:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010624a:	e9 59 ff ff ff       	jmp    801061a8 <sys_exec+0x69>
  return exec(path, argv);
}
8010624f:	c9                   	leave  
80106250:	c3                   	ret    

80106251 <sys_pipe>:

int
sys_pipe(void)
{
80106251:	55                   	push   %ebp
80106252:	89 e5                	mov    %esp,%ebp
80106254:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106257:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010625e:	00 
8010625f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106262:	89 44 24 04          	mov    %eax,0x4(%esp)
80106266:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010626d:	e8 06 f2 ff ff       	call   80105478 <argptr>
80106272:	85 c0                	test   %eax,%eax
80106274:	79 0a                	jns    80106280 <sys_pipe+0x2f>
    return -1;
80106276:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010627b:	e9 9b 00 00 00       	jmp    8010631b <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80106280:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106283:	89 44 24 04          	mov    %eax,0x4(%esp)
80106287:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010628a:	89 04 24             	mov    %eax,(%esp)
8010628d:	e8 1e dd ff ff       	call   80103fb0 <pipealloc>
80106292:	85 c0                	test   %eax,%eax
80106294:	79 07                	jns    8010629d <sys_pipe+0x4c>
    return -1;
80106296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010629b:	eb 7e                	jmp    8010631b <sys_pipe+0xca>
  fd0 = -1;
8010629d:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801062a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062a7:	89 04 24             	mov    %eax,(%esp)
801062aa:	e8 66 f3 ff ff       	call   80105615 <fdalloc>
801062af:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062b6:	78 14                	js     801062cc <sys_pipe+0x7b>
801062b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062bb:	89 04 24             	mov    %eax,(%esp)
801062be:	e8 52 f3 ff ff       	call   80105615 <fdalloc>
801062c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062ca:	79 37                	jns    80106303 <sys_pipe+0xb2>
    if(fd0 >= 0)
801062cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062d0:	78 14                	js     801062e6 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
801062d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062db:	83 c2 08             	add    $0x8,%edx
801062de:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801062e5:	00 
    fileclose(rf);
801062e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062e9:	89 04 24             	mov    %eax,(%esp)
801062ec:	e8 df ac ff ff       	call   80100fd0 <fileclose>
    fileclose(wf);
801062f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062f4:	89 04 24             	mov    %eax,(%esp)
801062f7:	e8 d4 ac ff ff       	call   80100fd0 <fileclose>
    return -1;
801062fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106301:	eb 18                	jmp    8010631b <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106303:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106306:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106309:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010630b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010630e:	8d 50 04             	lea    0x4(%eax),%edx
80106311:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106314:	89 02                	mov    %eax,(%edx)
  return 0;
80106316:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010631b:	c9                   	leave  
8010631c:	c3                   	ret    
8010631d:	00 00                	add    %al,(%eax)
	...

80106320 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106320:	55                   	push   %ebp
80106321:	89 e5                	mov    %esp,%ebp
80106323:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106326:	e8 38 e3 ff ff       	call   80104663 <fork>
}
8010632b:	c9                   	leave  
8010632c:	c3                   	ret    

8010632d <sys_exit>:

int
sys_exit(void)
{
8010632d:	55                   	push   %ebp
8010632e:	89 e5                	mov    %esp,%ebp
80106330:	83 ec 08             	sub    $0x8,%esp
  exit();
80106333:	e8 a6 e4 ff ff       	call   801047de <exit>
  return 0;  // not reached
80106338:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010633d:	c9                   	leave  
8010633e:	c3                   	ret    

8010633f <sys_wait>:

int
sys_wait(void)
{
8010633f:	55                   	push   %ebp
80106340:	89 e5                	mov    %esp,%ebp
80106342:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106345:	e8 b6 e5 ff ff       	call   80104900 <wait>
}
8010634a:	c9                   	leave  
8010634b:	c3                   	ret    

8010634c <sys_kill>:

int
sys_kill(void)
{
8010634c:	55                   	push   %ebp
8010634d:	89 e5                	mov    %esp,%ebp
8010634f:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106352:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106355:	89 44 24 04          	mov    %eax,0x4(%esp)
80106359:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106360:	e8 e5 f0 ff ff       	call   8010544a <argint>
80106365:	85 c0                	test   %eax,%eax
80106367:	79 07                	jns    80106370 <sys_kill+0x24>
    return -1;
80106369:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010636e:	eb 0b                	jmp    8010637b <sys_kill+0x2f>
  return kill(pid);
80106370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106373:	89 04 24             	mov    %eax,(%esp)
80106376:	e8 4a e9 ff ff       	call   80104cc5 <kill>
}
8010637b:	c9                   	leave  
8010637c:	c3                   	ret    

8010637d <sys_getpid>:

int
sys_getpid(void)
{
8010637d:	55                   	push   %ebp
8010637e:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106380:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106386:	8b 40 10             	mov    0x10(%eax),%eax
}
80106389:	5d                   	pop    %ebp
8010638a:	c3                   	ret    

8010638b <sys_sbrk>:

int
sys_sbrk(void)
{
8010638b:	55                   	push   %ebp
8010638c:	89 e5                	mov    %esp,%ebp
8010638e:	83 ec 28             	sub    $0x28,%esp

  int addr;
  int n;

  if(argint(0, &n) < 0)
80106391:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106394:	89 44 24 04          	mov    %eax,0x4(%esp)
80106398:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010639f:	e8 a6 f0 ff ff       	call   8010544a <argint>
801063a4:	85 c0                	test   %eax,%eax
801063a6:	79 07                	jns    801063af <sys_sbrk+0x24>
    return -1;
801063a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ad:	eb 48                	jmp    801063f7 <sys_sbrk+0x6c>
  addr = proc->sz;
801063af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063b5:	8b 00                	mov    (%eax),%eax
801063b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (n<0)
801063ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063bd:	85 c0                	test   %eax,%eax
801063bf:	79 16                	jns    801063d7 <sys_sbrk+0x4c>
  {
	  //will dealloc
	  if(growproc(n) < 0)
801063c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c4:	89 04 24             	mov    %eax,(%esp)
801063c7:	e8 f2 e1 ff ff       	call   801045be <growproc>
801063cc:	85 c0                	test   %eax,%eax
801063ce:	79 24                	jns    801063f4 <sys_sbrk+0x69>
	    return -1;
801063d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d5:	eb 20                	jmp    801063f7 <sys_sbrk+0x6c>
  }
  else if (n>0)
801063d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063da:	85 c0                	test   %eax,%eax
801063dc:	7e 16                	jle    801063f4 <sys_sbrk+0x69>
  {
	  //will not really alloc
	  proc->sz += n;
801063de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801063eb:	8b 0a                	mov    (%edx),%ecx
801063ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063f0:	01 ca                	add    %ecx,%edx
801063f2:	89 10                	mov    %edx,(%eax)
  }

  return addr;
801063f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801063f7:	c9                   	leave  
801063f8:	c3                   	ret    

801063f9 <sys_sleep>:

int
sys_sleep(void)
{
801063f9:	55                   	push   %ebp
801063fa:	89 e5                	mov    %esp,%ebp
801063fc:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801063ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106402:	89 44 24 04          	mov    %eax,0x4(%esp)
80106406:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010640d:	e8 38 f0 ff ff       	call   8010544a <argint>
80106412:	85 c0                	test   %eax,%eax
80106414:	79 07                	jns    8010641d <sys_sleep+0x24>
    return -1;
80106416:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010641b:	eb 6c                	jmp    80106489 <sys_sleep+0x90>
  acquire(&tickslock);
8010641d:	c7 04 24 60 59 11 80 	movl   $0x80115960,(%esp)
80106424:	e8 76 ea ff ff       	call   80104e9f <acquire>
  ticks0 = ticks;
80106429:	a1 a0 61 11 80       	mov    0x801161a0,%eax
8010642e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106431:	eb 34                	jmp    80106467 <sys_sleep+0x6e>
    if(proc->killed){
80106433:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106439:	8b 40 24             	mov    0x24(%eax),%eax
8010643c:	85 c0                	test   %eax,%eax
8010643e:	74 13                	je     80106453 <sys_sleep+0x5a>
      release(&tickslock);
80106440:	c7 04 24 60 59 11 80 	movl   $0x80115960,(%esp)
80106447:	e8 b5 ea ff ff       	call   80104f01 <release>
      return -1;
8010644c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106451:	eb 36                	jmp    80106489 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
80106453:	c7 44 24 04 60 59 11 	movl   $0x80115960,0x4(%esp)
8010645a:	80 
8010645b:	c7 04 24 a0 61 11 80 	movl   $0x801161a0,(%esp)
80106462:	e8 5a e7 ff ff       	call   80104bc1 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106467:	a1 a0 61 11 80       	mov    0x801161a0,%eax
8010646c:	89 c2                	mov    %eax,%edx
8010646e:	2b 55 f4             	sub    -0xc(%ebp),%edx
80106471:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106474:	39 c2                	cmp    %eax,%edx
80106476:	72 bb                	jb     80106433 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106478:	c7 04 24 60 59 11 80 	movl   $0x80115960,(%esp)
8010647f:	e8 7d ea ff ff       	call   80104f01 <release>
  return 0;
80106484:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106489:	c9                   	leave  
8010648a:	c3                   	ret    

8010648b <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010648b:	55                   	push   %ebp
8010648c:	89 e5                	mov    %esp,%ebp
8010648e:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
80106491:	c7 04 24 60 59 11 80 	movl   $0x80115960,(%esp)
80106498:	e8 02 ea ff ff       	call   80104e9f <acquire>
  xticks = ticks;
8010649d:	a1 a0 61 11 80       	mov    0x801161a0,%eax
801064a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801064a5:	c7 04 24 60 59 11 80 	movl   $0x80115960,(%esp)
801064ac:	e8 50 ea ff ff       	call   80104f01 <release>
  return xticks;
801064b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801064b4:	c9                   	leave  
801064b5:	c3                   	ret    
	...

801064b8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801064b8:	55                   	push   %ebp
801064b9:	89 e5                	mov    %esp,%ebp
801064bb:	83 ec 08             	sub    $0x8,%esp
801064be:	8b 55 08             	mov    0x8(%ebp),%edx
801064c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801064c4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801064c8:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801064cb:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801064cf:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801064d3:	ee                   	out    %al,(%dx)
}
801064d4:	c9                   	leave  
801064d5:	c3                   	ret    

801064d6 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801064d6:	55                   	push   %ebp
801064d7:	89 e5                	mov    %esp,%ebp
801064d9:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801064dc:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801064e3:	00 
801064e4:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801064eb:	e8 c8 ff ff ff       	call   801064b8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801064f0:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801064f7:	00 
801064f8:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801064ff:	e8 b4 ff ff ff       	call   801064b8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106504:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
8010650b:	00 
8010650c:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106513:	e8 a0 ff ff ff       	call   801064b8 <outb>
  picenable(IRQ_TIMER);
80106518:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010651f:	e8 15 d9 ff ff       	call   80103e39 <picenable>
}
80106524:	c9                   	leave  
80106525:	c3                   	ret    
	...

80106528 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106528:	1e                   	push   %ds
  pushl %es
80106529:	06                   	push   %es
  pushl %fs
8010652a:	0f a0                	push   %fs
  pushl %gs
8010652c:	0f a8                	push   %gs
  pushal
8010652e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010652f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106533:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106535:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106537:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010653b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010653d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010653f:	54                   	push   %esp
  call trap
80106540:	e8 eb 01 00 00       	call   80106730 <trap>
  addl $4, %esp
80106545:	83 c4 04             	add    $0x4,%esp

80106548 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106548:	61                   	popa   
  popl %gs
80106549:	0f a9                	pop    %gs
  popl %fs
8010654b:	0f a1                	pop    %fs
  popl %es
8010654d:	07                   	pop    %es
  popl %ds
8010654e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010654f:	83 c4 08             	add    $0x8,%esp
  iret
80106552:	cf                   	iret   
	...

80106554 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80106554:	55                   	push   %ebp
80106555:	89 e5                	mov    %esp,%ebp
80106557:	8b 45 08             	mov    0x8(%ebp),%eax
8010655a:	05 00 00 00 80       	add    $0x80000000,%eax
8010655f:	5d                   	pop    %ebp
80106560:	c3                   	ret    

80106561 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106561:	55                   	push   %ebp
80106562:	89 e5                	mov    %esp,%ebp
80106564:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106567:	8b 45 0c             	mov    0xc(%ebp),%eax
8010656a:	83 e8 01             	sub    $0x1,%eax
8010656d:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106571:	8b 45 08             	mov    0x8(%ebp),%eax
80106574:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106578:	8b 45 08             	mov    0x8(%ebp),%eax
8010657b:	c1 e8 10             	shr    $0x10,%eax
8010657e:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106582:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106585:	0f 01 18             	lidtl  (%eax)
}
80106588:	c9                   	leave  
80106589:	c3                   	ret    

8010658a <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010658a:	55                   	push   %ebp
8010658b:	89 e5                	mov    %esp,%ebp
8010658d:	53                   	push   %ebx
8010658e:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106591:	0f 20 d3             	mov    %cr2,%ebx
80106594:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106597:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010659a:	83 c4 10             	add    $0x10,%esp
8010659d:	5b                   	pop    %ebx
8010659e:	5d                   	pop    %ebp
8010659f:	c3                   	ret    

801065a0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801065a0:	55                   	push   %ebp
801065a1:	89 e5                	mov    %esp,%ebp
801065a3:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
801065a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801065ad:	e9 c3 00 00 00       	jmp    80106675 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801065b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b5:	8b 04 85 98 c0 10 80 	mov    -0x7fef3f68(,%eax,4),%eax
801065bc:	89 c2                	mov    %eax,%edx
801065be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c1:	66 89 14 c5 a0 59 11 	mov    %dx,-0x7feea660(,%eax,8)
801065c8:	80 
801065c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065cc:	66 c7 04 c5 a2 59 11 	movw   $0x8,-0x7feea65e(,%eax,8)
801065d3:	80 08 00 
801065d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d9:	0f b6 14 c5 a4 59 11 	movzbl -0x7feea65c(,%eax,8),%edx
801065e0:	80 
801065e1:	83 e2 e0             	and    $0xffffffe0,%edx
801065e4:	88 14 c5 a4 59 11 80 	mov    %dl,-0x7feea65c(,%eax,8)
801065eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065ee:	0f b6 14 c5 a4 59 11 	movzbl -0x7feea65c(,%eax,8),%edx
801065f5:	80 
801065f6:	83 e2 1f             	and    $0x1f,%edx
801065f9:	88 14 c5 a4 59 11 80 	mov    %dl,-0x7feea65c(,%eax,8)
80106600:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106603:	0f b6 14 c5 a5 59 11 	movzbl -0x7feea65b(,%eax,8),%edx
8010660a:	80 
8010660b:	83 e2 f0             	and    $0xfffffff0,%edx
8010660e:	83 ca 0e             	or     $0xe,%edx
80106611:	88 14 c5 a5 59 11 80 	mov    %dl,-0x7feea65b(,%eax,8)
80106618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661b:	0f b6 14 c5 a5 59 11 	movzbl -0x7feea65b(,%eax,8),%edx
80106622:	80 
80106623:	83 e2 ef             	and    $0xffffffef,%edx
80106626:	88 14 c5 a5 59 11 80 	mov    %dl,-0x7feea65b(,%eax,8)
8010662d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106630:	0f b6 14 c5 a5 59 11 	movzbl -0x7feea65b(,%eax,8),%edx
80106637:	80 
80106638:	83 e2 9f             	and    $0xffffff9f,%edx
8010663b:	88 14 c5 a5 59 11 80 	mov    %dl,-0x7feea65b(,%eax,8)
80106642:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106645:	0f b6 14 c5 a5 59 11 	movzbl -0x7feea65b(,%eax,8),%edx
8010664c:	80 
8010664d:	83 ca 80             	or     $0xffffff80,%edx
80106650:	88 14 c5 a5 59 11 80 	mov    %dl,-0x7feea65b(,%eax,8)
80106657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665a:	8b 04 85 98 c0 10 80 	mov    -0x7fef3f68(,%eax,4),%eax
80106661:	c1 e8 10             	shr    $0x10,%eax
80106664:	89 c2                	mov    %eax,%edx
80106666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106669:	66 89 14 c5 a6 59 11 	mov    %dx,-0x7feea65a(,%eax,8)
80106670:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106671:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106675:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010667c:	0f 8e 30 ff ff ff    	jle    801065b2 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106682:	a1 98 c1 10 80       	mov    0x8010c198,%eax
80106687:	66 a3 a0 5b 11 80    	mov    %ax,0x80115ba0
8010668d:	66 c7 05 a2 5b 11 80 	movw   $0x8,0x80115ba2
80106694:	08 00 
80106696:	0f b6 05 a4 5b 11 80 	movzbl 0x80115ba4,%eax
8010669d:	83 e0 e0             	and    $0xffffffe0,%eax
801066a0:	a2 a4 5b 11 80       	mov    %al,0x80115ba4
801066a5:	0f b6 05 a4 5b 11 80 	movzbl 0x80115ba4,%eax
801066ac:	83 e0 1f             	and    $0x1f,%eax
801066af:	a2 a4 5b 11 80       	mov    %al,0x80115ba4
801066b4:	0f b6 05 a5 5b 11 80 	movzbl 0x80115ba5,%eax
801066bb:	83 c8 0f             	or     $0xf,%eax
801066be:	a2 a5 5b 11 80       	mov    %al,0x80115ba5
801066c3:	0f b6 05 a5 5b 11 80 	movzbl 0x80115ba5,%eax
801066ca:	83 e0 ef             	and    $0xffffffef,%eax
801066cd:	a2 a5 5b 11 80       	mov    %al,0x80115ba5
801066d2:	0f b6 05 a5 5b 11 80 	movzbl 0x80115ba5,%eax
801066d9:	83 c8 60             	or     $0x60,%eax
801066dc:	a2 a5 5b 11 80       	mov    %al,0x80115ba5
801066e1:	0f b6 05 a5 5b 11 80 	movzbl 0x80115ba5,%eax
801066e8:	83 c8 80             	or     $0xffffff80,%eax
801066eb:	a2 a5 5b 11 80       	mov    %al,0x80115ba5
801066f0:	a1 98 c1 10 80       	mov    0x8010c198,%eax
801066f5:	c1 e8 10             	shr    $0x10,%eax
801066f8:	66 a3 a6 5b 11 80    	mov    %ax,0x80115ba6
  
  initlock(&tickslock, "time");
801066fe:	c7 44 24 04 28 8e 10 	movl   $0x80108e28,0x4(%esp)
80106705:	80 
80106706:	c7 04 24 60 59 11 80 	movl   $0x80115960,(%esp)
8010670d:	e8 6c e7 ff ff       	call   80104e7e <initlock>
}
80106712:	c9                   	leave  
80106713:	c3                   	ret    

80106714 <idtinit>:

void
idtinit(void)
{
80106714:	55                   	push   %ebp
80106715:	89 e5                	mov    %esp,%ebp
80106717:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010671a:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106721:	00 
80106722:	c7 04 24 a0 59 11 80 	movl   $0x801159a0,(%esp)
80106729:	e8 33 fe ff ff       	call   80106561 <lidt>
}
8010672e:	c9                   	leave  
8010672f:	c3                   	ret    

80106730 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106730:	55                   	push   %ebp
80106731:	89 e5                	mov    %esp,%ebp
80106733:	57                   	push   %edi
80106734:	56                   	push   %esi
80106735:	53                   	push   %ebx
80106736:	83 ec 4c             	sub    $0x4c,%esp
  if(tf->trapno == T_SYSCALL){
80106739:	8b 45 08             	mov    0x8(%ebp),%eax
8010673c:	8b 40 30             	mov    0x30(%eax),%eax
8010673f:	83 f8 40             	cmp    $0x40,%eax
80106742:	75 3e                	jne    80106782 <trap+0x52>
    if(proc->killed)
80106744:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010674a:	8b 40 24             	mov    0x24(%eax),%eax
8010674d:	85 c0                	test   %eax,%eax
8010674f:	74 05                	je     80106756 <trap+0x26>
      exit();
80106751:	e8 88 e0 ff ff       	call   801047de <exit>
    proc->tf = tf;
80106756:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010675c:	8b 55 08             	mov    0x8(%ebp),%edx
8010675f:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106762:	e8 aa ed ff ff       	call   80105511 <syscall>
    if(proc->killed)
80106767:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010676d:	8b 40 24             	mov    0x24(%eax),%eax
80106770:	85 c0                	test   %eax,%eax
80106772:	0f 84 63 03 00 00    	je     80106adb <trap+0x3ab>
      exit();
80106778:	e8 61 e0 ff ff       	call   801047de <exit>
    return;
8010677d:	e9 59 03 00 00       	jmp    80106adb <trap+0x3ab>
  }

  switch(tf->trapno){
80106782:	8b 45 08             	mov    0x8(%ebp),%eax
80106785:	8b 40 30             	mov    0x30(%eax),%eax
80106788:	83 e8 0e             	sub    $0xe,%eax
8010678b:	83 f8 31             	cmp    $0x31,%eax
8010678e:	0f 87 e8 01 00 00    	ja     8010697c <trap+0x24c>
80106794:	8b 04 85 0c 8f 10 80 	mov    -0x7fef70f4(,%eax,4),%eax
8010679b:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010679d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801067a3:	0f b6 00             	movzbl (%eax),%eax
801067a6:	84 c0                	test   %al,%al
801067a8:	75 31                	jne    801067db <trap+0xab>
      acquire(&tickslock);
801067aa:	c7 04 24 60 59 11 80 	movl   $0x80115960,(%esp)
801067b1:	e8 e9 e6 ff ff       	call   80104e9f <acquire>
      ticks++;
801067b6:	a1 a0 61 11 80       	mov    0x801161a0,%eax
801067bb:	83 c0 01             	add    $0x1,%eax
801067be:	a3 a0 61 11 80       	mov    %eax,0x801161a0
      wakeup(&ticks);
801067c3:	c7 04 24 a0 61 11 80 	movl   $0x801161a0,(%esp)
801067ca:	e8 cb e4 ff ff       	call   80104c9a <wakeup>
      release(&tickslock);
801067cf:	c7 04 24 60 59 11 80 	movl   $0x80115960,(%esp)
801067d6:	e8 26 e7 ff ff       	call   80104f01 <release>
    }
    lapiceoi();
801067db:	e8 3f c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067e0:	e9 70 02 00 00       	jmp    80106a55 <trap+0x325>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801067e5:	e8 13 bf ff ff       	call   801026fd <ideintr>
    lapiceoi();
801067ea:	e8 30 c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067ef:	e9 61 02 00 00       	jmp    80106a55 <trap+0x325>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801067f4:	e8 da c4 ff ff       	call   80102cd3 <kbdintr>
    lapiceoi();
801067f9:	e8 21 c7 ff ff       	call   80102f1f <lapiceoi>
    break;
801067fe:	e9 52 02 00 00       	jmp    80106a55 <trap+0x325>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106803:	e8 d8 04 00 00       	call   80106ce0 <uartintr>
    lapiceoi();
80106808:	e8 12 c7 ff ff       	call   80102f1f <lapiceoi>
    break;
8010680d:	e9 43 02 00 00       	jmp    80106a55 <trap+0x325>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
80106812:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106815:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106818:	8b 45 08             	mov    0x8(%ebp),%eax
8010681b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010681f:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106822:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106828:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010682b:	0f b6 c0             	movzbl %al,%eax
8010682e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106832:	89 54 24 08          	mov    %edx,0x8(%esp)
80106836:	89 44 24 04          	mov    %eax,0x4(%esp)
8010683a:	c7 04 24 30 8e 10 80 	movl   $0x80108e30,(%esp)
80106841:	e8 5b 9b ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106846:	e8 d4 c6 ff ff       	call   80102f1f <lapiceoi>
    break;
8010684b:	e9 05 02 00 00       	jmp    80106a55 <trap+0x325>

  case T_PGFLT:
  {
	uint va = rcr2();
80106850:	e8 35 fd ff ff       	call   8010658a <rcr2>
80106855:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	//bad access from kernal
	if( va <= proc->sz )
80106858:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010685e:	8b 00                	mov    (%eax),%eax
80106860:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
80106863:	0f 82 13 01 00 00    	jb     8010697c <trap+0x24c>
	{
		if (TLBhandlePageFault(proc,(void*)va) >= 0)	break;	//on success
80106869:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010686c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106872:	89 54 24 04          	mov    %edx,0x4(%esp)
80106876:	89 04 24             	mov    %eax,(%esp)
80106879:	e8 95 20 00 00       	call   80108913 <TLBhandlePageFault>
8010687e:	85 c0                	test   %eax,%eax
80106880:	0f 89 ce 01 00 00    	jns    80106a54 <trap+0x324>

		if( va >= KERNBASE ){
80106886:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106889:	85 c0                	test   %eax,%eax
8010688b:	79 1e                	jns    801068ab <trap+0x17b>
			cprintf("memory out of bounds!\n");
8010688d:	c7 04 24 54 8e 10 80 	movl   $0x80108e54,(%esp)
80106894:	e8 08 9b ff ff       	call   801003a1 <cprintf>
			proc->killed = 1;
80106899:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010689f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
			break;
801068a6:	e9 aa 01 00 00       	jmp    80106a55 <trap+0x325>
		}

		char *m;
		uint tmp = PGROUNDDOWN(va);
801068ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801068b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if( ( m = kalloc() ) == 0 ){
801068b6:	e8 50 c2 ff ff       	call   80102b0b <kalloc>
801068bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
801068be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801068c2:	75 1e                	jne    801068e2 <trap+0x1b2>
			//kalloc failed - kill proc
			cprintf("kalloc failed!\n");
801068c4:	c7 04 24 6b 8e 10 80 	movl   $0x80108e6b,(%esp)
801068cb:	e8 d1 9a ff ff       	call   801003a1 <cprintf>
			proc->killed = 1;
801068d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068d6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
			break;
801068dd:	e9 73 01 00 00       	jmp    80106a55 <trap+0x325>
		}
		else
		{
			//cprintf("page allocated!\n");
		}
		memset(m, 0, PGSIZE);
801068e2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801068e9:	00 
801068ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801068f1:	00 
801068f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801068f5:	89 04 24             	mov    %eax,(%esp)
801068f8:	e8 f1 e7 ff ff       	call   801050ee <memset>
		if (mappages(proc->pgdir, (char*) tmp, PGSIZE, v2p(m), PTE_W|PTE_U) < 0)
801068fd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106900:	89 04 24             	mov    %eax,(%esp)
80106903:	e8 4c fc ff ff       	call   80106554 <v2p>
80106908:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010690b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80106912:	8b 52 04             	mov    0x4(%edx),%edx
80106915:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010691c:	00 
8010691d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80106921:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106928:	00 
80106929:	89 4c 24 04          	mov    %ecx,0x4(%esp)
8010692d:	89 14 24             	mov    %edx,(%esp)
80106930:	e8 eb 16 00 00       	call   80108020 <mappages>
80106935:	85 c0                	test   %eax,%eax
80106937:	79 29                	jns    80106962 <trap+0x232>
		{
			cprintf("map pages failed!\n");
80106939:	c7 04 24 7b 8e 10 80 	movl   $0x80108e7b,(%esp)
80106940:	e8 5c 9a ff ff       	call   801003a1 <cprintf>
			kfree(m);
80106945:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106948:	89 04 24             	mov    %eax,(%esp)
8010694b:	e8 22 c1 ff ff       	call   80102a72 <kfree>
			proc->killed = 1;
80106950:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106956:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
			break;
8010695d:	e9 f3 00 00 00       	jmp    80106a55 <trap+0x325>
		}
		//cprintf("allocated page :)\n");
		TLBhandlePageFault(proc,(void*)va);
80106962:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106965:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010696b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010696f:	89 04 24             	mov    %eax,(%esp)
80106972:	e8 9c 1f 00 00       	call   80108913 <TLBhandlePageFault>
		break;
80106977:	e9 d9 00 00 00       	jmp    80106a55 <trap+0x325>
	}
  }

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010697c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106982:	85 c0                	test   %eax,%eax
80106984:	74 11                	je     80106997 <trap+0x267>
80106986:	8b 45 08             	mov    0x8(%ebp),%eax
80106989:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010698d:	0f b7 c0             	movzwl %ax,%eax
80106990:	83 e0 03             	and    $0x3,%eax
80106993:	85 c0                	test   %eax,%eax
80106995:	75 46                	jne    801069dd <trap+0x2ad>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106997:	e8 ee fb ff ff       	call   8010658a <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
8010699c:	8b 55 08             	mov    0x8(%ebp),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010699f:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801069a2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801069a9:	0f b6 12             	movzbl (%edx),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069ac:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
801069af:	8b 55 08             	mov    0x8(%ebp),%edx

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069b2:	8b 52 30             	mov    0x30(%edx),%edx
801069b5:	89 44 24 10          	mov    %eax,0x10(%esp)
801069b9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
801069bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801069c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801069c5:	c7 04 24 90 8e 10 80 	movl   $0x80108e90,(%esp)
801069cc:	e8 d0 99 ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
801069d1:	c7 04 24 c2 8e 10 80 	movl   $0x80108ec2,(%esp)
801069d8:	e8 60 9b ff ff       	call   8010053d <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069dd:	e8 a8 fb ff ff       	call   8010658a <rcr2>
801069e2:	89 c2                	mov    %eax,%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801069e4:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069e7:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801069ea:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069f0:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069f3:	0f b6 f0             	movzbl %al,%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801069f6:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069f9:	8b 58 34             	mov    0x34(%eax),%ebx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801069fc:	8b 45 08             	mov    0x8(%ebp),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069ff:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106a02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a08:	83 c0 6c             	add    $0x6c,%eax
80106a0b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106a0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a14:	8b 40 10             	mov    0x10(%eax),%eax
80106a17:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106a1b:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106a1f:	89 74 24 14          	mov    %esi,0x14(%esp)
80106a23:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106a27:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a2b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80106a2e:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a32:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a36:	c7 04 24 c8 8e 10 80 	movl   $0x80108ec8,(%esp)
80106a3d:	e8 5f 99 ff ff       	call   801003a1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106a42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a48:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a4f:	eb 04                	jmp    80106a55 <trap+0x325>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106a51:	90                   	nop
80106a52:	eb 01                	jmp    80106a55 <trap+0x325>
  {
	uint va = rcr2();
	//bad access from kernal
	if( va <= proc->sz )
	{
		if (TLBhandlePageFault(proc,(void*)va) >= 0)	break;	//on success
80106a54:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a5b:	85 c0                	test   %eax,%eax
80106a5d:	74 24                	je     80106a83 <trap+0x353>
80106a5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a65:	8b 40 24             	mov    0x24(%eax),%eax
80106a68:	85 c0                	test   %eax,%eax
80106a6a:	74 17                	je     80106a83 <trap+0x353>
80106a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a6f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a73:	0f b7 c0             	movzwl %ax,%eax
80106a76:	83 e0 03             	and    $0x3,%eax
80106a79:	83 f8 03             	cmp    $0x3,%eax
80106a7c:	75 05                	jne    80106a83 <trap+0x353>
    exit();
80106a7e:	e8 5b dd ff ff       	call   801047de <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106a83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a89:	85 c0                	test   %eax,%eax
80106a8b:	74 1e                	je     80106aab <trap+0x37b>
80106a8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a93:	8b 40 0c             	mov    0xc(%eax),%eax
80106a96:	83 f8 04             	cmp    $0x4,%eax
80106a99:	75 10                	jne    80106aab <trap+0x37b>
80106a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80106a9e:	8b 40 30             	mov    0x30(%eax),%eax
80106aa1:	83 f8 20             	cmp    $0x20,%eax
80106aa4:	75 05                	jne    80106aab <trap+0x37b>
    yield();
80106aa6:	e8 b8 e0 ff ff       	call   80104b63 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106aab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ab1:	85 c0                	test   %eax,%eax
80106ab3:	74 27                	je     80106adc <trap+0x3ac>
80106ab5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106abb:	8b 40 24             	mov    0x24(%eax),%eax
80106abe:	85 c0                	test   %eax,%eax
80106ac0:	74 1a                	je     80106adc <trap+0x3ac>
80106ac2:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ac9:	0f b7 c0             	movzwl %ax,%eax
80106acc:	83 e0 03             	and    $0x3,%eax
80106acf:	83 f8 03             	cmp    $0x3,%eax
80106ad2:	75 08                	jne    80106adc <trap+0x3ac>
    exit();
80106ad4:	e8 05 dd ff ff       	call   801047de <exit>
80106ad9:	eb 01                	jmp    80106adc <trap+0x3ac>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106adb:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106adc:	83 c4 4c             	add    $0x4c,%esp
80106adf:	5b                   	pop    %ebx
80106ae0:	5e                   	pop    %esi
80106ae1:	5f                   	pop    %edi
80106ae2:	5d                   	pop    %ebp
80106ae3:	c3                   	ret    

80106ae4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106ae4:	55                   	push   %ebp
80106ae5:	89 e5                	mov    %esp,%ebp
80106ae7:	53                   	push   %ebx
80106ae8:	83 ec 14             	sub    $0x14,%esp
80106aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80106aee:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106af2:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
80106af6:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80106afa:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
80106afe:	ec                   	in     (%dx),%al
80106aff:	89 c3                	mov    %eax,%ebx
80106b01:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80106b04:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
}
80106b08:	83 c4 14             	add    $0x14,%esp
80106b0b:	5b                   	pop    %ebx
80106b0c:	5d                   	pop    %ebp
80106b0d:	c3                   	ret    

80106b0e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106b0e:	55                   	push   %ebp
80106b0f:	89 e5                	mov    %esp,%ebp
80106b11:	83 ec 08             	sub    $0x8,%esp
80106b14:	8b 55 08             	mov    0x8(%ebp),%edx
80106b17:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b1a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106b1e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106b21:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106b25:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106b29:	ee                   	out    %al,(%dx)
}
80106b2a:	c9                   	leave  
80106b2b:	c3                   	ret    

80106b2c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b2c:	55                   	push   %ebp
80106b2d:	89 e5                	mov    %esp,%ebp
80106b2f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b39:	00 
80106b3a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106b41:	e8 c8 ff ff ff       	call   80106b0e <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b46:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106b4d:	00 
80106b4e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b55:	e8 b4 ff ff ff       	call   80106b0e <outb>
  outb(COM1+0, 115200/9600);
80106b5a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106b61:	00 
80106b62:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106b69:	e8 a0 ff ff ff       	call   80106b0e <outb>
  outb(COM1+1, 0);
80106b6e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b75:	00 
80106b76:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106b7d:	e8 8c ff ff ff       	call   80106b0e <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b82:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106b89:	00 
80106b8a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106b91:	e8 78 ff ff ff       	call   80106b0e <outb>
  outb(COM1+4, 0);
80106b96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b9d:	00 
80106b9e:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106ba5:	e8 64 ff ff ff       	call   80106b0e <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106baa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106bb1:	00 
80106bb2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106bb9:	e8 50 ff ff ff       	call   80106b0e <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106bbe:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106bc5:	e8 1a ff ff ff       	call   80106ae4 <inb>
80106bca:	3c ff                	cmp    $0xff,%al
80106bcc:	74 6c                	je     80106c3a <uartinit+0x10e>
    return;
  uart = 1;
80106bce:	c7 05 4c c6 10 80 01 	movl   $0x1,0x8010c64c
80106bd5:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106bd8:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106bdf:	e8 00 ff ff ff       	call   80106ae4 <inb>
  inb(COM1+0);
80106be4:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106beb:	e8 f4 fe ff ff       	call   80106ae4 <inb>
  picenable(IRQ_COM1);
80106bf0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106bf7:	e8 3d d2 ff ff       	call   80103e39 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106bfc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c03:	00 
80106c04:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106c0b:	e8 72 bd ff ff       	call   80102982 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c10:	c7 45 f4 d4 8f 10 80 	movl   $0x80108fd4,-0xc(%ebp)
80106c17:	eb 15                	jmp    80106c2e <uartinit+0x102>
    uartputc(*p);
80106c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c1c:	0f b6 00             	movzbl (%eax),%eax
80106c1f:	0f be c0             	movsbl %al,%eax
80106c22:	89 04 24             	mov    %eax,(%esp)
80106c25:	e8 13 00 00 00       	call   80106c3d <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106c2a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c31:	0f b6 00             	movzbl (%eax),%eax
80106c34:	84 c0                	test   %al,%al
80106c36:	75 e1                	jne    80106c19 <uartinit+0xed>
80106c38:	eb 01                	jmp    80106c3b <uartinit+0x10f>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106c3a:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106c3b:	c9                   	leave  
80106c3c:	c3                   	ret    

80106c3d <uartputc>:

void
uartputc(int c)
{
80106c3d:	55                   	push   %ebp
80106c3e:	89 e5                	mov    %esp,%ebp
80106c40:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106c43:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80106c48:	85 c0                	test   %eax,%eax
80106c4a:	74 4d                	je     80106c99 <uartputc+0x5c>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c53:	eb 10                	jmp    80106c65 <uartputc+0x28>
    microdelay(10);
80106c55:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106c5c:	e8 e3 c2 ff ff       	call   80102f44 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c61:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c65:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c69:	7f 16                	jg     80106c81 <uartputc+0x44>
80106c6b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106c72:	e8 6d fe ff ff       	call   80106ae4 <inb>
80106c77:	0f b6 c0             	movzbl %al,%eax
80106c7a:	83 e0 20             	and    $0x20,%eax
80106c7d:	85 c0                	test   %eax,%eax
80106c7f:	74 d4                	je     80106c55 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106c81:	8b 45 08             	mov    0x8(%ebp),%eax
80106c84:	0f b6 c0             	movzbl %al,%eax
80106c87:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c8b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106c92:	e8 77 fe ff ff       	call   80106b0e <outb>
80106c97:	eb 01                	jmp    80106c9a <uartputc+0x5d>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106c99:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106c9a:	c9                   	leave  
80106c9b:	c3                   	ret    

80106c9c <uartgetc>:

static int
uartgetc(void)
{
80106c9c:	55                   	push   %ebp
80106c9d:	89 e5                	mov    %esp,%ebp
80106c9f:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106ca2:	a1 4c c6 10 80       	mov    0x8010c64c,%eax
80106ca7:	85 c0                	test   %eax,%eax
80106ca9:	75 07                	jne    80106cb2 <uartgetc+0x16>
    return -1;
80106cab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cb0:	eb 2c                	jmp    80106cde <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106cb2:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106cb9:	e8 26 fe ff ff       	call   80106ae4 <inb>
80106cbe:	0f b6 c0             	movzbl %al,%eax
80106cc1:	83 e0 01             	and    $0x1,%eax
80106cc4:	85 c0                	test   %eax,%eax
80106cc6:	75 07                	jne    80106ccf <uartgetc+0x33>
    return -1;
80106cc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ccd:	eb 0f                	jmp    80106cde <uartgetc+0x42>
  return inb(COM1+0);
80106ccf:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106cd6:	e8 09 fe ff ff       	call   80106ae4 <inb>
80106cdb:	0f b6 c0             	movzbl %al,%eax
}
80106cde:	c9                   	leave  
80106cdf:	c3                   	ret    

80106ce0 <uartintr>:

void
uartintr(void)
{
80106ce0:	55                   	push   %ebp
80106ce1:	89 e5                	mov    %esp,%ebp
80106ce3:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106ce6:	c7 04 24 9c 6c 10 80 	movl   $0x80106c9c,(%esp)
80106ced:	e8 bb 9a ff ff       	call   801007ad <consoleintr>
}
80106cf2:	c9                   	leave  
80106cf3:	c3                   	ret    

80106cf4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106cf4:	6a 00                	push   $0x0
  pushl $0
80106cf6:	6a 00                	push   $0x0
  jmp alltraps
80106cf8:	e9 2b f8 ff ff       	jmp    80106528 <alltraps>

80106cfd <vector1>:
.globl vector1
vector1:
  pushl $0
80106cfd:	6a 00                	push   $0x0
  pushl $1
80106cff:	6a 01                	push   $0x1
  jmp alltraps
80106d01:	e9 22 f8 ff ff       	jmp    80106528 <alltraps>

80106d06 <vector2>:
.globl vector2
vector2:
  pushl $0
80106d06:	6a 00                	push   $0x0
  pushl $2
80106d08:	6a 02                	push   $0x2
  jmp alltraps
80106d0a:	e9 19 f8 ff ff       	jmp    80106528 <alltraps>

80106d0f <vector3>:
.globl vector3
vector3:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $3
80106d11:	6a 03                	push   $0x3
  jmp alltraps
80106d13:	e9 10 f8 ff ff       	jmp    80106528 <alltraps>

80106d18 <vector4>:
.globl vector4
vector4:
  pushl $0
80106d18:	6a 00                	push   $0x0
  pushl $4
80106d1a:	6a 04                	push   $0x4
  jmp alltraps
80106d1c:	e9 07 f8 ff ff       	jmp    80106528 <alltraps>

80106d21 <vector5>:
.globl vector5
vector5:
  pushl $0
80106d21:	6a 00                	push   $0x0
  pushl $5
80106d23:	6a 05                	push   $0x5
  jmp alltraps
80106d25:	e9 fe f7 ff ff       	jmp    80106528 <alltraps>

80106d2a <vector6>:
.globl vector6
vector6:
  pushl $0
80106d2a:	6a 00                	push   $0x0
  pushl $6
80106d2c:	6a 06                	push   $0x6
  jmp alltraps
80106d2e:	e9 f5 f7 ff ff       	jmp    80106528 <alltraps>

80106d33 <vector7>:
.globl vector7
vector7:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $7
80106d35:	6a 07                	push   $0x7
  jmp alltraps
80106d37:	e9 ec f7 ff ff       	jmp    80106528 <alltraps>

80106d3c <vector8>:
.globl vector8
vector8:
  pushl $8
80106d3c:	6a 08                	push   $0x8
  jmp alltraps
80106d3e:	e9 e5 f7 ff ff       	jmp    80106528 <alltraps>

80106d43 <vector9>:
.globl vector9
vector9:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $9
80106d45:	6a 09                	push   $0x9
  jmp alltraps
80106d47:	e9 dc f7 ff ff       	jmp    80106528 <alltraps>

80106d4c <vector10>:
.globl vector10
vector10:
  pushl $10
80106d4c:	6a 0a                	push   $0xa
  jmp alltraps
80106d4e:	e9 d5 f7 ff ff       	jmp    80106528 <alltraps>

80106d53 <vector11>:
.globl vector11
vector11:
  pushl $11
80106d53:	6a 0b                	push   $0xb
  jmp alltraps
80106d55:	e9 ce f7 ff ff       	jmp    80106528 <alltraps>

80106d5a <vector12>:
.globl vector12
vector12:
  pushl $12
80106d5a:	6a 0c                	push   $0xc
  jmp alltraps
80106d5c:	e9 c7 f7 ff ff       	jmp    80106528 <alltraps>

80106d61 <vector13>:
.globl vector13
vector13:
  pushl $13
80106d61:	6a 0d                	push   $0xd
  jmp alltraps
80106d63:	e9 c0 f7 ff ff       	jmp    80106528 <alltraps>

80106d68 <vector14>:
.globl vector14
vector14:
  pushl $14
80106d68:	6a 0e                	push   $0xe
  jmp alltraps
80106d6a:	e9 b9 f7 ff ff       	jmp    80106528 <alltraps>

80106d6f <vector15>:
.globl vector15
vector15:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $15
80106d71:	6a 0f                	push   $0xf
  jmp alltraps
80106d73:	e9 b0 f7 ff ff       	jmp    80106528 <alltraps>

80106d78 <vector16>:
.globl vector16
vector16:
  pushl $0
80106d78:	6a 00                	push   $0x0
  pushl $16
80106d7a:	6a 10                	push   $0x10
  jmp alltraps
80106d7c:	e9 a7 f7 ff ff       	jmp    80106528 <alltraps>

80106d81 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d81:	6a 11                	push   $0x11
  jmp alltraps
80106d83:	e9 a0 f7 ff ff       	jmp    80106528 <alltraps>

80106d88 <vector18>:
.globl vector18
vector18:
  pushl $0
80106d88:	6a 00                	push   $0x0
  pushl $18
80106d8a:	6a 12                	push   $0x12
  jmp alltraps
80106d8c:	e9 97 f7 ff ff       	jmp    80106528 <alltraps>

80106d91 <vector19>:
.globl vector19
vector19:
  pushl $0
80106d91:	6a 00                	push   $0x0
  pushl $19
80106d93:	6a 13                	push   $0x13
  jmp alltraps
80106d95:	e9 8e f7 ff ff       	jmp    80106528 <alltraps>

80106d9a <vector20>:
.globl vector20
vector20:
  pushl $0
80106d9a:	6a 00                	push   $0x0
  pushl $20
80106d9c:	6a 14                	push   $0x14
  jmp alltraps
80106d9e:	e9 85 f7 ff ff       	jmp    80106528 <alltraps>

80106da3 <vector21>:
.globl vector21
vector21:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $21
80106da5:	6a 15                	push   $0x15
  jmp alltraps
80106da7:	e9 7c f7 ff ff       	jmp    80106528 <alltraps>

80106dac <vector22>:
.globl vector22
vector22:
  pushl $0
80106dac:	6a 00                	push   $0x0
  pushl $22
80106dae:	6a 16                	push   $0x16
  jmp alltraps
80106db0:	e9 73 f7 ff ff       	jmp    80106528 <alltraps>

80106db5 <vector23>:
.globl vector23
vector23:
  pushl $0
80106db5:	6a 00                	push   $0x0
  pushl $23
80106db7:	6a 17                	push   $0x17
  jmp alltraps
80106db9:	e9 6a f7 ff ff       	jmp    80106528 <alltraps>

80106dbe <vector24>:
.globl vector24
vector24:
  pushl $0
80106dbe:	6a 00                	push   $0x0
  pushl $24
80106dc0:	6a 18                	push   $0x18
  jmp alltraps
80106dc2:	e9 61 f7 ff ff       	jmp    80106528 <alltraps>

80106dc7 <vector25>:
.globl vector25
vector25:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $25
80106dc9:	6a 19                	push   $0x19
  jmp alltraps
80106dcb:	e9 58 f7 ff ff       	jmp    80106528 <alltraps>

80106dd0 <vector26>:
.globl vector26
vector26:
  pushl $0
80106dd0:	6a 00                	push   $0x0
  pushl $26
80106dd2:	6a 1a                	push   $0x1a
  jmp alltraps
80106dd4:	e9 4f f7 ff ff       	jmp    80106528 <alltraps>

80106dd9 <vector27>:
.globl vector27
vector27:
  pushl $0
80106dd9:	6a 00                	push   $0x0
  pushl $27
80106ddb:	6a 1b                	push   $0x1b
  jmp alltraps
80106ddd:	e9 46 f7 ff ff       	jmp    80106528 <alltraps>

80106de2 <vector28>:
.globl vector28
vector28:
  pushl $0
80106de2:	6a 00                	push   $0x0
  pushl $28
80106de4:	6a 1c                	push   $0x1c
  jmp alltraps
80106de6:	e9 3d f7 ff ff       	jmp    80106528 <alltraps>

80106deb <vector29>:
.globl vector29
vector29:
  pushl $0
80106deb:	6a 00                	push   $0x0
  pushl $29
80106ded:	6a 1d                	push   $0x1d
  jmp alltraps
80106def:	e9 34 f7 ff ff       	jmp    80106528 <alltraps>

80106df4 <vector30>:
.globl vector30
vector30:
  pushl $0
80106df4:	6a 00                	push   $0x0
  pushl $30
80106df6:	6a 1e                	push   $0x1e
  jmp alltraps
80106df8:	e9 2b f7 ff ff       	jmp    80106528 <alltraps>

80106dfd <vector31>:
.globl vector31
vector31:
  pushl $0
80106dfd:	6a 00                	push   $0x0
  pushl $31
80106dff:	6a 1f                	push   $0x1f
  jmp alltraps
80106e01:	e9 22 f7 ff ff       	jmp    80106528 <alltraps>

80106e06 <vector32>:
.globl vector32
vector32:
  pushl $0
80106e06:	6a 00                	push   $0x0
  pushl $32
80106e08:	6a 20                	push   $0x20
  jmp alltraps
80106e0a:	e9 19 f7 ff ff       	jmp    80106528 <alltraps>

80106e0f <vector33>:
.globl vector33
vector33:
  pushl $0
80106e0f:	6a 00                	push   $0x0
  pushl $33
80106e11:	6a 21                	push   $0x21
  jmp alltraps
80106e13:	e9 10 f7 ff ff       	jmp    80106528 <alltraps>

80106e18 <vector34>:
.globl vector34
vector34:
  pushl $0
80106e18:	6a 00                	push   $0x0
  pushl $34
80106e1a:	6a 22                	push   $0x22
  jmp alltraps
80106e1c:	e9 07 f7 ff ff       	jmp    80106528 <alltraps>

80106e21 <vector35>:
.globl vector35
vector35:
  pushl $0
80106e21:	6a 00                	push   $0x0
  pushl $35
80106e23:	6a 23                	push   $0x23
  jmp alltraps
80106e25:	e9 fe f6 ff ff       	jmp    80106528 <alltraps>

80106e2a <vector36>:
.globl vector36
vector36:
  pushl $0
80106e2a:	6a 00                	push   $0x0
  pushl $36
80106e2c:	6a 24                	push   $0x24
  jmp alltraps
80106e2e:	e9 f5 f6 ff ff       	jmp    80106528 <alltraps>

80106e33 <vector37>:
.globl vector37
vector37:
  pushl $0
80106e33:	6a 00                	push   $0x0
  pushl $37
80106e35:	6a 25                	push   $0x25
  jmp alltraps
80106e37:	e9 ec f6 ff ff       	jmp    80106528 <alltraps>

80106e3c <vector38>:
.globl vector38
vector38:
  pushl $0
80106e3c:	6a 00                	push   $0x0
  pushl $38
80106e3e:	6a 26                	push   $0x26
  jmp alltraps
80106e40:	e9 e3 f6 ff ff       	jmp    80106528 <alltraps>

80106e45 <vector39>:
.globl vector39
vector39:
  pushl $0
80106e45:	6a 00                	push   $0x0
  pushl $39
80106e47:	6a 27                	push   $0x27
  jmp alltraps
80106e49:	e9 da f6 ff ff       	jmp    80106528 <alltraps>

80106e4e <vector40>:
.globl vector40
vector40:
  pushl $0
80106e4e:	6a 00                	push   $0x0
  pushl $40
80106e50:	6a 28                	push   $0x28
  jmp alltraps
80106e52:	e9 d1 f6 ff ff       	jmp    80106528 <alltraps>

80106e57 <vector41>:
.globl vector41
vector41:
  pushl $0
80106e57:	6a 00                	push   $0x0
  pushl $41
80106e59:	6a 29                	push   $0x29
  jmp alltraps
80106e5b:	e9 c8 f6 ff ff       	jmp    80106528 <alltraps>

80106e60 <vector42>:
.globl vector42
vector42:
  pushl $0
80106e60:	6a 00                	push   $0x0
  pushl $42
80106e62:	6a 2a                	push   $0x2a
  jmp alltraps
80106e64:	e9 bf f6 ff ff       	jmp    80106528 <alltraps>

80106e69 <vector43>:
.globl vector43
vector43:
  pushl $0
80106e69:	6a 00                	push   $0x0
  pushl $43
80106e6b:	6a 2b                	push   $0x2b
  jmp alltraps
80106e6d:	e9 b6 f6 ff ff       	jmp    80106528 <alltraps>

80106e72 <vector44>:
.globl vector44
vector44:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $44
80106e74:	6a 2c                	push   $0x2c
  jmp alltraps
80106e76:	e9 ad f6 ff ff       	jmp    80106528 <alltraps>

80106e7b <vector45>:
.globl vector45
vector45:
  pushl $0
80106e7b:	6a 00                	push   $0x0
  pushl $45
80106e7d:	6a 2d                	push   $0x2d
  jmp alltraps
80106e7f:	e9 a4 f6 ff ff       	jmp    80106528 <alltraps>

80106e84 <vector46>:
.globl vector46
vector46:
  pushl $0
80106e84:	6a 00                	push   $0x0
  pushl $46
80106e86:	6a 2e                	push   $0x2e
  jmp alltraps
80106e88:	e9 9b f6 ff ff       	jmp    80106528 <alltraps>

80106e8d <vector47>:
.globl vector47
vector47:
  pushl $0
80106e8d:	6a 00                	push   $0x0
  pushl $47
80106e8f:	6a 2f                	push   $0x2f
  jmp alltraps
80106e91:	e9 92 f6 ff ff       	jmp    80106528 <alltraps>

80106e96 <vector48>:
.globl vector48
vector48:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $48
80106e98:	6a 30                	push   $0x30
  jmp alltraps
80106e9a:	e9 89 f6 ff ff       	jmp    80106528 <alltraps>

80106e9f <vector49>:
.globl vector49
vector49:
  pushl $0
80106e9f:	6a 00                	push   $0x0
  pushl $49
80106ea1:	6a 31                	push   $0x31
  jmp alltraps
80106ea3:	e9 80 f6 ff ff       	jmp    80106528 <alltraps>

80106ea8 <vector50>:
.globl vector50
vector50:
  pushl $0
80106ea8:	6a 00                	push   $0x0
  pushl $50
80106eaa:	6a 32                	push   $0x32
  jmp alltraps
80106eac:	e9 77 f6 ff ff       	jmp    80106528 <alltraps>

80106eb1 <vector51>:
.globl vector51
vector51:
  pushl $0
80106eb1:	6a 00                	push   $0x0
  pushl $51
80106eb3:	6a 33                	push   $0x33
  jmp alltraps
80106eb5:	e9 6e f6 ff ff       	jmp    80106528 <alltraps>

80106eba <vector52>:
.globl vector52
vector52:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $52
80106ebc:	6a 34                	push   $0x34
  jmp alltraps
80106ebe:	e9 65 f6 ff ff       	jmp    80106528 <alltraps>

80106ec3 <vector53>:
.globl vector53
vector53:
  pushl $0
80106ec3:	6a 00                	push   $0x0
  pushl $53
80106ec5:	6a 35                	push   $0x35
  jmp alltraps
80106ec7:	e9 5c f6 ff ff       	jmp    80106528 <alltraps>

80106ecc <vector54>:
.globl vector54
vector54:
  pushl $0
80106ecc:	6a 00                	push   $0x0
  pushl $54
80106ece:	6a 36                	push   $0x36
  jmp alltraps
80106ed0:	e9 53 f6 ff ff       	jmp    80106528 <alltraps>

80106ed5 <vector55>:
.globl vector55
vector55:
  pushl $0
80106ed5:	6a 00                	push   $0x0
  pushl $55
80106ed7:	6a 37                	push   $0x37
  jmp alltraps
80106ed9:	e9 4a f6 ff ff       	jmp    80106528 <alltraps>

80106ede <vector56>:
.globl vector56
vector56:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $56
80106ee0:	6a 38                	push   $0x38
  jmp alltraps
80106ee2:	e9 41 f6 ff ff       	jmp    80106528 <alltraps>

80106ee7 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ee7:	6a 00                	push   $0x0
  pushl $57
80106ee9:	6a 39                	push   $0x39
  jmp alltraps
80106eeb:	e9 38 f6 ff ff       	jmp    80106528 <alltraps>

80106ef0 <vector58>:
.globl vector58
vector58:
  pushl $0
80106ef0:	6a 00                	push   $0x0
  pushl $58
80106ef2:	6a 3a                	push   $0x3a
  jmp alltraps
80106ef4:	e9 2f f6 ff ff       	jmp    80106528 <alltraps>

80106ef9 <vector59>:
.globl vector59
vector59:
  pushl $0
80106ef9:	6a 00                	push   $0x0
  pushl $59
80106efb:	6a 3b                	push   $0x3b
  jmp alltraps
80106efd:	e9 26 f6 ff ff       	jmp    80106528 <alltraps>

80106f02 <vector60>:
.globl vector60
vector60:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $60
80106f04:	6a 3c                	push   $0x3c
  jmp alltraps
80106f06:	e9 1d f6 ff ff       	jmp    80106528 <alltraps>

80106f0b <vector61>:
.globl vector61
vector61:
  pushl $0
80106f0b:	6a 00                	push   $0x0
  pushl $61
80106f0d:	6a 3d                	push   $0x3d
  jmp alltraps
80106f0f:	e9 14 f6 ff ff       	jmp    80106528 <alltraps>

80106f14 <vector62>:
.globl vector62
vector62:
  pushl $0
80106f14:	6a 00                	push   $0x0
  pushl $62
80106f16:	6a 3e                	push   $0x3e
  jmp alltraps
80106f18:	e9 0b f6 ff ff       	jmp    80106528 <alltraps>

80106f1d <vector63>:
.globl vector63
vector63:
  pushl $0
80106f1d:	6a 00                	push   $0x0
  pushl $63
80106f1f:	6a 3f                	push   $0x3f
  jmp alltraps
80106f21:	e9 02 f6 ff ff       	jmp    80106528 <alltraps>

80106f26 <vector64>:
.globl vector64
vector64:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $64
80106f28:	6a 40                	push   $0x40
  jmp alltraps
80106f2a:	e9 f9 f5 ff ff       	jmp    80106528 <alltraps>

80106f2f <vector65>:
.globl vector65
vector65:
  pushl $0
80106f2f:	6a 00                	push   $0x0
  pushl $65
80106f31:	6a 41                	push   $0x41
  jmp alltraps
80106f33:	e9 f0 f5 ff ff       	jmp    80106528 <alltraps>

80106f38 <vector66>:
.globl vector66
vector66:
  pushl $0
80106f38:	6a 00                	push   $0x0
  pushl $66
80106f3a:	6a 42                	push   $0x42
  jmp alltraps
80106f3c:	e9 e7 f5 ff ff       	jmp    80106528 <alltraps>

80106f41 <vector67>:
.globl vector67
vector67:
  pushl $0
80106f41:	6a 00                	push   $0x0
  pushl $67
80106f43:	6a 43                	push   $0x43
  jmp alltraps
80106f45:	e9 de f5 ff ff       	jmp    80106528 <alltraps>

80106f4a <vector68>:
.globl vector68
vector68:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $68
80106f4c:	6a 44                	push   $0x44
  jmp alltraps
80106f4e:	e9 d5 f5 ff ff       	jmp    80106528 <alltraps>

80106f53 <vector69>:
.globl vector69
vector69:
  pushl $0
80106f53:	6a 00                	push   $0x0
  pushl $69
80106f55:	6a 45                	push   $0x45
  jmp alltraps
80106f57:	e9 cc f5 ff ff       	jmp    80106528 <alltraps>

80106f5c <vector70>:
.globl vector70
vector70:
  pushl $0
80106f5c:	6a 00                	push   $0x0
  pushl $70
80106f5e:	6a 46                	push   $0x46
  jmp alltraps
80106f60:	e9 c3 f5 ff ff       	jmp    80106528 <alltraps>

80106f65 <vector71>:
.globl vector71
vector71:
  pushl $0
80106f65:	6a 00                	push   $0x0
  pushl $71
80106f67:	6a 47                	push   $0x47
  jmp alltraps
80106f69:	e9 ba f5 ff ff       	jmp    80106528 <alltraps>

80106f6e <vector72>:
.globl vector72
vector72:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $72
80106f70:	6a 48                	push   $0x48
  jmp alltraps
80106f72:	e9 b1 f5 ff ff       	jmp    80106528 <alltraps>

80106f77 <vector73>:
.globl vector73
vector73:
  pushl $0
80106f77:	6a 00                	push   $0x0
  pushl $73
80106f79:	6a 49                	push   $0x49
  jmp alltraps
80106f7b:	e9 a8 f5 ff ff       	jmp    80106528 <alltraps>

80106f80 <vector74>:
.globl vector74
vector74:
  pushl $0
80106f80:	6a 00                	push   $0x0
  pushl $74
80106f82:	6a 4a                	push   $0x4a
  jmp alltraps
80106f84:	e9 9f f5 ff ff       	jmp    80106528 <alltraps>

80106f89 <vector75>:
.globl vector75
vector75:
  pushl $0
80106f89:	6a 00                	push   $0x0
  pushl $75
80106f8b:	6a 4b                	push   $0x4b
  jmp alltraps
80106f8d:	e9 96 f5 ff ff       	jmp    80106528 <alltraps>

80106f92 <vector76>:
.globl vector76
vector76:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $76
80106f94:	6a 4c                	push   $0x4c
  jmp alltraps
80106f96:	e9 8d f5 ff ff       	jmp    80106528 <alltraps>

80106f9b <vector77>:
.globl vector77
vector77:
  pushl $0
80106f9b:	6a 00                	push   $0x0
  pushl $77
80106f9d:	6a 4d                	push   $0x4d
  jmp alltraps
80106f9f:	e9 84 f5 ff ff       	jmp    80106528 <alltraps>

80106fa4 <vector78>:
.globl vector78
vector78:
  pushl $0
80106fa4:	6a 00                	push   $0x0
  pushl $78
80106fa6:	6a 4e                	push   $0x4e
  jmp alltraps
80106fa8:	e9 7b f5 ff ff       	jmp    80106528 <alltraps>

80106fad <vector79>:
.globl vector79
vector79:
  pushl $0
80106fad:	6a 00                	push   $0x0
  pushl $79
80106faf:	6a 4f                	push   $0x4f
  jmp alltraps
80106fb1:	e9 72 f5 ff ff       	jmp    80106528 <alltraps>

80106fb6 <vector80>:
.globl vector80
vector80:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $80
80106fb8:	6a 50                	push   $0x50
  jmp alltraps
80106fba:	e9 69 f5 ff ff       	jmp    80106528 <alltraps>

80106fbf <vector81>:
.globl vector81
vector81:
  pushl $0
80106fbf:	6a 00                	push   $0x0
  pushl $81
80106fc1:	6a 51                	push   $0x51
  jmp alltraps
80106fc3:	e9 60 f5 ff ff       	jmp    80106528 <alltraps>

80106fc8 <vector82>:
.globl vector82
vector82:
  pushl $0
80106fc8:	6a 00                	push   $0x0
  pushl $82
80106fca:	6a 52                	push   $0x52
  jmp alltraps
80106fcc:	e9 57 f5 ff ff       	jmp    80106528 <alltraps>

80106fd1 <vector83>:
.globl vector83
vector83:
  pushl $0
80106fd1:	6a 00                	push   $0x0
  pushl $83
80106fd3:	6a 53                	push   $0x53
  jmp alltraps
80106fd5:	e9 4e f5 ff ff       	jmp    80106528 <alltraps>

80106fda <vector84>:
.globl vector84
vector84:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $84
80106fdc:	6a 54                	push   $0x54
  jmp alltraps
80106fde:	e9 45 f5 ff ff       	jmp    80106528 <alltraps>

80106fe3 <vector85>:
.globl vector85
vector85:
  pushl $0
80106fe3:	6a 00                	push   $0x0
  pushl $85
80106fe5:	6a 55                	push   $0x55
  jmp alltraps
80106fe7:	e9 3c f5 ff ff       	jmp    80106528 <alltraps>

80106fec <vector86>:
.globl vector86
vector86:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $86
80106fee:	6a 56                	push   $0x56
  jmp alltraps
80106ff0:	e9 33 f5 ff ff       	jmp    80106528 <alltraps>

80106ff5 <vector87>:
.globl vector87
vector87:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $87
80106ff7:	6a 57                	push   $0x57
  jmp alltraps
80106ff9:	e9 2a f5 ff ff       	jmp    80106528 <alltraps>

80106ffe <vector88>:
.globl vector88
vector88:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $88
80107000:	6a 58                	push   $0x58
  jmp alltraps
80107002:	e9 21 f5 ff ff       	jmp    80106528 <alltraps>

80107007 <vector89>:
.globl vector89
vector89:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $89
80107009:	6a 59                	push   $0x59
  jmp alltraps
8010700b:	e9 18 f5 ff ff       	jmp    80106528 <alltraps>

80107010 <vector90>:
.globl vector90
vector90:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $90
80107012:	6a 5a                	push   $0x5a
  jmp alltraps
80107014:	e9 0f f5 ff ff       	jmp    80106528 <alltraps>

80107019 <vector91>:
.globl vector91
vector91:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $91
8010701b:	6a 5b                	push   $0x5b
  jmp alltraps
8010701d:	e9 06 f5 ff ff       	jmp    80106528 <alltraps>

80107022 <vector92>:
.globl vector92
vector92:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $92
80107024:	6a 5c                	push   $0x5c
  jmp alltraps
80107026:	e9 fd f4 ff ff       	jmp    80106528 <alltraps>

8010702b <vector93>:
.globl vector93
vector93:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $93
8010702d:	6a 5d                	push   $0x5d
  jmp alltraps
8010702f:	e9 f4 f4 ff ff       	jmp    80106528 <alltraps>

80107034 <vector94>:
.globl vector94
vector94:
  pushl $0
80107034:	6a 00                	push   $0x0
  pushl $94
80107036:	6a 5e                	push   $0x5e
  jmp alltraps
80107038:	e9 eb f4 ff ff       	jmp    80106528 <alltraps>

8010703d <vector95>:
.globl vector95
vector95:
  pushl $0
8010703d:	6a 00                	push   $0x0
  pushl $95
8010703f:	6a 5f                	push   $0x5f
  jmp alltraps
80107041:	e9 e2 f4 ff ff       	jmp    80106528 <alltraps>

80107046 <vector96>:
.globl vector96
vector96:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $96
80107048:	6a 60                	push   $0x60
  jmp alltraps
8010704a:	e9 d9 f4 ff ff       	jmp    80106528 <alltraps>

8010704f <vector97>:
.globl vector97
vector97:
  pushl $0
8010704f:	6a 00                	push   $0x0
  pushl $97
80107051:	6a 61                	push   $0x61
  jmp alltraps
80107053:	e9 d0 f4 ff ff       	jmp    80106528 <alltraps>

80107058 <vector98>:
.globl vector98
vector98:
  pushl $0
80107058:	6a 00                	push   $0x0
  pushl $98
8010705a:	6a 62                	push   $0x62
  jmp alltraps
8010705c:	e9 c7 f4 ff ff       	jmp    80106528 <alltraps>

80107061 <vector99>:
.globl vector99
vector99:
  pushl $0
80107061:	6a 00                	push   $0x0
  pushl $99
80107063:	6a 63                	push   $0x63
  jmp alltraps
80107065:	e9 be f4 ff ff       	jmp    80106528 <alltraps>

8010706a <vector100>:
.globl vector100
vector100:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $100
8010706c:	6a 64                	push   $0x64
  jmp alltraps
8010706e:	e9 b5 f4 ff ff       	jmp    80106528 <alltraps>

80107073 <vector101>:
.globl vector101
vector101:
  pushl $0
80107073:	6a 00                	push   $0x0
  pushl $101
80107075:	6a 65                	push   $0x65
  jmp alltraps
80107077:	e9 ac f4 ff ff       	jmp    80106528 <alltraps>

8010707c <vector102>:
.globl vector102
vector102:
  pushl $0
8010707c:	6a 00                	push   $0x0
  pushl $102
8010707e:	6a 66                	push   $0x66
  jmp alltraps
80107080:	e9 a3 f4 ff ff       	jmp    80106528 <alltraps>

80107085 <vector103>:
.globl vector103
vector103:
  pushl $0
80107085:	6a 00                	push   $0x0
  pushl $103
80107087:	6a 67                	push   $0x67
  jmp alltraps
80107089:	e9 9a f4 ff ff       	jmp    80106528 <alltraps>

8010708e <vector104>:
.globl vector104
vector104:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $104
80107090:	6a 68                	push   $0x68
  jmp alltraps
80107092:	e9 91 f4 ff ff       	jmp    80106528 <alltraps>

80107097 <vector105>:
.globl vector105
vector105:
  pushl $0
80107097:	6a 00                	push   $0x0
  pushl $105
80107099:	6a 69                	push   $0x69
  jmp alltraps
8010709b:	e9 88 f4 ff ff       	jmp    80106528 <alltraps>

801070a0 <vector106>:
.globl vector106
vector106:
  pushl $0
801070a0:	6a 00                	push   $0x0
  pushl $106
801070a2:	6a 6a                	push   $0x6a
  jmp alltraps
801070a4:	e9 7f f4 ff ff       	jmp    80106528 <alltraps>

801070a9 <vector107>:
.globl vector107
vector107:
  pushl $0
801070a9:	6a 00                	push   $0x0
  pushl $107
801070ab:	6a 6b                	push   $0x6b
  jmp alltraps
801070ad:	e9 76 f4 ff ff       	jmp    80106528 <alltraps>

801070b2 <vector108>:
.globl vector108
vector108:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $108
801070b4:	6a 6c                	push   $0x6c
  jmp alltraps
801070b6:	e9 6d f4 ff ff       	jmp    80106528 <alltraps>

801070bb <vector109>:
.globl vector109
vector109:
  pushl $0
801070bb:	6a 00                	push   $0x0
  pushl $109
801070bd:	6a 6d                	push   $0x6d
  jmp alltraps
801070bf:	e9 64 f4 ff ff       	jmp    80106528 <alltraps>

801070c4 <vector110>:
.globl vector110
vector110:
  pushl $0
801070c4:	6a 00                	push   $0x0
  pushl $110
801070c6:	6a 6e                	push   $0x6e
  jmp alltraps
801070c8:	e9 5b f4 ff ff       	jmp    80106528 <alltraps>

801070cd <vector111>:
.globl vector111
vector111:
  pushl $0
801070cd:	6a 00                	push   $0x0
  pushl $111
801070cf:	6a 6f                	push   $0x6f
  jmp alltraps
801070d1:	e9 52 f4 ff ff       	jmp    80106528 <alltraps>

801070d6 <vector112>:
.globl vector112
vector112:
  pushl $0
801070d6:	6a 00                	push   $0x0
  pushl $112
801070d8:	6a 70                	push   $0x70
  jmp alltraps
801070da:	e9 49 f4 ff ff       	jmp    80106528 <alltraps>

801070df <vector113>:
.globl vector113
vector113:
  pushl $0
801070df:	6a 00                	push   $0x0
  pushl $113
801070e1:	6a 71                	push   $0x71
  jmp alltraps
801070e3:	e9 40 f4 ff ff       	jmp    80106528 <alltraps>

801070e8 <vector114>:
.globl vector114
vector114:
  pushl $0
801070e8:	6a 00                	push   $0x0
  pushl $114
801070ea:	6a 72                	push   $0x72
  jmp alltraps
801070ec:	e9 37 f4 ff ff       	jmp    80106528 <alltraps>

801070f1 <vector115>:
.globl vector115
vector115:
  pushl $0
801070f1:	6a 00                	push   $0x0
  pushl $115
801070f3:	6a 73                	push   $0x73
  jmp alltraps
801070f5:	e9 2e f4 ff ff       	jmp    80106528 <alltraps>

801070fa <vector116>:
.globl vector116
vector116:
  pushl $0
801070fa:	6a 00                	push   $0x0
  pushl $116
801070fc:	6a 74                	push   $0x74
  jmp alltraps
801070fe:	e9 25 f4 ff ff       	jmp    80106528 <alltraps>

80107103 <vector117>:
.globl vector117
vector117:
  pushl $0
80107103:	6a 00                	push   $0x0
  pushl $117
80107105:	6a 75                	push   $0x75
  jmp alltraps
80107107:	e9 1c f4 ff ff       	jmp    80106528 <alltraps>

8010710c <vector118>:
.globl vector118
vector118:
  pushl $0
8010710c:	6a 00                	push   $0x0
  pushl $118
8010710e:	6a 76                	push   $0x76
  jmp alltraps
80107110:	e9 13 f4 ff ff       	jmp    80106528 <alltraps>

80107115 <vector119>:
.globl vector119
vector119:
  pushl $0
80107115:	6a 00                	push   $0x0
  pushl $119
80107117:	6a 77                	push   $0x77
  jmp alltraps
80107119:	e9 0a f4 ff ff       	jmp    80106528 <alltraps>

8010711e <vector120>:
.globl vector120
vector120:
  pushl $0
8010711e:	6a 00                	push   $0x0
  pushl $120
80107120:	6a 78                	push   $0x78
  jmp alltraps
80107122:	e9 01 f4 ff ff       	jmp    80106528 <alltraps>

80107127 <vector121>:
.globl vector121
vector121:
  pushl $0
80107127:	6a 00                	push   $0x0
  pushl $121
80107129:	6a 79                	push   $0x79
  jmp alltraps
8010712b:	e9 f8 f3 ff ff       	jmp    80106528 <alltraps>

80107130 <vector122>:
.globl vector122
vector122:
  pushl $0
80107130:	6a 00                	push   $0x0
  pushl $122
80107132:	6a 7a                	push   $0x7a
  jmp alltraps
80107134:	e9 ef f3 ff ff       	jmp    80106528 <alltraps>

80107139 <vector123>:
.globl vector123
vector123:
  pushl $0
80107139:	6a 00                	push   $0x0
  pushl $123
8010713b:	6a 7b                	push   $0x7b
  jmp alltraps
8010713d:	e9 e6 f3 ff ff       	jmp    80106528 <alltraps>

80107142 <vector124>:
.globl vector124
vector124:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $124
80107144:	6a 7c                	push   $0x7c
  jmp alltraps
80107146:	e9 dd f3 ff ff       	jmp    80106528 <alltraps>

8010714b <vector125>:
.globl vector125
vector125:
  pushl $0
8010714b:	6a 00                	push   $0x0
  pushl $125
8010714d:	6a 7d                	push   $0x7d
  jmp alltraps
8010714f:	e9 d4 f3 ff ff       	jmp    80106528 <alltraps>

80107154 <vector126>:
.globl vector126
vector126:
  pushl $0
80107154:	6a 00                	push   $0x0
  pushl $126
80107156:	6a 7e                	push   $0x7e
  jmp alltraps
80107158:	e9 cb f3 ff ff       	jmp    80106528 <alltraps>

8010715d <vector127>:
.globl vector127
vector127:
  pushl $0
8010715d:	6a 00                	push   $0x0
  pushl $127
8010715f:	6a 7f                	push   $0x7f
  jmp alltraps
80107161:	e9 c2 f3 ff ff       	jmp    80106528 <alltraps>

80107166 <vector128>:
.globl vector128
vector128:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $128
80107168:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010716d:	e9 b6 f3 ff ff       	jmp    80106528 <alltraps>

80107172 <vector129>:
.globl vector129
vector129:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $129
80107174:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107179:	e9 aa f3 ff ff       	jmp    80106528 <alltraps>

8010717e <vector130>:
.globl vector130
vector130:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $130
80107180:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107185:	e9 9e f3 ff ff       	jmp    80106528 <alltraps>

8010718a <vector131>:
.globl vector131
vector131:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $131
8010718c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107191:	e9 92 f3 ff ff       	jmp    80106528 <alltraps>

80107196 <vector132>:
.globl vector132
vector132:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $132
80107198:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010719d:	e9 86 f3 ff ff       	jmp    80106528 <alltraps>

801071a2 <vector133>:
.globl vector133
vector133:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $133
801071a4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801071a9:	e9 7a f3 ff ff       	jmp    80106528 <alltraps>

801071ae <vector134>:
.globl vector134
vector134:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $134
801071b0:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801071b5:	e9 6e f3 ff ff       	jmp    80106528 <alltraps>

801071ba <vector135>:
.globl vector135
vector135:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $135
801071bc:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801071c1:	e9 62 f3 ff ff       	jmp    80106528 <alltraps>

801071c6 <vector136>:
.globl vector136
vector136:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $136
801071c8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801071cd:	e9 56 f3 ff ff       	jmp    80106528 <alltraps>

801071d2 <vector137>:
.globl vector137
vector137:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $137
801071d4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801071d9:	e9 4a f3 ff ff       	jmp    80106528 <alltraps>

801071de <vector138>:
.globl vector138
vector138:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $138
801071e0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801071e5:	e9 3e f3 ff ff       	jmp    80106528 <alltraps>

801071ea <vector139>:
.globl vector139
vector139:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $139
801071ec:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801071f1:	e9 32 f3 ff ff       	jmp    80106528 <alltraps>

801071f6 <vector140>:
.globl vector140
vector140:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $140
801071f8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801071fd:	e9 26 f3 ff ff       	jmp    80106528 <alltraps>

80107202 <vector141>:
.globl vector141
vector141:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $141
80107204:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107209:	e9 1a f3 ff ff       	jmp    80106528 <alltraps>

8010720e <vector142>:
.globl vector142
vector142:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $142
80107210:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107215:	e9 0e f3 ff ff       	jmp    80106528 <alltraps>

8010721a <vector143>:
.globl vector143
vector143:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $143
8010721c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107221:	e9 02 f3 ff ff       	jmp    80106528 <alltraps>

80107226 <vector144>:
.globl vector144
vector144:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $144
80107228:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010722d:	e9 f6 f2 ff ff       	jmp    80106528 <alltraps>

80107232 <vector145>:
.globl vector145
vector145:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $145
80107234:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107239:	e9 ea f2 ff ff       	jmp    80106528 <alltraps>

8010723e <vector146>:
.globl vector146
vector146:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $146
80107240:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107245:	e9 de f2 ff ff       	jmp    80106528 <alltraps>

8010724a <vector147>:
.globl vector147
vector147:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $147
8010724c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107251:	e9 d2 f2 ff ff       	jmp    80106528 <alltraps>

80107256 <vector148>:
.globl vector148
vector148:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $148
80107258:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010725d:	e9 c6 f2 ff ff       	jmp    80106528 <alltraps>

80107262 <vector149>:
.globl vector149
vector149:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $149
80107264:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107269:	e9 ba f2 ff ff       	jmp    80106528 <alltraps>

8010726e <vector150>:
.globl vector150
vector150:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $150
80107270:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107275:	e9 ae f2 ff ff       	jmp    80106528 <alltraps>

8010727a <vector151>:
.globl vector151
vector151:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $151
8010727c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107281:	e9 a2 f2 ff ff       	jmp    80106528 <alltraps>

80107286 <vector152>:
.globl vector152
vector152:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $152
80107288:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010728d:	e9 96 f2 ff ff       	jmp    80106528 <alltraps>

80107292 <vector153>:
.globl vector153
vector153:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $153
80107294:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107299:	e9 8a f2 ff ff       	jmp    80106528 <alltraps>

8010729e <vector154>:
.globl vector154
vector154:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $154
801072a0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801072a5:	e9 7e f2 ff ff       	jmp    80106528 <alltraps>

801072aa <vector155>:
.globl vector155
vector155:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $155
801072ac:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801072b1:	e9 72 f2 ff ff       	jmp    80106528 <alltraps>

801072b6 <vector156>:
.globl vector156
vector156:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $156
801072b8:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801072bd:	e9 66 f2 ff ff       	jmp    80106528 <alltraps>

801072c2 <vector157>:
.globl vector157
vector157:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $157
801072c4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801072c9:	e9 5a f2 ff ff       	jmp    80106528 <alltraps>

801072ce <vector158>:
.globl vector158
vector158:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $158
801072d0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801072d5:	e9 4e f2 ff ff       	jmp    80106528 <alltraps>

801072da <vector159>:
.globl vector159
vector159:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $159
801072dc:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801072e1:	e9 42 f2 ff ff       	jmp    80106528 <alltraps>

801072e6 <vector160>:
.globl vector160
vector160:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $160
801072e8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801072ed:	e9 36 f2 ff ff       	jmp    80106528 <alltraps>

801072f2 <vector161>:
.globl vector161
vector161:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $161
801072f4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801072f9:	e9 2a f2 ff ff       	jmp    80106528 <alltraps>

801072fe <vector162>:
.globl vector162
vector162:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $162
80107300:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107305:	e9 1e f2 ff ff       	jmp    80106528 <alltraps>

8010730a <vector163>:
.globl vector163
vector163:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $163
8010730c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107311:	e9 12 f2 ff ff       	jmp    80106528 <alltraps>

80107316 <vector164>:
.globl vector164
vector164:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $164
80107318:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010731d:	e9 06 f2 ff ff       	jmp    80106528 <alltraps>

80107322 <vector165>:
.globl vector165
vector165:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $165
80107324:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107329:	e9 fa f1 ff ff       	jmp    80106528 <alltraps>

8010732e <vector166>:
.globl vector166
vector166:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $166
80107330:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107335:	e9 ee f1 ff ff       	jmp    80106528 <alltraps>

8010733a <vector167>:
.globl vector167
vector167:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $167
8010733c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107341:	e9 e2 f1 ff ff       	jmp    80106528 <alltraps>

80107346 <vector168>:
.globl vector168
vector168:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $168
80107348:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010734d:	e9 d6 f1 ff ff       	jmp    80106528 <alltraps>

80107352 <vector169>:
.globl vector169
vector169:
  pushl $0
80107352:	6a 00                	push   $0x0
  pushl $169
80107354:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107359:	e9 ca f1 ff ff       	jmp    80106528 <alltraps>

8010735e <vector170>:
.globl vector170
vector170:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $170
80107360:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107365:	e9 be f1 ff ff       	jmp    80106528 <alltraps>

8010736a <vector171>:
.globl vector171
vector171:
  pushl $0
8010736a:	6a 00                	push   $0x0
  pushl $171
8010736c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107371:	e9 b2 f1 ff ff       	jmp    80106528 <alltraps>

80107376 <vector172>:
.globl vector172
vector172:
  pushl $0
80107376:	6a 00                	push   $0x0
  pushl $172
80107378:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010737d:	e9 a6 f1 ff ff       	jmp    80106528 <alltraps>

80107382 <vector173>:
.globl vector173
vector173:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $173
80107384:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107389:	e9 9a f1 ff ff       	jmp    80106528 <alltraps>

8010738e <vector174>:
.globl vector174
vector174:
  pushl $0
8010738e:	6a 00                	push   $0x0
  pushl $174
80107390:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107395:	e9 8e f1 ff ff       	jmp    80106528 <alltraps>

8010739a <vector175>:
.globl vector175
vector175:
  pushl $0
8010739a:	6a 00                	push   $0x0
  pushl $175
8010739c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801073a1:	e9 82 f1 ff ff       	jmp    80106528 <alltraps>

801073a6 <vector176>:
.globl vector176
vector176:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $176
801073a8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801073ad:	e9 76 f1 ff ff       	jmp    80106528 <alltraps>

801073b2 <vector177>:
.globl vector177
vector177:
  pushl $0
801073b2:	6a 00                	push   $0x0
  pushl $177
801073b4:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801073b9:	e9 6a f1 ff ff       	jmp    80106528 <alltraps>

801073be <vector178>:
.globl vector178
vector178:
  pushl $0
801073be:	6a 00                	push   $0x0
  pushl $178
801073c0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801073c5:	e9 5e f1 ff ff       	jmp    80106528 <alltraps>

801073ca <vector179>:
.globl vector179
vector179:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $179
801073cc:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801073d1:	e9 52 f1 ff ff       	jmp    80106528 <alltraps>

801073d6 <vector180>:
.globl vector180
vector180:
  pushl $0
801073d6:	6a 00                	push   $0x0
  pushl $180
801073d8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801073dd:	e9 46 f1 ff ff       	jmp    80106528 <alltraps>

801073e2 <vector181>:
.globl vector181
vector181:
  pushl $0
801073e2:	6a 00                	push   $0x0
  pushl $181
801073e4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801073e9:	e9 3a f1 ff ff       	jmp    80106528 <alltraps>

801073ee <vector182>:
.globl vector182
vector182:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $182
801073f0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801073f5:	e9 2e f1 ff ff       	jmp    80106528 <alltraps>

801073fa <vector183>:
.globl vector183
vector183:
  pushl $0
801073fa:	6a 00                	push   $0x0
  pushl $183
801073fc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107401:	e9 22 f1 ff ff       	jmp    80106528 <alltraps>

80107406 <vector184>:
.globl vector184
vector184:
  pushl $0
80107406:	6a 00                	push   $0x0
  pushl $184
80107408:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010740d:	e9 16 f1 ff ff       	jmp    80106528 <alltraps>

80107412 <vector185>:
.globl vector185
vector185:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $185
80107414:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107419:	e9 0a f1 ff ff       	jmp    80106528 <alltraps>

8010741e <vector186>:
.globl vector186
vector186:
  pushl $0
8010741e:	6a 00                	push   $0x0
  pushl $186
80107420:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107425:	e9 fe f0 ff ff       	jmp    80106528 <alltraps>

8010742a <vector187>:
.globl vector187
vector187:
  pushl $0
8010742a:	6a 00                	push   $0x0
  pushl $187
8010742c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107431:	e9 f2 f0 ff ff       	jmp    80106528 <alltraps>

80107436 <vector188>:
.globl vector188
vector188:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $188
80107438:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010743d:	e9 e6 f0 ff ff       	jmp    80106528 <alltraps>

80107442 <vector189>:
.globl vector189
vector189:
  pushl $0
80107442:	6a 00                	push   $0x0
  pushl $189
80107444:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107449:	e9 da f0 ff ff       	jmp    80106528 <alltraps>

8010744e <vector190>:
.globl vector190
vector190:
  pushl $0
8010744e:	6a 00                	push   $0x0
  pushl $190
80107450:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107455:	e9 ce f0 ff ff       	jmp    80106528 <alltraps>

8010745a <vector191>:
.globl vector191
vector191:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $191
8010745c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107461:	e9 c2 f0 ff ff       	jmp    80106528 <alltraps>

80107466 <vector192>:
.globl vector192
vector192:
  pushl $0
80107466:	6a 00                	push   $0x0
  pushl $192
80107468:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010746d:	e9 b6 f0 ff ff       	jmp    80106528 <alltraps>

80107472 <vector193>:
.globl vector193
vector193:
  pushl $0
80107472:	6a 00                	push   $0x0
  pushl $193
80107474:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107479:	e9 aa f0 ff ff       	jmp    80106528 <alltraps>

8010747e <vector194>:
.globl vector194
vector194:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $194
80107480:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107485:	e9 9e f0 ff ff       	jmp    80106528 <alltraps>

8010748a <vector195>:
.globl vector195
vector195:
  pushl $0
8010748a:	6a 00                	push   $0x0
  pushl $195
8010748c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107491:	e9 92 f0 ff ff       	jmp    80106528 <alltraps>

80107496 <vector196>:
.globl vector196
vector196:
  pushl $0
80107496:	6a 00                	push   $0x0
  pushl $196
80107498:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010749d:	e9 86 f0 ff ff       	jmp    80106528 <alltraps>

801074a2 <vector197>:
.globl vector197
vector197:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $197
801074a4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801074a9:	e9 7a f0 ff ff       	jmp    80106528 <alltraps>

801074ae <vector198>:
.globl vector198
vector198:
  pushl $0
801074ae:	6a 00                	push   $0x0
  pushl $198
801074b0:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801074b5:	e9 6e f0 ff ff       	jmp    80106528 <alltraps>

801074ba <vector199>:
.globl vector199
vector199:
  pushl $0
801074ba:	6a 00                	push   $0x0
  pushl $199
801074bc:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801074c1:	e9 62 f0 ff ff       	jmp    80106528 <alltraps>

801074c6 <vector200>:
.globl vector200
vector200:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $200
801074c8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801074cd:	e9 56 f0 ff ff       	jmp    80106528 <alltraps>

801074d2 <vector201>:
.globl vector201
vector201:
  pushl $0
801074d2:	6a 00                	push   $0x0
  pushl $201
801074d4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801074d9:	e9 4a f0 ff ff       	jmp    80106528 <alltraps>

801074de <vector202>:
.globl vector202
vector202:
  pushl $0
801074de:	6a 00                	push   $0x0
  pushl $202
801074e0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801074e5:	e9 3e f0 ff ff       	jmp    80106528 <alltraps>

801074ea <vector203>:
.globl vector203
vector203:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $203
801074ec:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801074f1:	e9 32 f0 ff ff       	jmp    80106528 <alltraps>

801074f6 <vector204>:
.globl vector204
vector204:
  pushl $0
801074f6:	6a 00                	push   $0x0
  pushl $204
801074f8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801074fd:	e9 26 f0 ff ff       	jmp    80106528 <alltraps>

80107502 <vector205>:
.globl vector205
vector205:
  pushl $0
80107502:	6a 00                	push   $0x0
  pushl $205
80107504:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107509:	e9 1a f0 ff ff       	jmp    80106528 <alltraps>

8010750e <vector206>:
.globl vector206
vector206:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $206
80107510:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107515:	e9 0e f0 ff ff       	jmp    80106528 <alltraps>

8010751a <vector207>:
.globl vector207
vector207:
  pushl $0
8010751a:	6a 00                	push   $0x0
  pushl $207
8010751c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107521:	e9 02 f0 ff ff       	jmp    80106528 <alltraps>

80107526 <vector208>:
.globl vector208
vector208:
  pushl $0
80107526:	6a 00                	push   $0x0
  pushl $208
80107528:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010752d:	e9 f6 ef ff ff       	jmp    80106528 <alltraps>

80107532 <vector209>:
.globl vector209
vector209:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $209
80107534:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107539:	e9 ea ef ff ff       	jmp    80106528 <alltraps>

8010753e <vector210>:
.globl vector210
vector210:
  pushl $0
8010753e:	6a 00                	push   $0x0
  pushl $210
80107540:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107545:	e9 de ef ff ff       	jmp    80106528 <alltraps>

8010754a <vector211>:
.globl vector211
vector211:
  pushl $0
8010754a:	6a 00                	push   $0x0
  pushl $211
8010754c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107551:	e9 d2 ef ff ff       	jmp    80106528 <alltraps>

80107556 <vector212>:
.globl vector212
vector212:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $212
80107558:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010755d:	e9 c6 ef ff ff       	jmp    80106528 <alltraps>

80107562 <vector213>:
.globl vector213
vector213:
  pushl $0
80107562:	6a 00                	push   $0x0
  pushl $213
80107564:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107569:	e9 ba ef ff ff       	jmp    80106528 <alltraps>

8010756e <vector214>:
.globl vector214
vector214:
  pushl $0
8010756e:	6a 00                	push   $0x0
  pushl $214
80107570:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107575:	e9 ae ef ff ff       	jmp    80106528 <alltraps>

8010757a <vector215>:
.globl vector215
vector215:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $215
8010757c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107581:	e9 a2 ef ff ff       	jmp    80106528 <alltraps>

80107586 <vector216>:
.globl vector216
vector216:
  pushl $0
80107586:	6a 00                	push   $0x0
  pushl $216
80107588:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010758d:	e9 96 ef ff ff       	jmp    80106528 <alltraps>

80107592 <vector217>:
.globl vector217
vector217:
  pushl $0
80107592:	6a 00                	push   $0x0
  pushl $217
80107594:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107599:	e9 8a ef ff ff       	jmp    80106528 <alltraps>

8010759e <vector218>:
.globl vector218
vector218:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $218
801075a0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801075a5:	e9 7e ef ff ff       	jmp    80106528 <alltraps>

801075aa <vector219>:
.globl vector219
vector219:
  pushl $0
801075aa:	6a 00                	push   $0x0
  pushl $219
801075ac:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801075b1:	e9 72 ef ff ff       	jmp    80106528 <alltraps>

801075b6 <vector220>:
.globl vector220
vector220:
  pushl $0
801075b6:	6a 00                	push   $0x0
  pushl $220
801075b8:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801075bd:	e9 66 ef ff ff       	jmp    80106528 <alltraps>

801075c2 <vector221>:
.globl vector221
vector221:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $221
801075c4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801075c9:	e9 5a ef ff ff       	jmp    80106528 <alltraps>

801075ce <vector222>:
.globl vector222
vector222:
  pushl $0
801075ce:	6a 00                	push   $0x0
  pushl $222
801075d0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801075d5:	e9 4e ef ff ff       	jmp    80106528 <alltraps>

801075da <vector223>:
.globl vector223
vector223:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $223
801075dc:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801075e1:	e9 42 ef ff ff       	jmp    80106528 <alltraps>

801075e6 <vector224>:
.globl vector224
vector224:
  pushl $0
801075e6:	6a 00                	push   $0x0
  pushl $224
801075e8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801075ed:	e9 36 ef ff ff       	jmp    80106528 <alltraps>

801075f2 <vector225>:
.globl vector225
vector225:
  pushl $0
801075f2:	6a 00                	push   $0x0
  pushl $225
801075f4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801075f9:	e9 2a ef ff ff       	jmp    80106528 <alltraps>

801075fe <vector226>:
.globl vector226
vector226:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $226
80107600:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107605:	e9 1e ef ff ff       	jmp    80106528 <alltraps>

8010760a <vector227>:
.globl vector227
vector227:
  pushl $0
8010760a:	6a 00                	push   $0x0
  pushl $227
8010760c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107611:	e9 12 ef ff ff       	jmp    80106528 <alltraps>

80107616 <vector228>:
.globl vector228
vector228:
  pushl $0
80107616:	6a 00                	push   $0x0
  pushl $228
80107618:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010761d:	e9 06 ef ff ff       	jmp    80106528 <alltraps>

80107622 <vector229>:
.globl vector229
vector229:
  pushl $0
80107622:	6a 00                	push   $0x0
  pushl $229
80107624:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107629:	e9 fa ee ff ff       	jmp    80106528 <alltraps>

8010762e <vector230>:
.globl vector230
vector230:
  pushl $0
8010762e:	6a 00                	push   $0x0
  pushl $230
80107630:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107635:	e9 ee ee ff ff       	jmp    80106528 <alltraps>

8010763a <vector231>:
.globl vector231
vector231:
  pushl $0
8010763a:	6a 00                	push   $0x0
  pushl $231
8010763c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107641:	e9 e2 ee ff ff       	jmp    80106528 <alltraps>

80107646 <vector232>:
.globl vector232
vector232:
  pushl $0
80107646:	6a 00                	push   $0x0
  pushl $232
80107648:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010764d:	e9 d6 ee ff ff       	jmp    80106528 <alltraps>

80107652 <vector233>:
.globl vector233
vector233:
  pushl $0
80107652:	6a 00                	push   $0x0
  pushl $233
80107654:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107659:	e9 ca ee ff ff       	jmp    80106528 <alltraps>

8010765e <vector234>:
.globl vector234
vector234:
  pushl $0
8010765e:	6a 00                	push   $0x0
  pushl $234
80107660:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107665:	e9 be ee ff ff       	jmp    80106528 <alltraps>

8010766a <vector235>:
.globl vector235
vector235:
  pushl $0
8010766a:	6a 00                	push   $0x0
  pushl $235
8010766c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107671:	e9 b2 ee ff ff       	jmp    80106528 <alltraps>

80107676 <vector236>:
.globl vector236
vector236:
  pushl $0
80107676:	6a 00                	push   $0x0
  pushl $236
80107678:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010767d:	e9 a6 ee ff ff       	jmp    80106528 <alltraps>

80107682 <vector237>:
.globl vector237
vector237:
  pushl $0
80107682:	6a 00                	push   $0x0
  pushl $237
80107684:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107689:	e9 9a ee ff ff       	jmp    80106528 <alltraps>

8010768e <vector238>:
.globl vector238
vector238:
  pushl $0
8010768e:	6a 00                	push   $0x0
  pushl $238
80107690:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107695:	e9 8e ee ff ff       	jmp    80106528 <alltraps>

8010769a <vector239>:
.globl vector239
vector239:
  pushl $0
8010769a:	6a 00                	push   $0x0
  pushl $239
8010769c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801076a1:	e9 82 ee ff ff       	jmp    80106528 <alltraps>

801076a6 <vector240>:
.globl vector240
vector240:
  pushl $0
801076a6:	6a 00                	push   $0x0
  pushl $240
801076a8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801076ad:	e9 76 ee ff ff       	jmp    80106528 <alltraps>

801076b2 <vector241>:
.globl vector241
vector241:
  pushl $0
801076b2:	6a 00                	push   $0x0
  pushl $241
801076b4:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801076b9:	e9 6a ee ff ff       	jmp    80106528 <alltraps>

801076be <vector242>:
.globl vector242
vector242:
  pushl $0
801076be:	6a 00                	push   $0x0
  pushl $242
801076c0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801076c5:	e9 5e ee ff ff       	jmp    80106528 <alltraps>

801076ca <vector243>:
.globl vector243
vector243:
  pushl $0
801076ca:	6a 00                	push   $0x0
  pushl $243
801076cc:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801076d1:	e9 52 ee ff ff       	jmp    80106528 <alltraps>

801076d6 <vector244>:
.globl vector244
vector244:
  pushl $0
801076d6:	6a 00                	push   $0x0
  pushl $244
801076d8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801076dd:	e9 46 ee ff ff       	jmp    80106528 <alltraps>

801076e2 <vector245>:
.globl vector245
vector245:
  pushl $0
801076e2:	6a 00                	push   $0x0
  pushl $245
801076e4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801076e9:	e9 3a ee ff ff       	jmp    80106528 <alltraps>

801076ee <vector246>:
.globl vector246
vector246:
  pushl $0
801076ee:	6a 00                	push   $0x0
  pushl $246
801076f0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801076f5:	e9 2e ee ff ff       	jmp    80106528 <alltraps>

801076fa <vector247>:
.globl vector247
vector247:
  pushl $0
801076fa:	6a 00                	push   $0x0
  pushl $247
801076fc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107701:	e9 22 ee ff ff       	jmp    80106528 <alltraps>

80107706 <vector248>:
.globl vector248
vector248:
  pushl $0
80107706:	6a 00                	push   $0x0
  pushl $248
80107708:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010770d:	e9 16 ee ff ff       	jmp    80106528 <alltraps>

80107712 <vector249>:
.globl vector249
vector249:
  pushl $0
80107712:	6a 00                	push   $0x0
  pushl $249
80107714:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107719:	e9 0a ee ff ff       	jmp    80106528 <alltraps>

8010771e <vector250>:
.globl vector250
vector250:
  pushl $0
8010771e:	6a 00                	push   $0x0
  pushl $250
80107720:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107725:	e9 fe ed ff ff       	jmp    80106528 <alltraps>

8010772a <vector251>:
.globl vector251
vector251:
  pushl $0
8010772a:	6a 00                	push   $0x0
  pushl $251
8010772c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107731:	e9 f2 ed ff ff       	jmp    80106528 <alltraps>

80107736 <vector252>:
.globl vector252
vector252:
  pushl $0
80107736:	6a 00                	push   $0x0
  pushl $252
80107738:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010773d:	e9 e6 ed ff ff       	jmp    80106528 <alltraps>

80107742 <vector253>:
.globl vector253
vector253:
  pushl $0
80107742:	6a 00                	push   $0x0
  pushl $253
80107744:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107749:	e9 da ed ff ff       	jmp    80106528 <alltraps>

8010774e <vector254>:
.globl vector254
vector254:
  pushl $0
8010774e:	6a 00                	push   $0x0
  pushl $254
80107750:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107755:	e9 ce ed ff ff       	jmp    80106528 <alltraps>

8010775a <vector255>:
.globl vector255
vector255:
  pushl $0
8010775a:	6a 00                	push   $0x0
  pushl $255
8010775c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107761:	e9 c2 ed ff ff       	jmp    80106528 <alltraps>
	...

80107768 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107768:	55                   	push   %ebp
80107769:	89 e5                	mov    %esp,%ebp
8010776b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010776e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107771:	83 e8 01             	sub    $0x1,%eax
80107774:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107778:	8b 45 08             	mov    0x8(%ebp),%eax
8010777b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010777f:	8b 45 08             	mov    0x8(%ebp),%eax
80107782:	c1 e8 10             	shr    $0x10,%eax
80107785:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107789:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010778c:	0f 01 10             	lgdtl  (%eax)
}
8010778f:	c9                   	leave  
80107790:	c3                   	ret    

80107791 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107791:	55                   	push   %ebp
80107792:	89 e5                	mov    %esp,%ebp
80107794:	83 ec 04             	sub    $0x4,%esp
80107797:	8b 45 08             	mov    0x8(%ebp),%eax
8010779a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010779e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077a2:	0f 00 d8             	ltr    %ax
}
801077a5:	c9                   	leave  
801077a6:	c3                   	ret    

801077a7 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801077a7:	55                   	push   %ebp
801077a8:	89 e5                	mov    %esp,%ebp
801077aa:	83 ec 04             	sub    $0x4,%esp
801077ad:	8b 45 08             	mov    0x8(%ebp),%eax
801077b0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801077b4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801077b8:	8e e8                	mov    %eax,%gs
}
801077ba:	c9                   	leave  
801077bb:	c3                   	ret    

801077bc <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801077bc:	55                   	push   %ebp
801077bd:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801077bf:	8b 45 08             	mov    0x8(%ebp),%eax
801077c2:	0f 22 d8             	mov    %eax,%cr3
}
801077c5:	5d                   	pop    %ebp
801077c6:	c3                   	ret    

801077c7 <v2p>:
801077c7:	55                   	push   %ebp
801077c8:	89 e5                	mov    %esp,%ebp
801077ca:	8b 45 08             	mov    0x8(%ebp),%eax
801077cd:	05 00 00 00 80       	add    $0x80000000,%eax
801077d2:	5d                   	pop    %ebp
801077d3:	c3                   	ret    

801077d4 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801077d4:	55                   	push   %ebp
801077d5:	89 e5                	mov    %esp,%ebp
801077d7:	8b 45 08             	mov    0x8(%ebp),%eax
801077da:	05 00 00 00 80       	add    $0x80000000,%eax
801077df:	5d                   	pop    %ebp
801077e0:	c3                   	ret    

801077e1 <tlb_print>:
void tlb_print(){
801077e1:	55                   	push   %ebp
801077e2:	89 e5                	mov    %esp,%ebp
801077e4:	83 ec 28             	sub    $0x28,%esp
	cprintf("%d | [%s] TLB: HEAD->", proc->pid, __FUNCTION__);
801077e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077ed:	8b 40 10             	mov    0x10(%eax),%eax
801077f0:	c7 44 24 08 39 91 10 	movl   $0x80109139,0x8(%esp)
801077f7:	80 
801077f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801077fc:	c7 04 24 dc 8f 10 80 	movl   $0x80108fdc,(%esp)
80107803:	e8 99 8b ff ff       	call   801003a1 <cprintf>
	int i;
	for(i=0; i< cpu->tlb.size; i++){
80107808:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010780f:	eb 33                	jmp    80107844 <tlb_print+0x63>
		if(cpu->tlb.arr[i].isUsed){
80107811:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107817:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010781a:	0f b6 44 d0 08       	movzbl 0x8(%eax,%edx,8),%eax
8010781f:	84 c0                	test   %al,%al
80107821:	74 1d                	je     80107840 <tlb_print+0x5f>
			cprintf("(0x%x) => ", cpu->tlb.arr[i].va);
80107823:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107829:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010782c:	8b 44 d0 0c          	mov    0xc(%eax,%edx,8),%eax
80107830:	89 44 24 04          	mov    %eax,0x4(%esp)
80107834:	c7 04 24 f2 8f 10 80 	movl   $0x80108ff2,(%esp)
8010783b:	e8 61 8b ff ff       	call   801003a1 <cprintf>
void tlb_print(){
	cprintf("%d | [%s] TLB: HEAD->", proc->pid, __FUNCTION__);
	int i;
	for(i=0; i< cpu->tlb.size; i++){
80107840:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107844:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010784a:	8b 40 18             	mov    0x18(%eax),%eax
8010784d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80107850:	7f bf                	jg     80107811 <tlb_print+0x30>
		if(cpu->tlb.arr[i].isUsed){
			cprintf("(0x%x) => ", cpu->tlb.arr[i].va);
		}
	}
	cprintf("->END \n");
80107852:	c7 04 24 fd 8f 10 80 	movl   $0x80108ffd,(%esp)
80107859:	e8 43 8b ff ff       	call   801003a1 <cprintf>
}
8010785e:	c9                   	leave  
8010785f:	c3                   	ret    

80107860 <tbl_clear_entry>:

void tbl_clear_entry(struct tlb_entry_wrapper* entry){
80107860:	55                   	push   %ebp
80107861:	89 e5                	mov    %esp,%ebp
80107863:	83 ec 28             	sub    $0x28,%esp
	//pointer to second level page table
	pte_t* pgtab = (pte_t*)p2v(PTE_ADDR( cpu->kpgdir[PDX(entry->va)]));
80107866:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010786c:	8b 50 04             	mov    0x4(%eax),%edx
8010786f:	8b 45 08             	mov    0x8(%ebp),%eax
80107872:	8b 40 04             	mov    0x4(%eax),%eax
80107875:	c1 e8 16             	shr    $0x16,%eax
80107878:	c1 e0 02             	shl    $0x2,%eax
8010787b:	01 d0                	add    %edx,%eax
8010787d:	8b 00                	mov    (%eax),%eax
8010787f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107884:	89 04 24             	mov    %eax,(%esp)
80107887:	e8 48 ff ff ff       	call   801077d4 <p2v>
8010788c:	89 45 ec             	mov    %eax,-0x14(%ebp)

	//remove entry
	pgtab[PTX(entry->va)] = 0;
8010788f:	8b 45 08             	mov    0x8(%ebp),%eax
80107892:	8b 40 04             	mov    0x4(%eax),%eax
80107895:	c1 e8 0c             	shr    $0xc,%eax
80107898:	25 ff 03 00 00       	and    $0x3ff,%eax
8010789d:	c1 e0 02             	shl    $0x2,%eax
801078a0:	03 45 ec             	add    -0x14(%ebp),%eax
801078a3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	//check to see if page table is still in use
	int isUsingPageTable = 0;
801078a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	pte_t i;
	for(i=0; i < NPTENTRIES; i++){
801078b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801078b7:	eb 1f                	jmp    801078d8 <tbl_clear_entry+0x78>
		if( (pgtab[i] & PTE_P) != 0){ // is Present
801078b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078bc:	c1 e0 02             	shl    $0x2,%eax
801078bf:	03 45 ec             	add    -0x14(%ebp),%eax
801078c2:	8b 00                	mov    (%eax),%eax
801078c4:	83 e0 01             	and    $0x1,%eax
801078c7:	84 c0                	test   %al,%al
801078c9:	74 09                	je     801078d4 <tbl_clear_entry+0x74>
//			if(pgtab[i] != 0){
				isUsingPageTable = 1;
801078cb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
				break;
801078d2:	eb 0d                	jmp    801078e1 <tbl_clear_entry+0x81>
	pgtab[PTX(entry->va)] = 0;

	//check to see if page table is still in use
	int isUsingPageTable = 0;
	pte_t i;
	for(i=0; i < NPTENTRIES; i++){
801078d4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801078d8:	81 7d f0 ff 03 00 00 	cmpl   $0x3ff,-0x10(%ebp)
801078df:	76 d8                	jbe    801078b9 <tbl_clear_entry+0x59>
		}

	}

	//deallocate page table if no longer in use
	if(!isUsingPageTable){
801078e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801078e5:	75 28                	jne    8010790f <tbl_clear_entry+0xaf>
		kfree((char*)pgtab);
801078e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801078ea:	89 04 24             	mov    %eax,(%esp)
801078ed:	e8 80 b1 ff ff       	call   80102a72 <kfree>
		//remove page table pointer from page directory
		cpu->kpgdir[PDX(entry->va)] = 0;
801078f2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801078f8:	8b 50 04             	mov    0x4(%eax),%edx
801078fb:	8b 45 08             	mov    0x8(%ebp),%eax
801078fe:	8b 40 04             	mov    0x4(%eax),%eax
80107901:	c1 e8 16             	shr    $0x16,%eax
80107904:	c1 e0 02             	shl    $0x2,%eax
80107907:	01 d0                	add    %edx,%eax
80107909:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	}


	//remove from TLB
	memset(entry, 0, sizeof(struct tlb_entry_wrapper));
8010790f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80107916:	00 
80107917:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010791e:	00 
8010791f:	8b 45 08             	mov    0x8(%ebp),%eax
80107922:	89 04 24             	mov    %eax,(%esp)
80107925:	e8 c4 d7 ff ff       	call   801050ee <memset>
	cpu->tlb.size --;
8010792a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107930:	8b 50 18             	mov    0x18(%eax),%edx
80107933:	83 ea 01             	sub    $0x1,%edx
80107936:	89 50 18             	mov    %edx,0x18(%eax)
}
80107939:	c9                   	leave  
8010793a:	c3                   	ret    

8010793b <tlb_clear>:

void tlb_clear(){
8010793b:	55                   	push   %ebp
8010793c:	89 e5                	mov    %esp,%ebp
8010793e:	83 ec 28             	sub    $0x28,%esp

	//clear fifo tlb
	int i;
	for(i = 0; i < TLB_MAX_SIZE; i++){
80107941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107948:	eb 32                	jmp    8010797c <tlb_clear+0x41>
		if(!cpu->tlb.arr[i].isUsed) continue;
8010794a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107950:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107953:	0f b6 44 d0 08       	movzbl 0x8(%eax,%edx,8),%eax
80107958:	84 c0                	test   %al,%al
8010795a:	74 1b                	je     80107977 <tlb_clear+0x3c>
		//clear pte
		tbl_clear_entry(&cpu->tlb.arr[i]);
8010795c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107962:	8d 50 08             	lea    0x8(%eax),%edx
80107965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107968:	c1 e0 03             	shl    $0x3,%eax
8010796b:	01 d0                	add    %edx,%eax
8010796d:	89 04 24             	mov    %eax,(%esp)
80107970:	e8 eb fe ff ff       	call   80107860 <tbl_clear_entry>
80107975:	eb 01                	jmp    80107978 <tlb_clear+0x3d>
void tlb_clear(){

	//clear fifo tlb
	int i;
	for(i = 0; i < TLB_MAX_SIZE; i++){
		if(!cpu->tlb.arr[i].isUsed) continue;
80107977:	90                   	nop

void tlb_clear(){

	//clear fifo tlb
	int i;
	for(i = 0; i < TLB_MAX_SIZE; i++){
80107978:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010797c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80107980:	7e c8                	jle    8010794a <tlb_clear+0xf>
	}

	//clear all tlb
	pte_t p;
	pte_t* pgtab;
	for(p=0; p<PGSIZE/8; p++){
80107982:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80107989:	eb 69                	jmp    801079f4 <tlb_clear+0xb9>
		if( (cpu->kpgdir[p] & PTE_P) != 0 ){ //available in physical memory
8010798b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107991:	8b 40 04             	mov    0x4(%eax),%eax
80107994:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107997:	c1 e2 02             	shl    $0x2,%edx
8010799a:	01 d0                	add    %edx,%eax
8010799c:	8b 00                	mov    (%eax),%eax
8010799e:	83 e0 01             	and    $0x1,%eax
801079a1:	84 c0                	test   %al,%al
801079a3:	74 34                	je     801079d9 <tlb_clear+0x9e>
			//cprintf("delete");
			pgtab = (pte_t*)p2v(PTE_ADDR( cpu->kpgdir[p]));
801079a5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801079ab:	8b 40 04             	mov    0x4(%eax),%eax
801079ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
801079b1:	c1 e2 02             	shl    $0x2,%edx
801079b4:	01 d0                	add    %edx,%eax
801079b6:	8b 00                	mov    (%eax),%eax
801079b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801079bd:	89 04 24             	mov    %eax,(%esp)
801079c0:	e8 0f fe ff ff       	call   801077d4 <p2v>
801079c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
			if(pgtab != 0){
801079c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079cc:	74 0b                	je     801079d9 <tlb_clear+0x9e>
				kfree((char*)pgtab);
801079ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079d1:	89 04 24             	mov    %eax,(%esp)
801079d4:	e8 99 b0 ff ff       	call   80102a72 <kfree>
			}

		}
		cpu->kpgdir[p] = 0;
801079d9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801079df:	8b 40 04             	mov    0x4(%eax),%eax
801079e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801079e5:	c1 e2 02             	shl    $0x2,%edx
801079e8:	01 d0                	add    %edx,%eax
801079ea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}

	//clear all tlb
	pte_t p;
	pte_t* pgtab;
	for(p=0; p<PGSIZE/8; p++){
801079f0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801079f4:	81 7d f0 ff 01 00 00 	cmpl   $0x1ff,-0x10(%ebp)
801079fb:	76 8e                	jbe    8010798b <tlb_clear+0x50>
		cpu->kpgdir[p] = 0;

	}


}
801079fd:	c9                   	leave  
801079fe:	c3                   	ret    

801079ff <tlb_insert>:

void tlb_insert(void* va){
801079ff:	55                   	push   %ebp
80107a00:	89 e5                	mov    %esp,%ebp
80107a02:	53                   	push   %ebx
80107a03:	83 ec 24             	sub    $0x24,%esp
	//cprintf("%d | [%s] insert 0x%x \n", proc->pid, __FUNCTION__, va);
	int i;

	if(cpu->tlb.size == TLB_MAX_SIZE){
80107a06:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a0c:	8b 40 18             	mov    0x18(%eax),%eax
80107a0f:	83 f8 02             	cmp    $0x2,%eax
80107a12:	75 62                	jne    80107a76 <tlb_insert+0x77>
		//cprintf("%d | [%s] no room! \n", proc->pid, __FUNCTION__);

		//take out the first one and shift left
		tbl_clear_entry(&cpu->tlb.arr[0]);
80107a14:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a1a:	83 c0 08             	add    $0x8,%eax
80107a1d:	89 04 24             	mov    %eax,(%esp)
80107a20:	e8 3b fe ff ff       	call   80107860 <tbl_clear_entry>
		for(i = 1; i < TLB_MAX_SIZE; i++){
80107a25:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80107a2c:	eb 2b                	jmp    80107a59 <tlb_insert+0x5a>
			cpu->tlb.arr[i-1] = cpu->tlb.arr[i];
80107a2e:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80107a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a38:	8d 58 ff             	lea    -0x1(%eax),%ebx
80107a3b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107a44:	8d 54 d0 08          	lea    0x8(%eax,%edx,8),%edx
80107a48:	8b 02                	mov    (%edx),%eax
80107a4a:	8b 52 04             	mov    0x4(%edx),%edx
80107a4d:	89 44 d9 08          	mov    %eax,0x8(%ecx,%ebx,8)
80107a51:	89 54 d9 0c          	mov    %edx,0xc(%ecx,%ebx,8)
	if(cpu->tlb.size == TLB_MAX_SIZE){
		//cprintf("%d | [%s] no room! \n", proc->pid, __FUNCTION__);

		//take out the first one and shift left
		tbl_clear_entry(&cpu->tlb.arr[0]);
		for(i = 1; i < TLB_MAX_SIZE; i++){
80107a55:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a59:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80107a5d:	7e cf                	jle    80107a2e <tlb_insert+0x2f>
			cpu->tlb.arr[i-1] = cpu->tlb.arr[i];
		}
		cpu->tlb.arr[TLB_MAX_SIZE-1].isUsed = 0;
80107a5f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a65:	c6 40 10 00          	movb   $0x0,0x10(%eax)
		cpu->tlb.arr[TLB_MAX_SIZE-1].va = 0;
80107a69:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a6f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	}

	for(i = 0; i < TLB_MAX_SIZE; i++){
80107a76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107a7d:	eb 45                	jmp    80107ac4 <tlb_insert+0xc5>
		if(!cpu->tlb.arr[i].isUsed){
80107a7f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107a88:	0f b6 44 d0 08       	movzbl 0x8(%eax,%edx,8),%eax
80107a8d:	84 c0                	test   %al,%al
80107a8f:	75 2f                	jne    80107ac0 <tlb_insert+0xc1>
			//cprintf("%d | [%s] adding 0x%x ! \n", proc->pid, __FUNCTION__, va);

			cpu->tlb.arr[i].va = va;
80107a91:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107a9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80107a9d:	89 4c d0 0c          	mov    %ecx,0xc(%eax,%edx,8)
			cpu->tlb.arr[i].isUsed = 1;
80107aa1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107aa7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107aaa:	c6 44 d0 08 01       	movb   $0x1,0x8(%eax,%edx,8)
			cpu->tlb.size++;
80107aaf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107ab5:	8b 50 18             	mov    0x18(%eax),%edx
80107ab8:	83 c2 01             	add    $0x1,%edx
80107abb:	89 50 18             	mov    %edx,0x18(%eax)
			break;
80107abe:	eb 0a                	jmp    80107aca <tlb_insert+0xcb>
		}
		cpu->tlb.arr[TLB_MAX_SIZE-1].isUsed = 0;
		cpu->tlb.arr[TLB_MAX_SIZE-1].va = 0;
	}

	for(i = 0; i < TLB_MAX_SIZE; i++){
80107ac0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107ac4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80107ac8:	7e b5                	jle    80107a7f <tlb_insert+0x80>
			cpu->tlb.size++;
			break;
		}
	}
	//tlb_print();
}
80107aca:	83 c4 24             	add    $0x24,%esp
80107acd:	5b                   	pop    %ebx
80107ace:	5d                   	pop    %ebp
80107acf:	c3                   	ret    

80107ad0 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107ad0:	55                   	push   %ebp
80107ad1:	89 e5                	mov    %esp,%ebp
80107ad3:	53                   	push   %ebx
80107ad4:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];  
80107ad7:	e8 e7 b3 ff ff       	call   80102ec3 <cpunum>
80107adc:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
80107ae2:	05 60 33 11 80       	add    $0x80113360,%eax
80107ae7:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aed:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107af4:	ff ff 
80107af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af9:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107b00:	00 00 
80107b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b05:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b16:	83 e2 f0             	and    $0xfffffff0,%edx
80107b19:	83 ca 0a             	or     $0xa,%edx
80107b1c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b25:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b2c:	83 ca 10             	or     $0x10,%edx
80107b2f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b38:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b3f:	83 e2 9f             	and    $0xffffff9f,%edx
80107b42:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b52:	83 ca 80             	or     $0xffffff80,%edx
80107b55:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5e:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b65:	83 ca 0f             	or     $0xf,%edx
80107b68:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b71:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b78:	83 e2 ef             	and    $0xffffffef,%edx
80107b7b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b84:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b8b:	83 e2 df             	and    $0xffffffdf,%edx
80107b8e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b97:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107b9e:	83 ca 40             	or     $0x40,%edx
80107ba1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107baa:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bb1:	83 ca 80             	or     $0xffffff80,%edx
80107bb4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bbd:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc7:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107bce:	ff ff 
80107bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd3:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107bda:	00 00 
80107bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdf:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107bf0:	83 e2 f0             	and    $0xfffffff0,%edx
80107bf3:	83 ca 02             	or     $0x2,%edx
80107bf6:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bff:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c06:	83 ca 10             	or     $0x10,%edx
80107c09:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c12:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c19:	83 e2 9f             	and    $0xffffff9f,%edx
80107c1c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c25:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c2c:	83 ca 80             	or     $0xffffff80,%edx
80107c2f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c38:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c3f:	83 ca 0f             	or     $0xf,%edx
80107c42:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c52:	83 e2 ef             	and    $0xffffffef,%edx
80107c55:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c5e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c65:	83 e2 df             	and    $0xffffffdf,%edx
80107c68:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c71:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c78:	83 ca 40             	or     $0x40,%edx
80107c7b:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c84:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c8b:	83 ca 80             	or     $0xffffff80,%edx
80107c8e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c97:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca1:	66 c7 80 a8 00 00 00 	movw   $0xffff,0xa8(%eax)
80107ca8:	ff ff 
80107caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cad:	66 c7 80 aa 00 00 00 	movw   $0x0,0xaa(%eax)
80107cb4:	00 00 
80107cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb9:	c6 80 ac 00 00 00 00 	movb   $0x0,0xac(%eax)
80107cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc3:	0f b6 90 ad 00 00 00 	movzbl 0xad(%eax),%edx
80107cca:	83 e2 f0             	and    $0xfffffff0,%edx
80107ccd:	83 ca 0a             	or     $0xa,%edx
80107cd0:	88 90 ad 00 00 00    	mov    %dl,0xad(%eax)
80107cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd9:	0f b6 90 ad 00 00 00 	movzbl 0xad(%eax),%edx
80107ce0:	83 ca 10             	or     $0x10,%edx
80107ce3:	88 90 ad 00 00 00    	mov    %dl,0xad(%eax)
80107ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cec:	0f b6 90 ad 00 00 00 	movzbl 0xad(%eax),%edx
80107cf3:	83 ca 60             	or     $0x60,%edx
80107cf6:	88 90 ad 00 00 00    	mov    %dl,0xad(%eax)
80107cfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cff:	0f b6 90 ad 00 00 00 	movzbl 0xad(%eax),%edx
80107d06:	83 ca 80             	or     $0xffffff80,%edx
80107d09:	88 90 ad 00 00 00    	mov    %dl,0xad(%eax)
80107d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d12:	0f b6 90 ae 00 00 00 	movzbl 0xae(%eax),%edx
80107d19:	83 ca 0f             	or     $0xf,%edx
80107d1c:	88 90 ae 00 00 00    	mov    %dl,0xae(%eax)
80107d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d25:	0f b6 90 ae 00 00 00 	movzbl 0xae(%eax),%edx
80107d2c:	83 e2 ef             	and    $0xffffffef,%edx
80107d2f:	88 90 ae 00 00 00    	mov    %dl,0xae(%eax)
80107d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d38:	0f b6 90 ae 00 00 00 	movzbl 0xae(%eax),%edx
80107d3f:	83 e2 df             	and    $0xffffffdf,%edx
80107d42:	88 90 ae 00 00 00    	mov    %dl,0xae(%eax)
80107d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4b:	0f b6 90 ae 00 00 00 	movzbl 0xae(%eax),%edx
80107d52:	83 ca 40             	or     $0x40,%edx
80107d55:	88 90 ae 00 00 00    	mov    %dl,0xae(%eax)
80107d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5e:	0f b6 90 ae 00 00 00 	movzbl 0xae(%eax),%edx
80107d65:	83 ca 80             	or     $0xffffff80,%edx
80107d68:	88 90 ae 00 00 00    	mov    %dl,0xae(%eax)
80107d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d71:	c6 80 af 00 00 00 00 	movb   $0x0,0xaf(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7b:	66 c7 80 b0 00 00 00 	movw   $0xffff,0xb0(%eax)
80107d82:	ff ff 
80107d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d87:	66 c7 80 b2 00 00 00 	movw   $0x0,0xb2(%eax)
80107d8e:	00 00 
80107d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d93:	c6 80 b4 00 00 00 00 	movb   $0x0,0xb4(%eax)
80107d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9d:	0f b6 90 b5 00 00 00 	movzbl 0xb5(%eax),%edx
80107da4:	83 e2 f0             	and    $0xfffffff0,%edx
80107da7:	83 ca 02             	or     $0x2,%edx
80107daa:	88 90 b5 00 00 00    	mov    %dl,0xb5(%eax)
80107db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db3:	0f b6 90 b5 00 00 00 	movzbl 0xb5(%eax),%edx
80107dba:	83 ca 10             	or     $0x10,%edx
80107dbd:	88 90 b5 00 00 00    	mov    %dl,0xb5(%eax)
80107dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc6:	0f b6 90 b5 00 00 00 	movzbl 0xb5(%eax),%edx
80107dcd:	83 ca 60             	or     $0x60,%edx
80107dd0:	88 90 b5 00 00 00    	mov    %dl,0xb5(%eax)
80107dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd9:	0f b6 90 b5 00 00 00 	movzbl 0xb5(%eax),%edx
80107de0:	83 ca 80             	or     $0xffffff80,%edx
80107de3:	88 90 b5 00 00 00    	mov    %dl,0xb5(%eax)
80107de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dec:	0f b6 90 b6 00 00 00 	movzbl 0xb6(%eax),%edx
80107df3:	83 ca 0f             	or     $0xf,%edx
80107df6:	88 90 b6 00 00 00    	mov    %dl,0xb6(%eax)
80107dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dff:	0f b6 90 b6 00 00 00 	movzbl 0xb6(%eax),%edx
80107e06:	83 e2 ef             	and    $0xffffffef,%edx
80107e09:	88 90 b6 00 00 00    	mov    %dl,0xb6(%eax)
80107e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e12:	0f b6 90 b6 00 00 00 	movzbl 0xb6(%eax),%edx
80107e19:	83 e2 df             	and    $0xffffffdf,%edx
80107e1c:	88 90 b6 00 00 00    	mov    %dl,0xb6(%eax)
80107e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e25:	0f b6 90 b6 00 00 00 	movzbl 0xb6(%eax),%edx
80107e2c:	83 ca 40             	or     $0x40,%edx
80107e2f:	88 90 b6 00 00 00    	mov    %dl,0xb6(%eax)
80107e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e38:	0f b6 90 b6 00 00 00 	movzbl 0xb6(%eax),%edx
80107e3f:	83 ca 80             	or     $0xffffff80,%edx
80107e42:	88 90 b6 00 00 00    	mov    %dl,0xb6(%eax)
80107e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4b:	c6 80 b7 00 00 00 00 	movb   $0x0,0xb7(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e55:	05 cc 00 00 00       	add    $0xcc,%eax
80107e5a:	89 c3                	mov    %eax,%ebx
80107e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5f:	05 cc 00 00 00       	add    $0xcc,%eax
80107e64:	c1 e8 10             	shr    $0x10,%eax
80107e67:	89 c1                	mov    %eax,%ecx
80107e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6c:	05 cc 00 00 00       	add    $0xcc,%eax
80107e71:	c1 e8 18             	shr    $0x18,%eax
80107e74:	89 c2                	mov    %eax,%edx
80107e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e79:	66 c7 80 a0 00 00 00 	movw   $0x0,0xa0(%eax)
80107e80:	00 00 
80107e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e85:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80107e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e8f:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
80107e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e98:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107e9f:	83 e1 f0             	and    $0xfffffff0,%ecx
80107ea2:	83 c9 02             	or     $0x2,%ecx
80107ea5:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eae:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107eb5:	83 c9 10             	or     $0x10,%ecx
80107eb8:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec1:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107ec8:	83 e1 9f             	and    $0xffffff9f,%ecx
80107ecb:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ed1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ed4:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80107edb:	83 c9 80             	or     $0xffffff80,%ecx
80107ede:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
80107ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee7:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107eee:	83 e1 f0             	and    $0xfffffff0,%ecx
80107ef1:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efa:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f01:	83 e1 ef             	and    $0xffffffef,%ecx
80107f04:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f14:	83 e1 df             	and    $0xffffffdf,%ecx
80107f17:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f20:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f27:	83 c9 40             	or     $0x40,%ecx
80107f2a:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f33:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80107f3a:	83 c9 80             	or     $0xffffff80,%ecx
80107f3d:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
80107f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f46:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f4f:	05 88 00 00 00       	add    $0x88,%eax
80107f54:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107f5b:	00 
80107f5c:	89 04 24             	mov    %eax,(%esp)
80107f5f:	e8 04 f8 ff ff       	call   80107768 <lgdt>
  loadgs(SEG_KCPU << 3);
80107f64:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107f6b:	e8 37 f8 ff ff       	call   801077a7 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f73:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107f79:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107f80:	00 00 00 00 
}
80107f84:	83 c4 24             	add    $0x24,%esp
80107f87:	5b                   	pop    %ebx
80107f88:	5d                   	pop    %ebp
80107f89:	c3                   	ret    

80107f8a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107f8a:	55                   	push   %ebp
80107f8b:	89 e5                	mov    %esp,%ebp
80107f8d:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107f90:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f93:	c1 e8 16             	shr    $0x16,%eax
80107f96:	c1 e0 02             	shl    $0x2,%eax
80107f99:	03 45 08             	add    0x8(%ebp),%eax
80107f9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107f9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fa2:	8b 00                	mov    (%eax),%eax
80107fa4:	83 e0 01             	and    $0x1,%eax
80107fa7:	84 c0                	test   %al,%al
80107fa9:	74 17                	je     80107fc2 <walkpgdir+0x38>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107fae:	8b 00                	mov    (%eax),%eax
80107fb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107fb5:	89 04 24             	mov    %eax,(%esp)
80107fb8:	e8 17 f8 ff ff       	call   801077d4 <p2v>
80107fbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fc0:	eb 4b                	jmp    8010800d <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107fc2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107fc6:	74 0e                	je     80107fd6 <walkpgdir+0x4c>
80107fc8:	e8 3e ab ff ff       	call   80102b0b <kalloc>
80107fcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107fd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107fd4:	75 07                	jne    80107fdd <walkpgdir+0x53>
      return 0;
80107fd6:	b8 00 00 00 00       	mov    $0x0,%eax
80107fdb:	eb 41                	jmp    8010801e <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107fdd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fe4:	00 
80107fe5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107fec:	00 
80107fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff0:	89 04 24             	mov    %eax,(%esp)
80107ff3:	e8 f6 d0 ff ff       	call   801050ee <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffb:	89 04 24             	mov    %eax,(%esp)
80107ffe:	e8 c4 f7 ff ff       	call   801077c7 <v2p>
80108003:	89 c2                	mov    %eax,%edx
80108005:	83 ca 07             	or     $0x7,%edx
80108008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010800b:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010800d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108010:	c1 e8 0c             	shr    $0xc,%eax
80108013:	25 ff 03 00 00       	and    $0x3ff,%eax
80108018:	c1 e0 02             	shl    $0x2,%eax
8010801b:	03 45 f4             	add    -0xc(%ebp),%eax
}
8010801e:	c9                   	leave  
8010801f:	c3                   	ret    

80108020 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108020:	55                   	push   %ebp
80108021:	89 e5                	mov    %esp,%ebp
80108023:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108026:	8b 45 0c             	mov    0xc(%ebp),%eax
80108029:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010802e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108031:	8b 45 0c             	mov    0xc(%ebp),%eax
80108034:	03 45 10             	add    0x10(%ebp),%eax
80108037:	83 e8 01             	sub    $0x1,%eax
8010803a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010803f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108042:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108049:	00 
8010804a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108051:	8b 45 08             	mov    0x8(%ebp),%eax
80108054:	89 04 24             	mov    %eax,(%esp)
80108057:	e8 2e ff ff ff       	call   80107f8a <walkpgdir>
8010805c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010805f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108063:	75 07                	jne    8010806c <mappages+0x4c>
      return -1;
80108065:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010806a:	eb 46                	jmp    801080b2 <mappages+0x92>
    if(*pte & PTE_P)
8010806c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010806f:	8b 00                	mov    (%eax),%eax
80108071:	83 e0 01             	and    $0x1,%eax
80108074:	84 c0                	test   %al,%al
80108076:	74 0c                	je     80108084 <mappages+0x64>
      panic("remap");
80108078:	c7 04 24 05 90 10 80 	movl   $0x80109005,(%esp)
8010807f:	e8 b9 84 ff ff       	call   8010053d <panic>
    *pte = pa | perm | PTE_P;
80108084:	8b 45 18             	mov    0x18(%ebp),%eax
80108087:	0b 45 14             	or     0x14(%ebp),%eax
8010808a:	89 c2                	mov    %eax,%edx
8010808c:	83 ca 01             	or     $0x1,%edx
8010808f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108092:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108097:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010809a:	74 10                	je     801080ac <mappages+0x8c>
      break;
    a += PGSIZE;
8010809c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801080a3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801080aa:	eb 96                	jmp    80108042 <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801080ac:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801080ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080b2:	c9                   	leave  
801080b3:	c3                   	ret    

801080b4 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801080b4:	55                   	push   %ebp
801080b5:	89 e5                	mov    %esp,%ebp
801080b7:	53                   	push   %ebx
801080b8:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801080bb:	e8 4b aa ff ff       	call   80102b0b <kalloc>
801080c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801080c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080c7:	75 0a                	jne    801080d3 <setupkvm+0x1f>
    return 0;
801080c9:	b8 00 00 00 00       	mov    $0x0,%eax
801080ce:	e9 98 00 00 00       	jmp    8010816b <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
801080d3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801080da:	00 
801080db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801080e2:	00 
801080e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080e6:	89 04 24             	mov    %eax,(%esp)
801080e9:	e8 00 d0 ff ff       	call   801050ee <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
801080ee:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
801080f5:	e8 da f6 ff ff       	call   801077d4 <p2v>
801080fa:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
801080ff:	76 0c                	jbe    8010810d <setupkvm+0x59>
    panic("PHYSTOP too high");
80108101:	c7 04 24 0b 90 10 80 	movl   $0x8010900b,(%esp)
80108108:	e8 30 84 ff ff       	call   8010053d <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010810d:	c7 45 f4 a0 c4 10 80 	movl   $0x8010c4a0,-0xc(%ebp)
80108114:	eb 49                	jmp    8010815f <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
80108116:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108119:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
8010811c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010811f:	8b 50 04             	mov    0x4(%eax),%edx
80108122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108125:	8b 58 08             	mov    0x8(%eax),%ebx
80108128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010812b:	8b 40 04             	mov    0x4(%eax),%eax
8010812e:	29 c3                	sub    %eax,%ebx
80108130:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108133:	8b 00                	mov    (%eax),%eax
80108135:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108139:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010813d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108141:	89 44 24 04          	mov    %eax,0x4(%esp)
80108145:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108148:	89 04 24             	mov    %eax,(%esp)
8010814b:	e8 d0 fe ff ff       	call   80108020 <mappages>
80108150:	85 c0                	test   %eax,%eax
80108152:	79 07                	jns    8010815b <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108154:	b8 00 00 00 00       	mov    $0x0,%eax
80108159:	eb 10                	jmp    8010816b <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010815b:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010815f:	81 7d f4 e0 c4 10 80 	cmpl   $0x8010c4e0,-0xc(%ebp)
80108166:	72 ae                	jb     80108116 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108168:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010816b:	83 c4 34             	add    $0x34,%esp
8010816e:	5b                   	pop    %ebx
8010816f:	5d                   	pop    %ebp
80108170:	c3                   	ret    

80108171 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(struct cpu *c)
{
80108171:	55                   	push   %ebp
80108172:	89 e5                	mov    %esp,%ebp
80108174:	83 ec 18             	sub    $0x18,%esp
  c->kpgdir = setupkvm();
80108177:	e8 38 ff ff ff       	call   801080b4 <setupkvm>
8010817c:	8b 55 08             	mov    0x8(%ebp),%edx
8010817f:	89 42 04             	mov    %eax,0x4(%edx)
  switchkvm(c);
80108182:	8b 45 08             	mov    0x8(%ebp),%eax
80108185:	89 04 24             	mov    %eax,(%esp)
80108188:	e8 02 00 00 00       	call   8010818f <switchkvm>
}
8010818d:	c9                   	leave  
8010818e:	c3                   	ret    

8010818f <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(struct cpu *c)
{
8010818f:	55                   	push   %ebp
80108190:	89 e5                	mov    %esp,%ebp
80108192:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(c->kpgdir));   // switch to the kernel page table
80108195:	8b 45 08             	mov    0x8(%ebp),%eax
80108198:	8b 40 04             	mov    0x4(%eax),%eax
8010819b:	89 04 24             	mov    %eax,(%esp)
8010819e:	e8 24 f6 ff ff       	call   801077c7 <v2p>
801081a3:	89 04 24             	mov    %eax,(%esp)
801081a6:	e8 11 f6 ff ff       	call   801077bc <lcr3>
}
801081ab:	c9                   	leave  
801081ac:	c3                   	ret    

801081ad <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801081ad:	55                   	push   %ebp
801081ae:	89 e5                	mov    %esp,%ebp
801081b0:	53                   	push   %ebx
801081b1:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801081b4:	e8 2e ce ff ff       	call   80104fe7 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801081b9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081bf:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081c6:	83 c2 20             	add    $0x20,%edx
801081c9:	89 d3                	mov    %edx,%ebx
801081cb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081d2:	83 c2 20             	add    $0x20,%edx
801081d5:	c1 ea 10             	shr    $0x10,%edx
801081d8:	89 d1                	mov    %edx,%ecx
801081da:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801081e1:	83 c2 20             	add    $0x20,%edx
801081e4:	c1 ea 18             	shr    $0x18,%edx
801081e7:	66 c7 80 b8 00 00 00 	movw   $0x67,0xb8(%eax)
801081ee:	67 00 
801081f0:	66 89 98 ba 00 00 00 	mov    %bx,0xba(%eax)
801081f7:	88 88 bc 00 00 00    	mov    %cl,0xbc(%eax)
801081fd:	0f b6 88 bd 00 00 00 	movzbl 0xbd(%eax),%ecx
80108204:	83 e1 f0             	and    $0xfffffff0,%ecx
80108207:	83 c9 09             	or     $0x9,%ecx
8010820a:	88 88 bd 00 00 00    	mov    %cl,0xbd(%eax)
80108210:	0f b6 88 bd 00 00 00 	movzbl 0xbd(%eax),%ecx
80108217:	83 c9 10             	or     $0x10,%ecx
8010821a:	88 88 bd 00 00 00    	mov    %cl,0xbd(%eax)
80108220:	0f b6 88 bd 00 00 00 	movzbl 0xbd(%eax),%ecx
80108227:	83 e1 9f             	and    $0xffffff9f,%ecx
8010822a:	88 88 bd 00 00 00    	mov    %cl,0xbd(%eax)
80108230:	0f b6 88 bd 00 00 00 	movzbl 0xbd(%eax),%ecx
80108237:	83 c9 80             	or     $0xffffff80,%ecx
8010823a:	88 88 bd 00 00 00    	mov    %cl,0xbd(%eax)
80108240:	0f b6 88 be 00 00 00 	movzbl 0xbe(%eax),%ecx
80108247:	83 e1 f0             	and    $0xfffffff0,%ecx
8010824a:	88 88 be 00 00 00    	mov    %cl,0xbe(%eax)
80108250:	0f b6 88 be 00 00 00 	movzbl 0xbe(%eax),%ecx
80108257:	83 e1 ef             	and    $0xffffffef,%ecx
8010825a:	88 88 be 00 00 00    	mov    %cl,0xbe(%eax)
80108260:	0f b6 88 be 00 00 00 	movzbl 0xbe(%eax),%ecx
80108267:	83 e1 df             	and    $0xffffffdf,%ecx
8010826a:	88 88 be 00 00 00    	mov    %cl,0xbe(%eax)
80108270:	0f b6 88 be 00 00 00 	movzbl 0xbe(%eax),%ecx
80108277:	83 c9 40             	or     $0x40,%ecx
8010827a:	88 88 be 00 00 00    	mov    %cl,0xbe(%eax)
80108280:	0f b6 88 be 00 00 00 	movzbl 0xbe(%eax),%ecx
80108287:	83 e1 7f             	and    $0x7f,%ecx
8010828a:	88 88 be 00 00 00    	mov    %cl,0xbe(%eax)
80108290:	88 90 bf 00 00 00    	mov    %dl,0xbf(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108296:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010829c:	0f b6 90 bd 00 00 00 	movzbl 0xbd(%eax),%edx
801082a3:	83 e2 ef             	and    $0xffffffef,%edx
801082a6:	88 90 bd 00 00 00    	mov    %dl,0xbd(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801082ac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082b2:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801082b8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082be:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801082c5:	8b 52 08             	mov    0x8(%edx),%edx
801082c8:	81 c2 00 10 00 00    	add    $0x1000,%edx
801082ce:	89 50 24             	mov    %edx,0x24(%eax)
  ltr(SEG_TSS << 3);
801082d1:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801082d8:	e8 b4 f4 ff ff       	call   80107791 <ltr>
  if(p->pgdir == 0)
801082dd:	8b 45 08             	mov    0x8(%ebp),%eax
801082e0:	8b 40 04             	mov    0x4(%eax),%eax
801082e3:	85 c0                	test   %eax,%eax
801082e5:	75 0c                	jne    801082f3 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
801082e7:	c7 04 24 1c 90 10 80 	movl   $0x8010901c,(%esp)
801082ee:	e8 4a 82 ff ff       	call   8010053d <panic>
  //lcr3(v2p(p->pgdir));  // switch to new address space
  TLBclear();
801082f3:	e8 c7 06 00 00       	call   801089bf <TLBclear>
  popcli();
801082f8:	e8 32 cd ff ff       	call   8010502f <popcli>
}
801082fd:	83 c4 14             	add    $0x14,%esp
80108300:	5b                   	pop    %ebx
80108301:	5d                   	pop    %ebp
80108302:	c3                   	ret    

80108303 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108303:	55                   	push   %ebp
80108304:	89 e5                	mov    %esp,%ebp
80108306:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108309:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108310:	76 0c                	jbe    8010831e <inituvm+0x1b>
    panic("inituvm: more than a page");
80108312:	c7 04 24 30 90 10 80 	movl   $0x80109030,(%esp)
80108319:	e8 1f 82 ff ff       	call   8010053d <panic>
  mem = kalloc();
8010831e:	e8 e8 a7 ff ff       	call   80102b0b <kalloc>
80108323:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108326:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010832d:	00 
8010832e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108335:	00 
80108336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108339:	89 04 24             	mov    %eax,(%esp)
8010833c:	e8 ad cd ff ff       	call   801050ee <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108341:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108344:	89 04 24             	mov    %eax,(%esp)
80108347:	e8 7b f4 ff ff       	call   801077c7 <v2p>
8010834c:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108353:	00 
80108354:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108358:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010835f:	00 
80108360:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108367:	00 
80108368:	8b 45 08             	mov    0x8(%ebp),%eax
8010836b:	89 04 24             	mov    %eax,(%esp)
8010836e:	e8 ad fc ff ff       	call   80108020 <mappages>
  memmove(mem, init, sz);
80108373:	8b 45 10             	mov    0x10(%ebp),%eax
80108376:	89 44 24 08          	mov    %eax,0x8(%esp)
8010837a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010837d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108384:	89 04 24             	mov    %eax,(%esp)
80108387:	e8 35 ce ff ff       	call   801051c1 <memmove>
}
8010838c:	c9                   	leave  
8010838d:	c3                   	ret    

8010838e <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010838e:	55                   	push   %ebp
8010838f:	89 e5                	mov    %esp,%ebp
80108391:	53                   	push   %ebx
80108392:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108395:	8b 45 0c             	mov    0xc(%ebp),%eax
80108398:	25 ff 0f 00 00       	and    $0xfff,%eax
8010839d:	85 c0                	test   %eax,%eax
8010839f:	74 0c                	je     801083ad <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801083a1:	c7 04 24 4c 90 10 80 	movl   $0x8010904c,(%esp)
801083a8:	e8 90 81 ff ff       	call   8010053d <panic>
  for(i = 0; i < sz; i += PGSIZE){
801083ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801083b4:	e9 ad 00 00 00       	jmp    80108466 <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801083b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bc:	8b 55 0c             	mov    0xc(%ebp),%edx
801083bf:	01 d0                	add    %edx,%eax
801083c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801083c8:	00 
801083c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801083cd:	8b 45 08             	mov    0x8(%ebp),%eax
801083d0:	89 04 24             	mov    %eax,(%esp)
801083d3:	e8 b2 fb ff ff       	call   80107f8a <walkpgdir>
801083d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801083db:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801083df:	75 0c                	jne    801083ed <loaduvm+0x5f>
      panic("loaduvm: address should exist");
801083e1:	c7 04 24 6f 90 10 80 	movl   $0x8010906f,(%esp)
801083e8:	e8 50 81 ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
801083ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083f0:	8b 00                	mov    (%eax),%eax
801083f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801083fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fd:	8b 55 18             	mov    0x18(%ebp),%edx
80108400:	89 d1                	mov    %edx,%ecx
80108402:	29 c1                	sub    %eax,%ecx
80108404:	89 c8                	mov    %ecx,%eax
80108406:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010840b:	77 11                	ja     8010841e <loaduvm+0x90>
      n = sz - i;
8010840d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108410:	8b 55 18             	mov    0x18(%ebp),%edx
80108413:	89 d1                	mov    %edx,%ecx
80108415:	29 c1                	sub    %eax,%ecx
80108417:	89 c8                	mov    %ecx,%eax
80108419:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010841c:	eb 07                	jmp    80108425 <loaduvm+0x97>
    else
      n = PGSIZE;
8010841e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108428:	8b 55 14             	mov    0x14(%ebp),%edx
8010842b:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010842e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108431:	89 04 24             	mov    %eax,(%esp)
80108434:	e8 9b f3 ff ff       	call   801077d4 <p2v>
80108439:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010843c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108440:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108444:	89 44 24 04          	mov    %eax,0x4(%esp)
80108448:	8b 45 10             	mov    0x10(%ebp),%eax
8010844b:	89 04 24             	mov    %eax,(%esp)
8010844e:	e8 17 99 ff ff       	call   80101d6a <readi>
80108453:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108456:	74 07                	je     8010845f <loaduvm+0xd1>
      return -1;
80108458:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010845d:	eb 18                	jmp    80108477 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010845f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108469:	3b 45 18             	cmp    0x18(%ebp),%eax
8010846c:	0f 82 47 ff ff ff    	jb     801083b9 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108472:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108477:	83 c4 24             	add    $0x24,%esp
8010847a:	5b                   	pop    %ebx
8010847b:	5d                   	pop    %ebp
8010847c:	c3                   	ret    

8010847d <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010847d:	55                   	push   %ebp
8010847e:	89 e5                	mov    %esp,%ebp
80108480:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108483:	8b 45 10             	mov    0x10(%ebp),%eax
80108486:	85 c0                	test   %eax,%eax
80108488:	79 0a                	jns    80108494 <allocuvm+0x17>
    return 0;
8010848a:	b8 00 00 00 00       	mov    $0x0,%eax
8010848f:	e9 c1 00 00 00       	jmp    80108555 <allocuvm+0xd8>
  if(newsz < oldsz)
80108494:	8b 45 10             	mov    0x10(%ebp),%eax
80108497:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010849a:	73 08                	jae    801084a4 <allocuvm+0x27>
    return oldsz;
8010849c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010849f:	e9 b1 00 00 00       	jmp    80108555 <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801084a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801084a7:	05 ff 0f 00 00       	add    $0xfff,%eax
801084ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801084b4:	e9 8d 00 00 00       	jmp    80108546 <allocuvm+0xc9>
    mem = kalloc();
801084b9:	e8 4d a6 ff ff       	call   80102b0b <kalloc>
801084be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801084c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084c5:	75 2c                	jne    801084f3 <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801084c7:	c7 04 24 8d 90 10 80 	movl   $0x8010908d,(%esp)
801084ce:	e8 ce 7e ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801084d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d6:	89 44 24 08          	mov    %eax,0x8(%esp)
801084da:	8b 45 10             	mov    0x10(%ebp),%eax
801084dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801084e1:	8b 45 08             	mov    0x8(%ebp),%eax
801084e4:	89 04 24             	mov    %eax,(%esp)
801084e7:	e8 6b 00 00 00       	call   80108557 <deallocuvm>
      return 0;
801084ec:	b8 00 00 00 00       	mov    $0x0,%eax
801084f1:	eb 62                	jmp    80108555 <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
801084f3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801084fa:	00 
801084fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108502:	00 
80108503:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108506:	89 04 24             	mov    %eax,(%esp)
80108509:	e8 e0 cb ff ff       	call   801050ee <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010850e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108511:	89 04 24             	mov    %eax,(%esp)
80108514:	e8 ae f2 ff ff       	call   801077c7 <v2p>
80108519:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010851c:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108523:	00 
80108524:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108528:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010852f:	00 
80108530:	89 54 24 04          	mov    %edx,0x4(%esp)
80108534:	8b 45 08             	mov    0x8(%ebp),%eax
80108537:	89 04 24             	mov    %eax,(%esp)
8010853a:	e8 e1 fa ff ff       	call   80108020 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010853f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108549:	3b 45 10             	cmp    0x10(%ebp),%eax
8010854c:	0f 82 67 ff ff ff    	jb     801084b9 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108552:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108555:	c9                   	leave  
80108556:	c3                   	ret    

80108557 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108557:	55                   	push   %ebp
80108558:	89 e5                	mov    %esp,%ebp
8010855a:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010855d:	8b 45 10             	mov    0x10(%ebp),%eax
80108560:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108563:	72 08                	jb     8010856d <deallocuvm+0x16>
    return oldsz;
80108565:	8b 45 0c             	mov    0xc(%ebp),%eax
80108568:	e9 a4 00 00 00       	jmp    80108611 <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
8010856d:	8b 45 10             	mov    0x10(%ebp),%eax
80108570:	05 ff 0f 00 00       	add    $0xfff,%eax
80108575:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010857a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010857d:	e9 80 00 00 00       	jmp    80108602 <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108585:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010858c:	00 
8010858d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108591:	8b 45 08             	mov    0x8(%ebp),%eax
80108594:	89 04 24             	mov    %eax,(%esp)
80108597:	e8 ee f9 ff ff       	call   80107f8a <walkpgdir>
8010859c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
8010859f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085a3:	75 09                	jne    801085ae <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801085a5:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801085ac:	eb 4d                	jmp    801085fb <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801085ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b1:	8b 00                	mov    (%eax),%eax
801085b3:	83 e0 01             	and    $0x1,%eax
801085b6:	84 c0                	test   %al,%al
801085b8:	74 41                	je     801085fb <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801085ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085bd:	8b 00                	mov    (%eax),%eax
801085bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801085c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085cb:	75 0c                	jne    801085d9 <deallocuvm+0x82>
        panic("kfree");
801085cd:	c7 04 24 a5 90 10 80 	movl   $0x801090a5,(%esp)
801085d4:	e8 64 7f ff ff       	call   8010053d <panic>
      char *v = p2v(pa);
801085d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085dc:	89 04 24             	mov    %eax,(%esp)
801085df:	e8 f0 f1 ff ff       	call   801077d4 <p2v>
801085e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801085e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801085ea:	89 04 24             	mov    %eax,(%esp)
801085ed:	e8 80 a4 ff ff       	call   80102a72 <kfree>
      *pte = 0;
801085f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801085fb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108605:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108608:	0f 82 74 ff ff ff    	jb     80108582 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010860e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108611:	c9                   	leave  
80108612:	c3                   	ret    

80108613 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108613:	55                   	push   %ebp
80108614:	89 e5                	mov    %esp,%ebp
80108616:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108619:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010861d:	75 0c                	jne    8010862b <freevm+0x18>
    panic("freevm: no pgdir");
8010861f:	c7 04 24 ab 90 10 80 	movl   $0x801090ab,(%esp)
80108626:	e8 12 7f ff ff       	call   8010053d <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010862b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108632:	00 
80108633:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010863a:	80 
8010863b:	8b 45 08             	mov    0x8(%ebp),%eax
8010863e:	89 04 24             	mov    %eax,(%esp)
80108641:	e8 11 ff ff ff       	call   80108557 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108646:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010864d:	eb 3c                	jmp    8010868b <freevm+0x78>
    if(pgdir[i] & PTE_P){
8010864f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108652:	c1 e0 02             	shl    $0x2,%eax
80108655:	03 45 08             	add    0x8(%ebp),%eax
80108658:	8b 00                	mov    (%eax),%eax
8010865a:	83 e0 01             	and    $0x1,%eax
8010865d:	84 c0                	test   %al,%al
8010865f:	74 26                	je     80108687 <freevm+0x74>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108664:	c1 e0 02             	shl    $0x2,%eax
80108667:	03 45 08             	add    0x8(%ebp),%eax
8010866a:	8b 00                	mov    (%eax),%eax
8010866c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108671:	89 04 24             	mov    %eax,(%esp)
80108674:	e8 5b f1 ff ff       	call   801077d4 <p2v>
80108679:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010867c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010867f:	89 04 24             	mov    %eax,(%esp)
80108682:	e8 eb a3 ff ff       	call   80102a72 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108687:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010868b:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108692:	76 bb                	jbe    8010864f <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108694:	8b 45 08             	mov    0x8(%ebp),%eax
80108697:	89 04 24             	mov    %eax,(%esp)
8010869a:	e8 d3 a3 ff ff       	call   80102a72 <kfree>
}
8010869f:	c9                   	leave  
801086a0:	c3                   	ret    

801086a1 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801086a1:	55                   	push   %ebp
801086a2:	89 e5                	mov    %esp,%ebp
801086a4:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086ae:	00 
801086af:	8b 45 0c             	mov    0xc(%ebp),%eax
801086b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801086b6:	8b 45 08             	mov    0x8(%ebp),%eax
801086b9:	89 04 24             	mov    %eax,(%esp)
801086bc:	e8 c9 f8 ff ff       	call   80107f8a <walkpgdir>
801086c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801086c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801086c8:	75 0c                	jne    801086d6 <clearpteu+0x35>
    panic("clearpteu");
801086ca:	c7 04 24 bc 90 10 80 	movl   $0x801090bc,(%esp)
801086d1:	e8 67 7e ff ff       	call   8010053d <panic>
  *pte &= ~PTE_U;
801086d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d9:	8b 00                	mov    (%eax),%eax
801086db:	89 c2                	mov    %eax,%edx
801086dd:	83 e2 fb             	and    $0xfffffffb,%edx
801086e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e3:	89 10                	mov    %edx,(%eax)
}
801086e5:	c9                   	leave  
801086e6:	c3                   	ret    

801086e7 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801086e7:	55                   	push   %ebp
801086e8:	89 e5                	mov    %esp,%ebp
801086ea:	53                   	push   %ebx
801086eb:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801086ee:	e8 c1 f9 ff ff       	call   801080b4 <setupkvm>
801086f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801086f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086fa:	75 0a                	jne    80108706 <copyuvm+0x1f>
    return 0;
801086fc:	b8 00 00 00 00       	mov    $0x0,%eax
80108701:	e9 fd 00 00 00       	jmp    80108803 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80108706:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010870d:	e9 cc 00 00 00       	jmp    801087de <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108715:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010871c:	00 
8010871d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108721:	8b 45 08             	mov    0x8(%ebp),%eax
80108724:	89 04 24             	mov    %eax,(%esp)
80108727:	e8 5e f8 ff ff       	call   80107f8a <walkpgdir>
8010872c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010872f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108733:	75 0c                	jne    80108741 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80108735:	c7 04 24 c6 90 10 80 	movl   $0x801090c6,(%esp)
8010873c:	e8 fc 7d ff ff       	call   8010053d <panic>
    if(!(*pte & PTE_P))
80108741:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108744:	8b 00                	mov    (%eax),%eax
80108746:	83 e0 01             	and    $0x1,%eax
80108749:	85 c0                	test   %eax,%eax
8010874b:	75 0c                	jne    80108759 <copyuvm+0x72>
      panic("copyuvm: page not present");
8010874d:	c7 04 24 e0 90 10 80 	movl   $0x801090e0,(%esp)
80108754:	e8 e4 7d ff ff       	call   8010053d <panic>
    pa = PTE_ADDR(*pte);
80108759:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010875c:	8b 00                	mov    (%eax),%eax
8010875e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108763:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108766:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108769:	8b 00                	mov    (%eax),%eax
8010876b:	25 ff 0f 00 00       	and    $0xfff,%eax
80108770:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108773:	e8 93 a3 ff ff       	call   80102b0b <kalloc>
80108778:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010877b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010877f:	74 6e                	je     801087ef <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108781:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108784:	89 04 24             	mov    %eax,(%esp)
80108787:	e8 48 f0 ff ff       	call   801077d4 <p2v>
8010878c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108793:	00 
80108794:	89 44 24 04          	mov    %eax,0x4(%esp)
80108798:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010879b:	89 04 24             	mov    %eax,(%esp)
8010879e:	e8 1e ca ff ff       	call   801051c1 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801087a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801087a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087a9:	89 04 24             	mov    %eax,(%esp)
801087ac:	e8 16 f0 ff ff       	call   801077c7 <v2p>
801087b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801087b4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801087b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
801087bc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087c3:	00 
801087c4:	89 54 24 04          	mov    %edx,0x4(%esp)
801087c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087cb:	89 04 24             	mov    %eax,(%esp)
801087ce:	e8 4d f8 ff ff       	call   80108020 <mappages>
801087d3:	85 c0                	test   %eax,%eax
801087d5:	78 1b                	js     801087f2 <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801087d7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801087de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087e4:	0f 82 28 ff ff ff    	jb     80108712 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
801087ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087ed:	eb 14                	jmp    80108803 <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
801087ef:	90                   	nop
801087f0:	eb 01                	jmp    801087f3 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
801087f2:	90                   	nop
  }
  return d;

bad:
  freevm(d);
801087f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087f6:	89 04 24             	mov    %eax,(%esp)
801087f9:	e8 15 fe ff ff       	call   80108613 <freevm>
  return 0;
801087fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108803:	83 c4 44             	add    $0x44,%esp
80108806:	5b                   	pop    %ebx
80108807:	5d                   	pop    %ebp
80108808:	c3                   	ret    

80108809 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108809:	55                   	push   %ebp
8010880a:	89 e5                	mov    %esp,%ebp
8010880c:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010880f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108816:	00 
80108817:	8b 45 0c             	mov    0xc(%ebp),%eax
8010881a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010881e:	8b 45 08             	mov    0x8(%ebp),%eax
80108821:	89 04 24             	mov    %eax,(%esp)
80108824:	e8 61 f7 ff ff       	call   80107f8a <walkpgdir>
80108829:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010882c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882f:	8b 00                	mov    (%eax),%eax
80108831:	83 e0 01             	and    $0x1,%eax
80108834:	85 c0                	test   %eax,%eax
80108836:	75 07                	jne    8010883f <uva2ka+0x36>
    return 0;
80108838:	b8 00 00 00 00       	mov    $0x0,%eax
8010883d:	eb 25                	jmp    80108864 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
8010883f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108842:	8b 00                	mov    (%eax),%eax
80108844:	83 e0 04             	and    $0x4,%eax
80108847:	85 c0                	test   %eax,%eax
80108849:	75 07                	jne    80108852 <uva2ka+0x49>
    return 0;
8010884b:	b8 00 00 00 00       	mov    $0x0,%eax
80108850:	eb 12                	jmp    80108864 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108855:	8b 00                	mov    (%eax),%eax
80108857:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010885c:	89 04 24             	mov    %eax,(%esp)
8010885f:	e8 70 ef ff ff       	call   801077d4 <p2v>
}
80108864:	c9                   	leave  
80108865:	c3                   	ret    

80108866 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108866:	55                   	push   %ebp
80108867:	89 e5                	mov    %esp,%ebp
80108869:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010886c:	8b 45 10             	mov    0x10(%ebp),%eax
8010886f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108872:	e9 8b 00 00 00       	jmp    80108902 <copyout+0x9c>
    va0 = (uint)PGROUNDDOWN(va);
80108877:	8b 45 0c             	mov    0xc(%ebp),%eax
8010887a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010887f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108882:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108885:	89 44 24 04          	mov    %eax,0x4(%esp)
80108889:	8b 45 08             	mov    0x8(%ebp),%eax
8010888c:	89 04 24             	mov    %eax,(%esp)
8010888f:	e8 75 ff ff ff       	call   80108809 <uva2ka>
80108894:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108897:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010889b:	75 07                	jne    801088a4 <copyout+0x3e>
      return -1;
8010889d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088a2:	eb 6d                	jmp    80108911 <copyout+0xab>
    n = PGSIZE - (va - va0);
801088a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801088a7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801088aa:	89 d1                	mov    %edx,%ecx
801088ac:	29 c1                	sub    %eax,%ecx
801088ae:	89 c8                	mov    %ecx,%eax
801088b0:	05 00 10 00 00       	add    $0x1000,%eax
801088b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801088b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088bb:	3b 45 14             	cmp    0x14(%ebp),%eax
801088be:	76 06                	jbe    801088c6 <copyout+0x60>
      n = len;
801088c0:	8b 45 14             	mov    0x14(%ebp),%eax
801088c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801088c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801088cc:	89 d1                	mov    %edx,%ecx
801088ce:	29 c1                	sub    %eax,%ecx
801088d0:	89 c8                	mov    %ecx,%eax
801088d2:	03 45 e8             	add    -0x18(%ebp),%eax
801088d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801088d8:	89 54 24 08          	mov    %edx,0x8(%esp)
801088dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801088df:	89 54 24 04          	mov    %edx,0x4(%esp)
801088e3:	89 04 24             	mov    %eax,(%esp)
801088e6:	e8 d6 c8 ff ff       	call   801051c1 <memmove>
    len -= n;
801088eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088ee:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801088f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088f4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801088f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088fa:	05 00 10 00 00       	add    $0x1000,%eax
801088ff:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108902:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108906:	0f 85 6b ff ff ff    	jne    80108877 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010890c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108911:	c9                   	leave  
80108912:	c3                   	ret    

80108913 <TLBhandlePageFault>:

int TLBhandlePageFault(struct proc* p, void* va){
80108913:	55                   	push   %ebp
80108914:	89 e5                	mov    %esp,%ebp
80108916:	83 ec 28             	sub    $0x28,%esp
//	cprintf("%d | [%s] page fault for process: %d with virtual address: 0x%x \n",proc->pid, __FUNCTION__, p->pid, va);

	//Getting the pte from the process page directory
	pte_t* desiredPageTableEntry = walkpgdir(p->pgdir, (const void*)va, 0);
80108919:	8b 45 08             	mov    0x8(%ebp),%eax
8010891c:	8b 40 04             	mov    0x4(%eax),%eax
8010891f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108926:	00 
80108927:	8b 55 0c             	mov    0xc(%ebp),%edx
8010892a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010892e:	89 04 24             	mov    %eax,(%esp)
80108931:	e8 54 f6 ff ff       	call   80107f8a <walkpgdir>
80108936:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if(desiredPageTableEntry == 0 || ( (*desiredPageTableEntry & PTE_P)==0) ){ //todo : should panic?
80108939:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010893d:	74 0c                	je     8010894b <TLBhandlePageFault+0x38>
8010893f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108942:	8b 00                	mov    (%eax),%eax
80108944:	83 e0 01             	and    $0x1,%eax
80108947:	85 c0                	test   %eax,%eax
80108949:	75 07                	jne    80108952 <TLBhandlePageFault+0x3f>
		//cprintf("%d | [%s] error finding page table entry \n",proc->pid, __FUNCTION__);
		return - 1;
8010894b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108950:	eb 6b                	jmp    801089bd <TLBhandlePageFault+0xaa>
	}

//	cprintf("%d | [%s] found page table entry. loading into TLB \n",proc->pid, __FUNCTION__);

	//Making space for the pte in the tlb
	pte_t* emptySpaceInTLB = walkpgdir(cpu->kpgdir, (const void*)va, 1);
80108952:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108958:	8b 40 04             	mov    0x4(%eax),%eax
8010895b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108962:	00 
80108963:	8b 55 0c             	mov    0xc(%ebp),%edx
80108966:	89 54 24 04          	mov    %edx,0x4(%esp)
8010896a:	89 04 24             	mov    %eax,(%esp)
8010896d:	e8 18 f6 ff ff       	call   80107f8a <walkpgdir>
80108972:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if(emptySpaceInTLB == 0){ //todo : should panic?
80108975:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108979:	75 28                	jne    801089a3 <TLBhandlePageFault+0x90>
		cprintf("%d | [%s] error - no free space in TLB! \n",proc->pid, __FUNCTION__);
8010897b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108981:	8b 40 10             	mov    0x10(%eax),%eax
80108984:	c7 44 24 08 26 91 10 	movl   $0x80109126,0x8(%esp)
8010898b:	80 
8010898c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108990:	c7 04 24 fc 90 10 80 	movl   $0x801090fc,(%esp)
80108997:	e8 05 7a ff ff       	call   801003a1 <cprintf>
		return -1;
8010899c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089a1:	eb 1a                	jmp    801089bd <TLBhandlePageFault+0xaa>
	}

	//Copying the pte to the TLB
	*emptySpaceInTLB = *desiredPageTableEntry;
801089a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a6:	8b 10                	mov    (%eax),%edx
801089a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ab:	89 10                	mov    %edx,(%eax)

	//register in the TLB structure
	tlb_insert(va);
801089ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801089b0:	89 04 24             	mov    %eax,(%esp)
801089b3:	e8 47 f0 ff ff       	call   801079ff <tlb_insert>
	return 0;
801089b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801089bd:	c9                   	leave  
801089be:	c3                   	ret    

801089bf <TLBclear>:

void TLBclear(){
801089bf:	55                   	push   %ebp
801089c0:	89 e5                	mov    %esp,%ebp
801089c2:	83 ec 08             	sub    $0x8,%esp
//	cprintf("%d | [%s] Clearing TLB (probably because of a context switch) \n",proc->pid, __FUNCTION__);
	tlb_clear();
801089c5:	e8 71 ef ff ff       	call   8010793b <tlb_clear>
}
801089ca:	c9                   	leave  
801089cb:	c3                   	ret    
