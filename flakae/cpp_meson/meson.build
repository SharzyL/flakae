project('cpp_meson_playground', 'cpp', version: '0.1.0')

executable('cpp_meson_playground', './src/main.cc', dependencies: dependency('spdlog'), install: true)

libname = 'foo'
lib = library(libname, './src/lib.cc', dependencies: dependency('fmt'), install: true)
install_headers('include/lib.h')
import('pkgconfig').generate(
  libraries : [lib],
  version : '1.0',
  name : 'lib' + libname,
  filebase : libname,
  description : '')
