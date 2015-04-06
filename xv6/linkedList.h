#define LINKED_LIST_SIZE 64

typedef struct node
{
	int id;
	struct proc* data;
    struct node* next;				/* address to next node */
    struct node* prev;				/* address to prev node */
    int used;
    void (*clean_up)(struct node* link);
} node;

typedef struct linkedList
{
	node* head;
	node* tail;
	int size;
	int max_size;
	struct node nodes[LINKED_LIST_SIZE];
	void (*add_last)(struct linkedList* list, node* link);
	void (*add)(struct linkedList* list, int id, struct proc* p);
	void (*remove_first)(struct linkedList* list);
	void (*print)(struct linkedList* list);
	node* (*get_link)(struct linkedList* list,int position);
	int (*remove_link)(struct linkedList* list,int id);
	node* (*search)(struct linkedList* list,int id);
} linkedList;


void add(struct linkedList* list, int id, struct proc* p);

struct node* create_link(linkedList* list);

void add_last(linkedList* list, node* link);

void remove_first(linkedList* list);

void clean_up(struct node* link);

void init_linkedList(linkedList* list,int fixed_size);

void print(linkedList* list);

node* get_link(linkedList* list,int position);

void clean_up(node* link);

node* search(linkedList* list,int id);

int remove_link(linkedList* list,int id);
