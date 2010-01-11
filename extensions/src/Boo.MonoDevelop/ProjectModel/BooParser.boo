namespace Boo.MonoDevelop.ProjectModel

import System.IO

import MonoDevelop.Projects.Dom
import MonoDevelop.Projects.Dom.Parser

import Boo.Lang.Compiler as BLC

class BooParser(AbstractParser):
	
	def constructor():
		super("Boo", "text/x-boo")
		
	override def CanParse(fileName as string):
		return Path.GetExtension(fileName).ToLower() == ".boo"
		
	override def Parse(dom as ProjectDom, fileName as string, content as string):
		result = ParseBooText(fileName, content)
		
		document = ParsedDocument(fileName)
		document.CompilationUnit = CompilationUnit(fileName)
		
		result.CompileUnit.Accept(DomConversionVisitor(document.CompilationUnit))
		
		return document
		
def ParseBooText(fileName as string, text as string):
	
	pipeline = BLC.Pipelines.Parse()
	pipeline.Add(BLC.Steps.InitializeTypeSystemServices())
	pipeline.Add(BLC.Steps.IntroduceModuleClasses())
	
	compiler = BLC.BooCompiler()
	compiler.Parameters.Pipeline = pipeline
	compiler.Parameters.Input.Add(BLC.IO.StringInput(fileName, text))
	return compiler.Run()