require 'rails_helper'

RSpec.describe 'Not signed in', :type => :request do
  let(:order) { create :contracted_order }
  let(:id) { order.id }
  let(:routing_error) { ActionController::RoutingError }

  it 'redirects :not_found unless :sc param is given' do
    expect { get '/orders/new' }.to raise_error(routing_error)
    expect { get "/orders/#{id}" }.to raise_error(routing_error)
    expect { get "/contracts/#{id}" }.to raise_error(routing_error)
  end

  it 'saves :return_to session for user /orders/new' do
    get '/orders/new', sc: :user
    expect(response).to have_http_status :ok
    expect(session[:return_to]).to end_with "/orders/new?sc=user"
  end

  it 'saves :return_to session for user /orders/:id' do
    get "/orders/#{id}", sc: :user
    expect(response).to have_http_status :ok
    expect(session[:return_to]).to end_with "/orders/#{order.id}?sc=user"
  end

  it 'saves :return_to session for handyman /contracts/:id' do
    get "/contracts/#{id}", sc: :handyman
    expect(response).to have_http_status :ok
    expect(session[:return_to])
      .to end_with "/contracts/#{id}?sc=handyman"
  end
end
