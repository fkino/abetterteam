require 'spec/spec_helper'
require 'abetterteam'

describe Sinatra::Application do
  describe 'get /' do
    before do
      get '/'
    end

    subject { last_response }

    it { should be_ok }
    its(:body) { should =~ %r(<h2>アジャイル度を評価しよう</h2>) }
  end

  describe 'get /new' do
    before do
      get '/new'
    end

    subject { last_response }

    it { should be_ok }
    its(:body) { should =~ %r(<form action='/create' method='get'>) }
  end

  describe 'get /create' do
    before do
      get '/create', :thinking0 => 'yes', :thinking1 => 'no'
    end

    subject { last_response }

    it { should be_redirect }

    context 'redirected' do
      before do
        follow_redirect!
      end

      subject { last_response }

      it { should be_ok }
      its(:body) { should =~ %r(考えること : 10点) }
    end
  end
end
