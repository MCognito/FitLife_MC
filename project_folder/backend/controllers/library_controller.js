const LibraryItem = require("../models/LibraryItem").model;

// Get all library items
exports.getAllLibraryItems = async (req, res) => {
  try {
    const libraryItems = await LibraryItem()
      .find()
      .sort({ category: 1, title: 1 });
    console.log("Found library items:", libraryItems); // Debug log
    res.status(200).json(libraryItems);
  } catch (error) {
    console.error("Error fetching library items:", error);
    res
      .status(500)
      .json({ message: "Failed to fetch library items", error: error.message });
  }
};

// Get library items by category
exports.getLibraryItemsByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    const libraryItems = await LibraryItem()
      .find({ category })
      .sort({ title: 1 });
    console.log("Found library items for category:", category, libraryItems); // Debug log
    res.status(200).json(libraryItems);
  } catch (error) {
    console.error("Error fetching library items by category:", error);
    res
      .status(500)
      .json({ message: "Failed to fetch library items", error: error.message });
  }
};
