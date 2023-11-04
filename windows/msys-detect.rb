# This Ruby script determines current MSYS2 environment and outputs
# library prefix for Ruby build and used for Windows builds.
# (See also "windows/Makefile")

if not ENV.key?('MSYSTEM')
  raise RuntimeError, 'Not defined $MSYSTEM variable'
end

case ENV['MSYSTEM'].downcase
when 'mingw64'
  puts 'x64-msvcrt'
when 'mingw32'
  puts 'msvcrt'
when 'ucrt64', 'clang64', 'clangarm64'
  puts 'x64-ucrt'
when 'clang32'
  puts 'ucrt'
else
  raise RuntimeError, 'Unknown $MSYSTEM value'
end
