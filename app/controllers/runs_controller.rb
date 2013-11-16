class RunsController < ApplicationController
  def new
  end
  def create
    splits = params[:file]
    run = Run.create(nick: new_nick, user: nil)
    File.open(Rails.root.join('private', 'runs', run.nick), 'wb') do |file|
      file.write(splits.read)
    end
    # todo: do things with the file
  end
  def popular
  end
  def front
  end

  def new_nick
    nick = SecureRandom.urlsafe_base64(4)
    while Run.find_by(nick: nick).present?
      nick = SecureRandom.urlsafe_base64(4)
    end
    nick
  end
end
