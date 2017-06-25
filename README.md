# Carrierwave::Base64

[![Gem Version](https://badge.fury.io/rb/carrierwave-base64.svg)](http://badge.fury.io/rb/carrierwave-base64)
[![Build Status](https://travis-ci.org/lebedev-yury/carrierwave-base64.svg?branch=master)](https://travis-ci.org/lebedev-yury/carrierwave-base64)
[![Code Climate](https://codeclimate.com/github/lebedev-yury/carrierwave-base64/badges/gpa.svg)](https://codeclimate.com/github/lebedev-yury/carrierwave-base64)

Upload files encoded as base64 to carrierwave.

This small gem can be useful for API's that interact with mobile devices.

This gem requires Ruby 2.0 or higher.

## Installation

Add the gem to your Gemfile:

```ruby
gem 'carrierwave-base64'
```

Also add this if you need mongoid support:

```ruby
gem "carrierwave-mongoid"
```

## Usage

Mount the uploader to your model:

```ruby
mount_base64_uploader :image, ImageUploader
```

Now you can also upload files by passing an encoded base64 string to the attribute.

## Upload file extension

The file extension for the uploaded base64 string is identified automatically using the [mime-types](https://github.com/mime-types/ruby-mime-types/) gem and `content_type` from the uploaded string.

If the required MIME type is not registered, you can add it, using [MIME::Types#add](http://www.rubydoc.info/gems/mime-types/MIME/Types#add-class_method):

```ruby
MIME::Types.add(
  MIME::Type.new('application/icml').tap do |type|
    type.add_extensions 'icml'
  end
)
```

## Setting the file name

You can set the `file_name` option to a lambda, that will return a filename without an extension, using the model instance:

```ruby
mount_base64_uploader :image, ImageUploader, file_name: -> (u) { u.username }
```

**[DEPRECATED: Settings this option to a string is deprecated, if you still want to set the filename to a fixed string, wrap it in a Proc]** To set the file name for the uploaded files, use the `:file_name` option (without extention):

```ruby
# Deprecated way:
mount_base64_uploader :image, ImageUploader, file_name: 'userpic'

# New way
mount_base64_uploader :image, ImageUploader, file_name: -> { 'userpic' }
```

## Data format

The string with the encoded data, should be prefixed with Data URI scheme format.

Keep in mind, that the content type specified in this string, would be used to identified the file extension. So if you have some custom content type uploaded, don't forget to register a Mime Type for it.

```
data:image/jpeg;base64,(base64 encoded data)
```

## Upload multiple files

You can also upload multiple file by mounting uploaders. 

```ruby
mount_base64_uploaders :attachments, AttachmentUploader
```

But you need to check `carrierwave` if it is supporting multiple files uploading first (only the master branch supports currently). Otherwise you need to update your `carrierwave` version:
```ruby
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'
```

You can name the files statically in the same way with single file uploading above. But if you are uploading more than one files to one repository, it is not a good idea. Instead, you can set the names for the files by request. For instance:
```ruby
attachments = []
new_attachment = {
    'icon.png': 'data:image/png;base64,/9j/4AAQSkZJRgABAQAASABIAAD...', 
    'avatar.jpg': 'data:image/jpeg;base64,/9j/LKJJLASKJLOASIDUOIUASO...'
}
new_attachments.each do |file_name, attachment| 
    attachments << [attachment, file_name]
end    
email.attachments = attachments
email.save
```

  


## Contributing

1. Fork it ( https://github.com/[my-github-username]/carrierwave-base64/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
