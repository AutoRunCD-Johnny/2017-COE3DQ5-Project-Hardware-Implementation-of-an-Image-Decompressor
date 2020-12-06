def f0():
    raw=file('IDCT_C.txt')
    out=file('C_mif.txt','w')
    n=0
    data=''
    temp=raw.readline()
    while(temp):
        #print temp
        for i in temp:
            if(i!=',' and i!='\n'):
                data=data+i
                #print data
            else:
                out.write(str(n)+':'+data+';\n')
                data=''
                n=n+1
        temp=raw.readline()     
    raw.close()
    out.close()

def f1():
    raw=file('IDCT_C_transpose.txt')
    out=file('Ct_mif.txt','w')
    n=0
    data=''
    temp=raw.readline()
    while(temp):
        #print temp
        for i in temp:
            if(i!=',' and i!='\n'):
                data=data+i
                #print data
            else:
                out.write(str(n)+':'+data+';\n')
                data=''
                n=n+1
        temp=raw.readline()     
    raw.close()
    out.close()

def f2():
    raw=file('IDCT_C_t_hex.txt')
    out=file('Ct_hex_mif.txt','w')
    n=0
    data=''
    temp=[raw.readline(),raw.readline()]
    while(temp[0]):
        for j in temp:
            for i in j:
                if(i!='\n'):
                    data=data+i
                    #print data
        out.write(str(n)+':'+data+';\n')
        data=''
        n=n+1
        temp=[raw.readline(),raw.readline()]
    raw.close()
    out.close()
    
def f3():
    raw=[0, 1, 8,16, 9, 2, 3,10,17,24,32,25,18,11, 4, 5,12,19,26,33,40,48,41,34,27,20,13, 6, 7,14,21,28,
	                           35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63]
    out=file('zigzag_order.txt','w')  
    n=64
    for i in raw:
        out.write(str(n)+':'+str(i)+';\n')
        n=n+1
    out.close


    
