# frozen_string_literal: true

module Items

  # Created Item Service Class
  class ItemService
    attr_reader :current_user, :result

    def initialize(current_user)
      @current_user = current_user
      @result = OpenStruct.new(success?: false, item: Item.new)
    end

    def list
      Item.all.order(created_at: :desc)
    end

    def new
      result
    end

    def edit(id)
      find_record(id)
    end

    def create(params)
      result.tap do |r|
        r.item = Item.new(params)
        r.send('success?=', r.item.save)
      end
    end

    def update(id, params)
      find_record(id)

      result.tap do |r|
        r.send('success?=', r.item.update(params))
      end
    end

    def delete(id)
      find_record(id)

      result.tap do |r|
        r.send('success?=', r.item.destroy)
      end
    end

    private

    def find_record(id)
      result.item = Item.find(id)
      result
    end
  end
end
