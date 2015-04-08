#include "linkedList.h"
#include "types.h"
#include "defs.h"

struct node* create_link(linkedList* list){
	int i;
	for (i = 0; i < LINKED_LIST_SIZE; i++) {
		if(!list->nodes[i].used){
			list->nodes[i].used = 1;
			return &list->nodes[i];
		}
	}

	//error not found
	cprintf("Error: linkedlist: cant create new link, list at full capacity!\n");
	return 0;
}

void clean_up(struct node* link){
	link->id = 0;
	link->data = 0;
	link->next = 0;
	link->prev = 0;
	link->used = 0;
}

void add_last(linkedList* list, node* link){
	if(list->head == 0){
		list->head = link;
		list->tail = link;
		list->size++;
	}
	else{
		link->prev = list->tail;
		list->tail->next = link;
		list->tail = link;
		list->size++;
	}
}

void add(struct linkedList* list, int id, struct proc* p){
//	if( search(list,id) != 0 ) return; //add unique

	//cprintf("(+%d)", id);
	node* node;
	node = create_link(list);
	node->id = id;
	node->data = p;
	list->add_last(list,node);
	//print(list);
}


struct proc* remove_first(linkedList* list){
	struct proc* p;
	node* tmp;
	if( list->head == 0 ){
		cprintf("ERROR: list is empty. cant remove 1st link");
		return 0;
	}
	tmp = list->head;
	//cprintf("(-%d)", tmp->id);
	p = tmp->data;
	list->head = list->head->next;
	tmp->clean_up(tmp);
	if(list->head != 0){
		list->head->prev = 0;
	}
	list->size--;
	return p;
}
void init_linkedList(linkedList* list,int fixed_size){
	int i;
	list->head = 0;
	list->tail = 0;
	list->size = 0;
	list->max_size = fixed_size;
	list->add_last = add_last;
	list->add = add;
	list->remove_first = remove_first;
	list->print = print;
	list->get_link = get_link;
	list->remove_link = remove_link;
	list->search = search;

	for(i=0; i < fixed_size; i++){
		list->nodes[i].clean_up = clean_up;
		list->nodes[i].clean_up(&list->nodes[i]);
	}

}

void clean_list(linkedList* list){
	while(list->size > 0){
		list->remove_first(list);
	}
}

void print(linkedList* list){
	node* link = list->head;

	cprintf("LinkedList content:\n");

	cprintf("HEAD");
	while(link != 0){
		cprintf(" => [%d ,0x%x] ",link->id,link->data);
		link = link->next;
	}
	cprintf("<= TAIL \n");

}

node* get_link(linkedList* list,int position){
	node* link = list->head;
	while(position > 0 && link != 0){
		link = link->next;
		position--;
	}
	if(position == 0) return link;

	return 0;
}
node* search(linkedList* list, int id){
	node* p = list->head;

	while(p != 0){
		if(p->id == id){
			return p;
		}
		p=p->next;
	}
	return 0;
}


int remove_link(linkedList* list,int id){
	node* tmp = search(list,id);
	cprintf("requested: %d, deleting, found:(%d) %d\n", id, tmp, tmp->id);
	if(tmp != 0){
		if(tmp->prev == 0){ /* was head*/
			list->head = tmp->next;
		}
		else{
			tmp->prev->next = tmp->next;
			if(tmp->next != 0){
				tmp->next->prev = tmp->prev;
			}
			else{
				list->tail = tmp->prev;
			}


		}
		tmp->clean_up(tmp);
		//list->print(list);

		return 1;
	}
	return 0;
}
