

I64cast = /cast\(.*,Int64\)/
I64arr1 = /\w+\[\w+\]/
I64arr2 = /\w+\[--\w+\]/
I64arr3 = /\w+\[\w+ \+ \w+\]/
I64arr4 = /\w+\[\w+ - \w+\]/
I64arr = /#{I64arr1}|#{I64arr2}|#{I64arr3}|#{I64arr4}/
I64free = /a0|x0|u|xi|acc|mask|limit|power|x_i|y_0|carry|m|d|x|IMASK|prod1|prod2|t|c|v|#{I64cast}|#{I64arr}/
I64braced = /\(#{I64free}\)/

SEPSTART = /\s+|;|\(/
SEPSTARTNB = /\s+|;/
NUM = /#{SEPSTART}\d+/	


$I64 = /#{I64braced}|#{I64free}/
I64orDigits = /#{$I64}|\d+/

H64op = /shl|shr|ushr|mul|add|mod|or|xor|neg|and/
$H64exp = /Int64\.#{H64op}\(#{$I64}, #{I64orDigits}\)/
H64ExpOrI64 = /#{$H64exp}|#{$I64}/
$H64exp = /Int64\.#{H64op}\(#{H64ExpOrI64}, #{I64orDigits}\)/
H64braced =  /\(#{$H64exp}\)/
$H64exp = /#{$H64exp}|#{H64braced}/
H64 =  $H64exp

$I64 =  /#{$I64}|#{H64}/

MUL_IS = /(\s*)(#{$I64})(\s*\*=\s*)(.*);(.*)/
ADD_IS = /(\s*)(#{$I64})(\s*\+=\s*)(.*);(.*)/
SHL_IS = /(\s*)(#{$I64})(\s*<<=\s*)(.*);(.*)/
SHR_IS = /(\s*)(#{$I64})(\s*>>=\s*)(.*);(.*)/
USHR_IS = /(\s*)(#{$I64})(\s*>>>=\s*)(.*);(.*)/
OR_IS = /(\s*)(#{$I64})(\s*\|=\s*)(.*);(.*)/
AND_IS = /(\s*)(#{$I64})(\s*&=\s*)(.*);(.*)/

SEP = /\s+|;|\)/
	  

SHL = /(.*)(#{$I64})\s*<<\s*(\d+)(.*)/
SHR = /(.*)(#{$I64})\s*>>\s*(\d+)(.*)/
USHR = /(.*)(#{$I64})\s*>>>\s*(\d+)(.*)/
MUL = /(.*)(#{$I64}|#{NUM})\s*\*\s*(#{$I64})(#{SEP}.*)/
ADD = /(.*)(#{$I64}|#{NUM})\s*\+\s*(#{$I64})(#{SEP}.*)/
SUB = /(.*)(#{$I64}|#{NUM})\s*-\s*(#{$I64})(#{SEP}.*)/
AND = /(.*)(#{$I64})\s*&\s*(#{$I64})(#{SEP}.*)/
OR = /(.*)(#{$I64})\s*\|\s*(#{$I64})(#{SEP}.*)/

def fix(s)
	if (m = MUL_IS.match(s))
		return m[1] + m[2] + " = Int64.mul(" + m[2] + ", " + m[4] + ");" + m[5]
	elsif (m = ADD_IS.match(s))
		return m[1] + m[2] + " = Int64.add(" + m[2] + ", " + m[4] + ");" + m[5]
	elsif (m = USHR_IS.match(s))
		return m[1] + m[2] + " = Int64.ushr(" + m[2] + ", " + m[4] + ");" + m[5]
	elsif (m = SHR_IS.match(s))
		return m[1] + m[2] + " = Int64.shr(" + m[2] + ", " + m[4] + ");" + m[5]
	elsif (m = SHL_IS.match(s))
		return m[1] + m[2] + " = Int64.shl(" + m[2] + ", " + m[4] + ");" + m[5]
	elsif (m = OR_IS.match(s))
		return m[1] + m[2] + " = Int64.or(" + m[2] + ", " + m[4] + ");" + m[5]
	elsif (m = AND_IS.match(s))
		return m[1] + m[2] + " = Int64.and(" + m[2] + ", " + m[4] + ");" + m[5]

	elsif (m = MUL.match(s))
		return m[1] + "Int64.mul(" + m[2] + ", " + m[3] + ")" + m[4]
	elsif (m = ADD.match(s))
		return m[1] + "Int64.add(" + m[2] + ", " + m[3] + ")" + m[4]
	elsif (m = SUB.match(s))
		return m[1] + "Int64.sub(" + m[2] + ", " + m[3] + ")" + m[4]
	elsif (m = SHL.match(s))
		return m[1] + "Int64.shl(" + m[2] + ", " + m[3] + ")" + m[4]
	elsif (m = SHR.match(s))
		return m[1] + "Int64.shr(" + m[2] + ", " + m[3] + ")" + m[4]
	elsif (m = USHR.match(s))
		return m[1] + "Int64.ushr(" + m[2] + ", " + m[3] + ")" + m[4]
	elsif (m = AND.match(s))
		return m[1] + "Int64.and(" + m[2] + ", " + m[3] + ")" + m[4]
	elsif (m = OR.match(s))
		return m[1] + "Int64.or(" + m[2] + ", " + m[3] + ")" + m[4]
	#elsif (m = /(.*)(\(a\[.*\])(.*)/.match(s))
	#	return m[1] + "(Int64.ofInt" + m[2] + ")" + m[3]
	else
		return s
	end
end

f = File.open("err.txt")
lines = f.readlines
f.close
f = File.open("src/crypto/math/BigInteger.hx")
hx = f.readlines
hxorig = hx.clone
#i = 0
#hx.each do |l|
#	hxorig[i] = hx[i]
#	i += 1
#end
f.close
cnt = 1
passes = 0
fixes = 0
while (cnt > 0) do
	cnt = 0
	i = 0
	cnt64err = 0
	lines.each do |l|
		if (/Int64 should be Int/.match(l))
			cnt64err += 1
			m = /.*hx:([0-9]*):.*/.match(l)
			n = m[1].to_i
			#puts n
			src = hx[n-1]
			src2 = src
			if (src2.index("//AUTOFIXFROM"))
			    src2 = src2[0,src2.index("//AUTOFIXFROM")]
			end
			fixed = fix(src2)
			if (fixed != src)
				hx[n-1] = fixed #+ "  //" + src
				cnt += 1
				fixes += 1
				#puts "FROM: " + src
				#puts "  TO: " + fixed
			end
			#puts "-->" + src
			#puts "|->" + fixed
			#puts l
		end
		i+=1
	end
	passes += 1
end

i = 0
cnt = 0
hx.each do |l|
	if (hx[i] != hxorig[i])
		cnt += 1	
		hx[i] = hx[i] + "    //AUTOFIXFROM: " + hxorig[i]
	end
	puts hx[i]
	i += 1
end
puts " // #{passes} passes"
puts " // #{fixes} fixes"
#puts "#{cnt} lines out of #{cnt64err} changed"

