#!/bin/awk

# write by    : oldmanpushcart@gmail.com
# date        : 2014-12-20
# version     : 0.0.1

/tid=0x[a-z0-9]+ nid=0x[a-z0-9]+/,/^$/{

	// head line
	if($0~/tid=0x/&&$0~/nid=0x/){
		
		// take tid
		if(match($0,/tid=0x[a-z0-9]+/)){
			tid=substr($0,RSTART,RLENGTH)
		}
	
		// take nid
		if(match($0,/nid=0x[a-z0-9]+/)){
			nid=substr($0,RSTART,RLENGTH)
		}

	}

	// state line
	if($0~/java\.lang\.Thread\.State: /) {
		if(match($0,/NEW|RUNNABLE|BLOCKED|WAITING|TIMED_WAITING|TERMINATED/)){
			state=substr($0,RSTART,RLENGTH)
		}
	}
	
	// code line
	if($0~/^\tat /&&match($0,/\([^)]+\)/)){

		# take code
		code=substr($0,RSTART,RLENGTH)
		gsub(" ","_",code)

		# take method
		method=substr($0,5,index($0,"(")-5)

		# output
		r[NR]=sprintf("%s\t%s\t%s\t%s\t%s",tid,nid,state,method,code)

		# sum
		sum_method[method]++
		sum_code[code]++
		
		# format output, max col length
		m[1]=max(m[1],length(tid))
		m[2]=max(m[2],length(nid))
		m[3]=max(m[3],length(state))
		m[4]=max(m[4],length(method))
		m[5]=max(m[5],length(code))

	}	
}

function max(a,b){
	return a>b?a:b
}

END{
	for(i in r){
		split(r[i],col,"\t")
		printf("%-"m[1]"s\t%-"m[2]"s\t%-"m[3]"s\t%-"m[4]"s\t%d\t%-"m[5]"s\t%d\n",
			col[1],col[2],col[3],col[4],sum_method[col[4]],col[5],sum_code[col[5]])
	}
}
