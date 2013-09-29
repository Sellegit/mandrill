Gem::Specification.new do |s|
    s.name = 'mandrill'
    s.version = '1.0.47'
    s.summary = 'A Ruby API library for the Mandrill email as a service platform.'
    s.description = s.summary
    s.authors = ['Mandrill Devs']
    s.email = 'community@mandrill.com'
    s.files = ['lib/mandrill.rb', 'lib/mandrill/api.rb', 'lib/mandrill/errors.rb', 'lib/mandrill/handler.rb']
    s.homepage = 'https://bitbucket.org/dementrock/mandrill/'
    s.add_dependency 'json', '>= 1.7.7', '< 2.0'
    s.add_dependency 'excon', '>= 0.13.0', '< 1.0'
end
