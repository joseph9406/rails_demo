class Category < ApplicationRecord
    # ***** 4-7 使用下拉選單(select)分類貼文 *****
    has_many :posts
end
