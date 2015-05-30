void tbl_clear_entry(struct tlb_entry_wrapper* entry){
	*(*entry).pte = 0;

	memset(entry, 0, sizeof(struct tlb_entry_wrapper));
	cpu->tlb.size --;
}

void tlb_clear(){
	int i;
	for(i = 0; i < TLB_MAX_SIZE; i++){
		if(!cpu->tlb.arr[i].isUsed) continue;
		//clear pte
		tbl_clear_entry(&cpu->tlb.arr[i]);
	}
}

void tlb_insert(pte_t* pte){
	int i;
	if(cpu->tlb.size == TLB_MAX_SIZE){
		//take out the first one and shift left
		tbl_clear_entry(&cpu->tlb.arr[0]);
		for(i = 1; i < TLB_MAX_SIZE; i++){
			cpu->tlb.arr[i-1] = cpu->tlb.arr[i];
		}
		cpu->tlb.arr[TLB_MAX_SIZE-1].isUsed = 0;
		cpu->tlb.arr[TLB_MAX_SIZE-1].pte = 0;
	}
	for(i = 0; i < TLB_MAX_SIZE; i++){
		if(!cpu->tlb.arr[i].isUsed){
			cpu->tlb.arr[i].pte = pte;
			cpu->tlb.arr[i].isUsed = 1;
			cpu->tlb.size++;
			break;
		}
	}
}
