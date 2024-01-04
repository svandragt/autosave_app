project('autosave_app', 'vala', 'c',
    version: '0.1',
    default_options: ['warning_level=2']
)

vala_sources = files('main.vala')

dependencies = [
    dependency('gtk+-3.0'),
]

executable('autosave_app', vala_sources,
    dependencies: dependencies,
    install: true
)
