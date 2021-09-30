# **Firma electrónica de documentación**

Esta herramienta de firma sirve para firmar con un certificado electrónico en un fichero con formato pfx, uno o varios documentos en formato pdf. Los ficheros firmados con esta herramienta después serán convertidos en los formatos Base64 y XML, para su posterior utilización.

**_Comando de ejecución_**

```sh
  ruby firmar_con_pfx.rb --pfx=CERTIFICADO.PFX --pdfs=PDF1.PDF,PDF2.PDF,[...] 
```

**_Entorno de ejecución_**

Para ejecutar la herramienta con éxito, debemos tener instalado en nuestro sistema operativo ruby en su versión 2.X.X o posteriores, y contar una serie de gemas instaladas que pasamos a enumerar en el siguiente apartado.

## **Recursos Open Source utilizados**

Esta utilidad se ha realizado utilizando una gran variedad de herramientas del sistema operativo, lenguajes y librerías Open Source. A continuación, hacemos una breve referencia a ellos.

- El lenguaje de desarrollo elegido ha sido [Ruby](https://www.ruby-lang.org/es/).
- Herramienta de conversión [Base64](https://es.wikipedia.org/wiki/Base64).
- Herramienta de conversión [pdftohtml](http://poppler.freedesktop.org).
- El entorno de pruebas ha sido un equipo con sistema operativo [Ubuntu](https://ubuntu.com/).
- Gemas de ruby.
  1. [Openssl](https://github.com/ruby/openssl).
  2. [Origami](https://github.com/gdelugre/origami).
  3. [Prawn](https://github.com/prawnpdf/prawn).
  4. [Io/console](https://github.com/ruby/io-console).

