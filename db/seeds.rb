# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

stocks = Stock.create([
    {
        name: "AAPL",
        price: 228,
        description: "Apple Inc. is an American multinational corporation and technology company headquartered in Cupertino, California, in Silicon Valley. It is best known for its consumer electronics, software, and services.",
        status: "available"
    },
    {   
        name: "MSFT",
        price: 435,
        description: "Microsoft Corporation is an American multinational corporation and technology company headquartered in Redmond, Washington. Its best-known software products are the Windows line of operating systems, the Microsoft 365 suite of productivity applications, the Azure cloud computing platform and the Edge web browser.",
        status: "available"
    },
    {   
        name: "NVDA",
        price: 116,
        description: "Nvidia Corporation is an American multinational corporation and technology company headquartered in Santa Clara, California, and incorporated in Delaware. ",
        status: "available"
    },
    {   
        name: "GOOG",
        price: 164,
        description: "Google LLC is an American multinational corporation and technology company focusing on online advertising, search engine technology, cloud computing, computer software, quantum computing, e-commerce, consumer electronics, and artificial intelligence",
        status: "available"
    },
    {   
        name: "AMZN",
        price: 191,
        description: "Amazon.com, Inc., doing business as Amazon, is an American multinational technology company, engaged in e-commerce, cloud computing, online advertising, digital streaming, and artificial intelligence.",
        status: "available"
    },
    {   
        name: "META",
        price: 561,
        description: "Meta Platforms, Inc., doing business as Meta, and formerly named Facebook, Inc., and TheFacebook, Inc., is an American multinational technology conglomerate based in Menlo Park, California.",
        status: "available"
    }
])