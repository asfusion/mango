<cfcomponent displayname="Image" hint="I am a CFC which can be used to create and edit images." output="no">
	<!--- // -- // -- // -- // -- // -- // -- // -- // ---- 
	//
	//		instance variables
	//
	----- // -- // -- // -- // -- // -- // -- // -- // --->
	<!--- version --->
	<!--- slightly modified by AsFusion to add missing scaleToBox() method --->
	<cfset variables.version = StructNew() />
	<cfset variables.version.product = "Alagad Image Component" />
	<cfset variables.version.version = "2.21" />
	<cfset variables.version.releaseDate = "8/4/2009" />

	<!--- Image: 			I am the image we're working with --->
	<cfset variables.Image = CreateObject("java", "java.awt.image.BufferedImage") />
	<!--- ImageIO: 			I am used to read, write and create images --->
	<cfset variables.ImageIO = CreateObject("Java", "javax.imageio.ImageIO") />
	<!--- typeList:			I hold a list of image types supported --->
	<cfset variables.typeList = "Grayscale,Gray,RGB,ARGB,BGR,INDEXED,BINARY" />
	<!--- imageLoaded (indicates if an image has been created or read) --->
	<cfset imageLoaded = false />
	
	<!---
		ImageReader:		I am the object used to read the initial image.  For now I'm not needed.  In the future
							I may be used to aid control of compression settings as well as writing image meta data
	<cfset variables.ImageReader = "" />--->
	
	<!--- BackgroundColor --->
	<cfset variables.BackgroundColor = 0 />
	<!--- Color --->
	<cfset variables.Color = 0 />
	<!--- Stroke --->
	<cfset variables.Stroke = 0 />
	<!--- Fill --->
	<cfset variables.Fill = 0 />
	<!--- Composite --->
	<cfset variables.composite = "srcOver" />
	<!--- alpha --->
	<cfset variables.transparency = 100 />
	<!--- Font --->
	<cfset variables.Font = 0 />
	<!--- rotate --->
	<cfset variables.rotate = 0 />
	<!--- rotateX --->
	<cfset variables.rotateX = 0 />
	<!--- rotateY --->
	<cfset variables.rotateY = 0 />
	<!--- shearX --->
	<cfset variables.shearX = 0 />
	<!--- shearY --->
	<cfset variables.shearY = 0 />
	<!--- Font --->
	<cfset variables.Font = CreateObject("Java", "java.awt.Font") />
	<!--- antialias --->
	<cfset variables.antialias = true />
	
	<!--- // -- // -- // -- // -- // -- // -- // -- // ---- 
	//
	//		setKey
	//
	----- // -- // -- // -- // -- // -- // -- // -- // --->
	<cffunction name="setKey" access="public" output="false" returntype="Image" hint="I set the license key for the component.">
		<cfargument name="key" hint="I am the license key to use." required="yes" type="string" />
		
		<!--- this method is a hold-over from before the AIC was free.  this function is now ignored --->
		
		<!--- return the image object. --->
		<cfreturn this />
	</cffunction>
	
	<!--- // -- // -- // -- // -- // -- // -- // -- // ---- 
	//
	//		public methods
	//
	----- // -- // -- // -- // -- // -- // -- // -- // --->
	<!--- CreateImage --->
	<cffunction name="createImage" access="public" output="false" returntype="void" hint="I create a new image.  The new image will be the color of the current background color.">
		<cfargument name="width" hint="I am the width of the image to create" required="yes" type="numeric" />
		<cfargument name="height" hint="I am the height of the image to create" required="yes" type="numeric" />
		<cfargument name="type" hint="I am the type of image to create.  Options are: Grayscale, RGB, ARGB, BGR, INDEXED, BINARY" default="argb" required="no" type="string" />
		<cfset var Image = getImageForLoad() />
		<cfset var Graphics = 0 />
		
		<!--- validate width/height --->
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attribute must be greater than 0." />
		</cfif>
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attribute must be greater than 0." />
		</cfif>
		
		<!--- create the new image --->
		<cfset Image.init( JavaCast("int", arguments.width), JavaCast("int", arguments.height), JavaCast("int", getColorModeId(arguments.type)) ) />
		
		<!--- get the new image's graphics --->
		<cfset Graphics = Image.getGraphics() />
		
		<!--- clear the new image (to set the background color, if any) --->
		<cfset clearImage() />
		
		<!--- set the image as the object's image --->
		<cfset setImage(Image) />
	</cffunction>
	
	<!--- readImage --->
	<cffunction name="readImage" access="public" output="false" returntype="void" hint="I read an image from disk.">
		<cfargument name="path" hint="I am the path of the image file to read." required="yes" type="string" />
		<cfargument name="mode" hint="I am an optional mode to convert the image to when reading.  Options are:Grayscale, RGB, ARGB, BGR, INDEXED, BINARY" default="" required="no" type="string" />
		<cfset var fileExt = ListLast(arguments.path, ".") />
		<cfset var ImageReader = 0 />
		<cfset var InputStream = CreateObject("Java", "java.io.FileInputStream") />
		
		<!--- verify that the requested file exists --->
		<cfif NOT fileExists(arguments.path)>
			<cfthrow
				type="Alagad.Image.InvalidPath"
				message="Invalid path argument.  The path specified does not exist or is not accessible. (#arguments.path#)  Please provide a valid path to an image file." />
		</cfif>
		
		<!--- get the Image Reader --->
		<cfset ImageReader = getImageReadersBySuffix(fileExt) />
				
		<cftry>
			<!--- grab an input stream for the image we're reading --->
			<cfset InputStream.init(arguments.path) />
			
			<cfcatch>
				<cfthrow
					type="Alagad.Image.ErrorOpeningFile"
					message="There was an error opening the file #arguments.path#." />
			</cfcatch>
		</cftry>
		
		<!--- read and set the image data --->
		<cfset setImage(readImageData(InputStream, ImageReader)) />
		
		<!--- if openMode is provided convert to the requested type --->
		<cfif Len(arguments.mode)>
			<cfset setImageMode(arguments.mode) />
		</cfif>
		
		<!--- close the input stream! --->
		<cfset InputStream.close() />
	</cffunction>
	
	<!--- readFromBase64 --->
	<cffunction name="readFromBase64" access="public" output="false" returntype="void" hint="I create a new image from base64 data.">
		<cfargument name="data" hint="I am the base 64 data which contains the image." required="yes" type="string" />
		<cfargument name="mode" hint="I am an optional mode to conver the image to when reading.  Options are:Grayscale, RGB, ARGB, BGR, INDEXED, BINARY" default="" required="no" type="string" />
		<cfset var ImageReader = 0 />
		<cfset var InputStream = CreateObject("Java", "java.io.ByteArrayInputStream") />
		
		<!--- verify that the data is base 64 data (via try/catch), convert it to binary and create an input stream, --->
		<cftry>
			<cfset InputStream = InputStream.init(ToBinary(data)) />
			
			<cfcatch>
				<cfthrow
					type="Alagad.Image.Base64ConversionError"
					message="Error converting base64 data to binary. Attribute data must be a Base-64 encoded string." />
			</cfcatch>
		</cftry>
		
		<!--- get the Image Reader --->
		<cfset ImageReader = getImageReadersByInputStream(InputStream) />
		
		<!--- reset the inputstream (so we dont get errors when reading) --->
		<cfset InputStream.reset() />
		
		<!--- read and set the image data --->
		<cfset setImage(readImageData(InputStream, ImageReader)) />
		
		<!--- if openMode is provided convert to the requested type --->
		<cfif Len(arguments.mode)>
			<cfset setImageMode(arguments.mode) />
		</cfif>
	</cffunction>
	
	<!--- getImageReadersByInputStream --->
	<cffunction name="getImageReadersByInputStream" access="private" output="false" returntype="any" hint="I return an ImageReader based on an input stream.">
		<cfargument name="InputStream" hint="I am the InputStream to get a reader for." required="yes" type="string" />
		<cfset var ImageIO = getImageIO() />
		<cfset var ImageInputStream = getImageIO().createImageInputStream(arguments.InputStream) />
		<cfset var Iterator = 0 />
		<cfset var ImageReader = 0 />
		
		<!--- find an image reader based on the currnet inputstream --->
		<cfset Iterator = ImageIO.getImageReaders(ImageInputStream) />
		
		<!--- check to see if there is a next image reader, IE: is there any image reader? --->
		<cfif Iterator.hasNext()>
			<!--- grab the ImageReader --->
			<cfset ImageReader = Iterator.next() />
		<cfelse>
			<!--- we couldn't find a valid image reader, throw an error --->
			<cfthrow
				type="Alagad.Image.ImageReaderNotFound"
				message="An Image Reader could not be found based on file data. Image is of an unsupported format." />
		</cfif>
		
		<cfreturn ImageReader />
	</cffunction>
	
	<!--- getImageReadersBySuffix --->
	<cffunction name="getImageReadersBySuffix" access="private" output="false" returntype="any" hint="I return an ImageReader based on a file extension.">
		<cfargument name="fileExt" hint="I am the file extension to get a reader for" required="yes" type="string" />
		<cfset var ImageIO = getImageIO() />
		<cfset var Iterator = 0 />
		<cfset var ImageReader = 0 />
		
		<!--- find/create an image reader for the correct type of file (gif, jpg, etc) --->
		<cfset Iterator = ImageIO.getImageReadersBySuffix(arguments.fileExt) />
		
		<!--- check to see if there is a next image reader, IE: is there any image reader? --->
		<cfif Iterator.hasNext()>
			<!--- grab the ImageReader --->
			<cfset ImageReader = Iterator.next() />
		<cfelse>
			<!--- we couldn't find a valid image reader, throw an error --->
			<cfthrow
				type="Alagad.Image.ImageReaderNotFound"
				message="An Image Reader could not be found for the file type (#arguments.fileExt#). Image is of an unsupported format." />
		</cfif>
		
		<cfreturn ImageReader />
	</cffunction>
	
	<!--- readImageFromURL --->
	<cffunction name="readImageFromURL" access="public" output="false" returntype="void" hint="I read an image from a URL.">
		<cfargument name="URL" hint="I am the URL of the image file to read." required="yes" type="string" />
		<cfargument name="mode" hint="I am an optional mode to conver the image to when reading.  Options are:Grayscale, RGB, ARGB, BGR, INDEXED, BINARY" default="" required="no" type="string" />
		<cfset var fileExt = ListLast(arguments.URL, ".") />
		<cfset var ImageReader = 0 />
		<cfset var URLStream = CreateObject("Java", "java.net.URL") />
		<cfset var InputStream = 0 />
		
		<!--- get the Image Reader --->
		<cfset ImageReader = getImageReadersBySuffix(fileExt) />
		
		<cftry>
			<!--- grab an input stream for the image we're reading --->
			<cfset URLStream.init(arguments.URL) />
			<cfset InputStream = URLStream.openConnection().getInputStream() />
			
			<cfcatch>
				<cfthrow
					type="Alagad.Image.ErrorOpeningURL"
					message="There was an error reading from the URL. (#arguments.URL#)" />
			</cfcatch>
		</cftry>

		<!--- read and set the image data --->
		<cfset setImage(readImageData(InputStream, ImageReader)) />		
		
		<!--- if openMode is provided convert to the requested type --->
		<cfif Len(arguments.mode)>
			<cfset setImageMode(arguments.mode) />
		</cfif>
	</cffunction>
	
	<!--- readImageData --->
	<cffunction name="readImageData" access="private" output="false" returntype="Any" hint="I read image data from an inputstream and return an Image.">
		<cfargument name="InputStream" hint="I am the InputStream to read image data from." required="yes" type="any" />
		<cfargument name="ImageReader" hint="I am the ImageReader object to use to read image data." required="yes" type="any" />
		<cfset var ImageInputStream = getImageIO().createImageInputStream(arguments.InputStream) />
		<cfset var Image = getImageForLoad() />
		
		<cftry>
			<!--- set the input for the image reader to the image input stream --->
			<cfset arguments.ImageReader.setInput(ImageInputStream) />
			
			<!--- read the image --->
			<cfset Image = arguments.ImageReader.read(JavaCast("int", 0)) />
			
			<!--- set the image reader (used by some write methods to get metadata)
			<cfset setImageReader(arguments.ImageReader) /> --->
						
			<!--- close the input stream.  prevents memory leaks and locked files --->
			<cfset ImageInputStream.close() />
			<cfset arguments.ImageReader.dispose() />
			
			<cfcatch>
				<!--- close the input stream.  prevents memory leaks and locked files. --->
				<cfset ImageInputStream.close() />
				<cfset arguments.ImageReader.dispose() />
			
				<cfthrow
					type="Alagad.Image.ErrorReadingImage"
					message="There was an error reading the image.  Image may be corrupted?" />
			</cfcatch>
		</cftry>
				
		<!--- return the image --->
		<cfreturn Image />
	</cffunction>
	
	<!--- getImageMode --->
	<cffunction name="getImageMode" access="public" output="false" returntype="string" hint="I return the image mode.  Returns one of: Grayscale, RGB, ARGB, BGR, INDEXED, BINARY, or Unrecognized.">
		<cfset var imageType = "" />
		
		<cfswitch expression="#getImage().getType()#">
			<cfcase value="10,11">
				<cfset imageType = "Grayscale" />
			</cfcase>
			<cfcase value="1">
				<cfset imageType = "RGB" />
			</cfcase>
			<cfcase value="2">
				<cfset imageType = "ARGB" />
			</cfcase>
			<cfcase value="4,5">
				<cfset imageType = "BGR" />
			</cfcase>
			<cfcase value="13">
				<cfset imageType = "INDEXED" />
			</cfcase>
			<cfcase value="12">
				<cfset imageType = "BINARY" />
			</cfcase>
			<cfdefaultcase>
				<cfset imageType = "Unrecognized" />
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn imageType />
	</cffunction>
	
	<!--- setImageMode --->
	<cffunction name="setImageMode" access="public" output="false" returntype="void" hint="I convert the images mode.  Options are: Grayscale, RGB, ARGB, BGR, INDEXED, BINARY">
		<cfargument name="mode" hint="I am the mode to convert the image to.  Options are: Grayscale, RGB, ARGB, BGR, INDEXED, BINARY" required="yes" type="string" />
		<cfset var Image = getImage() />
		<cfset var NewImage = CreateObject("Java", "java.awt.image.BufferedImage") />
		<cfset var Graphics = 0 />
		<cfset var Operation = CreateObject("Java", "java.awt.image.AffineTransformOp") />
		<cfset var Transform = CreateObject("Java", "java.awt.geom.AffineTransform") />
		
		<cfscript>
			NewImage.init(JavaCast("int", Image.getWidth()), JavaCast("int", Image.getHeight()), JavaCast("int", getColorModeId(arguments.mode)));
			Graphics = NewImage.getGraphics();
			
			Graphics.fillRect(0, 0, JavaCast("int", Image.getWidth()), JavaCast("int", Image.getHeight()));
			
			Transform.scale(1, 1);
			Operation.init(Transform, Operation.TYPE_BILINEAR);
			Graphics.drawImage(Image, Operation, JavaCast("int", 0), JavaCast("int", 0));
		</cfscript>
		
		<cfset setImage(NewImage) />
	</cffunction>
	
	<!--- getColorModeId --->
	<cffunction name="getColorModeId" access="private" output="false" returntype="numeric" hint="Based on a name, I return the int representing a color mode.">
		<cfargument name="mode" hint="I am the color mode name. Options are: Grayscale, RGB, ARGB, BGR, INDEXED, BINARY" required="yes" type="string" />
		<cfset var imageMode = 0 />
		
		<!--- validate the modes --->
		<cfset verifyImageMode(arguments.mode) />
		
		<!--- get the mode ID --->
		<cfswitch expression="#arguments.mode#">
			<cfcase value="Grayscale,Gray">
				<cfset imageMode = Image.TYPE_BYTE_GRAY />
			</cfcase>
			<cfcase value="RGB">
				<cfset imageMode = Image.TYPE_INT_RGB />
			</cfcase>
			<cfcase value="ARGB">
				<cfset imageMode = Image.TYPE_INT_ARGB />
			</cfcase>
			<cfcase value="BGR">
				<cfset imageMode = Image.TYPE_INT_BGR />
			</cfcase>
			<cfcase value="INDEXED">
				<cfset imageMode = Image.TYPE_BYTE_INDEXED />
			</cfcase>
			<cfcase value="BINARY">
				<cfset imageMode = Image.TYPE_BYTE_BINARY />
			</cfcase>
		</cfswitch>
		
		<!--- return the mode ID --->
		<cfreturn imageMode />
	</cffunction>
	
	<!---- getSize --->
	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="I return the size the image would be if written to disk.">
		<cfargument name="format" hint="I am the format of the file to write to." required="yes" type="string" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." required="no" type="numeric" />
		<cfset var OutputStream = CreateObject("Java", "java.io.ByteArrayOutputStream").init() /> 
		
		<cftry>
			<cfif IsDefined("arguments.quality")>
				<!--- the user wants to controll the quality of the image --->
				<cfset writeToOutputStream(arguments.format, OutputStream, arguments.quality) />
			<cfelse>
				<!--- the user wants to use the defaults (or has a non-jpeg image) --->
				<cfset writeToOutputStream(arguments.format, OutputStream) />
			</cfif>
			
			<!--- catch any errors and clean up --->
			<cfcatch>
				<!--- close the outputstream --->
				<cfset OutputStream.close() />
				
				<cftry>
					<!--- clean up any files which may have been created --->
					<cffile action="delete"
						file="#arguments.path#" />
					<cfcatch></cfcatch>
				</cftry>				
				
				<!--- rethrow our error --->
				<cfrethrow />
			</cfcatch>
		</cftry>
		
		<!--- return the resulting size of the image --->
		<cfreturn OutputStream.size() />		
	</cffunction>
	
	<!--- writeImage --->
	<cffunction name="writeImage" access="public" output="false" returntype="void" hint="I write the image to disk.">
		<cfargument name="path" hint="I am the path of the file to write to." required="yes" type="string"/>
		<cfargument name="format" hint="I am the format of the file to write to." required="yes" type="string" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." required="no" type="numeric" />
		<cfset var OutputStream = CreateObject("Java", "java.io.FileOutputStream") /> 
		
		<!--- attempt to init/open the output stream --->
		<cftry>
			<cfset OutputStream = OutputStream.init(arguments.path) />
			<cfcatch>
				<cfthrow
					type="Alagad.Image.InvalidPath"
					message="Invalid path attribute. The path is not accessible." />
			</cfcatch>
		</cftry>
		
		<cftry>
			<cfif IsDefined("arguments.quality")>
				<!--- the user wants to controll the quality of the image --->
				<cfset writeToOutputStream(arguments.format, OutputStream, arguments.quality) />
			<cfelse>
				<!--- the user wants to use the defaults (or has a non-jpeg image) --->
				<cfset writeToOutputStream(arguments.format, OutputStream) />
			</cfif>
			
			<!--- catch any errors and clean up --->
			<cfcatch>
				<!--- close the outputstream --->
				<cfset OutputStream.close() />
				
				<cftry>
					<!--- clean up any files which may have been created --->
					<cffile action="delete"
						file="#arguments.path#" />
					<cfcatch></cfcatch>
				</cftry>				
				
				<!--- rethrow our error --->
				<cfrethrow />
			</cfcatch>
		</cftry>		
	</cffunction>
	
	<!--- writeToBase64 --->
	<cffunction name="writeToBase64" access="public" output="false" returntype="string" hint="I return the image data in base64.">
		<cfargument name="format" hint="I am the format of the data to return." required="yes" type="string" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." required="no" type="numeric" />
		<cfset var OutputStream = CreateObject("Java", "java.io.ByteArrayOutputStream").init() /> 
		<cfset var base64data = "" />
		
		<cfif IsDefined("arguments.quality")>
			<!--- the user wants to controll the quality of the image --->
			<cfset writeToOutputStream(arguments.format, OutputStream, arguments.quality) />
		<cfelse>
			<!--- the user wants to use the defaults (or has a non-jpeg image) --->
			<cfset writeToOutputStream(arguments.format, OutputStream) />
		</cfif>
		
		<cfset base64data = ToBase64(OutputStream.toByteArray()) />
		
		<!--- return the base 64 data --->
		<cfreturn base64data />
	</cffunction>
	
	<!--- writeToBrowser --->
	<cffunction name="writeToBrowser" access="public" output="false" returntype="void" hint="I write the image data directly to the browser.">
		<cfargument name="format" hint="I am the format of the data to write." required="yes" type="string" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." required="no" type="numeric" />
		<cfset var tempFile = getTempFile(getTempDirectory(), "AIC") />
		
		<cfif IsDefined("arguments.quality")>
			<!--- write the image to a temp file --->
			<cfset writeImage(tempFile, arguments.format, arguments.quality) />
		<cfelse>
			<!--- the user wants to use the defaults (or has a non-jpeg image) --->
			<cfset writeImage(tempFile, arguments.format) />
		</cfif>
		
		<!--- dump the image --->
		<cfcontent file="#tempFile#" deletefile="yes" reset="yes" type="image/#arguments.format#" />		
	</cffunction>
	
	<!--- writeToOutputStream --->
	<cffunction name="writeToOutputStream" access="private" output="false" returntype="void" hint="I write the image to a java outputstream.">
		<cfargument name="format" hint="I am the format of the file to write to." required="yes" type="string" />
		<cfargument name="OutputStream" hint="I am the OutputStream to write to." required="yes" type="any" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." required="no" type="numeric" />
		
		<!--- insure that the provided format is a supported format --->
		<cfif NOT verifyWritableFormat(arguments.format)>
			<cfthrow
				type="Alagad.Image.InvalidFormat"
				message="Invalid format attribute.  Valid format attributes are #getWritableFormats()#" />
		</cfif>	
		
		<!--- if quality is provided, insure that it's between 0 and 100 --->
		<cfif IsDefined("arguments.quality") AND NOT (arguments.quality GTE 0 AND arguments.quality LTE 100) >
			<cfthrow
				type="Alagad.Image.InvalidQualitySetting"
				message="Invalid quality attribute.  The quality attribute must be from 0 to 100." />
		</cfif>
		
		<cfif IsDefined("arguments.quality")>
			<!--- the user wants to controll the quality of the image. call writeQuality --->
			<cfset writeQualityToOutputStream(arguments.format, arguments.OutputStream, arguments.quality) />
		<cfelse>
			<!--- the user wants to use the defaults (or has a non-jpeg image), call writeStandard --->
			<cfset writeQualityToOutputStream(arguments.format, arguments.OutputStream, 75) />
		</cfif>
		
		<cfset arguments.OutputStream.close() />
	</cffunction>
	
	<!--- writeQualityToOutputStream --->
	<cffunction name="writeQualityToOutputStream" access="private" output="false" returntype="void" hint="I write the image to an outputstream at a specific quality setting.">
		<cfargument name="format" hint="I am the format of the file to write to." required="yes" type="string" />
		<cfargument name="OutputStream" hint="I am the OutputStream to write to." required="yes" type="any" />
		<cfargument name="quality" hint="I am set the compression quality when writing the image." required="yes" type="numeric" />
		<cfset var Image = getImage() />
		<cfset var ImageWriterIterator = 0 />
		<cfset var ImageWriter = 0 />
		<cfset var ImageWriteParam = 0 />
		<cfset var ImageTypeSpecifier = 0 />
		<cfset var IIOMetadata = 0 />
		<cfset var IIOImage = 0 />
		<cfset var ImageOutputStream = 0 />
		<cfset var width = getWidth() />
		<cfset var height = getHeight() />
		<cfset var proportion = 0 />
		<cfset var newWidth = 0 />
		<cfset var newHeight = 0 />
		<cfset var ThumbnailImage = 0 />
		<cfset var Transform = CreateObject("Java", "java.awt.geom.AffineTransform") />
		<cfset var Operation = CreateObject("Java", "java.awt.image.AffineTransformOp") />
		<cfset var List = 0 />
		
		<cfset ImageWriterIterator = getImageIO().getImageWritersByFormatName(JavaCast("string", arguments.format)) />

		<cfif ImageWriterIterator.hasNext()>
			<cfset ImageWriter = ImageWriterIterator.next() />
		<cfelse>
			<!--- we couldn't find a valid image writer, throw an error --->
			<cfthrow
				type="Alagad.Image.ImageWriterNotFound"
				message="An Image Writer could not be found for the file type (#arguments.format#)." />
		</cfif>
		
		<cfif Image.getColorModel().hasAlpha() AND ImageWriter.getClass().getName() contains "jpeg">
			<!---
				This method creates an RGB image and draws our current image into it to remove the alpha channel.
				According to Sun, JPEGs support alpha channels.  However, most native apps don't support this.
				Unfortunatly, sun chooses to write these images how they choose.  So we need to put this hack in 
				so that if we read an image with an alpha channel that we can then remove the alpha when writing
				to JPEG.
			--->
			<cfset setImageMode("RGB") />
			<cfset Image = getImage() />
		</cfif>		
		
		<!--- configure the image writer --->
		<cfset ImageWriteParam = ImageWriter.getDefaultWriteParam() />
		
		<!--- check to make sure compression is supported --->
		<!--- this is some really ugly code.  Sorry! --->
		<cfif ImageWriteParam.canWriteCompressed()
			and NOT FindNoCase("tif", arguments.format)
			and NOT FindNoCase("jpeg2000", arguments.format)
			and NOT FindNoCase("bmp", arguments.format)
			and NOT FindNoCase("jpeg 2000", arguments.format)>
			
			<!--- if we get this far compression is supported!  woo hoo! --->
			<cfset ImageWriteParam.setCompressionMode(ImageWriteParam.MODE_EXPLICIT) />
			<cfset ImageWriteParam.setCompressionQuality( JavaCast("float", arguments.quality/100 )) />
		</cfif>
				
		<!---
			because CFMX 6.1 and earlier did not support passing Null to Java we had to have a lot of extra 
			mumbo jumbo to write compressed images.  This cfif checks the version.  If we're on 7 we save
			a little effort.
		--->
		<cfif ListFirst(server.coldfusion.ProductVersion) LT 7>
			<!--- 
				Try to create a thumbnail.  Before we can do this we need to know what the preferred thumbnail sizes are.
				To find this out I will call getPreferredThumbnailSizes on the ImageWriter.				
				
				To do this you will need these:
					ImageTypeSpecifier
					ImageWriteParam (created above)
					IIOMetadata
					IIOMetadata
			--->
			<cfset ImageTypeSpecifier = CreateObject("Java", "javax.imageio.ImageTypeSpecifier").init(Image) />
			<!---
				If you created an image, the getImageMetadata method will throw an error because there's 
				not an imagereader to get it from.  To get arround this I simply put in a try/catch
				here.  I don't like it, I should go futher to see if an image was read or created and switch
				based on that.  For now, it is what it is.
			--->
			<!--- <cftry>
				<cfset IIOMetadata = getImageReader().getImageMetadata(0) />
				<cfcatch> --->
			<cfset IIOMetadata = ImageWriter.getDefaultImageMetadata(ImageTypeSpecifier, ImageWriteParam) />
				<!--- </cfcatch>
			</cftry> --->
			
			<!--- create a new buffered image --->
			<cfif width GTE height>
				<cfset proportion = 1 / width />
			<cfelse>
				<cfset proportion = 1 / height />
			</cfif>
						
			<cfset ThumbnailImage = createComparableImage(Image, JavaCast("int", 1), JavaCast("int", 1)) />
			
			<!--- create a list and add this thumbnail to it --->
			<cfset List = CreateObject("Java", "java.util.Vector").init(JavaCast("int", 0)) />
			<cfset List.add(ThumbnailImage) />
			
			<!--- create an IIOImage (this is our image that we're going to write out) (no, its not really an image) --->
			<cfset IIOImage = CreateObject('Java', "javax.imageio.IIOImage").init(Image, List, IIOMetadata) />
					
			<!--- create an output stream based on the provided outputstream --->
			<cfset ImageOutputStream = getImageIO().createImageOutputStream(arguments.OutputStream) />
			<cfset ImageWriter.setOutput(ImageOutputStream) />
					
			<!--- write the image  --->
			<cfset ImageWriter.write(IIOMetadata, IIOImage, ImageWriteParam) />
		<cfelse>
			<!--- we're running on MX 7, save some effort (and size!) --->
			
			<!--- create an IIOImage (this is our image that we're going to write out) (no, its not really an image) --->
			<cfset IIOImage = CreateObject('Java', "javax.imageio.IIOImage").init(Image, JavaCast("null", ""), JavaCast("null", "")) />
			
			<!--- create an output stream based on the provided outputstream --->
			<cfset ImageOutputStream = getImageIO().createImageOutputStream(arguments.OutputStream) />
			<cfset ImageWriter.setOutput(ImageOutputStream) />
			
			<!--- write the image  --->
			<cfset ImageWriter.write( JavaCast("null", ""), IIOImage, ImageWriteParam) />

		</cfif>

		<!--- flush and finalize the image --->
		<cfset Image.flush() />
		
		<!--- cleanup
		<cftry>
			<cfset getImageReader().close() />
			<cfcatch></cfcatch>
		</cftry> --->
		
		<cfset ImageOutputStream.flush() />
		<cfset ImageWriter.dispose() />
		<cfset ImageOutputStream.close() />
		<cfset arguments.OutputStream.close() />		
	</cffunction>
	
	<!--- writeStandardToOutputStream
	<cffunction name="writeStandardToOutputStream" access="private" output="false" returntype="void" hint="I write the image to an outputstream.">
		<cfargument name="format" hint="I am the format of the file to write to." required="yes" type="string" />
		<cfargument name="OutputStream" hint="I am the OutputStream to write to." required="yes" type="any" />
		<cfset var Image = getImage() />
		
		<!--- Because this is a private method I'm not validating that the OutputStream comming in is really an output stream ---> 
				
		<cftry>
			<!--- output the file --->
			<cfset getImageIO().write(Image, arguments.format, arguments.OutputStream) />
		
			<cfcatch>
				<cfthrow message="There was an error writing the image to the #arguments.path#." />
			</cfcatch>		
		</cftry>
		
	</cffunction> --->
		
	<!--- scalePixels --->
	<cffunction name="scalePixels" access="public" output="false" returntype="void" hint="I scale the image to a width and height specified in pixels.">
		<cfargument name="width" hint="I am the new pixel width for the image" required="yes" type="numeric" />
		<cfargument name="height" hint="I am the new pixel height for the image" required="yes" type="numeric" />
		<cfset var Image = getImage() />
		<cfset var widthPercent = 0 />
		<cfset var heightPercent = 0 />
		
		<!--- insure that the width and height are > 0 --->
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attribute must be greater than 0." />
		</cfif> 
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attribute must be greater than 0." />
		</cfif> 
		
		<!--- change new pixel sizes to percents --->
		<cfset widthPercent = arguments.width / Image.getWidth() />
		<cfset heigthPercent = arguments.height / Image.getHeight() />
		
		<!--- scale the image --->
		<cfset scale(widthPercent, heigthPercent) />
	</cffunction>
	
	<!--- scalePercent --->
	<cffunction name="scalePercent" access="public" output="false" returntype="void" hint="I scale the image to a width and height specified by percent.">
		<cfargument name="width" hint="I am the percent by which the image width will be scaled." required="yes" type="numeric" />
		<cfargument name="height" hint="I am the percent by which the image height will be scaled." required="yes" type="numeric" />
		
		<!--- insure that the width and height are > 0 --->
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attribute must be greater than 0." />
		</cfif> 
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attribute must be greater than 0." />
		</cfif> 
		
		<!--- scale the image --->
		<cfset scale(arguments.width / 100, arguments.height / 100) />
	</cffunction>
	
	<!--- scaleWidth(size[numeric:required], percentOrPixels[string:optional:percent(default),pixels], proportional[boolean:optional]) --->
	<!--- scaleWidth --->
	<cffunction name="scaleWidth" access="public" output="false" returntype="void" hint="I scale the image based on a provided width.">
		<cfargument name="value" hint="I am the size value to rescale to." required="yes" type="numeric" />
		<cfargument name="percentOrPixels" hint="I indicate if the scaling is in percent or pixels.  Options are: percent or pixels." required="no" type="string" default="pixels" />
		<cfargument name="proportional" hint="I indicate if the scale operation is proportional." required="no" type="boolean" default="true" />
		<cfset var initialHeight = getHeight() />
		<cfset var initialWidth = getWidth() />
		<cfset var scaleRatio = arguments.value / initialWidth />
		
		<cfif arguments.value LT 1>
			<cfthrow message="Invalid value attribute.  The value attribute must be greater than or equal to 1." />
		</cfif>
		<!--- verify the percentOrPixels argument --->
		<cfif NOT ListFindNoCase("percent,pixels", arguments.percentOrPixels)>
			<cfthrow message="Invalid percentOrPixels attribute.  The percentOrPixels attribute must be one of: percent or pixels." />
		</cfif>
		
		<!--- check to see if we're rescaling according to percent size or pixel size --->
		<cfif arguments.percentOrPixels IS "percent">
			<!--- percent --->
			<!--- we recieved the width in percent already, all we need to know is if we use the same percent or 100 percent --->
			<cfif arguments.proportional>
				<cfset scalePercent(arguments.value, arguments.value) />
			<cfelse>
				<cfset scalePercent(arguments.value, 100) />
			</cfif>
		<cfelseif arguments.percentOrPixels IS "pixels">
			<!--- pixels --->
			<!--- we know the target width in pixels, do we use the inital height or a scaled height? --->
			<cfif arguments.proportional>
				<cfset scalePixels(arguments.value, initialHeight * scaleRatio) />
			<cfelse>
				<cfset scalePixels(arguments.value, initialHeight) />
			</cfif>
		</cfif>
	</cffunction>
	
	<!--- scaleHeight --->
	<cffunction name="scaleHeight" access="public" output="false" returntype="void" hint="I scale the image based on a provided height.">
		<cfargument name="value" hint="I am the size value to rescale to." required="yes" type="numeric" />
		<cfargument name="percentOrPixels" hint="I indicate if the scaling is in percent or pixels.  Options are: percent or pixels." required="no" type="string" default="pixels" />
		<cfargument name="proportional" hint="I indicate if the scale operation is proportional." required="no" type="boolean" default="true" />
		<cfset var initialHeight = getHeight() />
		<cfset var initialWidth = getWidth() />
		<cfset var scaleRatio = arguments.value / initialHeight />
		
		<cfif arguments.value LT 1>
			<cfthrow message="Invalid value attribute.  The value attribute must be greater than or equal to 1." />
		</cfif>
		<!--- verify the percentOrPixels argument --->
		<cfif NOT ListFindNoCase("percent,pixels", arguments.percentOrPixels)>
			<cfthrow message="Invalid percentOrPixels attribute.  The percentOrPixels attribute must be one of: percent or pixels." />
		</cfif>
		
		<!--- check to see if we're rescaling according to percent size or pixel size --->
		<cfif arguments.percentOrPixels IS "percent">
			<!--- percent --->
			<!--- we recieved the height in percent already, all we need to know is if we use the same percent or 100 percent --->
			<cfif arguments.proportional>
				<cfset scalePercent(arguments.value, arguments.value) />
			<cfelse>
				<cfset scalePercent(100, arguments.value) />
			</cfif>
		<cfelseif arguments.percentOrPixels IS "pixels">
			<!--- pixels --->
			<!--- we know the target height in pixels, do we use the inital width or a scaled width? --->
			<cfif arguments.proportional>
				<cfset scalePixels(initialWidth * scaleRatio, arguments.value) />
			<cfelse>
				<cfset scalePixels(initialWidth, arguments.value) />
			</cfif>
		</cfif>
	</cffunction>
	
	<!--- scaleToFit --->
	<cffunction name="scaleToFit" access="public" output="false" returntype="void" hint="I scale the image to fit within a square of a certian pixel size.">
		<cfargument name="value" hint="I am the pixel size to rescale to fit within." required="yes" type="numeric" />
		<cfset var initialHeight = getHeight() />
		<cfset var initialWidth = getWidth() />
		<cfset var scaleRatio = 0 />
		
		<cfif arguments.value LT 1>
			<cfthrow message="Invalid value attribute.  The value attribute must be greater than or equal to 1." />
		</cfif>
		
		<!--- check to see if the image is taller or as tall as it is wide --->
		<cfif initialHeight GTE initialWidth>
			<cfset scaleHeight(arguments.value) />
		<cfelse>
			<cfset scaleWidth(arguments.value) />
		</cfif>
		
	</cffunction>
	
	<!--- scaleToFit --->
	<cffunction name="scaleToBox" access="public" output="false" returntype="void" hint="I scale the image to fit within a box of a certian pixel size.">
		<cfargument name="width" hint="I am the pixel width to rescale to fit within." required="yes" type="numeric" />
		<cfargument name="height" hint="I am the pixel height to rescale to fit within." required="yes" type="numeric" />
		<cfargument name="enlarge" type="boolean" required="false" default="false" hint="Whether to enlarge image if smaller than given width/height">
		
		<cfset var initialHeight = getHeight() />
		<cfset var initialWidth = getWidth() />
		<cfset var scaleRatioW = arguments.width / initialWidth />
		<cfset var scaleRatioH = arguments.height / initialHeight />
		<cfset var minScale = min(scaleRatioW, scaleRatioH) />
		
		<cfif arguments.width LT 1 OR arguments.height LT 1>
			<cfthrow message="Invalid width or height attribute.  The width and height attributes must be greater than or equal to 1." />
		</cfif>
		
		<cfif (NOT arguments.enlarge)>
			<cfset minScale = min(1, minScale) />
			<cfif minScale EQ 1>
				<cfreturn /><!--- no resizing needed --->
			</cfif>
		</cfif>
		
		<cfif scaleRatioH LT scaleRatioW>
			<cfset scaleHeight(arguments.height) />
		<cfelse>
			<cfset scaleWidth(arguments.width) />
		</cfif>
		
	</cffunction>
		
	<!--- crop --->
	<cffunction name="crop" access="public" output="false" returntype="void" hint="I crop the image.">
		<cfargument name="x" hint="I am the upper left X coordinate." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the upper left Y coordinate." required="yes" type="numeric" />
		<cfargument name="width" hint="I am the width of the crop." required="yes" type="numeric" />
		<cfargument name="height" hint="I am the height of the crop." required="yes" type="numeric" />
		<cfset var Image = getImage() />
		<cfset var CroppedImage = createObject("java", "java.awt.image.BufferedImage") />
		
		<cfif arguments.x LT 0>
			<cfthrow message="Invalid x attribute.  The x attribute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.y LT 0>
			<cfthrow message="Invalid y attribute.  The y attribute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attribute must be greater than 0." />
		</cfif>
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attribute must be greater than 0." />
		</cfif>
		
		<!---
			Verify the crop region is inside the image:
				1) x >= 0
				2) x < Image width
				3) width > 0
				4) x+width <= Image width
				5) y >= 0
				6) y < Image height
				7) height > 0
				8) y+height <= Image height
		--->
		<cfif NOT(
			arguments.x GTE 0 AND
			arguments.x LT Image.getWidth() AND
			arguments.width GT 0 AND
			arguments.x + arguments.width LTE Image.getWidth() AND
			arguments.y GTE 0 AND
			arguments.y LT Image.getHeight() AND
			arguments.height GT 0 AND
			arguments.y + arguments.height LTE Image.getHeight()
		)>
			<cfthrow message="Image does not contain crop region." />
		</cfif>
		
		<!--- crop the image --->
		<cfset CroppedImage = Image.getSubimage(JavaCast("int", arguments.x), JavaCast("int", arguments.y), JavaCast("int", arguments.width), JavaCast("int", arguments.height)) />
		
		<!--- return the cropped image --->
		<cfset setImage(CroppedImage) />		
	</cffunction>
	
	<!--- setImageSize --->
	<cffunction name="setImageSize" access="public" output="false" returntype="void" hint="I change the size of the image without rescaling the image.">
		<cfargument name="width" hint="I am the new pixel width for the image" required="yes" type="numeric">
		<cfargument name="height" hint="I am the new pixel height for the image" required="yes" type="numeric">
		<cfargument name="align" hint="I am the location to align the image inside the new canvas.  Options are: topLeft, middleLeft, bottomLeft, topCenter, middleCenter, bottomCenter, topRight, middleRight, bottomRight.  Defaults to topLeft." required="no" type="string" default="topLeft" />
		<cfset var Image = getImage() />
		<cfset var NewImage = createComparableImage(Image, JavaCast("int", arguments.width), JavaCast("int", arguments.height)) />
		<cfset var Transform = CreateObject("Java", "java.awt.geom.AffineTransform") />
		<cfset var Operation = CreateObject("Java", "java.awt.image.AffineTransformOp") />
		<cfset var Graphics = 0 />
		<cfset var x = 0 />
		<cfset var y = 0 />
		
		<!--- validate attributes --->
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attribute must be greater than 0." />
		</cfif>
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attribute must be greater than 0." />
		</cfif>
		<cfif NOT ListFindNoCase("topLeft,middleLeft,bottomLeft,topCenter,middleCenter,bottomCenter,topRight,middleRight,bottomRight", arguments.align)>
			<cfthrow message="Invalid align attribute.  The align attribute must be one of: topLeft, middleLeft, bottomLeft, topCenter, middleCenter, bottomCenter, topRight, middleRight, bottomRight." />
		</cfif>
		
		<!--- find out how far we need to translate the image --->
		<cfswitch expression="#arguments.align#">
			<cfcase value="topLeft">
				<cfset x = 0 />
				<cfset y = 0 />
			</cfcase>
			<cfcase value="middleLeft">
				<cfset x = 0 />
				<cfset y = round((arguments.height - Image.getHeight()) / 2) />
			</cfcase>
			<cfcase value="bottomLeft">
				<cfset x = 0 />
				<cfset y = arguments.height - Image.getHeight() />
			</cfcase>
			
			<cfcase value="topCenter">
				<cfset x = round((arguments.width - Image.getWidth()) / 2) />
				<cfset y = 0 />
			</cfcase>
			<cfcase value="middleCenter">
				<cfset x = round((arguments.width - Image.getWidth()) / 2) />
				<cfset y = round((arguments.height - Image.getHeight()) / 2) />
			</cfcase>
			<cfcase value="bottomCenter">
				<cfset x = round((arguments.width - Image.getWidth()) / 2) />
				<cfset y = arguments.height - Image.getHeight() />
			</cfcase>
			
			<cfcase value="topRight">
				<cfset x = arguments.width - Image.getWidth() />
				<cfset y = 0 />
			</cfcase>
			<cfcase value="middleRight">
				<cfset x = arguments.width - Image.getWidth() />
				<cfset y = round((arguments.height - Image.getHeight()) / 2) />
			</cfcase>
			<cfcase value="bottomRight">
				<cfset x = arguments.width - Image.getWidth() />
				<cfset y = arguments.height - Image.getHeight() />
			</cfcase>			
		</cfswitch>
		
		<cfscript>
			Graphics = NewImage.getGraphics();
			If( IsObject(getBackgroundColor()) ){
				Graphics.setBackground(getBackgroundColor());
			}
			Graphics.clearRect(JavaCast("int", 0), JavaCast("int", 0), JavaCast("int", width), JavaCast("int", height));
			
			Transform.translate(x, y);
			Operation.init(Transform, Operation.TYPE_NEAREST_NEIGHBOR);
			Graphics.drawImage(Image, Operation, JavaCast("int", 0), JavaCast("int", 0));
		</cfscript>
		
		<cfset setImage(NewImage) />	
	</cffunction>
	
	<!--- flipHorizontal --->
	<cffunction name="flipHorizontal" access="public" output="false" returntype="void" hint="I flip the image along the horizontal axis.">
		<cfset var Image = getImage() />
		<cfset var FlippedImage = createComparableImage(Image) />
		<cfset var Transform = CreateObject("Java", "java.awt.geom.AffineTransform") />
		<cfset var Operation = CreateObject("Java", "java.awt.image.AffineTransformOp") />
		
		<cfscript>
			Transform = Transform.getScaleInstance(1, -1);
			Transform.translate(0, -Image.getHeight());
			Operation.init(Transform, Operation.TYPE_NEAREST_NEIGHBOR);
			Operation.filter(Image, FlippedImage);
		</cfscript>
		
		<cfset setImage(FlippedImage) />	
	</cffunction>
	
	<!--- flipVertical --->
	<cffunction name="flipVertical" access="public" output="false" returntype="void" hint="I flip the image along the vertical axis.">
		<cfset var Image = getImage() />
		<cfset var FlippedImage = createComparableImage(Image) />
		<cfset var Transform = CreateObject("Java", "java.awt.geom.AffineTransform") />
		<cfset var Operation = CreateObject("Java", "java.awt.image.AffineTransformOp") />
		
		<cfscript>
			Transform = Transform.getScaleInstance(-1, 1);
			Transform.translate(-Image.getWidth(), 0);
			Operation.init(Transform, Operation.TYPE_NEAREST_NEIGHBOR);
			Operation.filter(Image, FlippedImage);
		</cfscript>
		
		<cfset setImage(FlippedImage) />	
	</cffunction>
	
	<!--- grayScale --->
	<cffunction name="grayScale" access="public" output="false" returntype="void" hint="I set the image to gray scale.">
		<cfset var Image = getImage() />
		<cfset var GrayImage = createObject("java", "java.awt.image.BufferedImage") />
		<cfset var ColorSpace = CreateObject("Java", "java.awt.color.ColorSpace") />
		<cfset var RenderingHints = CreateObject("Java", "java.awt.RenderingHints") />
		<cfset var ColorConvertOp = CreateObject("Java", "java.awt.image.ColorConvertOp") />
		
		<cfscript>
			GrayImage.init(JavaCast("int", Image.getWidth()), JavaCast("int", Image.getHeight()), JavaCast("int", Image.getType()));
			ColorSpace = ColorSpace.getInstance(ColorSpace.CS_GRAY);
			RenderingHints.init(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_DEFAULT);
			ColorConvertOp.init(ColorSpace, RenderingHints);
			GrayImage = ColorConvertOp.filter(Image, GrayImage);
		</cfscript>
		
		<cfset setImage(GrayImage) />	
	</cffunction>
	
	<!--- blur --->
	<cffunction name="blur" access="public" output="false" returntype="void" hint="I blur the image.">
		<cfargument name="size" hint="I am the size of the blur.  In general, I am the number of pixels arround the souce pixel which are used for the blur.  The higher the number, the more blury the image." required="yes" type="numeric">
		<cfset var kernelArray = ArrayNew(1) />	
		<cfset var blurAmount = JavaCast("int", (round(arguments.size) * 2) + 1) />
		<cfset var q = 0 />
		
		<!--- validate size --->
		<cfif arguments.size LT 0>
			<cfthrow
				type="Alagad.Image.InvalidArgumentValue"
				message="Invalid size attribute.  The size attribute must be greater than or equal to 0." />
		</cfif>
				
		<!--- create the kernel --->
		<cfloop from="1" to="#evaluate(blurAmount*blurAmount)#" index="q">
			<cfset ArrayAppend(kernelArray, 1/(blurAmount*blurAmount)) />
		</cfloop>
		
		<cfset convolve(JavaCast("int", blurAmount), kernelArray) />	
	</cffunction>
	
	<!--- findEdges --->
	<cffunction name="findEdges" access="public" output="false" returntype="void" hint="I find the image's edges.">
		<cfargument name="size" hint="I am the size of the edge to find." required="yes" type="numeric">
		<cfargument name="strength" hint="I am the strength of the function." required="yes" type="numeric">
		<cfset var kernelArray = ArrayNew(1) />	
		<cfset var edgeAmount = int((round(arguments.size) * 2) + 1) />
		<cfset var row = 0 />
		<cfset var column = 0 />
		<cfset var denominator = arguments.size * 4 />
		<cfset var q = 0 />
		
		<!--- validate size --->
		<cfif arguments.size LTE 0>
			<cfthrow message="Invalid size attribute.  The size attribute must be greater than 0." />
		</cfif>
		<cfif arguments.strength LTE 0>
			<cfthrow message="Invalid strength attribute.  The strength attribute must be greater than 0." />
		</cfif>
		
		<!--- create the kernel --->
		<cfloop from="1" to="#evaluate(edgeAmount*edgeAmount)#" index="q">
			<cfif q MOD edgeAmount IS 1>
				<cfset row = row + 1 />
			</cfif>
			<cfset column = ((q-1) MOD edgeAmount) + 1 />
			
			<!--- check to see if we're in the middle column or row, but not the middle element --->
			<cfif row IS arguments.size + 1 AND column IS arguments.size + 1>
				<cfset ArrayAppend(kernelArray, arguments.strength) />
			<cfelseif row IS arguments.size + 1 or column IS arguments.size + 1>
				<cfset ArrayAppend(kernelArray, -(arguments.strength/denominator)) />
			<cfelse>
				<cfset ArrayAppend(kernelArray, 0.0) />
			</cfif>
		</cfloop>
		
		<cfset convolve(JavaCast("int", edgeAmount), kernelArray) />	
	</cffunction>
	
	<!--- sharpen --->
	<cffunction name="sharpen" access="public" output="false" returntype="void" hint="I sharpen the image.">
		<cfargument name="size" hint="I am the size of the edge to sharpen." required="yes" type="numeric">
		<cfargument name="strength" hint="I am the strength of the function." required="yes" type="numeric">
		<cfset var kernelArray = ArrayNew(1) />	
		<cfset var edgeAmount = int((round(arguments.size) * 2) + 1) />
		<cfset var row = 0 />
		<cfset var column = 0 />
		<cfset var denominator = arguments.size * 4 />
		<cfset var q = 0 />
		
		<!--- validate size --->
		<cfif arguments.size LTE 0>
			<cfthrow message="Invalid size attribute.  The size attribute must be greater than 0." />
		</cfif>
		<cfif arguments.strength LTE 0>
			<cfthrow message="Invalid strength attribute.  The strength attribute must be greater than 0." />
		</cfif>
		
		<!--- create the kernel --->
		<cfloop from="1" to="#evaluate(edgeAmount*edgeAmount)#" index="q">
			<cfif q MOD edgeAmount IS 1>
				<cfset row = row + 1 />
			</cfif>
			<cfset column = ((q-1) MOD edgeAmount) + 1 />
			
			<!--- check to see if we're in the middle column or row, but not the middle element --->
			<cfif row IS arguments.size + 1 AND column IS arguments.size + 1>
				<!--- unlike the findEdges method, the sharpen method nees to have the source pixel be brigher than the kernel pixels, so we set it to the amount + 1 --->
				<cfset ArrayAppend(kernelArray, arguments.strength + 1) />
			<cfelseif row IS arguments.size + 1 or column IS arguments.size + 1>
				<cfset ArrayAppend(kernelArray, -(arguments.strength/denominator)) />
			<cfelse>
				<cfset ArrayAppend(kernelArray, 0.0) />
			</cfif>
		</cfloop>
		
		<cfset convolve(JavaCast("int", edgeAmount), kernelArray) />	
	</cffunction>
	
	<!--- emboss --->
	<cffunction name="emboss" access="public" output="false" returntype="void" hint="I emboss the image.">
		<cfargument name="size" hint="I am the size of the edge to emboss." required="yes" type="numeric">
		<cfargument name="strength" hint="I am the strength of the function." required="yes" type="numeric">
		<cfset var kernelArray = ArrayNew(1) />	
		<cfset var embossAmount = int((round(arguments.size) * 2) + 1) />
		<cfset var row = 0 />
		<cfset var column = 0 />
		<cfset var q = 0 />
		
		<!--- validate size --->
		<cfif arguments.size LTE 0>
			<cfthrow message="Invalid size attribute.  The size attribute must be greater than 0." />
		</cfif>
		<cfif arguments.strength LTE 0>
			<cfthrow message="Invalid strength attribute.  The strength attribute must be greater than 0." />
		</cfif>
		
		<!--- create the kernel --->
		<cfloop from="1" to="#evaluate(embossAmount*embossAmount)#" index="q">
			<cfif q MOD embossAmount IS 1>
				<cfset row = row + 1 />
			</cfif>
			<cfset column = ((q-1) MOD embossAmount) + 1 />
			
			<!--- check to see if we're in the middle column or row, but not the middle element --->
			<cfif row IS column AND row LT arguments.size + 1>
				<cfset ArrayAppend(kernelArray, -arguments.strength) />
			<cfelseif row GT arguments.size + 1 AND column GT arguments.size + 1 AND row IS column>
				<cfset ArrayAppend(kernelArray, 1) />
			<cfelseif row IS arguments.size + 1 AND column IS arguments.size + 1>
				<cfset ArrayAppend(kernelArray, arguments.strength) />
			<cfelse>
				<cfset ArrayAppend(kernelArray, 0.0) />
			</cfif>
		</cfloop>
				
		<cfset convolve(JavaCast("int", embossAmount), kernelArray) />	
	</cffunction>
	
	<!--- rotate --->
	<cffunction name="rotate" access="public" returntype="void" hint="I rotate an image a given number of degrees.">
		<cfargument name="angle" hint="I am the angle in degrees to rotate the image." required="yes" type="numeric" />
		<cfargument name="resizeImage" hint="I indicate if the image should be resized to fit the rotated Image." required="no" default="false" type="boolean" />
		<cfset var Image = getImage() />
		<cfset var RotatedImage = 0 />
		<cfset var RenderingHints = CreateObject("Java", "java.awt.RenderingHints") />
		<cfset var Transform = CreateObject("Java", "java.awt.geom.AffineTransform") />
		<cfset var Operation = CreateObject("Java", "java.awt.image.AffineTransformOp") />
		<cfset var RADIAN_DEGREE_RATIO = 0.0174532925 />
		<cfset var width = Image.getWidth() />
		<cfset var height = Image.getHeight() />
		<cfset var translateDown = 0 />
		<cfset var translateRight = 0 />
		<cfset var Graphics = 0 />
		
		<!--- fix the angle --->
		<cfset arguments.angle = arguments.angle MOD 360 />
		<cfif arguments.angle LT 0>
			<cfset arguments.angle = arguments.angle + 360 />
		</cfif>
		
		<cfif arguments.resizeImage AND (arguments.angle LTE 90 OR (arguments.angle GT 180 AND arguments.angle LT 270))>
			<cfset height = abs(round(sin((90 - arguments.angle) * RADIAN_DEGREE_RATIO) * Image.getHeight() + sin(arguments.angle * RADIAN_DEGREE_RATIO) * Image.getWidth())) />
			<cfset width  = abs(round(sin((90 - arguments.angle) * RADIAN_DEGREE_RATIO) * Image.getWidth()  + sin(arguments.angle * RADIAN_DEGREE_RATIO) * Image.getHeight()))/>
		<cfelseif arguments.resizeImage>
			<cfset height = abs(round(sin( (90 - (arguments.angle - 90)) * RADIAN_DEGREE_RATIO) * Image.getWidth()  + sin( (arguments.angle - 90) * RADIAN_DEGREE_RATIO) * Image.getHeight())) />
			<cfset width  = abs(round(sin( (90 - (arguments.angle - 90)) * RADIAN_DEGREE_RATIO) * Image.getHeight() + sin( (arguments.angle - 90) * RADIAN_DEGREE_RATIO) * Image.getWidth())) />
		</cfif>
		<cfset translateDown = int((Image.getHeight() - height) / 2) />
		<cfset translateRight = int((Image.getWidth() - width) / 2) />
		
		<cfscript>
			RotatedImage = createComparableImage(Image, JavaCast("int", width), JavaCast("int", height));
			Graphics = RotatedImage.getGraphics();
			If( IsObject(getBackgroundColor()) ){
				Graphics.setBackground(getBackgroundColor());
			}
			Graphics.clearRect(JavaCast("int", 0), JavaCast("int", 0), JavaCast("int", width), JavaCast("int", height));		
			RenderingHints.init(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
			Transform = Transform.getTranslateInstance(-translateRight, -translateDown);
			Transform.rotate(arguments.angle * RADIAN_DEGREE_RATIO, Image.getWidth()/2, Image.getHeight()/2);
			Operation.init(Transform, RenderingHints);
			Operation.filter(Image, RotatedImage);
		</cfscript>
		
		<cfset setImage(RotatedImage) />
	</cffunction>
	
	<!--- negate --->
	<cffunction name="negate" access="public" output="false" returntype="void" hint="I invert the image colors.">
		<cfset adjustLevels(255, 0) />
	</cffunction>
	
	<!--- lighten --->
	<cffunction name="lighten" access="public" output="false" returntype="void" hint="I lighten the image.">
		<cfargument name="percent" hint="I am the percent to lighten the image" required="yes" type="numeric">
		
		<!--- check to make sure the percent is >= 0 and <= 100 --->
		<cfif NOT (arguments.percent GTE 0 AND arguments.percent LTE 100)>
			<cfthrow message="Invalid percent attribute.  The percent attribute must be greater than or equal to 0 and less than or equal to 100." />
		</cfif>
		
		<cfset arguments.percent = round(255 * (arguments.percent / 100)) />
				
		<cfset adjustLevels(arguments.percent, 255) />
	</cffunction>
	
	<!--- darken --->
	<cffunction name="darken" access="public" output="false" returntype="void" hint="I darken the image.">
		<cfargument name="percent" hint="I am the percent to darken the image" required="yes" type="numeric">
		
		<!--- check to make sure the percent is >= 0 and <= 100 --->
		<cfif NOT (arguments.percent GTE 0 AND arguments.percent LTE 100)>
			<cfthrow message="Invalid percent attribute.  The percent attribute must be greater than or equal to 0 and less than or equal to 100." />
		</cfif>
		
		<cfset arguments.percent = 255 - round(255 * (arguments.percent / 100)) />
				
		<cfset adjustLevels(0, arguments.percent) />
	</cffunction>
	
	<!--- adjustLevels --->
	<cffunction name="adjustLevels" access="public" output="false" returntype="void" hint="I adjust the contrast levels in the image.">
		<cfargument name="low" hint="I am the low value.  I must be between 0 and 255" required="yes" type="numeric">
		<cfargument name="high" hint="I am the high value.  I must be between 0 and 255" required="yes" type="numeric">
		<cfset var ArrayObj = CreateObject("Java", "java.lang.reflect.Array") />
		<cfset var Short = CreateObject("Java", "java.lang.Short") />
		<cfset var ArrayType = Short.TYPE />
		<cfset var ShortArray = ArrayObj.newInstance(ArrayType, 256) />
		<cfset var slope = (arguments.high - arguments.low) / 255  />
		<cfset var x1 = 0 />
		<cfset var y1 = arguments.low />
		<cfset var y = 0 />
		<cfset var x = 0 />
		
		<!--- verify arguments --->
		<cfif arguments.low LT 0 OR arguments.low GT 255>
			<cfthrow
				type="Alagad.Image.InvalidArgumentValue"
				message="Invalid low attribute.  The low attribute must be greater than or equal to 0 and less than or equal to 255." />
		</cfif>
		<cfif arguments.high LT 0 OR arguments.high GT 255>
			<cfthrow
				type="Alagad.Image.InvalidArgumentValue"
				message="Invalid high attribute.  The high attribute must be greater than or equal to 0 and less than or equal to 255." />
		</cfif>
		
		<cfloop from="0" to="255" index="x">
			<cfset x = int(x) />
			<cfset y = int(round((slope * (x - x1)) + y1)) />
			
			<cfset ArrayObj.setShort(ShortArray, Short.parseShort(JavaCast("string", x)), Short.parseShort(JavaCast("string", y))) />
		</cfloop>
		
		<cfset applyLookupTable(ShortArray) />
	</cffunction>
	
	<!--- drawLine --->
	<cffunction name="drawLine" access="public" output="false" returntype="void" hint="I draw a line on the image.">
		<cfargument name="x1" hint="I am the first x coordinate." required="yes" type="numeric" />
		<cfargument name="y1" hint="I am the first y coordinate." required="yes" type="numeric" />
		<cfargument name="x2" hint="I am the second x coordinate." required="yes" type="numeric" />
		<cfargument name="y2" hint="I am the second y coordinate." required="yes" type="numeric" />
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		
		<!--- validate x1, y1, x2, y2 --->
		<cfif arguments.x1 LT 0>
			<cfthrow message="Invalid x1 attribute.  The x1 attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.y1 LT 0>
			<cfthrow message="Invalid y1 attribute.  The y1 attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.x2 LT 0>
			<cfthrow message="Invalid x2 attribute.  The x2 attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.y2 LT 0>
			<cfthrow message="Invalid y2 attribute.  The y2 attibute must be greater than or equal to 0." />
		</cfif>
		
		<!--- check to see if we have a color --->
		<cfif IsObject(getColor())>
			<cfset Graphics.setColor(getColor()) />
		</cfif>
		
		<!--- check to see if we have a stroke --->
		<cfif IsObject(getStroke())>
			<cfset Graphics.setStroke(getStroke()) />
		</cfif>
		
		<!--- draw the line --->
		<cfset Graphics.drawLine(JavaCast("int", arguments.x1), JavaCast("int", arguments.y1), JavaCast("int", arguments.x2), JavaCast("int", arguments.y2)) />
		
		<!--- reset the graphics context --->
		<cfset Graphics.finalize() />
		<cfset Graphics.dispose() />
	</cffunction>
	
	<!--- addPolygonPoint --->
	<cffunction name="addPolygonPoint" access="public" output="false" returntype="void" hint="I add a point to the current polygon.">
		<cfargument name="Polygon" hint="I am the polygon to append the point to." required="yes" type="any" />
		<cfargument name="x" hint="I am the upper left X coordinate." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the upper left Y coordinate." required="yes" type="numeric" />
		
		<!--- verify the polygon --->
		<cfif NOT IsObject(arguments.Polygon) OR arguments.Polygon.getClass().getName() IS NOT "java.awt.Polygon" >
			<cfthrow message="The Polygon attribute must be a Polygon object." />
		</cfif>	


		<!--- validate the point
		<cfif arguments.x LT 0>
			<cfthrow message="Invalid x attribute.  The x attribute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.y LT 0>
			<cfthrow message="Invalid y attribute.  The y attribute must be greater than or equal to 0." />
		</cfif> --->
		<cfset arguments.Polygon.addPoint(javacast("int", arguments.x), javacast("int", arguments.y))  />
	</cffunction>
	
	<!--- addPathLine --->
	<cffunction name="addPathLine" access="public" output="false" returntype="void" hint="I draw a straight line from the last point in the path to the next.">
		<cfargument name="Path" hint="I am the path to append the point to." required="yes" type="any" />
		<cfargument name="x" hint="I am the upper left X coordinate." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the upper left Y coordinate." required="yes" type="numeric" />
		
		<!--- verify the path --->
		<cfif NOT IsObject(arguments.Path) OR arguments.Path.getClass().getName() IS NOT "java.awt.geom.GeneralPath" >
			<cfthrow message="The Path attribute must be a Path object." />
		</cfif>	

		<cfset arguments.Path.lineTo(javacast("int", arguments.x), javacast("int", arguments.y))  />
	</cffunction>
	
	<!--- addPathJump --->
	<cffunction name="addPathJump" access="public" output="false" returntype="void" hint="I add a point to the path without drawing a line.">
		<cfargument name="Path" hint="I am the path to append the point to." required="yes" type="any" />
		<cfargument name="x" hint="I am the upper left X coordinate." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the upper left Y coordinate." required="yes" type="numeric" />
		
		<!--- verify the path --->
		<cfif NOT IsObject(arguments.Path) OR arguments.Path.getClass().getName() IS NOT "java.awt.geom.GeneralPath" >
			<cfthrow message="The Path attribute must be a Path object." />
		</cfif>	

		<cfset arguments.Path.moveTo(javacast("int", arguments.x), javacast("int", arguments.y))  />
	</cffunction>
	
	<!--- addPathQuadraticCurve --->
	<cffunction name="addPathQuadraticCurve" access="public" output="false" returntype="void" hint="I add a quadratic curve to the path from the last point.">
		<cfargument name="Path" hint="I am the path to append the point to." required="yes" type="any" />
		<cfargument name="x" hint="I am the target X coordinate." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the target Y coordinate." required="yes" type="numeric" />
		<cfargument name="controlX" hint="I am the X coordinate for the control point." required="yes" type="numeric" />
		<cfargument name="controlY" hint="I am the Y coordinate for the control point." required="yes" type="numeric" />
		
		<!--- verify the path --->
		<cfif NOT IsObject(arguments.Path) OR arguments.Path.getClass().getName() IS NOT "java.awt.geom.GeneralPath" >
			<cfthrow message="The Path attribute must be a Path object." />
		</cfif>	

		<cfset arguments.Path.quadTo(javacast("int", arguments.controlX), javacast("int", arguments.controlY), javacast("int", arguments.x), javacast("int", arguments.y))  />
	</cffunction>
	
	<!--- addPathBezierCurve --->
	<cffunction name="addPathBezierCurve" access="public" output="false" returntype="void" hint="I add a bezier curve to the path from the last point.">
		<cfargument name="Path" hint="I am the path to append the point to." required="yes" type="any" />
		<cfargument name="x" hint="I am the target X coordinate." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the target Y coordinate." required="yes" type="numeric" />
		<cfargument name="controlX1" hint="I am the X coordinate for the first control point." required="yes" type="numeric" />
		<cfargument name="controlY1" hint="I am the Y coordinate for the first control point." required="yes" type="numeric" />
		<cfargument name="controlX2" hint="I am the X coordinate for the second control point." required="yes" type="numeric" />
		<cfargument name="controlY2" hint="I am the Y coordinate for the second control point." required="yes" type="numeric" />
		
		<!--- verify the path --->
		<cfif NOT IsObject(arguments.Path) OR arguments.Path.getClass().getName() IS NOT "java.awt.geom.GeneralPath" >
			<cfthrow message="The Path attribute must be a Path object." />
		</cfif>	

		<cfset arguments.Path.curveTo(
			javacast("int", arguments.controlX1), javacast("int", arguments.controlY1), 
			javacast("int", arguments.controlX2), javacast("int", arguments.controlY2), 
			javacast("int", arguments.x), javacast("int", arguments.y))  />
	</cffunction>
	
	<!--- closePath --->
	<cffunction name="closePath" access="public" output="false" returntype="void" hint="I draw a strait line from the last path to the first path.">
		<cfargument name="Path" hint="I am the path to append the point to." required="yes" type="any" />
		<!--- verify the path --->
		<cfif NOT IsObject(arguments.Path) OR arguments.Path.getClass().getName() IS NOT "java.awt.geom.GeneralPath" >
			<cfthrow message="The Path attribute must be a Path object." />
		</cfif>	

		<cfset arguments.Path.closePath() />
	</cffunction>
	
	<!--- drawPath --->
	<cffunction name="drawPath" access="public" output="false" returntype="void" hint="I draw the current path into the image.">
		<cfargument name="Path" hint="I am the path to append the point to." required="yes" type="any" />
		<cfargument name="fillRule" hint="I am the rule to apply when filling this path.  Options are: evenOdd, or nonZero" required="no" type="string" default="evenOdd" />
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		<cfset var OldColor = Graphics.getColor() />
		
		<!--- verify the path --->
		<cfif NOT IsObject(arguments.Path) OR arguments.Path.getClass().getName() IS NOT "java.awt.geom.GeneralPath" >
			<cfthrow message="The Path attribute must be a Path object." />
		</cfif>
		
		<!--- verify the fill rule --->
		<cfif NOT ListFindNoCase("evenOdd,nonZero", arguments.fillRule)>
			<cfthrow message="Invalid fillRule attribute.  The fillRule attribute must be one of: evenOdd, or nonZero." />
		</cfif>
		
		<!--- apply the fill rule --->
		<cfif arguments.fillRule IS "evenOdd">
			<cfset arguments.Path.setWindingRule(arguments.Path.WIND_EVEN_ODD) />
		<cfelse>
			<cfset arguments.Path.setWindingRule(arguments.Path.WIND_NON_ZERO) />
		</cfif>
		
		<!--- apply any other graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- in the case that we get a fill , we want to first draw a filled object --->
		<cfif IsObject(getFill())>
			<cfset Graphics.setPaint(getFill()) />
			<cfset Graphics.fill(arguments.Path) />
		</cfif>
		
		<!--- in the case that we get a color setting, we want to set the color --->
		<cfif IsObject(getColor())>
			<!--- use the configured color --->
			<cfset Graphics.setColor(getColor()) />
		<cfelse>
			<!--- use the default color --->
			<cfset Graphics.setColor(OldColor) />
		</cfif>
		
		<!--- if we have a stroke, then draw the rectangle --->
		<cfif IsObject(getStroke())>
			<cfset Graphics.setStroke(getStroke()) />
		</cfif>	
		
		<!--- try to draw the Path --->
		<cftry>
			<cfset Graphics.draw(arguments.Path) />
			<cfcatch>
				<cfthrow message="Error drawing path.  Paths without points can not be drawn.  You must add at least one point to the path with the addPathPoint() method." />
			</cfcatch>
		</cftry>
		
		<!--- reset the graphics context --->
		<cfset Graphics.finalize() />
		<cfset Graphics.dispose() />
	</cffunction>
	
	<!--- drawPolygon --->
	<cffunction name="drawPolygon" access="public" output="false" returntype="void" hint="I draw the current polygon into the image.">
		<cfargument name="Polygon" hint="I am the polygon to append the point to." required="yes" type="any" />
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		<cfset var OldColor = Graphics.getColor() />
		
		<!--- verify the polygon --->
		<cfif NOT IsObject(arguments.Polygon) OR arguments.Polygon.getClass().getName() IS NOT "java.awt.Polygon" >
			<cfthrow message="The Polygon attribute must be a Polygon object." />
		</cfif>
		
		<!--- apply any other graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- in the case that we get a fill , we want to first draw a filled object --->
		<cfif IsObject(getFill())>
			<cfset Graphics.setPaint(getFill()) />
			<cfset Graphics.fillPolygon(arguments.Polygon) />
		</cfif>
		
		<!--- in the case that we get a color setting, we want to set the color --->
		<cfif IsObject(getColor())>
			<!--- use the configured color --->
			<cfset Graphics.setColor(getColor()) />
		<cfelse>
			<!--- use the default color --->
			<cfset Graphics.setColor(OldColor) />
		</cfif>
		
		<!--- if we have a stroke, then draw the rectangle --->
		<cfif IsObject(getStroke())>
			<cfset Graphics.setStroke(getStroke()) />
		</cfif>	
		
		<!--- try to draw the polygon --->
		<cftry>
			<cfset Graphics.drawPolygon(arguments.Polygon) />
			<cfcatch>
				<cfthrow message="Error drawing polygon.  Polygons without points can not be drawn.  You must add at least one point to the polygon with the addPolygonPoint() method." />
			</cfcatch>
		</cftry>
		
		<!--- reset the graphics context --->
		<cfset Graphics.finalize() />
		<cfset Graphics.dispose() />
	</cffunction>
	
	<!--- drawRectangle --->
	<cffunction name="drawRectangle" access="public" output="false" returntype="void" hint="I draw a rectangle on the image.">
		<cfargument name="x" hint="I am the x coordinate of the top left corner of the rectangle." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the y coordinate of the top left corner of the rectangle." required="yes" type="numeric" />
		<cfargument name="width" hint="I am the width of the rectangle" required="yes" type="numeric" />
		<cfargument name="height" hint="I am the height of the rectangle" required="yes" type="numeric" />
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		<cfset var OldColor = Graphics.getColor() />
		
		<!--- validate x, y, width and height --->
		<cfif arguments.X LT 0>
			<cfthrow message="Invalid x attribute.  The x attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.Y LT 0>
			<cfthrow message="Invalid y attribute.  The y attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attibute must be greater than 0." />
		</cfif>
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attibute must be greater than 0." />
		</cfif>
		
		<!--- apply any other graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- in the case that we get a fill , we want to first draw a filled object --->
		<cfif IsObject(getFill())>
			<cfset Graphics.setPaint(getFill()) />
			<cfset Graphics.fillRect(JavaCast("int", arguments.x), JavaCast("int", arguments.y), JavaCast("int", arguments.width), JavaCast("int", arguments.height)) />
		</cfif>
		
		<!--- in the case that we get a color setting, we want to set the color --->
		<cfif IsObject(getColor())>
			<!--- use the configured color --->
			<cfset Graphics.setColor(getColor()) />
		<cfelse>
			<!--- use the default color --->
			<cfset Graphics.setColor(OldColor) />
		</cfif>
		
		<!--- if we have a stroke, then draw the rectangle --->
		<cfif IsObject(getStroke())>
			<cfset Graphics.setStroke(getStroke()) />
		</cfif>	
		
		<cfset Graphics.drawRect(javaCast("int", arguments.x), javaCast("int", arguments.y), javaCast("int", arguments.width), javaCast("int", arguments.height)) />
		
		<!--- reset the graphics context --->
		<cfset Graphics.finalize() />
		<cfset Graphics.dispose() />
	</cffunction>
	
	<!--- drawRoundRectangle --->
	<cffunction name="drawRoundRectangle" access="public" output="false" returntype="void" hint="I draw a rounded rectangle on the image.">
		<cfargument name="x" hint="I am the x coordinate of the top left corner of the rectangle." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the y coordinate of the top left corner of the rectangle." required="yes" type="numeric" />
		<cfargument name="width" hint="I am the width of the rectangle" required="yes" type="numeric" />
		<cfargument name="height" hint="I am the height of the rectangle" required="yes" type="numeric" />
		<cfargument name="arcWidth" hint="I am the horizontal diameter of the corner arc." required="yes" type="numeric" />
		<cfargument name="arcHeight" hint="I am the vertical diameter of the corner arc." required="yes" type="numeric" />
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		<cfset var OldColor = Graphics.getColor() />
		
		<!--- validate x, y, width and height --->
		<cfif arguments.X LT 0>
			<cfthrow message="Invalid x attribute.  The x attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.Y LT 0>
			<cfthrow message="Invalid y attribute.  The y attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attibute must be greater than 0." />
		</cfif>
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attibute must be greater than 0." />
		</cfif>
		<cfif arguments.arcWidth LTE 0>
			<cfthrow message="Invalid arcWidth attribute.  The arcWidth attibute must be greater than 0." />
		</cfif>
		<cfif arguments.arcHeight LTE 0>
			<cfthrow message="Invalid arcHeight attribute.  The arcHeight attibute must be greater than 0." />
		</cfif>
		
		<!--- apply any other graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- in the case that we get a fill , we want to first draw a filled object --->
		<cfif IsObject(getFill())>
			<cfset Graphics.setPaint(getFill()) />
			<cfset Graphics.fillRoundRect(JavaCast("int", arguments.x), JavaCast("int", arguments.y), JavaCast("int", arguments.width), JavaCast("int", arguments.height), JavaCast("int", arguments.arcWidth), JavaCast("int", arguments.arcHeight)) />
		</cfif>
		
		<!--- in the case that we get a color setting, we want to set the color --->
		<cfif IsObject(getColor())>
			<!--- use the configured color --->
			<cfset Graphics.setColor(getColor()) />
		<cfelse>
			<!--- use the default color --->
			<cfset Graphics.setColor(OldColor) />
		</cfif>
		
		<!--- if we have a stroke, then draw the rectangle --->
		<cfif IsObject(getStroke())>
			<cfset Graphics.setStroke(getStroke()) />
		</cfif>
				
		<cfset Graphics.drawRoundRect(JavaCast("int", arguments.x), JavaCast("int", arguments.y), JavaCast("int", arguments.width), JavaCast("int", arguments.height), JavaCast("int", arguments.arcWidth), JavaCast("int", arguments.arcHeight)) />
		
		<!--- reset the graphics context --->
		<cfset Graphics.finalize() />
		<cfset Graphics.dispose() />
	</cffunction>
	
	<!--- getSystemFonts --->
	<cffunction name="getSystemFonts" access="public" output="false" returntype="array" hint="I return an array of all system fonts.">
		<cfset var GraphicsEnvironment = CreateObject("Java", "java.awt.GraphicsEnvironment") />
		<cfreturn GraphicsEnvironment.getLocalGraphicsEnvironment().getAvailableFontFamilyNames() />
	</cffunction>
	
	<!--- loadTTFFile --->
	<cffunction name="loadTTFFile" access="public" output="false" returntype="any" hint="I load and return the specified True Type Font file.">
		<cfargument name="ttfFilePath" hint="I am the path to a True Type Font file (.ttf)." required="yes" type="string" />
		<cfargument name="size" hint="I am the size of the font." required="yes" type="numeric" />
		<cfargument name="style" hint="I am the style of the font.  Options: plain, bold, italic, boldItalic." required="no" type="string" default="plain" />
		<cfset var Font = CreateObject("Java", "java.awt.Font") />
		<cfset var InputStream = CreateObject("Java", "java.io.FileInputStream") />
		<cfset var StyledFont = 0 />
		
		<!--- validate the style argument --->
		<cfif NOT ListFindNoCase("plain,bold,italic,boldItalic", arguments.style)>
			<cfthrow message="Invalid style attribute.  The style attribute must be one of: plain, bold, italic, boldItalic.">
		</cfif>
		
		<cfset InputStream.init(arguments.ttfFilePath) />
		<cfset Font = Font.createFont(Font.TRUETYPE_FONT, InputStream) />
		
		<cfswitch expression="#arguments.style#">
			<cfcase value="plain">
				<cfset StyledFont = Font.deriveFont(Font.PLAIN, JavaCast("float", arguments.size)) />
			</cfcase>
			<cfcase value="bold">
				<cfset StyledFont = Font.deriveFont(Font.BOLD, JavaCast("float", arguments.size)) />
			</cfcase>
			<cfcase value="italic">
				<cfset StyledFont = Font.deriveFont(Font.ITALIC, JavaCast("float", arguments.size)) />
			</cfcase>
			<cfcase value="boldItalic">
				<!--- 3 == bold + italic --->
				<cfset StyledFont = Font.deriveFont(3, JavaCast("float", arguments.size)) />
			</cfcase>
		</cfswitch>
				
		<cfreturn StyledFont />
	</cffunction>
	
	<!--- loadSystemFont --->
	<cffunction name="loadSystemFont"  access="public" output="false" returntype="any" hint="I load and return the specified system fonts.">
		<cfargument name="systemFontName" hint="I am the name of a system font as returned by getSystemFonts()" required="yes" type="string" />
		<cfargument name="size" hint="I am the size of the font." required="yes" type="numeric" />
		<cfargument name="style" hint="I am the style of the font.  Options: plain, bold, italic, boldItalic." required="no" type="string" default="plain" />
		<cfset var Font = CreateObject("Java","java.awt.Font") />
		
		<cfreturn Font.decode("#arguments.systemFontName#-#ucase(arguments.style)#-#arguments.size#") />
	</cffunction>
	
	<!--- getStringMetrics --->
	<cffunction name="getStringMetrics" access="public" output="false" returntype="struct" hint="I return a structure of font metrics for the advanced string.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to get the metrics of." required="yes" type="any" />
		<cfset var Image = CreateObject("Java", "java.awt.image.BufferedImage") />
		<cfset var Graphics = 0 />
		<cfset var TextLayout = CreateObject("Java", "java.awt.font.TextLayout") />
		<cfset var Iterator = 0 />
		<cfset var Bounds = 0 />
		<cfset var metrics = StructNew() />
		
		<!--- validate the advancedString --->
		<cfif NOT IsObject(arguments.advancedString) OR arguments.advancedString.getClass().getName() IS NOT "java.text.AttributedString" >
			<cfthrow message="The advancedString attribute must be an Advanced String Object." />
		</cfif>
		
		<!---
			init the "holder" image
			-- we don't want to have created an image just to get the size of text
			-- what if we wanted to create an image based on the size of some text?
		--->
		<cfset Image.init(JavaCast("int", 1), JavaCast("int", 1), JavaCast("int", Image.TYPE_INT_ARGB)) />
		<cfset Graphics = Image.getGraphics() />
				
		<!--- apply standard graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- get the itterator --->
		<cfset Iterator = arguments.AdvancedString.getIterator() />
		
		<!--- create a new textlayout to get the metrics of the string --->
		<cfset TextLayout.init(Iterator, Graphics.getFontRenderContext()) />
		
		<!--- get the font metrics --->
		<cfset Bounds = TextLayout.getBounds() />
		<cfset metrics.height = ceiling(Bounds.getHeight()) />
		<cfset metrics.width = ceiling(Bounds.getWidth()) />
		<cfset metrics.ascent = ceiling(TextLayout.getAscent()) />
		<cfset metrics.descent = ceiling(TextLayout.getDescent()) />
		<cfset metrics.leading = ceiling(TextLayout.getLeading()) />
		
		<cfreturn metrics />
	</cffunction>
	
	<!--- getSimpleStringMetrics --->
	<cffunction name="getSimpleStringMetrics" access="public" output="false" returntype="struct" hint="I return a structure of font metrics for a simple string.">
		<cfargument name="string" hint="I am the string to get the metrics of." required="yes" type="string" />
		<cfargument name="Font" hint="I am the font to use." required="no" type="any" default="" />
		<cfset var Image = CreateObject("Java", "java.awt.image.BufferedImage") />
		<cfset var Graphics = 0 />
		<cfset var FontMetrics = 0 />
		<cfset var LineMetrics = 0 />
		<cfset var Bounds = 0 />
		<cfset var metrics = StructNew() />
		
		<!--- validate the font argument --->
		<cftry>
			<cfif (IsObject(arguments.Font) AND arguments.Font.getClass().getName() IS NOT "java.awt.Font") OR (NOT IsObject(arguments.Font) AND Len(arguments.Font))>
				<cfthrow message="Invalid Font attribute.  The Font attibute must be a Font object.  These can be loaded with loadSystemFont() or loadTTFFile()." />
			</cfif>
			<cfcatch>
				<cfthrow message="Invalid Font attribute.  The Font attibute must be a Font object.  These can be loaded with loadSystemFont() or loadTTFFile()." />
			</cfcatch>
		</cftry>
		
		<!---
			init the "holder" image
			-- we don't want to have created an image just to get the size of text
			-- what if we wanted to create an image based on the size of some text?
		--->
		<cfset Image.init(JavaCast("int", 1), JavaCast("int", 1), JavaCast("int", Image.TYPE_INT_ARGB)) />
		<cfset Graphics = Image.getGraphics() />
		
		<!--- validate font --->
		<cfif IsObject(arguments.Font)>
			<cfset Graphics.setFont(arguments.Font) />
		</cfif>
		
		<!--- apply any other graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- load the font metrics --->
		<cfset FontMetrics = Graphics.getFontMetrics() />
		
		<!--- get the font metrics, etc --->
		<cfset Bounds = FontMetrics.getStringBounds(arguments.string, Graphics) />
		<cfset LineMetrics = FontMetrics.getLineMetrics(arguments.string, Graphics) />
		<cfset metrics.height = ceiling(bounds.getHeight()) />
		<cfset metrics.width = ceiling(bounds.getWidth()) />
		<cftry>
			<!--- in BD 6.2 this causes a server error --->
			<cfset metrics.ascent = ceiling(LineMetrics.getAscent()) />
			<cfset metrics.descent = ceiling(LineMetrics.getDescent()) />
			<cfset metrics.leading = ceiling(LineMetrics.getLeading()) />
			<cfcatch></cfcatch>
		</cftry>		
		<cfreturn metrics />
	</cffunction>
	
	<!--- drawSimpleString --->
	<cffunction name="drawSimpleString" access="public" output="false" returntype="void" hint="I am a simple method to draw a string on the image.">
		<cfargument name="string" hint="I am the string to write onto the image." required="yes" type="string" />
		<cfargument name="x" hint="I am the x coordinate of the top left corner of the rectangle." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the y coordinate of the top left corner of the rectangle." required="yes" type="numeric" />
		<cfargument name="Font" hint="I am the font to use." required="no" type="any" default="" />
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		
		<!--- validate x, y, width and height --->
		<!--- 07/09/2004 - I commented this out because I found a neet to start drawing text outside the image area --->
		<!--- <cfif arguments.X LT 0>
			<cfthrow message="Invalid x attribute.  The x attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.Y LT 0>
			<cfthrow message="Invalid y attribute.  The y attibute must be greater than or equal to 0." />
		</cfif> --->
		<cftry>
			<cfif (IsObject(arguments.Font) AND arguments.Font.getClass().getName() IS NOT "java.awt.Font") OR (NOT IsObject(arguments.Font) AND Len(arguments.Font))>
				<cfthrow message="Invalid Font attribute.  The Font attibute must be a Font object.  These can be loaded with loadSystemFont() or loadTTFFile()." />
			</cfif>
			<cfcatch>
				<cfthrow message="Invalid Font attribute.  The Font attibute must be a Font object.  These can be loaded with loadSystemFont() or loadTTFFile()." />
			</cfcatch>
		</cftry>
				
		<cfif IsObject(arguments.Font)>
			<cfset Graphics.setFont(Font) />			
		</cfif>
		
		<!--- apply any other graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- in the case that we get a fill , we want to first draw a filled object --->
		<cfif IsObject(getFill())>
			<cfset Graphics.setPaint(getFill()) />
		</cfif>

		<cfset Graphics.drawString(arguments.string, javaCast("int", arguments.x), javaCast("int", arguments.y)) />	
	</cffunction>
	
	<!--- drawString --->
	<cffunction name="drawString" access="public" output="false" returntype="void" hint="I draw the advanced string onto the image.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to draw." required="yes" type="any" />
		<cfargument name="x" hint="I am the x coordinate of the string baseline." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the y coordinate of the string baseline." required="yes" type="numeric" />
		<cfset var Iterator = 0 />
		<cfset var Graphics = Image.getGraphics() />

		<!--- validate the advancedString --->
		<cfif NOT IsObject(arguments.advancedString) OR arguments.advancedString.getClass().getName() IS NOT "java.text.AttributedString" >
			<cfthrow message="The advancedString attribute must be an Advanced String Object." />
		</cfif>
		<!--- validate x, y, width and height --->
		<!--- <cfif arguments.X LT 0>
			<cfthrow message="Invalid x attribute.  The x attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.Y LT 0>
			<cfthrow message="Invalid y attribute.  The y attibute must be greater than or equal to 0." />
		</cfif> --->
		
		<!--- apply standard graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- try to get the itterator --->
		<cftry>
			<cfset Iterator = arguments.AdvancedString.getIterator() />
			<cfcatch>
				<cfthrow message="Can not use drawString() before calling createString()." />
			</cfcatch>
		</cftry>
		
		<!--- output the string --->
		<cfset Graphics.drawString(Iterator, javaCast("float", arguments.x), javaCast("float", arguments.y)) />
	</cffunction>
	
	<!--- drawImage --->
	<cffunction name="drawImage" access="public" output="false" returntype="void" hint="I draw an image into the current image.">
		<cfargument name="path" hint="I am the path of the image file to draw into this image." required="yes" type="string">
		<cfargument name="x" hint="I am the x coordinate of the top left corner of the image to draw." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the y coordinate of the top left corner of the image to draw." required="yes" type="numeric" />
		<cfargument name="width" hint="I am the width of the image to draw." required="no" type="numeric" default="-1" />
		<cfargument name="height" hint="I am the height of the image to draw." required="no" type="numeric" default="-1" />
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		<cfset var InputStream = CreateObject("Java", "java.io.FileInputStream") />
		<cfset var Image2 = CreateObject("java", "java.awt.image.BufferedImage") />
		<cfset var Operation = CreateObject("Java", "java.awt.image.AffineTransformOp") />
		<cfset var Transform = CreateObject("Java", "java.awt.geom.AffineTransform") />
		
		<!--- validate x, y, width and height --->
		<!--- <cfif arguments.X LT 0>
			<cfthrow message="Invalid x attribute.  The x attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.Y LT 0>
			<cfthrow message="Invalid y attribute.  The y attibute must be greater than or equal to 0." />
		</cfif> --->
		<cfif arguments.width IS NOT -1 AND arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attibute must be greater than 0." />
		</cfif>
		<cfif arguments.height IS NOT -1 AND arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attibute must be greater than 0." />
		</cfif>
		
		<!--- read the image --->
		<cftry>
			<cfset InputStream.init(arguments.path) />
			<cfset Image2 = getImageIO().read(InputStream) />
			
			<cfif arguments.width IS -1>
				<cfset arguments.width = Image2.getWidth() />
			</cfif>
			<cfif arguments.height IS -1>
				<cfset arguments.height = Image2.getHeight() />
			</cfif>
			
			<cfcatch>
				<cfthrow message="There was an unknown error reading image from #arguments.path#. This is possibly an invalid path or an unsupported file format." />
			</cfcatch>		
		</cftry>
		
		<!--- convert the pixel widths request to percents --->
		<cfset arguments.width = arguments.width / Image2.getWidth() />
		<cfset arguments.height = arguments.height / Image2.getHeight() />
		
		<!--- apply any other graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- transform and draw the image --->
		<cfscript>
			Transform.scale(arguments.width, arguments.height);
			Operation.init(Transform, Operation.TYPE_BILINEAR);
			Graphics.drawImage(Image2, Operation, JavaCast("int", arguments.x), JavaCast("int", arguments.y));
		</cfscript>
		
		<cfset setImage(Image) />
		
		<!--- reset the graphics context --->
		<cfset Graphics.finalize() />
		<cfset Graphics.dispose() />
	</cffunction>
	
	<!--- drawOval --->
	<cffunction name="drawOval" access="public" output="false" returntype="void" hint="I draw an oval on the image.">
		<cfargument name="x" hint="I am the x coordinate of the top left corner of the rectangle." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the y coordinate of the top left corner of the rectangle." required="yes" type="numeric" />
		<cfargument name="width" hint="I am the width of the rectangle" required="yes" type="numeric" />
		<cfargument name="height" hint="I am the height of the rectangle" required="yes" type="numeric" />
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		<cfset var OldColor = Graphics.getColor() />
		
		<!--- validate x, y, width and height --->
		<cfif arguments.X LT 0>
			<cfthrow message="Invalid x attribute.  The x attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.Y LT 0>
			<cfthrow message="Invalid y attribute.  The y attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attibute must be greater than 0." />
		</cfif>
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attibute must be greater than 0." />
		</cfif>
		
		<!--- apply any other graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- in the case that we get a fill , we want to first draw a filled object --->
		<cfif IsObject(getFill())>
			<cfset Graphics.setPaint(getFill()) />
			<cfset Graphics.fillOval(JavaCast("int", arguments.x), JavaCast("int", arguments.y), JavaCast("int", arguments.width), JavaCast("int", arguments.height)) />
		</cfif>
		
		<!--- if we have a stroke, then draw the rectangle --->
		<cfif IsObject(getStroke())>
			<!--- in the case that we get a color setting, we want to set the color --->
			<cfif IsObject(getColor())>
				<!--- use the configured color --->
				<cfset Graphics.setColor(getColor()) />
			<cfelse>
				<!--- use the default color --->
				<cfset Graphics.setColor(OldColor) />
			</cfif>
			
			<cfif IsObject(getStroke())>
				<cfset Graphics.setStroke(getStroke()) />
			</cfif>
		</cfif>
		
		<cfset Graphics.drawOval(JavaCast("int", arguments.x), JavaCast("int", arguments.y), JavaCast("int", arguments.width), JavaCast("int", arguments.height)) />
		
		<!--- reset the graphics context --->
		<cfset Graphics.finalize() />
		<cfset Graphics.dispose() />
	</cffunction>
	
	<!--- drawArc --->
	<cffunction name="drawArc" access="public" output="false" returntype="void" hint="I draw an oval on the image.">
		<cfargument name="x" hint="I am the x coordinate of the top left corner of the rectangle." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the y coordinate of the top left corner of the rectangle." required="yes" type="numeric" />
		<cfargument name="width" hint="I am the width of the rectangle" required="yes" type="numeric" />
		<cfargument name="height" hint="I am the height of the rectangle" required="yes" type="numeric" />
		<cfargument name="startAngle" hint="I am the angle at which to begin the arc." required="yes" type="numeric" />
		<cfargument name="endAngle" hint="I am the angle at which to end the arc." required="yes" type="numeric" />
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		<cfset var OldColor = Graphics.getColor() />
		
		<!--- validate x, y, width and height --->
		<cfif arguments.X LTE 0>
			<cfthrow message="Invalid x attribute.  The x attibute must be greater than 0." />
		</cfif>
		<cfif arguments.Y LTE 0>
			<cfthrow message="Invalid y attribute.  The y attibute must be greater than 0." />
		</cfif>
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attibute must be greater than 0." />
		</cfif>
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attibute must be greater than 0." />
		</cfif>
		<cfif arguments.startAngle LT 0>
			<cfthrow message="Invalid startAngle attribute.  The startAngle attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.endAngle LT 0>
			<cfthrow message="Invalid endAngle attribute.  The endAngle attibute must be greater than or equal to 0." />
		</cfif>
		
		<!--- apply any other graphic settings --->
		<cfset applyGrapicsSettings(Graphics) />
		
		<!--- in the case that we get a fill , we want to first draw a filled object --->
		<cfif IsObject(getFill())>
			<cfset Graphics.setPaint(getFill()) />
			<cfset Graphics.fillArc(JavaCast("int", arguments.x), JavaCast("int", arguments.y), JavaCast("int", arguments.width), JavaCast("int", arguments.height), JavaCast("int", arguments.startAngle), JavaCast("int", arguments.endAngle)) />
		</cfif>
		
		<!--- in the case that we get a color setting, we want to set the color --->
		<cfif IsObject(getColor())>
			<!--- use the configured color --->
			<cfset Graphics.setColor(getColor()) />
		<cfelse>
			<!--- use the default color --->
			<cfset Graphics.setColor(OldColor) />
		</cfif>
		
		<cfif IsObject(getStroke())>
			<cfset Graphics.setStroke(getStroke()) />
		</cfif>
		
		<cfset Graphics.drawArc(JavaCast("int", arguments.x), JavaCast("int", arguments.y), JavaCast("int", arguments.width), JavaCast("int", arguments.height), JavaCast("int", arguments.startAngle), JavaCast("int", arguments.endAngle)) />
		
		<!--- reset the graphics context --->
		<cfset Graphics.finalize() />
		<cfset Graphics.dispose() />
	</cffunction>
		
	<!--- getColorByName --->
	<cffunction name="getColorByName" access="public" output="false" returntype="any" hint="I get a color object by name for use when drawing lines and shapes.">
		<cfargument name="name" hint="I am the name of the color to get.  For all possible options call getColorList()." required="yes" type="string" />
		<cfset var Color = CreateObject("Java", "java.awt.Color") />
		
		<!--- validate the name attribute --->
		<cfswitch expression="#arguments.name#">
			<cfcase value="AliceBlue">
			  <cfset Color.init(15792383) />
			</cfcase>
			<cfcase value="AntiqueWhite">
			  <cfset Color.init(16444375) />
			</cfcase>
			<cfcase value="Aqua">
			  <cfset Color.init(65535) />
			</cfcase>
			<cfcase value="Aquamarine">
			  <cfset Color.init(8388564) />
			</cfcase>
			<cfcase value="Azure">
			  <cfset Color.init(15794175) />
			</cfcase>
			<cfcase value="Beige">
			  <cfset Color.init(16119260) />
			</cfcase>
			<cfcase value="Bisque">
			  <cfset Color.init(16770244) />
			</cfcase>
			<cfcase value="Black">
			  <cfset Color.init(0) />
			</cfcase>
			<cfcase value="BlanchedAlmond">
			  <cfset Color.init(16772045) />
			</cfcase>
			<cfcase value="Blue">
			  <cfset Color.init(255) />
			</cfcase>
			<cfcase value="BlueViolet">
			  <cfset Color.init(9055202) />
			</cfcase>
			<cfcase value="Brown">
			  <cfset Color.init(10824234) />
			</cfcase>
			<cfcase value="BurlyWood">
			  <cfset Color.init(14596231) />
			</cfcase>
			<cfcase value="CadetBlue">
			  <cfset Color.init(6266528) />
			</cfcase>
			<cfcase value="Chartreuse">
			  <cfset Color.init(8388352) />
			</cfcase>
			<cfcase value="Chocolate">
			  <cfset Color.init(13789470) />
			</cfcase>
			<cfcase value="Coral">
			  <cfset Color.init(16744272) />
			</cfcase>
			<cfcase value="CornflowerBlue">
			  <cfset Color.init(6591981) />
			</cfcase>
			<cfcase value="Cornsilk">
			  <cfset Color.init(16775388) />
			</cfcase>
			<cfcase value="Crimson">
			  <cfset Color.init(14423100) />
			</cfcase>
			<cfcase value="Cyan">
			  <cfset Color.init(65535) />
			</cfcase>
			<cfcase value="DarkBlue">
			  <cfset Color.init(139) />
			</cfcase>
			<cfcase value="DarkCyan">
			  <cfset Color.init(35723) />
			</cfcase>
			<cfcase value="DarkGoldenRod">
			  <cfset Color.init(12092939) />
			</cfcase>
			<cfcase value="DarkGray">
			  <cfset Color.init(11119017) />
			</cfcase>
			<cfcase value="DarkGreen">
			  <cfset Color.init(25600) />
			</cfcase>
			<cfcase value="DarkKhaki">
			  <cfset Color.init(12433259) />
			</cfcase>
			<cfcase value="DarkMagenta">
			  <cfset Color.init(9109643) />
			</cfcase>
			<cfcase value="DarkOliveGreen">
			  <cfset Color.init(5597999) />
			</cfcase>
			<cfcase value="Darkorange">
			  <cfset Color.init(16747520) />
			</cfcase>
			<cfcase value="DarkOrchid">
			  <cfset Color.init(10040012) />
			</cfcase>
			<cfcase value="DarkRed">
			  <cfset Color.init(9109504) />
			</cfcase>
			<cfcase value="DarkSalmon">
			  <cfset Color.init(15308410) />
			</cfcase>
			<cfcase value="DarkSeaGreen">
			  <cfset Color.init(9419919) />
			</cfcase>
			<cfcase value="DarkSlateBlue">
			  <cfset Color.init(4734347) />
			</cfcase>
			<cfcase value="DarkSlateGray">
			  <cfset Color.init(3100495) />
			</cfcase>
			<cfcase value="DarkTurquoise">
			  <cfset Color.init(52945) />
			</cfcase>
			<cfcase value="DarkViolet">
			  <cfset Color.init(9699539) />
			</cfcase>
			<cfcase value="DeepPink">
			  <cfset Color.init(16716947) />
			</cfcase>
			<cfcase value="DeepSkyBlue">
			  <cfset Color.init(49151) />
			</cfcase>
			<cfcase value="DimGray">
			  <cfset Color.init(6908265) />
			</cfcase>
			<cfcase value="DodgerBlue">
			  <cfset Color.init(2003199) />
			</cfcase>
			<cfcase value="Feldspar">
			  <cfset Color.init(13734517) />
			</cfcase>
			<cfcase value="FireBrick">
			  <cfset Color.init(11674146) />
			</cfcase>
			<cfcase value="FloralWhite">
			  <cfset Color.init(16775920) />
			</cfcase>
			<cfcase value="ForestGreen">
			  <cfset Color.init(2263842) />
			</cfcase>
			<cfcase value="Fuchsia">
			  <cfset Color.init(16711935) />
			</cfcase>
			<cfcase value="Gainsboro">
			  <cfset Color.init(14474460) />
			</cfcase>
			<cfcase value="GhostWhite">
			  <cfset Color.init(16316671) />
			</cfcase>
			<cfcase value="Gold">
			  <cfset Color.init(16766720) />
			</cfcase>
			<cfcase value="GoldenRod">
			  <cfset Color.init(14329120) />
			</cfcase>
			<cfcase value="Gray">
			  <cfset Color.init(8421504) />
			</cfcase>
			<cfcase value="Green">
			  <cfset Color.init(32768) />
			</cfcase>
			<cfcase value="GreenYellow">
			  <cfset Color.init(11403055) />
			</cfcase>
			<cfcase value="HoneyDew">
			  <cfset Color.init(15794160) />
			</cfcase>
			<cfcase value="HotPink">
			  <cfset Color.init(16738740) />
			</cfcase>
			<cfcase value="IndianRed">
			  <cfset Color.init(13458524) />
			</cfcase>
			<cfcase value="Indigo">
			  <cfset Color.init(4915330) />
			</cfcase>
			<cfcase value="Ivory">
			  <cfset Color.init(16777200) />
			</cfcase>
			<cfcase value="Khaki">
			  <cfset Color.init(15787660) />
			</cfcase>
			<cfcase value="Lavender">
			  <cfset Color.init(15132410) />
			</cfcase>
			<cfcase value="LavenderBlush">
			  <cfset Color.init(16773365) />
			</cfcase>
			<cfcase value="LawnGreen">
			  <cfset Color.init(8190976) />
			</cfcase>
			<cfcase value="LemonChiffon">
			  <cfset Color.init(16775885) />
			</cfcase>
			<cfcase value="LightBlue">
			  <cfset Color.init(11393254) />
			</cfcase>
			<cfcase value="LightCoral">
			  <cfset Color.init(15761536) />
			</cfcase>
			<cfcase value="LightCyan">
			  <cfset Color.init(14745599) />
			</cfcase>
			<cfcase value="LightGoldenRodYellow">
			  <cfset Color.init(16448210) />
			</cfcase>
			<cfcase value="LightGray">
			  <cfset Color.init(13882323) />
			</cfcase>
			<cfcase value="LightGreen">
			  <cfset Color.init(9498256) />
			</cfcase>
			<cfcase value="LightPink">
			  <cfset Color.init(16758465) />
			</cfcase>
			<cfcase value="LightSalmon">
			  <cfset Color.init(16752762) />
			</cfcase>
			<cfcase value="LightSeaGreen">
			  <cfset Color.init(2142890) />
			</cfcase>
			<cfcase value="LightSkyBlue">
			  <cfset Color.init(8900346) />
			</cfcase>
			<cfcase value="LightSlateBlue">
			  <cfset Color.init(8679679) />
			</cfcase>
			<cfcase value="LightSlateGray">
			  <cfset Color.init(7833753) />
			</cfcase>
			<cfcase value="LightSteelBlue">
			  <cfset Color.init(11584734) />
			</cfcase>
			<cfcase value="LightYellow">
			  <cfset Color.init(16777184) />
			</cfcase>
			<cfcase value="Lime">
			  <cfset Color.init(65280) />
			</cfcase>
			<cfcase value="LimeGreen">
			  <cfset Color.init(3329330) />
			</cfcase>
			<cfcase value="Linen">
			  <cfset Color.init(16445670) />
			</cfcase>
			<cfcase value="Magenta">
			  <cfset Color.init(16711935) />
			</cfcase>
			<cfcase value="Maroon">
			  <cfset Color.init(8388608) />
			</cfcase>
			<cfcase value="MediumAquaMarine">
			  <cfset Color.init(6737322) />
			</cfcase>
			<cfcase value="MediumBlue">
			  <cfset Color.init(205) />
			</cfcase>
			<cfcase value="MediumOrchid">
			  <cfset Color.init(12211667) />
			</cfcase>
			<cfcase value="MediumPurple">
			  <cfset Color.init(9662680) />
			</cfcase>
			<cfcase value="MediumSeaGreen">
			  <cfset Color.init(3978097) />
			</cfcase>
			<cfcase value="MediumSlateBlue">
			  <cfset Color.init(8087790) />
			</cfcase>
			<cfcase value="MediumSpringGreen">
			  <cfset Color.init(64154) />
			</cfcase>
			<cfcase value="MediumTurquoise">
			  <cfset Color.init(4772300) />
			</cfcase>
			<cfcase value="MediumVioletRed">
			  <cfset Color.init(13047173) />
			</cfcase>
			<cfcase value="MidnightBlue">
			  <cfset Color.init(1644912) />
			</cfcase>
			<cfcase value="MintCream">
			  <cfset Color.init(16121850) />
			</cfcase>
			<cfcase value="MistyRose">
			  <cfset Color.init(16770273) />
			</cfcase>
			<cfcase value="Moccasin">
			  <cfset Color.init(16770229) />
			</cfcase>
			<cfcase value="NavajoWhite">
			  <cfset Color.init(16768685) />
			</cfcase>
			<cfcase value="Navy">
			  <cfset Color.init(128) />
			</cfcase>
			<cfcase value="OldLace">
			  <cfset Color.init(16643558) />
			</cfcase>
			<cfcase value="Olive">
			  <cfset Color.init(8421376) />
			</cfcase>
			<cfcase value="OliveDrab">
			  <cfset Color.init(7048739) />
			</cfcase>
			<cfcase value="Orange">
			  <cfset Color.init(16753920) />
			</cfcase>
			<cfcase value="OrangeRed">
			  <cfset Color.init(16729344) />
			</cfcase>
			<cfcase value="Orchid">
			  <cfset Color.init(14315734) />
			</cfcase>
			<cfcase value="PaleGoldenRod">
			  <cfset Color.init(15657130) />
			</cfcase>
			<cfcase value="PaleGreen">
			  <cfset Color.init(10025880) />
			</cfcase>
			<cfcase value="PaleTurquoise">
			  <cfset Color.init(11529966) />
			</cfcase>
			<cfcase value="PaleVioletRed">
			  <cfset Color.init(14184595) />
			</cfcase>
			<cfcase value="PapayaWhip">
			  <cfset Color.init(16773077) />
			</cfcase>
			<cfcase value="PeachPuff">
			  <cfset Color.init(16767673) />
			</cfcase>
			<cfcase value="Peru">
			  <cfset Color.init(13468991) />
			</cfcase>
			<cfcase value="Pink">
			  <cfset Color.init(16761035) />
			</cfcase>
			<cfcase value="Plum">
			  <cfset Color.init(14524637) />
			</cfcase>
			<cfcase value="PowderBlue">
			  <cfset Color.init(11591910) />
			</cfcase>
			<cfcase value="Purple">
			  <cfset Color.init(8388736) />
			</cfcase>
			<cfcase value="Red">
			  <cfset Color.init(16711680) />
			</cfcase>
			<cfcase value="RosyBrown">
			  <cfset Color.init(12357519) />
			</cfcase>
			<cfcase value="RoyalBlue">
			  <cfset Color.init(267920) />
			</cfcase>
			<cfcase value="SaddleBrown">
			  <cfset Color.init(9127187) />
			</cfcase>
			<cfcase value="Salmon">
			  <cfset Color.init(16416882) />
			</cfcase>
			<cfcase value="SandyBrown">
			  <cfset Color.init(16032864) />
			</cfcase>
			<cfcase value="SeaGreen">
			  <cfset Color.init(3050327) />
			</cfcase>
			<cfcase value="SeaShell">
			  <cfset Color.init(16774638) />
			</cfcase>
			<cfcase value="Sienna">
			  <cfset Color.init(10506797) />
			</cfcase>
			<cfcase value="Silver">
			  <cfset Color.init(12632256) />
			</cfcase>
			<cfcase value="SkyBlue">
			  <cfset Color.init(8900331) />
			</cfcase>
			<cfcase value="SlateBlue">
			  <cfset Color.init(6970061) />
			</cfcase>
			<cfcase value="SlateGray">
			  <cfset Color.init(7372944) />
			</cfcase>
			<cfcase value="Snow">
			  <cfset Color.init(16775930) />
			</cfcase>
			<cfcase value="SpringGreen">
			  <cfset Color.init(65407) />
			</cfcase>
			<cfcase value="SteelBlue">
			  <cfset Color.init(4620980) />
			</cfcase>
			<cfcase value="Tan">
			  <cfset Color.init(13808780) />
			</cfcase>
			<cfcase value="Teal">
			  <cfset Color.init(32896) />
			</cfcase>
			<cfcase value="Thistle">
			  <cfset Color.init(14204888) />
			</cfcase>
			<cfcase value="Tomato">
			  <cfset Color.init(16737095) />
			</cfcase>
			<cfcase value="Turquoise">
			  <cfset Color.init(4251856) />
			</cfcase>
			<cfcase value="Violet">
			  <cfset Color.init(15631086) />
			</cfcase>
			<cfcase value="VioletRed">
			  <cfset Color.init(13639824) />
			</cfcase>
			<cfcase value="Wheat">
			  <cfset Color.init(16113331) />
			</cfcase>
			<cfcase value="White">
			  <cfset Color.init(16777215) />
			</cfcase>
			<cfcase value="WhiteSmoke">
			  <cfset Color.init(16119285) />
			</cfcase>
			<cfcase value="Yellow">
			  <cfset Color.init(16776960) />
			</cfcase>
			<cfcase value="YellowGreen">
			  <cfset Color.init(10145074) />
			</cfcase>
			<cfdefaultcase>
				<cfthrow message="Invalid color attribute.  Color attribute must be a valid color.  To get a list of valid colors please run getColorList()." />
			</cfdefaultcase>
		</cfswitch>
		
		<cfreturn Color />		
	</cffunction>
	
	<!--- getColorList --->
	<cffunction name="getColorList" access="public" output="false" returntype="string" hint="I return a list of predefined colors supported.">
		<cfreturn "AliceBlue,AntiqueWhite,Aqua,Aquamarine,Azure,Beige,Bisque,Black,BlanchedAlmond,Blue,BlueViolet,Brown,BurlyWood,CadetBlue,Chartreuse,Chocolate,Coral,CornflowerBlue,Cornsilk,Crimson,Cyan,DarkBlue,DarkCyan,DarkGoldenRod,DarkGray,DarkGreen,DarkKhaki,DarkMagenta,DarkOliveGreen,Darkorange,DarkOrchid,DarkRed,DarkSalmon,DarkSeaGreen,DarkSlateBlue,DarkSlateGray,DarkTurquoise,DarkViolet,DeepPink,DeepSkyBlue,DimGray,DodgerBlue,Feldspar,FireBrick,FloralWhite,ForestGreen,Fuchsia,Gainsboro,GhostWhite,Gold,GoldenRod,Gray,Green,GreenYellow,HoneyDew,HotPink,IndianRed,Indigo,Ivory,Khaki,Lavender,LavenderBlush,LawnGreen,LemonChiffon,LightBlue,LightCoral,LightCyan,LightGoldenRodYellow,LightGray,LightGreen,LightPink,LightSalmon,LightSeaGreen,LightSkyBlue,LightSlateBlue,LightSlateGray,LightSteelBlue,LightYellow,Lime,LimeGreen,Linen,Magenta,Maroon,MediumAquaMarine,MediumBlue,MediumOrchid,MediumPurple,MediumSeaGreen,MediumSlateBlue,MediumSpringGreen,MediumTurquoise,MediumVioletRed,MidnightBlue,MintCream,MistyRose,Moccasin,NavajoWhite,Navy,OldLace,Olive,OliveDrab,Orange,OrangeRed,Orchid,PaleGoldenRod,PaleGreen,PaleTurquoise,PaleVioletRed,PapayaWhip,PeachPuff,Peru,Pink,Plum,PowderBlue,Purple,Red,RosyBrown,RoyalBlue,SaddleBrown,Salmon,SandyBrown,SeaGreen,SeaShell,Sienna,Silver,SkyBlue,SlateBlue,SlateGray,Snow,SpringGreen,SteelBlue,Tan,Teal,Thistle,Tomato,Turquoise,Violet,VioletRed,Wheat,White,WhiteSmoke,Yellow,YellowGreen"/>
	</cffunction>
	
	<!--- getColorFromPixel --->
	<cffunction name="getColorFromPixel" access="public" output="false" returntype="string" hint="I get the color of a specific pixel and return a color.">
		<cfargument name="x" hint="I am the X coordinate." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the Y coordinate." required="yes" type="numeric" />
		<cfset var Image = getImage() />
		<cfset var Color = CreateObject("Java", "java.awt.Color") />
		
		<cfif arguments.x LT 0 OR arguments.x GTE getWidth()>
			<cfthrow message="Invalid x attribute.  The x attribute must be greater than or equal to 0 and less than the image width." />
		</cfif>
		<cfif arguments.y LT 0 OR arguments.x GTE getHeight()>
			<cfthrow message="Invalid y attribute.  The y attribute must be greater than or equal to 0 and less than the image height." />
		</cfif>
		
		<cfreturn Color.init(Image.getRGB(JavaCast("int", arguments.x), JavaCast("int", arguments.y))) />
	</cffunction>
	
	<!--- trimEdges --->
	<cffunction name="trimEdges" access="public" output="false" returntype="void" hint="I trim pixels of the same color from the edges of an image.">
		<cfargument name="startingPixel" hint="I am the pixel to base the trim on.  Options are: topLeft, topRight, bottomLeft, bottomRight." required="no" type="string" default="topLeft" />
		<cfargument name="trimLeft" hint="I indicate if the left side of the image should be trimmed." required="no" type="boolean" default="true" />
		<cfargument name="trimTop" hint="I indicate if the top of the image should be trimmed." required="no" type="boolean" default="true" />
		<cfargument name="trimRight" hint="I indicate if the right side of the image should be trimmed." required="no" type="boolean" default="true" />
		<cfargument name="trimBottom" hint="I indicate if the bottom of the image should be trimmed." required="no" type="boolean" default="true" />
		<cfset var Image = getImage() />
		<cfset var RGB = 0 />
		<cfset var edge = "top" />
		<cfset var x = 0 />
		<cfset var y = 0 />
		<cfset var breakLoop = false />
		<cfset var triming = StructNew() />
		
		<cfif NOT ListFindNoCase("topLeft,topRight,bottomLeft,bottomRight", arguments.startingPixel)>
			<cfthrow message="Invalid startingPixel attribute.  The startingPixel attribute must be one of: topLeft, topRight, bottomLeft, bottomRight." />
		</cfif>
		
		<cfset triming.top = 0 />
		<cfset triming.bottom = getHeight() - 1 />
		<cfset triming.left = 0 />
		<cfset triming.right = getWidth() - 1 />
				
		<cfswitch expression="#arguments.startingPixel#">
			<cfcase value="topLeft">
				<cfset RGB = Image.getRGB(JavaCast("int", triming.left), JavaCast("int", triming.top)) />
			</cfcase>
			<cfcase value="topRight">
				<cfset RGB = Image.getRGB(JavaCast("int", triming.right), JavaCast("int", triming.top)) />
			</cfcase>
			<cfcase value="bottomLeft">
				<cfset RGB = Image.getRGB(JavaCast("int", triming.left), JavaCast("int", triming.bottom)) />
			</cfcase>
			<cfcase value="bottomRight">
				<cfset RGB = Image.getRGB(JavaCast("int", triming.right), JavaCast("int", triming.bottom)) />
			</cfcase>		
		</cfswitch>
		
		<cfif arguments.trimTop>
			<!--- trim the top --->
			<cfloop from="0" to="#evaluate(getHeight()-1)#" index="y">
				<cfloop from="0" to="#evaluate(getWidth()-1)#" index="x">
					<!--- check to see if the RGB value for this pixel is the same as the starting RGB --->
					<cfif NOT RGB IS Image.getRGB(JavaCast("int", x), JavaCast("int", y))>
						<cfset breakLoop = true />
						<cfbreak />
					</cfif>			
				</cfloop>
				
				<cfif breakLoop>
					<cfbreak>
				</cfif>
			</cfloop>
		
			<!--- set the amount I can trim --->
			<cfset triming.top = y />
			<cfset breakLoop = false />
		</cfif>
				
		<cfif arguments.trimBottom>
			<!--- trim the bottom --->
			<cfloop from="#evaluate(getHeight()-1)#" to="0" index="y" step="-1">
				<cfloop from="0" to="#evaluate(getWidth()-1)#" index="x">
					
					<!--- check to see if the RGB value for this pixel is the same as the starting RGB --->
					<cfif NOT RGB IS Image.getRGB(JavaCast("int", x), JavaCast("int", y))>
						<cfset breakLoop = true />
						<cfbreak />
					</cfif>			
				</cfloop>
				
				<cfif breakLoop>
					<cfbreak>
				</cfif>
			</cfloop>
		
			<!--- set the amount I can trim  --->
			<cfset triming.bottom = y />
			<cfset breakLoop = false />
		</cfif>
		
		<cfif arguments.trimLeft>
			<!--- trim the left side --->
			<cfloop from="0" to="#evaluate(getWidth()-1)#" index="x">
				<cfloop from="#triming.top#" to="#triming.bottom#" index="y">
					<!--- check to see if the RGB value for this pixel is the same as the starting RGB --->
					<cfif NOT RGB IS Image.getRGB(JavaCast("int", x), JavaCast("int", y))>
						<cfset breakLoop = true />
						<cfbreak />
					</cfif>			
				</cfloop>
				
				<cfif breakLoop>
					<cfbreak>
				</cfif>
			</cfloop>
			
			<!--- set the amount I can trim --->
			<cfset triming.left = x />
			<cfset breakLoop = false />
		</cfif>
		
		<cfif arguments.trimRight>
			<!--- trim the right side --->
			<cfloop from="#evaluate(getWidth()-1)#" to="0" index="x" step="-1">
				<cfloop from="#triming.top#" to="#triming.bottom#" index="y">
					<!--- check to see if the RGB value for this pixel is the same as the starting RGB --->
					<cfif NOT RGB IS Image.getRGB(JavaCast("int", x), JavaCast("int", y))>
						<cfset breakLoop = true />
						<cfbreak />
					</cfif>			
				</cfloop>
				
				<cfif breakLoop>
					<cfbreak>
				</cfif>
			</cfloop>
			
			<!--- set the amount I can trim --->
			<cfset triming.right = x />
			<cfset breakLoop = false />
		</cfif>
		
		<!--- crop the image according to the information we have --->
		<cfset crop(triming.left, triming.top, triming.right - triming.left, triming.bottom - triming.top) />
	</cffunction>
	
	<!--- createColor --->
	<cffunction name="createColor" access="public" output="false" returntype="any" hint="I create and return a color object for use when drawing lines and shapes.">
		<cfargument name="red" hint="I am the red value of the color.  Valid options are 0 to 255." required="yes" type="numeric" />
		<cfargument name="green" hint="I am the green value of the color.  Valid options are 0 to 255." required="yes" type="numeric" />
		<cfargument name="blue" hint="I am the blue value of the color.  Valid options are 0 to 255." required="yes" type="numeric" />
		<cfargument name="alpha" hint="I am the transparency of the color.  Valid options are 0 to 255.  255 = Opaque, 0 = Transparent." required="no" default="255" type="numeric" />
		<cfset var Color = CreateObject("Java", "java.awt.Color") />
		
		<!--- validate attributes --->
		<cfif NOT (arguments.red GTE 0 AND arguments.red LTE 255)>
			<cfthrow message="Invalid red attribute.  Valid options are 0 - 255" />
		</cfif> 
		<cfif NOT (arguments.green GTE 0 AND arguments.green LTE 255)>
			<cfthrow message="Invalid green attribute.  Valid options are 0 - 255" />
		</cfif> 
		<cfif NOT (arguments.blue GTE 0 AND arguments.blue LTE 255)>
			<cfthrow message="Invalid blue attribute.  Valid options are 0 - 255" />
		</cfif> 
		<cfif NOT (arguments.alpha GTE 0 AND arguments.alpha LTE 255)>
			<cfthrow message="Invalid alpha attribute.  Valid options are 0 - 255" />
		</cfif> 
		
		<cfset Color.init(JavaCast("int", arguments.red), JavaCast("int", arguments.green), JavaCast("int", arguments.blue), JavaCast("int", arguments.alpha)) />
		
		<cfreturn Color />
	</cffunction>
	
	<!--- createFill
	<cffunction name="createFill" access="public" output="false" returntype="any" hint="I create and return a fill object for use when drawing shapes.">
		<cfargument name="red" hint="I am the red value of the color.  Valid options are 0 to 255." required="yes" type="numeric" />
		<cfargument name="green" hint="I am the green value of the color.  Valid options are 0 to 255." required="yes" type="numeric" />
		<cfargument name="blue" hint="I am the blue value of the color.  Valid options are 0 to 255." required="yes" type="numeric" />
		<cfargument name="alpha" hint="I am the transparency of the color.  Valid options are 0 to 255.  255 = Opaque, 0 = Transparent." required="no" default="255" type="numeric" />
		<cfreturn createColor(arguments.red, arguments.green, arguments.blue, arguments.alpha) />
	</cffunction> --->
	
	<!--- createTexture --->
	<cffunction name="createTexture" access="public" output="false" returntype="any" hint="I create and return a texture object for use when drawing shapes.">
		<cfargument name="textureFilePath" hint="I am the path to a texture image to use." required="yes" type="string" />
		<cfargument name="x" hint="I am the upper left X coordinate used to set the origin of the texture in the image." required="no" type="numeric" default="0" />
		<cfargument name="y" hint="I am the upper left Y coordinate used to set the origin of the texture in the image." required="no" type="numeric" default="0" />
		<cfargument name="width" hint="I am the width of the texture." required="no" type="numeric" default="-1" />
		<cfargument name="height" hint="I am the height of the texture." required="no" type="numeric" default="-1" />
		<cfset var InputStream = CreateObject("Java", "java.io.FileInputStream") />
		<cfset var Image2 = CreateObject("Java", "java.awt.image.BufferedImage") />
		<cfset var Texture = CreateObject("Java", "java.awt.TexturePaint") />
		<cfset var Rectangle = CreateObject("Java", "java.awt.Rectangle") />
				
		<!--- validate the arguments --->
		<cfif NOT fileExists(arguments.textureFilePath)>
			<cfthrow message="Invalid textureFilePath argument.  The textureFilePath specified does not exist. (#arguments.textureFilePath#)  Please provide a valid path to an image file." />
		</cfif>
		
		<!--- read the texture image --->
		<cftry>
			<!--- read the texture image --->
			<cfset InputStream.init(arguments.textureFilePath) />
			<cfset Image2 = getImageIO().read(InputStream) />
			
			<cfcatch>
				<cfthrow message="There was an unknown error reading image from #arguments.path#. This is possibly an invalid path or an unsupported file format." />
			</cfcatch>		
		</cftry>
		
		<!--- default width / height --->
		<cfif arguments.width IS -1>
			<cfset arguments.width = Image2.getWidth() />
		</cfif>
		<cfif arguments.height IS -1>
			<cfset arguments.height = Image2.getHeight() />
		</cfif>
		
		<!--- validate the rest of the attributes --->
		<cfif arguments.x LT 0>
			<cfthrow message="Invalid x attribute.  The x attribute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.y LT 0>
			<cfthrow message="Invalid y attribute.  The y attribute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attribute must be greater than 0." />
		</cfif>
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attribute must be greater than 0." />
		</cfif>
		
		<!--- init the rectangle used for drawing the texture --->
		<cfset Rectangle.init(JavaCast("int", arguments.x), JavaCast("int", arguments.y), JavaCast("int", arguments.width), JavaCast("int", arguments.height)) />
		
		<!--- create the texture --->
		<cfset Texture.init(Image2, Rectangle) />
		
		<!--- return the texture --->
		<cfreturn Texture />
	</cffunction>
	
	<!--- createGradient --->
	<cffunction name="createGradient" access="public" output="false" returntype="any" hint="I create and return a gradient object for use when drawing shapes.">
		<cfargument name="x1" hint="I am the first X coordinate for the gradient.  I am based on the Image's coordinate space." required="yes" type="numeric" />
		<cfargument name="y1" hint="I am the first Y coordinate for the gradient.  I am based on the Image's coordinate space." required="yes" type="numeric" />
		<cfargument name="x2" hint="I am the second X coordinate for the gradient.  I am based on the Image's coordinate space." required="yes" type="numeric" />
		<cfargument name="y2" hint="I am the second Y coordinate for the gradient.  I am based on the Image's coordinate space." required="yes" type="numeric" />
		<cfargument name="Color1" hint="I am the first color for the gradient." required="yes" type="any" />
		<cfargument name="Color2" hint="I am the second color for the gradient." required="yes" type="any" />
		<cfargument name="cycle" hint="I indicate if the gradient pattern should repeat (true) or extend (false)." required="no" type="boolean" default="true" />
		<cfset var Gradient = CreateObject("Java", "java.awt.GradientPaint") />
		
		<!--- validate the coordinates --->
		<cfif arguments.x1 LT 0>
			<cfthrow message="Invalid x1 attribute.  The x1 attribute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.y1 LT 0>
			<cfthrow message="Invalid y1 attribute.  The y1 attribute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.x2 LT 0>
			<cfthrow message="Invalid x2 attribute.  The x2 attribute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.y2 LT 0>
			<cfthrow message="Invalid y2 attribute.  The y2 attribute must be greater than or equal to 0." />
		</cfif>
		
		<!--- validate Color1 argument --->
		<cfif NOT IsObject(arguments.Color1) OR (IsObject(arguments.Color1) AND arguments.Color1.getClass().getName() IS NOT "java.awt.Color")>
			<cfthrow message="Invalid Color1 attribute.  The Color1 attribute must be a Color object." />
		</cfif>
		<cfif NOT IsObject(arguments.Color2) OR (IsObject(arguments.Color2) AND arguments.Color2.getClass().getName() IS NOT "java.awt.Color")>
			<cfthrow message="Invalid Color2 attribute.  The Color2 attribute must be a Color object." />
		</cfif>
		
		<cfset Gradient.init(JavaCast("float", arguments.x1), JavaCast("float", arguments.y1), arguments.Color1, JavaCast("float", arguments.x2), JavaCast("float", arguments.y2), arguments.Color2, JavaCast("boolean", arguments.cycle)) />
		
		<cfreturn Gradient />
	</cffunction>
	
	<!--- copyRectangleTo --->
	<cffunction name="copyRectangleTo" access="public" output="false" returntype="void" hint="I copy a rectangular area to another area of the image.">
		<cfargument name="x" hint="I am the upper left X coordinate." required="yes" type="numeric">
		<cfargument name="y" hint="I am the upper left Y coordinate." required="yes" type="numeric">
		<cfargument name="width" hint="I am the width of the region to copy." required="yes" type="numeric">
		<cfargument name="height" hint="I am the height of the region to copy." required="yes" type="numeric">
		<cfargument name="distanceX" hint="I am the horizontal distance to move the image." required="yes" type="numeric">
		<cfargument name="distanceY" hint="I am the vertical distance to move the image." required="yes" type="numeric">
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		
		<!--- validate the arguments --->
		<cfif arguments.X LT 0>
			<cfthrow message="Invalid x attribute.  The x attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.Y LT 0>
			<cfthrow message="Invalid y attribute.  The y attibute must be greater than or equal to 0." />
		</cfif>
		<cfif arguments.width LTE 0>
			<cfthrow message="Invalid width attribute.  The width attibute must be greater than 0." />
		</cfif>
		<cfif arguments.height LTE 0>
			<cfthrow message="Invalid height attribute.  The height attibute must be greater than 0." />
		</cfif>
		
		<cfset Graphics.copyArea(JavaCast("int", arguments.X), JavaCast("int", arguments.Y), JavaCast("int", arguments.width), JavaCast("int", arguments.height), JavaCast("int", arguments.distanceX), JavaCast("int", arguments.distanceY)) />
	</cffunction>
	
	<!--- clearImage --->
	<cffunction name="clearImage" access="public" output="false" returntype="void" hint="I clear the entire area of the image, setting it to the background color.">
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
		
		<!--- check to see if we have a background color --->
		<cfif IsObject(getBackgroundColor())>
			<cfset Graphics.setBackground(getBackgroundColor()) />
		</cfif>
		
		<cfset Graphics.clearRect(JavaCast("int", 0), JavaCast("int", 0), JavaCast("int", Image.getWidth()), JavaCast("int", Image.getHeight())) />
	</cffunction>
	
	<!--- clearRectangle --->
	<cffunction name="clearRectangle" access="public" output="false" returntype="void" hint="I clear a rectangular area of the image, setting it to the background color.">
		<cfargument name="x" hint="I am the upper left X coordinate." required="yes" type="numeric">
		<cfargument name="y" hint="I am the upper left Y coordinate." required="yes" type="numeric">
		<cfargument name="width" hint="I am the width of the region to clear." required="yes" type="numeric">
		<cfargument name="height" hint="I am the height of the region to clear." required="yes" type="numeric">
		<cfset var Image = getImage() />
		<cfset var Graphics = Image.getGraphics() />
						
		<!--- check to see if we have a background color --->
		<cfif IsObject(getBackgroundColor())>
			<cfset Graphics.setBackground(getBackgroundColor()) />
		</cfif>
		
		<cfset Graphics.clearRect(JavaCast("int", arguments.x), JavaCast("int", arguments.y), JavaCast("int", arguments.width), JavaCast("int", arguments.height)) />
	</cffunction>
	
	<!--- getReadableFormats --->
	<cffunction name="getReadableFormats" access="public" output="false" returntype="string">
		<cfreturn ArrayToList(getImageIO().getReaderFormatNames()) />
	</cffunction>
	<!--- getWritableFormats --->
	<cffunction name="getWritableFormats" access="public" output="false" returntype="string">
		<cfreturn ArrayToList(getImageIO().getWriterFormatNames()) />
	</cffunction>
	<!--- getWidth --->
	<cffunction name="getWidth" access="public" output="false" returntype="numeric">
		<cfreturn getImage().getWidth() />	
	</cffunction>
	<!--- getHeight --->
	<cffunction name="getHeight" access="public" output="false" returntype="numeric">
		<cfreturn getImage().getHeight() />	
	</cffunction>
	
	<!--- setBackgroundColor --->
	<cffunction name="setBackgroundColor" access="public" output="false" returntype="void" hint="I set the background color.">
		<cfargument name="Color" hint="I am the color to set the background." required="yes" type="any" />
		
		<!--- validate Color argument --->
		<cfif NOT IsObject(arguments.Color) OR (IsObject(arguments.Color) AND arguments.Color.getClass().getName() IS NOT "java.awt.Color")>
			<cfthrow message="Invalid Color attribute.  The Color attribute must be a Color object." />
		</cfif>
		
		<cfset variables.BackgroundColor = arguments.Color />
	</cffunction>
	<cffunction name="getBackgroundColor" access="private" output="false" returntype="any" hint="I return the background color.">
		<cfreturn variables.BackgroundColor />
	</cffunction>
	<!--- resetBackgroundColor --->
	<cffunction name="resetBackgroundColor" access="public" output="false" returntype="void" hint="I reset the background color to the default.">
		<cfset variables.BackgroundColor = 0 />
	</cffunction>
	
	<!--- setStroke --->
	<cffunction name="setStroke" access="public" output="false" returntype="void" hint="I set the stroke which will be applied to lines and shapes.">
		<cfargument name="weight" hint="I am the weight of the stroke." required="yes" type="numeric" />
		<cfargument name="Color" hint="I am the color of the stroke." required="no" type="any" default="" />
		<cfargument name="cap" hint="I am the decoration at the end of a line. Options: Butt, Round, Square" required="no" type="string" default="Square" />
		<cfargument name="join" hint="I am the decoration at the join between two lines. Options: Bevel, Miter, Round" required="no" type="string" default="Miter" />
		<cfargument name="miterLimit" hint="I am the limit applied to miter joins.  If the angle of the join is less than or equal to the miter joins are trimed." required="no" type="numeric" default="10" />
		<cfargument name="dashLengthList" hint="I am a comma delimited list of lengths of dash segments." required="no" type="string" default="" />
		<cfargument name="dashOffset" hint="I am the offset of the begining of the dash pattern." required="no" type="numeric" default="0" />
		<cfset var Stroke = CreateObject("Java", "java.awt.BasicStroke") />
		<cfset var ArrayObj = CreateObject("Java", "java.lang.reflect.Array") />
		<cfset var ArrayType = CreateObject("Java", "java.lang.Float").TYPE />
		<cfset var Float = CreateObject("Java", "java.lang.Float") />
		<cfset var DashArray = ArrayObj.newInstance(ArrayType, ListLen(arguments.dashLengthList)) />
		<cfset var index = 0 />
		<cfset var x = 0 />
		
		<!--- validate weight argument --->
		<cfif arguments.weight LT 0>
			<cfthrow message="Invalid weight attribute.  The weight must be greater than or equal to 0." />
		</cfif>
		
		<!--- validate Color argument --->
		<cfif (NOT IsObject(arguments.Color) AND arguments.Color IS NOT "") OR (IsObject(arguments.Color) AND arguments.Color.getClass().getName() IS NOT "java.awt.Color")>
			<cfthrow message="Invalid Color attribute.  The Color attribute must be a Color object." />
		</cfif>
		
		<!--- validate the cap arguments --->
		<cfif NOT ListFindNoCase("Butt,Round,Square", arguments.cap)>
			<cfthrow message="Invalid cap attribute.  The cap attribute must be one of Butt, Round, Square." />
		</cfif>
		<!--- validate the join arguments --->
		<cfif NOT ListFindNoCase("Bevel,Miter,Round", arguments.join)>
			<cfthrow message="Invalid join attribute.  The join attribute must be one of Bevel, Miter, Round." />
		</cfif>		
		
		<!--- validate miterlimit --->
		<cfif arguments.join IS "Miter" AND arguments.miterLimit LT 1>
			<cfthrow message="Invalid miterLimit attribute.  The miterLimit attribute must be greater than or equal to 1 when the join attribute is Miter." />
		</cfif>
		
		<!--- validate dashLengthList and dashSpace --->
		<cfif Len(arguments.dashLengthList)>
			<cfloop list="#arguments.dashLengthList#" index="index">
				<cfif NOT IsNumeric(index) OR index LT 0>
					<cfthrow message="Invalid dashLengthList attribute.  All items in the dashLengthList attribute must be numeric and greater than or equal to 0." />
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- validate dashOffset --->
		<cfif arguments.dashOffset LT 0>
			<cfthrow message="Invalid dashOffset attribute.  The dashOffset attribute must be greater than or equal to 0." />
		</cfif>
		
		<!--- get the correct cap value --->
		<cfswitch expression="#arguments.cap#">
			<cfcase value="Butt">
				<cfset arguments.cap = Stroke.CAP_BUTT />
			</cfcase>
			<cfcase value="Round">
				<cfset arguments.cap = Stroke.CAP_ROUND />
			</cfcase>
			<cfcase value="Square">
				<cfset arguments.cap = Stroke.CAP_SQUARE />
			</cfcase>
		</cfswitch>
		
		<!--- get the correct join value --->
		<cfswitch expression="#arguments.join#">
			<cfcase value="Bevel">
				<cfset arguments.join = Stroke.JOIN_BEVEL />
			</cfcase>
			<cfcase value="Miter">
				<cfset arguments.join = Stroke.JOIN_MITER />

			</cfcase>
			<cfcase value="Round">
				<cfset arguments.join = Stroke.JOIN_ROUND />
			</cfcase>
		</cfswitch>
		
		<!--- check to see if this is a dashed line --->
		<cfif Len(arguments.dashLengthList)>
			<cfloop list="#arguments.dashLengthList#" index="index">
				<cfset index = Float.parseFloat(index) />
				<cfset ArrayObj.setFloat(DashArray, JavaCast("int", x), index) />
				<cfset x = x + 1 />
			</cfloop>
			
			<cfset Stroke.init(JavaCast("float", arguments.weight), JavaCast("int", arguments.cap), JavaCast("int", arguments.join), JavaCast("float", arguments.miterlimit), DashArray, JavaCast("float", arguments.dashOffset)) />
		<cfelse>
			<cfset Stroke.init(JavaCast("float", arguments.weight), JavaCast("int", arguments.cap), JavaCast("int", arguments.join), JavaCast("float", arguments.miterlimit)) />
		</cfif>
			
		<!--- set the color --->
		<cfif IsObject(arguments.Color)>
			<cfset variables.Color = arguments.Color />
		<cfelse>
			<cfset variables.Color = 0 />
		</cfif>
		
		<!--- set the stroke --->		
		<cfset variables.Stroke = Stroke />
	</cffunction>
	<!--- getStroke --->
	<cffunction name="getStroke" access="private" output="false" returntype="any" hint="I return the Stroke.">
		<cfreturn variables.Stroke />
	</cffunction>
	<!--- getColor --->
	<cffunction name="getColor" access="private" output="false" returntype="any" hint="I return the Color.">
		<cfreturn variables.Color />
	</cffunction>
	<!--- resetStroke --->
	<cffunction name="resetStroke" access="public" output="false" returntype="void" hint="I reset the Stroke to the default.">
		<cfset variables.Stroke = 0 />
		<cfset variables.Color = 0 />
	</cffunction>
	
	<!--- setFill --->
	<cffunction name="setFill" access="public" output="false" returntype="void" hint="I set the fill used when drawing shapes.">
		<cfargument name="Fill" hint="I am the fill to apply when drawing shapes.  This can be either a Color object, Gradient object, or Texture object." required="yes" type="any" />
		
		<!--- validate the fill --->
		<cfif (NOT IsObject(arguments.Fill) AND arguments.Fill IS NOT "") OR (IsObject(arguments.Fill) AND arguments.Fill.getClass().getName() IS NOT "java.awt.Color" AND arguments.Fill.getClass().getName() IS NOT "java.awt.GradientPaint" AND arguments.Fill.getClass().getName() IS NOT "java.awt.TexturePaint")>
			<cfthrow message="Invalid Fill attribute.  The Fill attribute must be a Color object or Gradient object." />
		</cfif>
		
		<cfset variables.Fill = Arguments.Fill />
	</cffunction>
	<!--- getFill --->
	<cffunction name="getFill" access="private" output="false" returntype="any" hint="I return the Fill.">
		<cfreturn variables.Fill />
	</cffunction>
	<!--- resetFill --->
	<cffunction name="resetFill" access="public" output="false" returntype="any" hint="I reset the Fill to the default.">
		<cfset variables.Fill = 0 />
	</cffunction>
  
	<!--- setRotation --->
	<cffunction name="setRotation" access="public" output="false" returntype="void" hint="I set the rotation of shapes drawn into the image.">
		<cfargument name="angle" hint="I am the angle in degrees to set the rotation to." required="yes" type="numeric" />
		<cfargument name="x" hint="I am the X coordinate where the rotation takes place." required="no" type="numeric" default="0" />
		<cfargument name="y" hint="I am the Y coordinate where the rotation takes place." required="no" type="numeric" default="0" />
		
		<cfset var RADIAN_DEGREE_RATIO = 0.0174532925 />
		
		<cfset variables.rotate = arguments.angle * RADIAN_DEGREE_RATIO />		
		<cfset variables.rotateX = arguments.x />
		<cfset variables.rotateY = arguments.y />
	</cffunction>
	
	<!--- getRotation --->
	<cffunction name="getRotation" access="private" output="false" returntype="numeric" hint="I return the rotationin radians.">
		<cfreturn variables.rotate />
	</cffunction>
	<!--- resetRotation --->
	<cffunction name="resetRotation" access="public" output="false" returntype="void" hint="I reset the rotation.">
		<cfset variables.rotate = 0 />

		<cfset variables.rotateX = 0 />
		<cfset variables.rotateY = 0 />
	</cffunction>
	<!--- getRotationX --->
	<cffunction name="getRotationX" access="private" output="false" returntype="numeric" hint="I return the X coordinate for the rotation point.">
		<cfreturn variables.rotateX />			
	</cffunction>
	<!--- getRotationY --->
	<cffunction name="getRotationY" access="private" output="false" returntype="numeric" hint="I return the Y coordinate for the rotation point.">
		<cfreturn variables.rotateY />			
	</cffunction>
	
	<!--- setShear --->
	<cffunction name="setShear" access="public" output="false" returntype="void" hint="I set the shear of shapes drawn into the image.">
		<cfargument name="x" hint="I am the shear X percent value." required="no" type="numeric" default="0" />
		<cfargument name="y" hint="I am the shear Y percent value." required="no" type="numeric" default="0" />
		
		<cfset variables.shearX = arguments.x / 100 />
		<cfset variables.shearY = arguments.y / 100 />	
	</cffunction>
	<!--- getShearX --->
	<cffunction name="getShearX" access="private" output="false" returntype="numeric" hint="I return the shear X percent value">
		<cfreturn variables.shearX />
	</cffunction>
	<!--- getShearY --->
	<cffunction name="getShearY" access="private" output="false" returntype="numeric" hint="I return the shear Y percent value">
		<cfreturn variables.shearY />
	</cffunction>
	<!--- resetShear --->
	<cffunction name="resetShear" access="public" output="false" returntype="void" hint="I reset the shear.">
		<cfset variables.shearX = 0 />
		<cfset variables.shearY = 0 />
	</cffunction>
	
	<!--- setTransparency --->
	<cffunction name="setTransparency" access="public" output="false" returntype="void" hint="I set the alpha transparency">
  		<cfargument name="transparency" hint="I am the percent transparency to use." required="true" type="numeric" />
		
		<cfif arguments.transparency LT 0 OR arguments.transparency GT 100>
			<cfthrow message="Invalid transparency attribute.  The transparency must be greater than or equal to 0 and less than or equal to 100." />
		</cfif>
		
		<cfset variables.transparency = arguments.transparency />
	</cffunction>
	<cffunction name="getTransparency" access="private" output="false" returntype="numeric" hint="I return the current transparency.">
		<cfreturn javaCast("float", variables.transparency / 100) />
	</cffunction>
	<cffunction name="resetTransparency" access="public" output="false" returntype="void" hint="I reset the transparency.">
		<cfset variables.transparency = 100 />
	</cffunction>
	<!--- setComposite --->
	<cffunction name="setComposite" access="public" output="false" returntype="void" hint="I set the composite.">
		<cfargument name="composite" hint="I am the name of the composite to use.  Options are: dstAtop, dstIn, dstOut, dstOver, srcAtop, srcIn, srcOut, srcOver." required="true" type="string" />
		
		<!--- validate the composite --->
		<cfif NOT ListFindNoCase("dstAtop,dstIn,dstOut,dstOver,srcAtop,srcIn,srcOut,srcOver", arguments.composite)>
			<cfthrow message="Invalid composite attribute.  The composite attribute must be one of: dstAtop, dstIn, dstOut, dstOver, srcAtop, srcIn, srcOut, srcOver." />
		</cfif>
		
		<cfset variables.composite = arguments.composite />
	</cffunction>
	<cffunction name="getComposite" access="private" output="false" returntype="any" hint="I return the Composite">
		<cfreturn variables.composite />
	</cffunction>
	<cffunction name="resetComposite" access="public" output="false" returntype="void" hint="I reset the Composite">
		<cfset variables.composite = "srcOver"/>
	</cffunction>
	
	<!--- setAntialias --->
	<cffunction name="setAntialias" access="public" output="false" returntype="void" hint="I indicate if antialiasing is on or off.">
		<cfargument name="antialias" hint="I indicate if antialiasing is turned on or off." required="true" type="boolean" />

		<cfset variables.antialias = arguments.antialias />
	</cffunction>
	<cffunction name="getAntialias" access="private" output="false" returntype="any" hint="I return the Composite">
		<cfreturn variables.antialias />
	</cffunction>

	<cffunction name="resetAntialias" access="public" output="false" returntype="void" hint="I reset the Composite">
		<cfset variables.antialias = true/>
	</cffunction>
		
	<!--- reset --->
	<cffunction name="reset" access="public" output="false" returntype="void" hint="I reset all drawing related settings.">
		<cfscript>
			resetComposite();
			resetShear();
			resetRotation();
			resetFill();
			resetStroke();
			resetBackgroundColor();
			resetTransparency();
			resetAntialias();
		</cfscript>
	</cffunction>
	
	<!--- createPolygon --->
	<cffunction name="createPolygon" access="public" output="false" returntype="any" hint="I create and return a new polygon with no points.  Use addPolygonPoint() to add points to the polygon.">
		<cfset var Polygon = CreateObject("Java", "java.awt.Polygon").init() />
		<cfreturn Polygon />
	</cffunction>
	
	<!--- createPath --->
	<cffunction name="createPath" access="public" output="false" returntype="any" hint="I create and return a new path with no points.  Use addPathPoint() to add points to the path.">
		<cfargument name="x" hint="I am the inital left X coordinate for the path." required="yes" type="numeric" />
		<cfargument name="y" hint="I am the inital left Y coordinate for the path." required="yes" type="numeric" />
		<cfset var Path = CreateObject("Java", "java.awt.geom.GeneralPath").init() />
		
		<cfset Path.moveTo(javacast("int", arguments.x), javacast("int", arguments.y))  />
		
		<cfreturn Path />
	</cffunction>
	
	<!--- createString --->
	<cffunction name="createString" access="public" output="false" returntype="any" hint="I create and return a new Advanced String for advanced text formatting.">
		<cfargument name="string" hint="I am the string to use for advanced text formatting." required="yes" type="string">
		<cfset var newString = CreateObject("Java", "java.text.AttributedString") />
		<cfreturn newString.init(arguments.string) />
	</cffunction>
	
	<!--- setStringBackground --->
	<cffunction name="setStringBackground" access="public" output="false" returntype="void" hint="I set advanced text background color.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="color" hint="I am the background color to use." type="any" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />
		
		<cfif NOT IsObject(arguments.color) OR arguments.color.getClasS().getName() IS NOT "java.awt.Color" >
			<cfthrow message="The color attribute must be a Color object." />
		</cfif>		
		
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.BACKGROUND, arguments.color, arguments.start, arguments.end) />
	</cffunction>
	<!--- setStringForeground --->
	<cffunction name="setStringForeground" access="public" output="false" returntype="void" hint="I set advanced text foreground color.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="color" hint="I am the foreground color to use." type="any" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />
		
		<cfif NOT IsObject(arguments.color) OR arguments.color.getClasS().getName() IS NOT "java.awt.Color" >
			<cfthrow message="The color attribute must be a Color object." />
		</cfif>
		
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.FOREGROUND, arguments.color, arguments.start, arguments.end) />
	</cffunction>
	<!--- setStringSize --->
	<cffunction name="setStringSize" access="public" output="false" returntype="void" hint="I set advanced text font size.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="size" hint="I am the font size to use." type="numeric" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />
		
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.SIZE, JavaCast("float", arguments.size), arguments.start, arguments.end) />
	</cffunction>
	<!--- setStringFamily --->
	<cffunction name="setStringFamily" access="public" output="false" returntype="void" hint="I set advanced text font family.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="family" hint="I am the font family to use. See getSystemFonts() for an array of options." type="string" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />
		
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.FAMILY, arguments.family, arguments.start, arguments.end) />
	</cffunction>
	<!--- setStringFont --->
	<cffunction name="setStringFont" access="public" output="false" returntype="void" hint="I set advanced text font based on a provided font.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="Font" hint="I am the Font object to use." type="any" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />
		
		<!--- validate the font --->
		<cftry>
			<cfif (IsObject(arguments.Font) AND arguments.Font.getClass().getName() IS NOT "java.awt.Font") OR (NOT IsObject(arguments.Font) AND Len(arguments.Font))>
				<cfthrow message="Invalid Font attribute.  The Font attibute must be a Font object.  These can be loaded with loadSystemFont() or loadTTFFile()." />
			</cfif>
			<cfcatch>
				<cfthrow message="Invalid Font attribute.  The Font attibute must be a Font object.  These can be loaded with loadSystemFont() or loadTTFFile()." />
			</cfcatch>
		</cftry>
				
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.FONT, arguments.Font, arguments.start, arguments.end) />
	</cffunction>
	<!--- setStringStrikeThrough --->
	<cffunction name="setStringStrikeThrough" access="public" output="false" returntype="void" hint="I set set the string strikethough settings.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="state" hint="I indicate if strikethrough is on or off." type="boolean" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />

		<!--- validate the direction --->
		<cfif NOT IsBoolean(state)>
			<cfthrow message="Invalid state attribute.  The state attribute must be a boolean value." />
		</cfif>
		
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.STRIKETHROUGH, javaCast("boolean", arguments.state), arguments.start, arguments.end) />
	</cffunction>
	<!--- setStringPosture --->
	<cffunction name="setStringPosture" access="public" output="false" returntype="void" hint="I set set the string posture settings.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="posture" hint="I indicate the posture to use. Options are: oblique, regular." type="string" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />

		<!--- validate the underline --->
		<cfif NOT ListFindNoCase("oblique,regular", arguments.posture)>
			<cfthrow message="Invalid posture attribute.  The posture attribute must be oblique or regular." />
		</cfif>
		
		<cfswitch expression="#arguments.posture#">
			<cfcase value="oblique">
				<cfset arguments.posture = TextAttribute.POSTURE_OBLIQUE />
			</cfcase>
			<cfcase value="regular">
				<cfset arguments.posture = TextAttribute.POSTURE_REGULAR />
			</cfcase>
		</cfswitch>
		
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.POSTURE, arguments.posture, arguments.start, arguments.end) />
	</cffunction>
	<!--- setStringDirection --->
	<cffunction name="setStringDirection" access="public" output="false" returntype="void" hint="I set set the string direction settings.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="direction" hint="I indicate the direction to use. Options are: ltr, rtl." type="string" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />

		<!--- validate the underline --->
		<cfif NOT ListFindNoCase("rtl,ltr", arguments.direction)>
			<cfthrow message="Invalid direction attribute.  The direction attribute must be rtl or ltr." />
		</cfif>
		
		<cfswitch expression="#arguments.direction#">
			<cfcase value="rtl">
				<cfset arguments.direction = TextAttribute.RUN_DIRECTION_RTL />
			</cfcase>
			<cfcase value="ltr">
				<cfset arguments.direction = TextAttribute.RUN_DIRECTION_LTR />
			</cfcase>
		</cfswitch>
		
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.RUN_DIRECTION, arguments.direction, arguments.start, arguments.end) />
	</cffunction>
	<!--- setStringUnderline --->
	<cffunction name="setStringUnderline" access="public" output="false" returntype="void" hint="I set set the underline options for the string.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="underline" hint="I indicate the underline setting to use. Options: on, off, lowOnePixel, lowTwoPixel, lowDotted, lowGray, lowDashed." type="string" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />

		<!--- validate the underline --->
		<cfif NOT ListFindNoCase("on,off,lowOnePixel,lowTwoPixel,lowDotted,lowGray,lowDashed", arguments.underline)>
			<cfthrow message="Invalid underline attribute.  The underline attribute must be one of: on, off, lowOnePixel, lowTwoPixel, lowDotted, lowGray, lowDashed." />
		</cfif>
		
		<cfswitch expression="#arguments.underline#">
			<cfcase value="on">
				<cfset arguments.underline = TextAttribute.UNDERLINE_ON />
			</cfcase>
			<cfcase value="off">
				<cfset arguments.underline = -1 />
			</cfcase>
			<cfcase value="lowOnePixel">
				<cfset arguments.underline = TextAttribute.UNDERLINE_LOW_ONE_PIXEL />
			</cfcase>
			<cfcase value="lowTwoPixel">
				<cfset arguments.underline = TextAttribute.UNDERLINE_LOW_TWO_PIXEL />
			</cfcase>
			<cfcase value="lowDotted">
				<cfset arguments.underline = TextAttribute.UNDERLINE_LOW_DOTTED />
			</cfcase>
			<cfcase value="lowGray">
				<cfset arguments.underline = TextAttribute.UNDERLINE_LOW_GRAY />
			</cfcase>			
			<cfcase value="lowDashed">
				<cfset arguments.underline = TextAttribute.UNDERLINE_LOW_DASHED />
			</cfcase>
			
		</cfswitch>
		
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.UNDERLINE, arguments.underline, arguments.start, arguments.end) />
	</cffunction>
	<!--- setStringWeight --->
	<cffunction name="setStringWeight" access="public" output="false" returntype="void" hint="I set set the weight options for the string.  The font must support this weight.  If not, regular will be used.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="weight" hint="I indicate the weight setting to use. Options: regular, bold, demiBold, demiLight, extraLight, extraBold, heavy, light, medium, semiBold, ultraBold." type="string" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />

		<!--- validate the weight --->
		<cfif NOT ListFindNoCase("regular,bold,demiBold,demiLight,extraLight,extraBold,heavy,light,medium,semiBold,ultraBold", arguments.weight)>
			<cfthrow message="Invalid weight attribute.  The weight attribute must be one of: regular, bold, demiBold, demiLight, extraLight, extraBold, heavy, light, medium, semiBold, ultraBold." />
		</cfif>
		
		<cfswitch expression="#arguments.weight#">
			<cfcase value="regular">
				<cfset arguments.weight = TextAttribute.WEIGHT_REGULAR />
			</cfcase>
			<cfcase value="bold">
				<cfset arguments.weight = TextAttribute.WEIGHT_BOLD />
			</cfcase>
			<cfcase value="demiBold">
				<cfset arguments.weight = TextAttribute.WEIGHT_DEMIBOLD />
			</cfcase>
			<cfcase value="demiLight">
				<cfset arguments.weight = TextAttribute.WEIGHT_DEMILIGHT />
			</cfcase>
			<cfcase value="extraLight">
				<cfset arguments.weight = TextAttribute.WEIGHT_EXTRA_LIGHT />
			</cfcase>
			<cfcase value="extraBold">
				<cfset arguments.weight = TextAttribute.WEIGHT_EXTRABOLD />
			</cfcase>			
			<cfcase value="heavy">
				<cfset arguments.weight = TextAttribute.WEIGHT_HEAVY />
			</cfcase>
			<cfcase value="light">
				<cfset arguments.weight = TextAttribute.WEIGHT_LIGHT />
			</cfcase>
			<cfcase value="medium">
				<cfset arguments.weight = TextAttribute.WEIGHT_MEDIUM />
			</cfcase>
			<cfcase value="semiBold">
				<cfset arguments.weight = TextAttribute.WEIGHT_SEMIBOLD />
			</cfcase>
			<cfcase value="ultraBold">
				<cfset arguments.weight = TextAttribute.WEIGHT_ULTRABOLD />
			</cfcase>
		</cfswitch>
		
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.WEIGHT, javaCast("float", arguments.weight), arguments.start, arguments.end) />
	</cffunction>	
	<!--- setStringWidth --->
	<cffunction name="setStringWidth" access="public" output="false" returntype="void" hint="I set set the width options for the string.  The font must support this width.  If not, regular will be used.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to format." required="yes" type="any" />
		<cfargument name="width" hint="I indicate the width setting to use. Options: regular, condensed, extended, semiCondensed, semiExtended." type="string" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="no" default="-1" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="no" default="-1" />
		<cfset var TextAttribute = CreateObject("Java", "java.awt.font.TextAttribute") />

		<!--- validate the width --->
		<cfif NOT ListFindNoCase("regular,condensed,extended,semiCondensed,semiExtended", arguments.width)>
			<cfthrow message="Invalid width attribute.  The width attribute must be one of: regular, condensed, extended, semiCondensed, semiExtended." />
		</cfif>
		
		<cfswitch expression="#arguments.width#">
			<cfcase value="regular">
				<cfset arguments.width = TextAttribute.WIDTH_REGULAR />
			</cfcase>
			<cfcase value="condensed">
				<cfset arguments.width = TextAttribute.WIDTH_CONDENSED />
			</cfcase>
			<cfcase value="extended">
				<cfset arguments.width = TextAttribute.WIDTH_EXTENDED />
			</cfcase>
			<cfcase value="semiCondensed">
				<cfset arguments.width = TextAttribute.WIDTH_SEMI_CONDENSED />
			</cfcase>
			<cfcase value="semiExtended">
				<cfset arguments.width = TextAttribute.WIDTH_SEMI_EXTENDED />
			</cfcase>
		</cfswitch>
		
		<cfset setTextAttribute(arguments.AdvancedString, TextAttribute.WIDTH, javaCast("float", arguments.width), arguments.start, arguments.end) />
	</cffunction>
	
	<!--- get/setBufferedImage --->
	<cffunction name="getBufferedImage" access="public" output="false" returntype="any" hint="I return the current Java Buffered Image.  This is intended for third parties to add functionality not supported by the Image Component.">
		<cfreturn getImage() />
	</cffunction>
	<cffunction name="setBufferedImage" access="public" output="false" returntype="void" hint="I set the current Java Buffered Image.  This is intended for third parties to add functionality not supported by the Image Component.">
		<cfargument name="BufferedImage" hint="I am the BufferedImage to set into the Image." required="yes" type="any" />
		<!--- check the data type of the attribute --->
		<cfif NOT IsObject(arguments.BufferedImage) OR arguments.BufferedImage.getClass().getName() IS NOT "java.awt.image.BufferedImage">
			<cfthrow message="The BufferedImage attribute must be a Java BufferedImage object." />
		</cfif>
		
		<!--- make sure that the image is indicates to be loaded --->
		<cfset setImageLoaded(true) />
		
		<!--- set the buffered image --->
		<cfset setImage(arguments.BufferedImage) />
	</cffunction>
	
	<!--- getVersion --->
	<cffunction name="getVersion" access="public" output="false" returntype="struct">
		<cfreturn variables.version />
	</cffunction>
	
	<!--- // -- // -- // -- // -- // -- // -- // -- // ---- 
	//
	//		private methods
	//
	----- // -- // -- // -- // -- // -- // -- // -- // --->
	
	<!--- setTextAttribute --->
	<cffunction name="setTextAttribute" access="private" output="false" returntype="void" hint="I set a given text attribute to the provided value.">
		<cfargument name="AdvancedString" hint="I am the Advanced String to set the attributes of." required="yes" type="any" />
		<cfargument name="attribute" hint="I am the attribute to set." type="any" required="yes" />
		<cfargument name="value" hint="I am the value for the attribute." type="any" required="yes" />
		<cfargument name="start" hint="I am the starting character for this style." type="numeric" required="yes" />
		<cfargument name="end" hint="I am the ending character for this style." type="numeric" required="yes" />
		<cfset var stringLen = arguments.AdvancedString.getIterator().getEndIndex() />
		
		<!--- validate the advancedString --->
		<cfif NOT IsObject(arguments.advancedString) OR arguments.advancedString.getClass().getName() IS NOT "java.text.AttributedString" >
			<cfthrow message="The AdvancedString attribute must be an Advanced String Object." />
		</cfif>
		
		<!--- if both start and end are -1 then we're applying this to the whole string.  If either are not -1 then we need to validate their values --->
		<cfif arguments.start IS NOT -1 AND arguments.end IS NOT -1>
			<!--- validate start and end. --->
			<cfif arguments.start GTE 0 AND arguments.end GTE 0 AND arguments.start IS NOT arguments.end AND arguments.start GTE arguments.end>
				<cfthrow message="If the start and end attributes are provided they must both be greater than or equal to 0.  The end attribute must be greater than the start attribute.">
			</cfif>
			
			<!--- make sure start and end are both greater than or equal to 0 --->
			<cfif arguments.start LT 0 OR arguments.end LT 0>
				<cfthrow message="The start and end attributes must be greater than or equal to 0.">
			</cfif>
			
			<!--- make sure both elements are less than the string length --->
			<cfif arguments.start GT stringLen OR arguments.end GT stringLen>
				<cfthrow message="The start and end attributes must be less than or equal to the length of the string.">
			</cfif>
		</cfif>		
		
		<cfif arguments.start GT -1 AND arguments.end GT -1>
			<cfset arguments.AdvancedString.addAttribute(arguments.attribute, arguments.value, javaCast("int", arguments.start), javaCast("int", arguments.end)) />
		<cfelse>
			<cfset arguments.AdvancedString.addAttribute(arguments.attribute, arguments.value) />
		</cfif>
	</cffunction>
	
	<!--- applyGrapicsSettings --->
	<cffunction name="applyGrapicsSettings" access="private" output="false" returntype="void" hint="I apply all of the generic settings to the provided Graphics context.">
		<cfargument name="Graphics" hint="I am the Graphics to apply the settings to." required="yes" type="any" />
		<cfset var RenderingHints = CreateObject("Java", "java.awt.RenderingHints") />
		<cfset var AlphaComposite = CreateObject("Java", "java.awt.AlphaComposite") />
		<cfset var Composite = 0 />

		<!--- check if antialiasing is on or off --->
		<cfif getAntialias()>
			<!--- turn on antialiasing --->
			<cfset RenderingHints.init(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON) />
			<cfset RenderingHints.init(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON ) />
		<cfelse>
			<cfset RenderingHints.init(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_OFF) />
			<cfset RenderingHints.init(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_OFF ) />
		</cfif>
		
		
		<!--- set the antialias settings --->
		<cfset Graphics.addRenderingHints(RenderingHints) />
		
		<!--- set the composite / alpha --->
		<cfswitch expression="#getComposite()#">
			<!--- <cfcase value="clear">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.CLEAR, getTransparency()) />
			</cfcase>
			<cfcase value="dst">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.DST, getTransparency()) />
			</cfcase> --->
			<cfcase value="dstAtop">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.DST_ATOP, getTransparency()) />
			</cfcase>
			<cfcase value="dstIn">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.DST_IN , getTransparency()) />
			</cfcase>
			<cfcase value="dstOut">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.DST_OUT, getTransparency()) />
			</cfcase>
			<cfcase value="dstOver">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.DST_OVER, getTransparency()) />
			</cfcase>
			<!--- <cfcase value="src">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.SRC, getTransparency()) />
			</cfcase> --->
			<cfcase value="srcAtop">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.SRC_ATOP, getTransparency()) />
			</cfcase>
			<cfcase value="srcIn">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.SRC_IN, getTransparency()) />
			</cfcase>
			<cfcase value="srcOut">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.SRC_OUT, getTransparency()) />
			</cfcase>
			<cfcase value="srcOver">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.SRC_OVER, getTransparency()) />
			</cfcase>
			<!--- <cfcase value="Xor">
				<cfset Composite = AlphaComposite.getInstance(AlphaComposite.XOR, getTransparency()) />
			</cfcase> --->
		</cfswitch>
		<cfset arguments.Graphics.setComposite(Composite) />
		
		<!--- set the rotation --->
		<cfif getRotation()>
			<cfset arguments.Graphics.rotate(getRotation(), JavaCast("double", getRotationX()), JavaCast("double", getRotationY())) />
		</cfif>
		
		<!--- set the shear --->
		<cfif getShearX() OR getShearY()>
			<cfset arguments.Graphics.shear(JavaCast("double", getShearX()), JavaCast("double", getShearY())) />
		</cfif>
	</cffunction>
  
	<!--- applyLookupTable --->
	<cffunction name="applyLookupTable" access="private" output="false" returntype="void" hint="I apply a lookup table to the image.">
		<cfargument name="lookupArray" hint="I am the array which populates the lookup table." required="yes" type="array" />
		<cfset var Image = getImage() />
		<cfset var NewImage = createObject("java", "java.awt.image.BufferedImage") />
		<cfset var RenderingHints = CreateObject("Java", "java.awt.RenderingHints") />
		<cfset var LookupTable = CreateObject("Java", "java.awt.image.ShortLookupTable") />
		<cfset var LookupOp = CreateObject("Java", "java.awt.image.LookupOp") />
		
		<!--- we can't convolve indexed images --->
		<cfif Image.getType() IS Image.TYPE_BYTE_INDEXED>
			<cfthrow
				type="Alagad.Image.IndexedImageCanNotBeConvolved"
				message="Indexed images can not be convolved (adjustlevels, brighten, darken, etc.)" />
		</cfif>
		
		<cfscript>
			NewImage.init(JavaCast("int", Image.getWidth()), JavaCast("int", Image.getHeight()), JavaCast("int", Image.getType()));
			RenderingHints.init(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_DEFAULT);
			LookupTable.init(JavaCast("int", 0), arguments.lookupArray);
			LookupOp.init(LookupTable, RenderingHints);
			LookupOp.filter(Image, NewImage);
		</cfscript>

		<cfset setImage(NewImage) />
	</cffunction>
	
	<!--- applyKernel --->
	<cffunction name="convolve" access="private" output="false" returntype="void" hint="I apply a convolve opperation.">
		<cfargument name="size" hint="I am the width and height of the kernel" required="yes" type="numeric">
		<cfargument name="kernelArray" hint="I am the kernel to apply to this image." required="yes" type="array">
		<cfset var Image = getImage() />
		<cfset var ConvolvedImage = createComparableImage(Image) />
		<cfset var Kernel = CreateObject("Java", "java.awt.image.Kernel") />
		<cfset var ConvolveOp = CreateObject("Java", "java.awt.image.ConvolveOp") />
		
		<cfscript>
			Kernel.init(JavaCast("int", arguments.size), JavaCast("int", arguments.size), arguments.kernelArray);
			ConvolveOp.init(Kernel);
			ConvolveOp.filter(Image, ConvolvedImage);
		</cfscript>
		
		<cfset setImage(ConvolvedImage) />
	</cffunction>
	
	<!--- scale --->
	<cffunction name="scale" access="private" output="false" returntype="void">
		<cfargument name="widthPercent" hint="I am the new width for the image" required="yes" type="numeric">
		<cfargument name="heightPercent" hint="I am the new height for the image" required="yes" type="numeric">
		<cfset var Image = getImage() />
		<cfset var ScaledImage = 0/>
		<cfset var Transform = CreateObject("Java", "java.awt.geom.AffineTransform") />
		<cfset var Operation = CreateObject("Java", "java.awt.image.AffineTransformOp") />
		<cfset var width = javaCast("int", Image.getWidth() * arguments.widthPercent) />
		<cfset var height = javaCast("int", Image.getHeight() * arguments.heightPercent) />
		<cfset var type = 0 />
		
		<cfif NOT width OR NOT height>
			<cfthrow message="Scale operation produced image of 0 width or height." />
		</cfif>
		
		<!--- attempt to get the image type --->
		<cfif Image.getType()>
			<cfset type = Image.getType() />
		<cfelse>
			<cfset type = Image.TYPE_INT_ARGB />
		</cfif>
		
		<cfscript>
			ScaledImage = createComparableImage(Image, JavaCast("int", width), JavaCast("int", height));
			Transform.scale(JavaCast("double", arguments.widthPercent), JavaCast("double", arguments.heightPercent));
			Operation.init(Transform, Operation.TYPE_BILINEAR);
			Operation.filter(Image, ScaledImage);
		</cfscript>
		
		<cfset setImage(ScaledImage) />
	</cffunction>
	
	<!--- getTypeList --->
    <cffunction name="getTypeList" access="private" output="false" returntype="string">
       <cfreturn variables.typeList />
    </cffunction>
	<!--- verifyImageMode --->
	<cffunction name="verifyImageMode" access="private" output="false" returntype="void" hint="I verify that we have a valid image mode.  If not, I throw an error.">
		<cfargument name="mode" hint="I am the type to validate" required="no" type="string" />
		
		<cfif NOT ListFindNoCase(getTypeList(), arguments.mode)>
			<cfthrow
				type="Alagad.Image.InvalidMode"
				message="Invalid mode argument.  The percentOrPixels argument must be one of: #getTypeList()#." />
		</cfif>
		
	</cffunction>
	<!--- verifyReadableFormat --->
	<cffunction name="verifyReadableFormat" access="private" output="false" returntype="boolean">
		<cfargument name="format" hint="I am the write format to validate" required="no" type="string" />
		<cfreturn ListFindNoCase(getReadableFormats(), arguments.format) />
	</cffunction>
	<!--- verifyWritableFormat --->
	<cffunction name="verifyWritableFormat" access="private" output="false" returntype="boolean">
		<cfargument name="format" hint="I am the write format to validate" required="no" type="string" />
		<cfreturn ListFindNoCase(getWritableFormats(), arguments.format) GT 0 />
	</cffunction>
	
	<!--- key related --->
	<cffunction name="validateKey" access="private" output="false" returntype="boolean">
		<cfargument name="key" required="true" type="string" />
		<cfargument name="appText" required="true" type="string" />
		<cfset var initialChars = "" />
		
		<!--- fix the key (remove all hyphens) --->
		<cfset arguments.key = Replace(arguments.key, "-", "", "all") />
	
		<!--- grab the first 9 chars --->
		<cfset initialChars = Left(arguments.key, 9) />
			
		<!--- get a key and compare to our current key  --->
		<cfreturn Replace(getKey(initialChars, arguments.appText), "-", "", "all") IS arguments.key />
	</cffunction>
	
	<cffunction name="getKey" access="private" output="false" returntype="string">
		<cfargument name="initialChars" required="true" type="string" />
		<cfargument name="appText" required="true" type="string" />
		<cfset var md5String = "" />
		<cfset var key = "" />
		
		<!--- get a hash of the string --->
		<cfset md5String = hash(initialChars & arguments.appText) />
		<cfset key = arguments.initialChars />
		
		<!--- 
			Loop over the has, grabing 2 chars on each look, convert them to base 10 and mod 32 the results.
			This value is the character in the list of valid chars we will be using for this char in the resulting key.
		--->
		<cfloop from="1" to="32" index="i" step="2">
			<cfset key = key & Mid(variables.charString, (InputBaseN(Mid(md5String, i, 2),16) Mod 32) + 1, 1) />
		</cfloop>
		
		<cfif Len(key) IS 25>
			<!--- add dashes --->
			<cfset key = Insert("-", key, 20) />
			<cfset key = Insert("-", key, 15) />
			<cfset key = Insert("-", key, 10) />
			<cfset key = Insert("-", key, 5) />
		</cfif>
		
		<cfreturn key />
	</cffunction>
	
	<!--- createComparableImage --->
	<cffunction name="createComparableImage" access="private" output="false" returntype="any">
		<cfargument name="Image" hint="I am the image to sample" required="yes" type="any" />
		<cfargument name="width" hint="I set the width of the image" required="no" default="0" type="numeric" />
		<cfargument name="height" hint="I set the height of the image" required="no" default="0" type="numeric" />
		<cfset var NewImage = CreateObject("java", "java.awt.image.BufferedImage") />
		<cfset var type = Iif(arguments.Image.getType(), DE(arguments.Image.getType()), DE(Image.TYPE_INT_ARGB)) />
		<cfset var ColorModel = arguments.Image.getColorModel() />
		<cfset arguments.width = Iif(arguments.width, DE(arguments.width), DE(arguments.Image.getWidth())) />
		<cfset arguments.height = Iif(arguments.height, DE(arguments.height), DE(arguments.Image.getHeight())) />
		
		<!--- based on the image's type, init it --->
		<cfif type IS 12 OR type is 13>
			<!--- the color model is indexed or binary (per http://java.sun.com/j2se/1.4.2/docs/api/java/awt/image/BufferedImage.html) --->
			<cfset NewImage.init(JavaCast("int", arguments.width), JavaCast("int", arguments.height), JavaCast("int", type), ColorModel) />
		<cfelse>
			<!--- the image is not indexed --->
			<cfset NewImage.init(JavaCast("int", arguments.width), JavaCast("int", arguments.height), JavaCast("int", type)) />
		</cfif>
		
		<!--- return the new image --->
		<cfreturn NewImage />
	</cffunction>
	
	<cffunction name="getImageForLoad" access="private" output="false" returntype="any">
		<cfset setImageLoaded(true) />
		<cfreturn getImage() />
	</cffunction>
	
	
	<!--- // -- // -- // -- // -- // -- // -- // -- // ---- 
	//
	//		getters/setters (may be public or private) 
	//
	----- // -- // -- // -- // -- // -- // -- // -- // --->
	
	<!--- image --->
    <cffunction name="setImage" access="private" output="false" returntype="void">
       <cfargument name="image" hint="I am the image we're working with" required="yes" type="any" />
       <cfset variables.image = arguments.image />
    </cffunction>
    <cffunction name="getImage" access="private" output="false" returntype="any">
       <cfif NOT getImageLoaded()>
			<cfthrow
				type="Alagad.Image.NoImageLoaded"
				message="There was an error accessing image data. Before calling methods to work with image data you must first read or create an image with readImage() or createImage() respectively." />
		</cfif>
		<cfreturn variables.image />
    </cffunction>
	
	<!--- setImageReader
	<cffunction name="setImageReader" access="private" output="false" returntype="void">
       <cfargument name="ImageReader" hint="I am the ImageReader we're working with" required="yes" type="any" />
       <cfset variables.ImageReader = arguments.ImageReader />
    </cffunction>
    <cffunction name="getImageReader" access="private" output="false" returntype="any">
       <cfreturn variables.ImageReader />
    </cffunction> --->
	
	<!--- imageIO --->
    <cffunction name="setImageIO" access="private" output="false" returntype="void">
       <cfargument name="imageIO" hint="I am used to read, write and create images" required="yes" type="any" />
       <cfset variables.imageIO = arguments.imageIO />
    </cffunction>
    <cffunction name="getImageIO" access="private" output="false" returntype="any">
       <cfreturn variables.imageIO />
    </cffunction>		
	
	<!--- imageLoaded --->
    <cffunction name="setImageLoaded" access="private" output="false" returntype="void">
       <cfargument name="imageLoaded" hint="I indicate if an image has been loaded." required="yes" type="boolean" />
       <cfset variables.imageLoaded = arguments.imageLoaded />
    </cffunction>
    <cffunction name="getImageLoaded" access="private" output="false" returntype="boolean">
       <cfreturn variables.imageLoaded />
    </cffunction>
</cfcomponent>