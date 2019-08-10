require 'rails_helper'

describe Api::V4::GamesController do
  describe '#index' do
  end

  describe '#show' do
    context 'for an existing game' do
      let(:game) { create(:game, :shortnamed) }
      subject { get :show, params: {game: game.srdc.shortname} }

      it 'returns a 200' do
        expect(subject).to have_http_status(:ok)
      end

      it 'renders a game schema' do
        expect(subject.body).to match_json_schema(:game)
      end
    end

    context 'for a nonexisting game' do
      subject { get :show, params: {game: 'boopy'} }

      it 'returns a 404' do
        expect(subject).to have_http_status(:not_found)
      end
    end
  end
end
