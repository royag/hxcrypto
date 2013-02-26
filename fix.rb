

def fix(s)
	#if (m = /(.*and)(\([amx]\[[^\[]*\])(.*)/.match(s))
	#	return m[1] + "(Int64.ofInt" + m[2] + ")" + m[3]
	if (m = /(.*)(cast\()(.*),\s*Int\)(.*)/.match(s))
		return m[1] + "Int64.toInt(" + m[3] + ")" + m[4]
	elsif (m = /(.*)(cast\()(.*),\s*Int64\)(.*)/.match(s))
		return m[1] + "Int64.ofInt(" + m[3] + ")" + m[4]
	else
		return s
	end
end


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
i = 0
while (cnt > 0) do
	cnt = 0
	i = 0
	hx.each do |l|
			src2 =l
			fixed = fix(src2)
			if (fixed != src2)
				cnt+=1
				hx[i] = fixed
				#puts "FROM: " + src2
				#puts "  TO: " + fixed
			end
			#puts fixed
			#puts "-->" + src
			#puts "|->" + fixed
			#puts l
			i+=1
		end
end

hx.each do |l|
	puts l
end


