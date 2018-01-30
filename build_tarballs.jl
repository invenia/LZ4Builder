using BinaryBuilder

# These are the platforms built inside the wizard
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
  BinaryProvider.Linux(:x86_64, :glibc),
  BinaryProvider.Linux(:aarch64, :glibc),
  BinaryProvider.Linux(:armv7l, :glibc),
  BinaryProvider.Linux(:powerpc64le, :glibc),
  BinaryProvider.MacOS(),
  BinaryProvider.Windows(:x86_64)
]


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

# Collection of sources required to build LZ4
sources = [
    "https://github.com/lz4/lz4.git" =>
    "dfed9fa1d77f0434306d377c4da1f7191d3ba08a",
]

script = raw"""
cd $WORKSPACE/srcdir
cd lz4/contrib/cmake_unofficial/
cmake -DCMAKE_INSTALL_PREFIX=/ -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain
make lz4_shared
touch lz4 lz4c lz4.exe lz4c.exe
make install/fast
exit

"""

products = prefix -> [
    LibraryProduct(prefix,"liblz4")
]


# Build the given platforms using the given sources
hashes = autobuild(pwd(), "LZ4", platforms, sources, script, products)

