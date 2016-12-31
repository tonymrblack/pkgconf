#!/usr/bin/env atf-sh

. $(atf_get_srcdir)/test_env.sh

tests_init \
	case_sensitivity \
	depgraph_break_1 \
	depgraph_break_2 \
	depgraph_break_3 \
	define_variable \
	variable \
	keep_system_libs \
	libs \
	libs_only \
	libs_never_mergeback \
	cflags_only \
	cflags_never_mergeback \
	incomplete_libs \
	incomplete_cflags \
	isystem_munge_order \
	isystem_munge_sysroot \
	idirafter_munge_order \
	idirafter_munge_sysroot \
	idirafter_ordering \
	pcpath \
	sysroot_munge

case_sensitivity_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"3\n" \
		pkgconf --variable=foo case-sensitivity
	atf_check \
		-o inline:"4\n" \
		pkgconf --variable=Foo case-sensitivity
}

depgraph_break_1_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check -s exit:1 -e ignore \
		pkgconf --exists --print-errors 'foo > 0.6.0 foo < 0.8.0'
}

depgraph_break_2_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check -s exit:1 -e ignore \
		pkgconf --exists --print-errors 'nonexisting foo <= 3'
}

depgraph_break_3_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check -s exit:1 -e ignore \
		pkgconf --exists --print-errors 'depgraph-break'
}

define_variable_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check -o inline:"\\\${libdir}/typelibdir\n" \
		pkgconf --variable=typelibdir --define-variable='libdir=\${libdir}' typelibdir
}

variable_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"/test/include\n" \
		pkgconf --variable=includedir foo
}

keep_system_libs_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"-L/test/local/lib  \n" \
		pkgconf --libs-only-L --keep-system-libs cflags-libs-only
}

libs_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"-L/test/local/lib -lfoo  \n" \
		pkgconf --libs cflags-libs-only
}

libs_only_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"-L/test/local/lib -lfoo  \n" \
		pkgconf --libs-only-L --libs-only-l cflags-libs-only
}

libs_never_mergeback_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"-L/test/bar/lib -lfoo1  \n" \
		pkgconf --libs prefix-foo1	
	atf_check \
		-o inline:"-L/test/bar/lib -lfoo1 -lfoo2  \n" \
		pkgconf --libs prefix-foo1 prefix-foo2
}

cflags_only_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"-I/test/local/include/foo  \n" \
		pkgconf --cflags-only-I --cflags-only-other cflags-libs-only
}

cflags_never_mergeback_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"-I/test/bar/include/foo -DBAR -fPIC -DFOO  \n" \
		pkgconf --cflags prefix-foo1 prefix-foo2
}

incomplete_libs_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:" \n" \
		pkgconf --libs incomplete
}

incomplete_cflags_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:" \n" \
		pkgconf --cflags incomplete
}

isystem_munge_order_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"-isystem /opt/bad/include -isystem /opt/bad2/include  \n" \
		pkgconf --cflags isystem
}

isystem_munge_sysroot_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1" PKG_CONFIG_SYSROOT_DIR='/test'
	atf_check \
		-o match:"-isystem /test/opt/bad/include" \
		pkgconf --cflags isystem
}

idirafter_munge_order_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"-idirafter /opt/bad/include -idirafter /opt/bad2/include  \n" \
		pkgconf --cflags idirafter
}

idirafter_munge_sysroot_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1" PKG_CONFIG_SYSROOT_DIR='/test'
	atf_check \
		-o match:"-idirafter /test/opt/bad/include" \
		pkgconf --cflags idirafter
}

idirafter_ordering_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1"
	atf_check \
		-o inline:"-I/opt/bad/include1 -idirafter -I/opt/bad/include2 -I/opt/bad/include3  \n" \
		pkgconf --cflags idirafter-ordering
}

pcpath_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib2"
	atf_check \
		-o inline:"-fPIC -I/test/include/foo  \n" \
		pkgconf --cflags ${selfdir}/lib3/bar.pc	
}

sysroot_munge_body()
{
	export PKG_CONFIG_PATH="${selfdir}/lib1" PKG_CONFIG_SYSROOT_DIR="/sysroot"
	atf_check \
		-o inline:"-L/sysroot/lib -lfoo  \n" \
		pkgconf --libs sysroot-dir

	export PKG_CONFIG_SYSROOT_DIR="/sysroot2"
	atf_check \
		-o inline:"-L/sysroot2/sysroot/lib -lfoo  \n" \
		pkgconf --libs sysroot-dir
}
