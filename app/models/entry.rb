class Entry < ApplicationRecord

    belongs_to :category
    belongs_to :user
    has_many :thoughts
    has_many :entries_cards
    has_many :cards, through: :entries_cards

    validates_length_of :cards, maximum: 3
    validates :category, presence: true

    scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
    scope :designation, -> (designation) { joins(:cards).where("cards.designation = ?", "#{designation}") }
    scope :court_cards, -> { joins(:cards).where("cards.court = ?", true) }
    scope :suit_cards, -> (suit) { joins(:cards).where("cards.suit = ?", "#{suit}") }

    def add_randomized_card
        until !self.cards.include?(random_card = Card.randomize) do
            random_card = Card.randomize
        end
        self.cards << random_card
    end

    def category_attributes=(category_attributes)
        if category_attributes[:name].present? && category_attributes[:question_1].present? && category_attributes[:question_2].present? && category_attributes[:question_3].present?
            self.build_category(category_attributes)
        end
    end
    
end
