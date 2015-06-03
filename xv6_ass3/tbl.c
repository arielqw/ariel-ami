void tlb_print(){
	cprintf("%d | [%s] TLB: HEAD->", proc->pid, __FUNCTION__);
	int i;
	for(i=0; i< cpu->tlb.size; i++){
		if(cpu->tlb.arr[i].isUsed){
			cprintf("(0x%x) => ", cpu->tlb.arr[i].va);
		}
	}
	cprintf("->END \n");
}

void tbl_clear_entry(struct tlb_entry_wrapper* entry){
	//pointer to second level page table
	pte_t* pgtab = (pte_t*)p2v(PTE_ADDR( cpu->kpgdir[PDX(entry->va)]));

	//remove entry
	pgtab[PTX(entry->va)] = 0;

	//check to see if page table is still in use
	int isUsingPageTable = 0;
	pte_t i;
	for(i=0; i < NPTENTRIES; i++){
		if( (pgtab[i] & PTE_P) != 0){ // is Present
//			if(pgtab[i] != 0){
				isUsingPageTable = 1;
				break;
//			}
		}

	}

	//deallocate page table if no longer in use
	if(!isUsingPageTable){
		kfree((char*)pgtab);
		//remove page table pointer from page directory
		cpu->kpgdir[PDX(entry->va)] = 0;


		//cprintf("%d | [%s] deallocated page!", proc->pid, __FUNCTION__);

	}


	//remove from TLB
	memset(entry, 0, sizeof(struct tlb_entry_wrapper));
	cpu->tlb.size --;
}

void tlb_clear(){

	//clear fifo tlb
	int i;
	for(i = 0; i < TLB_MAX_SIZE; i++){
		if(!cpu->tlb.arr[i].isUsed) continue;
		//clear pte
		tbl_clear_entry(&cpu->tlb.arr[i]);
	}

	//clear all tlb
	pte_t p;
	pte_t* pgtab;
	for(p=0; p<PGSIZE/8; p++){
		if( (cpu->kpgdir[p] & PTE_P) != 0 ){ //available in physical memory
			//cprintf("delete");
			pgtab = (pte_t*)p2v(PTE_ADDR( cpu->kpgdir[p]));
			if(pgtab != 0){
				kfree((char*)pgtab);
			}

		}
		cpu->kpgdir[p] = 0;

	}


}

void tlb_insert(void* va){
	//cprintf("%d | [%s] insert 0x%x \n", proc->pid, __FUNCTION__, va);
	int i;

	if(cpu->tlb.size == TLB_MAX_SIZE){
		//cprintf("%d | [%s] no room! \n", proc->pid, __FUNCTION__);

		//take out the first one and shift left
		tbl_clear_entry(&cpu->tlb.arr[0]);
		for(i = 1; i < TLB_MAX_SIZE; i++){
			cpu->tlb.arr[i-1] = cpu->tlb.arr[i];
		}
		cpu->tlb.arr[TLB_MAX_SIZE-1].isUsed = 0;
		cpu->tlb.arr[TLB_MAX_SIZE-1].va = 0;
	}

	for(i = 0; i < TLB_MAX_SIZE; i++){
		if(!cpu->tlb.arr[i].isUsed){
			//cprintf("%d | [%s] adding 0x%x ! \n", proc->pid, __FUNCTION__, va);

			cpu->tlb.arr[i].va = va;
			cpu->tlb.arr[i].isUsed = 1;
			cpu->tlb.size++;
			break;
		}
	}
	//tlb_print();
}
