const mongoose = require("mongoose");

const libraryItemSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  content: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
    trim: true,
  },
  created_at: {
    type: Date,
    default: Date.now,
  },
});

// Create a text index for search functionality
libraryItemSchema.index({ title: "text", content: "text", category: "text" });

let LibraryItemModel;

module.exports = {
  init: (connection) => {
    LibraryItemModel = connection.model(
      "LibraryItem",
      libraryItemSchema,
      "library_items"
    );
    return LibraryItemModel;
  },
  model: () => {
    if (!LibraryItemModel) {
      throw new Error("LibraryItem model not initialized");
    }
    return LibraryItemModel;
  },
  schema: libraryItemSchema,
};
