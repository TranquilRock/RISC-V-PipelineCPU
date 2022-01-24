cp testdata/instruction_$1.txt codes/instruction.txt
cp testdata/cache_$1.txt codes/cache_ans.txt
cp testdata/output_$1.txt codes/ans.txt
cd codes
iverilog *.v -o CPU.out
./CPU.out
# tail -n 19 output.txt > tmp1.txt
# tail -n 19 ans.txt > tmp2.txt
# diff tmp1.txt tmp2.txt
# diff cache_ans.txt cache.txt
rm ./CPU.out  ./*.txt  #./CPU.vcd
