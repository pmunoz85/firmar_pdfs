
# Método de firma de documentos
def firmar_pdf(pfx_file, input_files)
  require 'openssl'
  #require 'base64'
  require 'time'
  require 'io/console'
  require 'prawn'
  begin
    require 'origami'
  rescue LoadError
    abort "La gema Origami no está instalada, use: gem install origami"
  end
  include Origami

  # Preguntamos por el DIR3
  puts "Escribe el DIR3 de origen del documento"
  dir3 = STDIN.gets.chomp

  # Preguntamos la contraseña del certificado
  puts "Escribe la password del certificado"
  contrasena = STDIN.noecho(&:gets).chomp

  # Obtenemos el certificado
  begin
    pkcs = OpenSSL::PKCS12.new(File.read(pfx_file), contrasena)
  rescue 
    abort "Error abrir el certificado electrónico, posiblemente la contraseña no sea la correcta o que el fichero no esté en la ubicación indicada."
  end

  # Separamos la clave privada y el certificado
  key = OpenSSL::PKey::RSA.new(pkcs.key.to_pem)
  cert = OpenSSL::X509::Certificate.new(pkcs.certificate.to_pem)

  # Datos del certificado con el que vamos a firmar
  puts "==== Datos del certificado ===="
  puts "Firmante: " + cert.subject.to_s.split('/')[5]  
  puts "Versión: " + cert.version.to_s
  puts "Número de serie: " + cert.serial.to_s
  puts "Tipo de certificado: " + cert.issuer.to_s
  puts "==============================="

  # Variables para el posicionamiento del recuadro y el tamaño de las fuentes
  width = 600.0
  height = 1150.0
  x = 20.0
  y = 320.0
  size = 8  
  now = Time.now

  # Bucle iterativo por la lista de ficheros pdfs
  input_files.each do |file|
    puts "++++++++++++++++++++++++++++++++"

    # Creamos las anotaciones para después insertarlas en el recuadro
    text_annotation = Annotation::AppearanceStream.new
    text_annotation.Type = Origami::Name.new("XObject")
    text_annotation.Resources = Resources.new
    text_annotation.Resources.ProcSet = [Origami::Name.new("Text")]
    text_annotation.set_indirect(true)
    text_annotation.Matrix = [ 1, 0, 0, 1, 0, 0 ]
    text_annotation.BBox = [ 0, 0, width, height ]
    text_annotation.write("-------------  METADATOS  ------------", x: 35, y: 302, size: size)
    text_annotation.write("Version NTI: http://administracionelectronica.gob.es/ENI/XSD/v1.0/documento-e", x: 35, y: 282, size: size)
    text_annotation.write("Identificador: ES_#{dir3}_2020_000000000000000000000XXXX", x: 35, y: 262, size: size)
    text_annotation.write("Organo: #{dir3}", x: 35, y: 242, size: size)
    text_annotation.write("Origen: Administracion", x: 35, y: 222, size: size)
    text_annotation.write("Estado de elaboracion:Original", x: 35, y: 202, size: size)
    text_annotation.write("Formato: PDF", x: 35, y: 182, size: size)
    text_annotation.write("Tipo Documental: Comunicacion", x: 35, y: 162, size: size)
    text_annotation.write("Tipo Firma: XAdES Internally deteched signature", x: 35, y: 142, size: size)
    text_annotation.write("Firmado el: #{now.iso8601}", x: 35, y: 122, size: size)
    text_annotation.write("Valor CSV: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", x: 35, y: 102, size: size)
    text_annotation.write("Regulacion CSV: Decreto 3628/2017 de 20-12-2017", x: 35, y: 82, size: size)
    text_annotation.write("Hash SHA1 : #{OpenSSL::Digest::SHA1.hexdigest(File.read(file))}", x: 35, y: 62, size: size)
    text_annotation.write("Firmado el: #{now.iso8601}", x: 35, y: 42, size: size)
    text_annotation.write("por: #{cert.subject.to_s.split('/')[5]}", x: 35, y: 22, size: size)
    text_annotation.write("--------------------------------------", x: 35, y: 2, size: size)

    # Añadimos un recuadro con la anotaciones en el pdf
    signature_annotation = Annotation::Widget::Signature.new
    signature_annotation.Rect = Rectangle[llx: x, lly: y+height, urx: x+width, ury: y]
    signature_annotation.F = Annotation::Flags::PRINT
    signature_annotation.set_normal_appearance(text_annotation)

    # Nombre para el fichero firmado
    outputfile = file.dup.insert(file.rindex("."), "_signed")

    # Apertura del pdf original y añadimos la caja en la última página
    pdf = Origami::PDF.read(file)
    pdf.append_page do |page|
      page.add_annotation(signature_annotation)
    end

    # Firmamos el pdf con el certificado electrónico
    begin
      pdf.sign(cert, key, :method => 'adbe.pkcs7.sha1')
    rescue 
      abort "Error al firmar."
    end

    # Guardamos el fichero firmado
    pdf.save(outputfile)

    # Mostramos los hashes del fichero con y sin firma
    puts "=== HASH del fichero SIN firmar SHA1 ==="
    puts "................................"
    puts OpenSSL::Digest::SHA1.hexdigest(File.read(file))
    puts "--------------------------------"
    puts "=== HASH del fichero firmado SHA1  ==="
    puts "................................"
    puts OpenSSL::Digest::SHA1.hexdigest(File.read(outputfile))
    puts "--------------------------------"

    # Convertimos el fichero firmado en Base64
    `base64 #{file} > #{outputfile}.txt`

    # Convertimos el fichero firmado en XML
    `pdftohtml -c -xml #{file} > #{outputfile}.xml`
    end
end

# MAIN
args = Hash[ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/)]

# Comprobamos los parámetros introducidos
if args['pfx'].nil? or args['pdfs'].nil?
  abort "Errr de sinitaxis, use la siguinete: ruby firmar_con_pfx.rb --pfx=CERTIFICADO.PFX --pdfs=PDF1.PDF,PDF2.PDF,[...]"
end

pfx = args['pfx']
pdfs = args['pdfs'].split(',')

# Llamamos a la función para fimar los documentos
firmar_pdf(pfx, pdfs)

