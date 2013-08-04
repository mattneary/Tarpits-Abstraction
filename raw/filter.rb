code = false
STDIN.read.split("\n").each do |line|
	if code
		if line == "</div>"
			code = false
		end
	else
		if line == "<div>"
			code = true
		else
			if line[0] != ?= and line[0] != ?- and line[0] != ?#
				puts line
			end
		end
	end	
end