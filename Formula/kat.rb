class Kat < Formula
  include Language::Python::Virtualenv

  # cite Mapleson_2016: "https://doi.org/10.1093/bioinformatics/btw663"
  desc "K-mer Analysis Toolkit (KAT) analyses k-mer spectra"
  homepage "https://github.com/TGAC/KAT"
  url "https://github.com/TGAC/KAT/archive/Release-2.4.1.tar.gz"
  sha256 "068bd63b022588058d2ecae817140ca67bba81a9949c754c6147175d73b32387"
  revision 1
  head "https://github.com/TGAC/KAT.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles-bio"
    sha256 "229032478102a56b377d37937e693ae4191e53d31f4beb02084a21180c09538a" => :sierra_or_later
    sha256 "55f362ff01406d6d06fb79b40dbef7080da0ab86a12ef61d5c1c18c32dedd015" => :x86_64_linux
  end

  needs :cxx11

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  depends_on "matplotlib"
  depends_on "scipy"

  resource "tabulate" do
    url "https://files.pythonhosted.org/packages/1c/a1/3367581782ce79b727954f7aa5d29e6a439dc2490a9ac0e7ea0a7115435d/tabulate-0.7.7.tar.gz"
    sha256 "83a0b8e17c09f012090a50e1e97ae897300a72b35e0c86c0b53d3bd2ae86d8c6"
  end

  def install
    # Reduce memory usage for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    venv = virtualenv_create(libexec)
    %w[tabulate].each do |r|
      venv.pip_install resource(r)
    end

    system "./build_boost.sh"
    system "./autogen.sh"
    system "./configure",
      "--disable-silent-rules",
      "--disable-dependency-tracking",
      "--disable-pykat-install",
      "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kat --version")
  end
end
