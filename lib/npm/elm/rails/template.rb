require "pathname"

require "tilt/template"
require "elm-compiler"

module Npm
  module Elm
    module Rails
      class Template < Tilt::Template

        class << self
          attr_accessor :debug
        end

        self.default_mime_type = "application/javascript"

        def self.elm_make_path
          @elm_make_path ||= "#{`npm bin`.strip}/elm-make"
        end

        def self.elm_make_path=(path)
          @elm_make_path = path
        end

        def prepare
          # do nothing:  no prep needed
        end

        def evaluate(scope, _locals, &_block)
          Dir.chdir(elm_package_root) do
            ::Elm::Compiler.compile(file_with_debug, elm_make_path: self.class.elm_make_path)
          end
        end

        private

        def file_with_debug
          self.class.debug ? [file, '--debug'] : file
        end

        def elm_package_root
          dir = Pathname.new(file).dirname
          loop do
            elm_package = dir + "elm-package.json"
            return dir.to_s if elm_package.exist?

            fail "Could not find elm-package.json" if dir.to_s == "/"
            dir = dir.parent
          end
        end
      end
    end
  end
end
