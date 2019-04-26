# frozen_string_literal: true

require 'base64'
require 'rbnacl'

# Hashes password using key-stretching hash algorithm
module KeyStretch
  def new_salt
    Base64.strict_encode64(
      RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    )
  end

  def password_hash(salt, password)
    opslimit = 2**20
    memlimit = 2**24
    digest_size = 64
    RbNaCl::PasswordHash.scrypt(
      password,
      Base64.strict_decode64(salt),
      opslimit,
      memlimit,
      digest_size
    )
  end
end
