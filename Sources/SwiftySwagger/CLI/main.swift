import Foundation
import SwiftCLI
import SwiftySwaggerTools
import PathKit
import Stencil
import StencilSwiftKit

#if DEBUG
Path.current = Path(#file)
#endif

let armature = CLI(
    name: "swiftySwagger",
    version: "1.0.0",
    description: "API client code generator from OpenAPI specification."
)

//var executablePath = Path(ProcessInfo.processInfo.executablePath)
//
//let context = [
//	"model": "test"
//]


//let environment = Environment(loader: FileSystemLoader(paths: [try resolveTemplatePath(of: "Model")]))
//
//let rendered = try! environment.renderTemplate(name: "Model.stencil", context: context)
//
//let path = Path("/Users/rmuhammetzyanov/Downloads/SwiftySwagger/Templates/Models/asdas.swift")
//try! path.write(rendered, encoding: .utf8)

armature.commands = [GenerateCommand()]

armature.goAndExit()
//armature.go(with: ["generate", "https://petstore3.swagger.io/api/v3/openapi.yaml", "Moya"])


class GreetCommand: Command {
    let name = "greet"

    @Param
	var person: String

    @Param
	var followUp: String

    func execute() throws {
        stdout <<< "Hey there, \(person)!"
        stdout <<< followUp
		stdout <<< Path.current.string

    }
}

private func resolveTemplatePath(of templateName: String) throws -> Path {
	let templateFileName = templateName.appending(String.templatesFileExtension)

	#if DEBUG
	let xcodeTemplatesPath = Path.current.appending(.templatesXcodeRelativePath)

	if xcodeTemplatesPath.exists {
		return xcodeTemplatesPath.appending(templateFileName)
	}
	#endif

	var executablePath = Path(ProcessInfo.processInfo.executablePath)

	while executablePath.isSymlink {
		executablePath = try executablePath.symlinkDestination()
	}

	let podsTemplatesPath = executablePath.appending(.templatesPodsRelativePath)

	if podsTemplatesPath.exists {
		return podsTemplatesPath.appending(templateFileName)
	}

	return executablePath
		.appending(.templatesShareRelativePath)
		.appending(templateFileName)
}

private extension String {

    // MARK: - Type Properties

    static let templatesFileExtension = ".stencil"
    static let templatesXcodeRelativePath = "../Examples"
    static let templatesPodsRelativePath = "../Examples"
    static let templatesShareRelativePath = "../../share/fugen"
    static let templateOptionsKey = "options"
}
