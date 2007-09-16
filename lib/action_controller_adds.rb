module ActionController
  module Caching
    module Fragments

      # for_fragment() takes the same argument as cache(). It will execute the associated block only if the fragment
      # corresponding to this argument doesn't exist. This allows us to conditionally execute code in our controller
      # action based on existance of cached fragments.
      #
      # For example:
      #
      # If you have the following in your view:
      #
      #   <% cache do %>
      #     All Topics:
      #     <%= render_collection_of_partials "topic", @topics %>
      #   <% end %>
      #
      # You can use in your controller action:
      #
      #   for_fragment do
      #     @topics = Topic.find(:all)
      #   end
      #
      # Now if the view is going to render from cache anyway, we save a database call b/c @topics will not be used
      # anyway at this point.
      def for_fragment(name = {})
        raise("Block required") unless block_given?
        yield unless read_fragment(name)
      end
    end
  end
end