module Crypt
  module ECB
    def padded_last_block(last_block)
      block = last_block || ''
      buffer = block.split('')
      remainingMessageBytes = buffer.length
      remainingMessageBytes.upto(block_size()-1) { buffer << 0.chr }
      return buffer.join('')
    end

    def unpadded_last_block(last_block)
      block = last_block || ''
      chars = block.split('')
      buffer = []
      chars.each do |c|
        if c != 0
          buffer << c
        else
          break
        end
      end
      return buffer.join('')
    end

    def encrypt_stream(plainStream, cryptStream)
      while ((block = plainStream.read(block_size())) && (block.length == block_size()))
        cryptStream.write(encrypt_block(block))
      end
      cryptStream.write(encrypt_block(padded_last_block(block)))
    end

    def decrypt_stream(cryptStream, plainStream)
      while (block = cryptStream.read(block_size()))
        plainText = decrypt_block(block)
        plainStream.write(plainText) unless cryptStream.eof?
      end
      plainStream.write(unpadded_last_block(plainText))
    end

    def carefully_open_file(filename, mode)
      begin
        aFile = File.new(filename, mode)
      rescue
        puts "Sorry. There was a problem opening the file <#{filename}>."
        aFile.close() unless aFile.nil?
        raise
      end
      return(aFile)
    end

    def encrypt_file(plainFilename, cryptFilename)
      plainFile = carefully_open_file(plainFilename, 'rb')
      cryptFile = carefully_open_file(cryptFilename, 'wb+')
      encrypt_stream(plainFile, cryptFile)
      plainFile.close unless plainFile.closed?
      cryptFile.close unless cryptFile.closed?
    end

    def decrypt_file(cryptFilename, plainFilename)
      cryptFile = carefully_open_file(cryptFilename, 'rb')
      plainFile = carefully_open_file(plainFilename, 'wb+')
      decrypt_stream(cryptFile, plainFile)
      cryptFile.close unless cryptFile.closed?
      plainFile.close unless plainFile.closed?
    end

    def encrypt_string(plainText)
      plainStream = StringIO.new(plainText)
      cryptStream = StringIO.new('')
      encrypt_stream(plainStream, cryptStream)
      cryptText = cryptStream.string
      return(cryptText)
    end

    def decrypt_string(cryptText)
      cryptStream = StringIO.new(cryptText)
      plainStream = StringIO.new('')
      decrypt_stream(cryptStream, plainStream)
      plainText = plainStream.string
      return(plainText)
    end
  end
end

module Crypt
  class Blowfish
    include Crypt::ECB
  end
end