#include <SFML/Graphics.hpp>

int main(){
    sf::RenderWindow window(sf::VideoMode(200, 200), "SFML works! Hello.");
    sf::CircleShape shape(100.f);
    shape.setFillColor(sf::Color::Blue);

    while (window.isOpen()){
        sf::Event event;
        while (window.pollEvent(event)){
            if (event.type == sf::Event::Closed)
                window.close();
        }
        window.clear();       
       
        window.draw(shape);

        sf::Text text;
        sf::Font font;
        font.loadFromFile("arial.ttf");
        text.setFont(font);
        text.setString("Hello world");
        text.setCharacterSize(24); // in pixels, not points!
        text.setFillColor(sf::Color::White);
        text.setStyle(sf::Text::Bold | sf::Text::Underlined);
        window.draw(text);

        window.display();
    }
    return 0;
}