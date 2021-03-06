require File.expand_path(File.join(File.dirname(__FILE__),'teststrap'))
require File.expand_path(File.join(File.dirname(__FILE__),'..','lib','rack','recaptcha','helpers'))
require 'riot/rr'

class Helper
  attr_accessor :env
  include Rack::Recaptcha::Helpers
end

context "Rack::Recaptcha::Helpers" do
  setup do
    Rack::Recaptcha.public_key = '0'*40
    @helper = Helper.new
  end


  context "recaptcha_tag" do

    context "ajax" do
      context "with display" do
        setup { @helper.recaptcha_tag(:ajax,:display => {:theme => 'red'}) }
        asserts("has js") { topic }.matches %r{recaptcha_ajax.js}
        asserts("has div") { topic }.matches %r{<div id="ajax_recaptcha"></div>}
        asserts("has display") { topic }.matches %r{RecaptchaOptions}
        asserts("has red theme") { topic }.matches %r{"theme":"red"}
      end
      context "without display" do
        setup { @helper.recaptcha_tag(:ajax) }
        asserts("has js") { topic }.matches %r{recaptcha_ajax.js}
        asserts("has div") { topic }.matches %r{<div id="ajax_recaptcha"></div>}
        asserts("has display") { topic =~ %r{RecaptchaOptions} }.not!
        asserts("has red theme") { topic =~ %r{"theme":"red"} }.not!
      end
    end

    context "noscript" do
      setup { @helper.recaptcha_tag :noscript, :public_key => "hello_world_world" }
      asserts("iframe") { topic }.matches %r{iframe}
      asserts("no script tag") { topic }.matches %r{<noscript>}
      asserts("public key") { topic }.matches %r{hello_world_world}
      asserts("has js") { topic =~ %r{recaptcha_ajax.js} }.not!
    end

    context "challenge" do
      setup { @helper.recaptcha_tag(:challenge) }
      asserts("has script tag") { topic }.matches %r{script}
      asserts("has challenge js") { topic }.matches %r{challenge}
      asserts("has js") { topic =~ %r{recaptcha_ajax.js} }.not!
      asserts("has display") { topic =~ %r{RecaptchaOptions} }.not!
      asserts("has public_key") { topic }.matches %r{#{'0'*40}}
    end

    context "server" do
      asserts("using ssl url") { @helper.recaptcha_tag(:challenge, :ssl => true) }.matches %r{https://api-secure.recaptcha.net}
      asserts("using non ssl url") { @helper.recaptcha_tag(:ajax) }.matches %r{http://api.recaptcha.net}
    end

  end

  context "verified?" do
    
    context "passing" do
      setup do
        mock(@helper.env).[]('recaptcha.value').returns('true')
        @helper.verified?
      end
      asserts_topic
    end

    context "failing" do
      setup do
        mock(@helper.env).[]('recaptcha.value').returns('false')
        @helper.verified?
      end
      asserts_topic.not!
    end

  end
end
