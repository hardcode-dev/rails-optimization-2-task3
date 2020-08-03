require 'ruby-prof'

RubyProf.measure_mode = RubyProf::MEMORY

GC.disable

result = RubyProf.profile do
  work('files/data16000.txt')
end

printer4 = RubyProf::CallTreePrinter.new(result)
printer4.print(path: 'reports', profile: 'profile')

