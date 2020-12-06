for i=1:8;
    for j=1:8;
        if(i==1);
            A(i,j)=int16(fix(sqrt(1/8)*cos(((i-1)*pi/8)*(0.5+(j-1)))*4096));
        else;
            A(i,j)=int16(fix(sqrt(2/8)*cos(((i-1)*pi/8)*(0.5+(j-1)))*4096));
        end
    end
end

for i=1:8;
    for j=1:8;
        if(A(i,j)<0);
            uA(i,j)=uint16(2^16+double(A(i,j)));
        else
            uA(i,j)=uint16(A(i,j));
        end
    end
end


A
A_t=A'
uA
uA_t=uA'
%dec2hex read in transposed order
hex_uA_t=dec2hex(uA);



dlmwrite('C:\Users\Johnny Jiang\OneDrive\Engineering\COMP-ENG 3DQ5\project\IDCT_C.txt',A,'newline','pc');
dlmwrite('C:\Users\Johnny Jiang\OneDrive\Engineering\COMP-ENG 3DQ5\project\IDCT_C_transpose.txt',A_t,'newline','pc');
dlmwrite('C:\Users\Johnny Jiang\OneDrive\Engineering\COMP-ENG 3DQ5\project\IDCT_C_t_hex.txt',hex_uA_t,'newline','pc','delimiter','');
