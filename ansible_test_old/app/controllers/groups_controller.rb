class GroupsController < ApplicationController
    def index
        @groups = Group.all 
    end

    def new
        @group = Group.new
    end

    def create
        @group = Group.new()
    end

    def show
    end

    def edit
    end

    def update
    end

    def destroy
    end

    protected

    def group_params
        params.require(:group).permit(:name, :description)
    end
end
