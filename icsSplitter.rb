#!/usr/bin/ruby

numberOfEvents=ARGV[0]
file=ARGV[1]

def printUsage
  puts "Usage: ruby icsSplitter.rb <number junk-size> <file.ics>"
end

if numberOfEvents.to_i<2
  puts "The number of events must be greater than 1"
  printUsage
  exit 1
end

if file.nil?
  printUsage
  exit 1
end

if ! File.file?(file)
  puts "Can't open file "+file.to_s
  printUsage
  exit 1
end

# Save data
data = Array.new
File.open(file,"r").each do |line|
  data.push(line)
end

# Save header
@header = Array.new
counter = 0
data.each do |line|
  if line.match(/BEGIN:VEVENT/)
    break
  end
  @header.push(line)
  counter+=1
end
data.slice!(0..(counter-1))

# Save footer
@footer = Array.new
data.reverse().each do |line|
  if line.match(/END:VEVENT/)
    break
  end
  @footer.push(line)
end
@footer.reverse!

def addHeader(f)
  @header.each do |line|
    f.write(line)
  end
end

def addFooter(f)
  @footer.each do |line|
    f.write(line)
  end
end

# Count appointments
counter = 0
data.each do |line|
  if line.match(/BEGIN:VEVENT/)
    counter+=1
  end
end

puts "Fount "+counter.to_s+" appointments"

# Iterate data and save file
counter = 1
fileCounter = 0
newFile = File.open("split_part_"+fileCounter.to_s+".ics","w")
addHeader(newFile)
data.each do |line|
  if line.match(/BEGIN:VEVENT/) || line.match(/END:VEVENT/)
    newFile.write(line)
    if line.match(/END:VEVENT/)
      if counter>=numberOfEvents.to_i
        fileCounter+=1
        addFooter(newFile)
        newFile.close
        newFile = File.open("split_part_"+fileCounter.to_s+".ics","w")
        addHeader(newFile)
        counter = 1
      else
        counter+=1
      end
    end
  else
    newFile.write(line)
  end
end

newFile.close