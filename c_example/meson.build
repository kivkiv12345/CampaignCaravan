project('c_example', 'c', subproject_dir: 'lib', default_options: [
    'buildtype=debug', 
	'c_std=gnu11', 
	'b_lto=false',
	'default_library=static',
])

add_global_arguments('-I../include', language: 'c')

c_example_deps = []
c_example_sources = [
	'src/main.c',
]

conf = configuration_data()
# conf.set('USE_VM', 1)

c_example_sources += vcs_tag(input: files('src/version.c.in'), output: 'version.c', command: ['git', 'describe', '--always', '--dirty=+'])

c_example_config_h = configure_file(output: 'c_example_config.h', configuration: conf)
# install_subdir('include', install_dir : '.')
# install_headers(c_example_config_h, install_dir : 'include/c_example')

c_example = executable('c_example', [c_example_sources, c_example_config_h],
	dependencies : c_example_deps,
	link_args : ['-Wl,-Map=c_example.map', '-lm', '-Wl,--export-dynamic', '-ldl'],  # -ldl is needed on ARM/raspbarian
	install : true,
)
