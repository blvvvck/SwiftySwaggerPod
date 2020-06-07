Pod::Spec.new do |spec|
    spec.name = "SwiftySwaggerPod"
    spec.version = "1.0.0"
    spec.summary = "A swifty parser for OpenAPI (Swagger) specs"

    spec.homepage = 'The Swift code generator for OpenAPI / Swagger specifications.'
    spec.license = { :type => 'MIT', :file => 'LICENSE' }
    spec.author = { 'Rinat Muhammetzyanov' => 'theblvvvck@gmail.com' }
    spec.source = { :git => "https://github.com/blvvvck/SwiftySwaggerPod.git", :tag => "#{spec.version}" }

    spec.swift_version = '5.0'

    spec.source_files = 'Sources/SwiftySwagger/Core/SourceGenerator/DefaultGenerator.swift'
    spec.frameworks = 'Foundation'

    spec.ios.deployment_target = "10.0"
    spec.osx.deployment_target = "10.12"
    spec.watchos.deployment_target = "3.0"
    spec.tvos.deployment_target = "10.0"
end