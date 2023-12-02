# This Ruby script determines current MSYS2 environment and outputs
# library prefix for Ruby build and used for Windows builds.
# (See also "windows/Makefile")

case ENV['MSYSTEM'].downcase
when 'mingw64'
  puts 'x64-msvcrt'
when 'mingw32'
  puts 'msvcrt'
when 'ucrt64', 'clang64', 'clangarm64'
  puts 'x64-ucrt'
when 'clang32'
  puts 'ucrt'
end
