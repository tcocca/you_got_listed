def valid_complex_rash
  Hashie::Rash.new({
    'id' => 'CP-000-676',
    'name' => 'Church Park',
    'addresses' => Hashie::Rash.new({
      'address' => [
        Hashie::Rash.new({
          'id' => '1051',
          'street_number' => '221',
          'street_name' => 'Massachusetts Ave.`',
          'city' => 'Boston',
          'state' => 'MA',
          'zip' => '02115',
          'neighborhood' => 'Back Bay',
          'latitude' => '42.344133',
          'longitude' => '-71.086222'
        }),
        Hashie::Rash.new({
          'id' => '1052',
          'street_number' => '255',
          'street_name' => 'Massachusetts Ave.`',
          'city' => 'Boston',
          'state' => 'MA',
          'zip' => '02115',
          'neighborhood' => 'Back Bay',
          'latitude' => '42.343736',
          'longitude' => '-71.086023'
        }),
        Hashie::Rash.new({
          'id' => '1053',
          'street_number' => '199',
          'street_name' => 'Massachusetts Ave.`',
          'city' => 'Boston',
          'state' => 'MA',
          'zip' => '02115',
          'neighborhood' => 'Back Bay',
          'latitude' => '42.344390',
          'longitude' => '-71.086350'
        })
      ]
    }),
    'public_notes' => 'Our apartments mingle casual elegance with contemporary details. Gourmet kitchens with ceramic tile floors, granite counter tops, Gaggeneau, GE and Miele convection ovens and dishwashers, Sub Zero and GE refrigerators, Birchwood cabinets, and built-in pantries. Living areas with hardwood floors and crown molding, elegant baths, walk-in closets, private balconies and spectacular views make it home.',
    'photos' => Hashie::Rash.new({
      'photo' => [
        'http://ygl-photos.s3.amazonaws.com/AC-000-010%2F516795.jpg',
        'http://ygl-photos.s3.amazonaws.com/AC-000-010%2F516796.jpg',
        'http://ygl-photos.s3.amazonaws.com/AC-000-010%2F516797.jpg',
        'http://ygl-photos.s3.amazonaws.com/AC-000-010%2F516798.jpg',
        'http://ygl-photos.s3.amazonaws.com/AC-000-010%2F516799.jpg',
        'http://ygl-photos.s3.amazonaws.com/AC-000-010%2F516800.jpg'
      ]
    }),
    'listings' => Hashie::Rash.new({
      'listing' => [
        Hashie::Rash.new({
          'listing_id' => 'BOS-009-741',
          'address_id' => '1051',
          'type' => 'R',
          'source' => 'F',
          'price' => '1423',
          'beds' => '1',
          'baths' => '1',
          'square_feet' => '',
          'unit_level' => '',
          'photo' => 'http://ygl-photos.s3.amazonaws.com/AC-000-010%2F65131.jpg'
        }),
        Hashie::Rash.new({
          'listing_id' => 'BOS-331-359',
          'address_id' => '1053',
          'type' => 'R',
          'source' => 'F',
          'price' => '1423',
          'beds' => '1',
          'baths' => '1',
          'square_feet' => '',
          'unit_level' => '',
          'photo' => 'http://ygl-photos.s3.amazonaws.com/AC-000-010%2F65130.jpg'
        })
      ]
    })
  })
end
