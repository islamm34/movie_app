import '../../../core/utilities/aap_assets.dart';

class OnboardingModel {
  String image;
  String title;
  String? description;
  String buttonText;
  List<String>? backButtons;

  OnboardingModel({
    required this.image,
    required this.title,
    this.description,
    required this.buttonText,
    this.backButtons,
  });

  static List<OnboardingModel> datalist = [
    OnboardingModel(
      image: AppAssets.MoviesPosters,
      title: "Find Your Next\nFavorite Movie Here",
      description:
          "Get access to a huge library of movies to suit all tastes. You will surely like it.",
      buttonText: "Explore Now",
    ),
    OnboardingModel(
      image: AppAssets.xll,
      title: "Discover Movies",
      description:
          "Explore a vast collection of movies in all genres and genres. Find your next favorite film with ease.",
      buttonText: "Next",
    ),
    OnboardingModel(
      image: AppAssets.theGodfather1Png,
      title: "Explore All Genres",
      description:
          "Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.",
      buttonText: "Next",
    ),
    OnboardingModel(
      image: AppAssets.samMendesHollywoodWarFilmPng,
      title: "Create Watchlists",
      description:
          "Save movies to your watchlist to keep track of what you want to watch next. Enjoy films in various quality tiers.",
      buttonText: "Next",
      backButtons: ["Back"],
    ),
    OnboardingModel(
      image: AppAssets.xl9419884887ed6c71Png,
      title: "Rate, Review, and Learn",
      description:
          "Share your thoughts on the movie you've watched. Dive deep into film details and help others discover great movies with your reviews.",
      buttonText: "Next",
    ),
    OnboardingModel(
      image: AppAssets.theGodfather1Png,
      title: "Start Watching Now",
      description: "",
      buttonText: "Finish",
      backButtons: ["Back", "Back", "Back"],
    ),
  ];
}
