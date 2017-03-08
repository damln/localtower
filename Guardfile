guard :rspec do
# guard :rspec, cmd: 'zeus rake spec' do
  watch(%r{^lib/(.+)\.rb$}) { "spec" }
  watch(%r{^app/(.+)\.rb$}) { "spec" }
  watch(%r{^spec/.+_spec\.rb$}) { "spec" }
end
